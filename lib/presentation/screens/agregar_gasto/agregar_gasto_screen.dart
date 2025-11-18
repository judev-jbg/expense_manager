import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/adjunto_model.dart';
import '../../../data/models/categoria_model.dart';
import '../../../data/models/empresa_model.dart';
import '../../../data/models/gasto_model.dart';
import '../../../data/models/gasto_sugerencia_model.dart';
import '../../../data/repositories/gastos_repository_impl.dart';
import '../../bloc/categorias/categorias_bloc.dart';
import '../../bloc/categorias/categorias_state.dart';
import '../../bloc/empresas/empresas_bloc.dart';
import '../../bloc/empresas/empresas_event.dart';
import '../../bloc/empresas/empresas_state.dart';
import '../../bloc/gastos/gastos_bloc.dart';
import '../../bloc/gastos/gastos_event.dart';
import 'widgets/adjuntos_gallery.dart';

class AgregarGastoScreen extends StatefulWidget {
  final GastoModel? gastoParaEditar;

  const AgregarGastoScreen({Key? key, this.gastoParaEditar}) : super(key: key);

  @override
  State<AgregarGastoScreen> createState() => _AgregarGastoScreenState();
}

class _AgregarGastoScreenState extends State<AgregarGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _importeController = TextEditingController();
  final _notasController = TextEditingController();

  final _gastosRepository = GastosRepositoryImpl();
  final _imagePicker = ImagePicker();

  CategoriaModel? _categoriaSeleccionada;
  EmpresaModel? _empresaSeleccionada;
  DateTime _fechaSeleccionada = DateTime.now();

  bool _isEditMode = false;
  bool _sugerenciaSeleccionada = false;

  // ✨ NUEVO: Lista de adjuntos
  List<AdjuntoModel> _adjuntos = [];
  bool _cargandoAdjuntos = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.gastoParaEditar != null;

    if (_isEditMode) {
      final gasto = widget.gastoParaEditar!;
      _nombreController.text = gasto.nombre;
      _importeController.text = gasto.importe.toString();
      _notasController.text = gasto.notas ?? '';
      _fechaSeleccionada = gasto.fecha;

      _cargarDatosParaEdicion(gasto);
      _cargarAdjuntosExistentes(gasto.id); // ✨ NUEVO
    }
  }

  // ✨ NUEVO: Cargar adjuntos existentes en modo edición
  Future<void> _cargarAdjuntosExistentes(String gastoId) async {
    setState(() {
      _cargandoAdjuntos = true;
    });

    try {
      final adjuntos = await _gastosRepository.getAdjuntosPorGasto(gastoId);
      setState(() {
        _adjuntos = adjuntos;
        _cargandoAdjuntos = false;
      });
    } catch (e) {
      setState(() {
        _cargandoAdjuntos = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar adjuntos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cargarDatosParaEdicion(GastoModel gasto) async {
    await Future.delayed(Duration(milliseconds: 100));

    final categoriasState = context.read<CategoriasBloc>().state;
    if (categoriasState is CategoriasLoaded) {
      final categoria = categoriasState.categorias.firstWhere(
        (cat) => cat.id == gasto.categoriaId,
        orElse: () => categoriasState.categorias.first,
      );

      setState(() {
        _categoriaSeleccionada = categoria;
      });

      context.read<EmpresasBloc>().add(
        LoadEmpresasPorCategoria(categoriaId: categoria.id),
      );

      if (gasto.empresaId != null) {
        await Future.delayed(Duration(milliseconds: 100));
        final empresasState = context.read<EmpresasBloc>().state;
        if (empresasState is EmpresasLoaded) {
          final empresa = empresasState.empresas.firstWhere(
            (emp) => emp.id == gasto.empresaId,
            orElse: () => empresasState.empresas.first,
          );
          setState(() {
            _empresaSeleccionada = empresa;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _importeController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: Locale('es', 'ES'),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  void _onSugerenciaSeleccionada(GastoSugerenciaModel sugerencia) async {
    setState(() {
      _sugerenciaSeleccionada = true;
    });

    if (sugerencia.ultimaNota != null && sugerencia.ultimaNota!.isNotEmpty) {
      _notasController.text = sugerencia.ultimaNota!;
    }

    final categoriasState = context.read<CategoriasBloc>().state;
    if (categoriasState is CategoriasLoaded) {
      final categoria = categoriasState.categorias.firstWhere(
        (cat) => cat.id == sugerencia.categoriaId,
      );

      setState(() {
        _categoriaSeleccionada = categoria;
      });

      context.read<EmpresasBloc>().add(
        LoadEmpresasPorCategoria(categoriaId: categoria.id),
      );

      if (sugerencia.empresaId != null) {
        await Future.delayed(Duration(milliseconds: 200));
        final empresasState = context.read<EmpresasBloc>().state;
        if (empresasState is EmpresasLoaded) {
          try {
            final empresa = empresasState.empresas.firstWhere(
              (emp) => emp.id == sugerencia.empresaId,
            );
            setState(() {
              _empresaSeleccionada = empresa;
            });
          } catch (e) {
            // Empresa no encontrada
          }
        }
      }
    }
  }

  // ✨ NUEVO: Mostrar opciones para agregar adjunto
  Future<void> _mostrarOpcionesAdjunto() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _tomarFoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Elegir de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _elegirDeGaleria();
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text('Elegir PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _elegirPDF();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ✨ NUEVO: Solicitar permisos
  Future<bool> _solicitarPermisos() async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.photos.request();

    return cameraStatus.isGranted && storageStatus.isGranted;
  }

  // ✨ NUEVO: Tomar foto
  Future<void> _tomarFoto() async {
    final permisos = await _solicitarPermisos();
    if (!permisos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se necesitan permisos de cámara y almacenamiento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final XFile? foto = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (foto != null) {
        _agregarAdjunto(foto.path, 'image');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al tomar foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✨ NUEVO: Elegir de galería
  Future<void> _elegirDeGaleria() async {
    final permisos = await _solicitarPermisos();
    if (!permisos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se necesitan permisos de almacenamiento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final XFile? imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (imagen != null) {
        _agregarAdjunto(imagen.path, 'image');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al elegir imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✨ NUEVO: Elegir PDF
  Future<void> _elegirPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        _agregarAdjunto(result.files.single.path!, 'pdf');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al elegir PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✨ NUEVO: Agregar adjunto a la lista
  void _agregarAdjunto(String rutaArchivo, String tipo) {
    final archivo = File(rutaArchivo);
    final uuid = Uuid();

    if (!archivo.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El archivo no existe'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final tamanio = archivo.lengthSync();
    final nombreArchivo = rutaArchivo.split('/').last;

    final adjunto = AdjuntoModel(
      id: uuid.v4(),
      gastoId: _isEditMode ? widget.gastoParaEditar!.id : 'temporal',
      rutaLocal: rutaArchivo,
      tipo: tipo,
      nombreArchivo: nombreArchivo,
      tamanio: tamanio,
      createdAt: DateTime.now(),
    );

    setState(() {
      _adjuntos.add(adjunto);
    });
  }

  // ✨ NUEVO: Eliminar adjunto
  void _eliminarAdjunto(AdjuntoModel adjunto) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Eliminar adjunto'),
          content: Text('¿Estás seguro de que deseas eliminar este adjunto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Si el gasto ya existe, eliminar de BD
                if (_isEditMode && adjunto.gastoId != 'temporal') {
                  try {
                    await _gastosRepository.deleteAdjunto(adjunto.id);
                  } catch (e) {
                    // Error al eliminar de BD, pero continuar con la UI
                  }
                }

                setState(() {
                  _adjuntos.remove(adjunto);
                });

                Navigator.of(dialogContext).pop();
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ✨ MODIFICADO: Guardar gasto con adjuntos en el orden correcto
  void _guardarGasto() async {
    if (_formKey.currentState!.validate()) {
      if (_categoriaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor selecciona una categoría'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      try {
        final uuid = Uuid();
        String gastoId;

        if (_isEditMode) {
          gastoId = widget.gastoParaEditar!.id;

          final gastoActualizado = widget.gastoParaEditar!.copyWith(
            nombre: _nombreController.text.trim(),
            importe: double.parse(_importeController.text),
            fecha: _fechaSeleccionada,
            categoriaId: _categoriaSeleccionada!.id,
            empresaId: _empresaSeleccionada?.id,
            notas: _notasController.text.trim().isEmpty
                ? null
                : _notasController.text.trim(),
            updatedAt: DateTime.now(),
          );

          // ✨ CAMBIO: Guardar directamente en repositorio
          await _gastosRepository.updateGasto(gastoActualizado);
        } else {
          gastoId = uuid.v4();

          final nuevoGasto = GastoModel(
            id: gastoId,
            nombre: _nombreController.text.trim(),
            importe: double.parse(_importeController.text),
            fecha: _fechaSeleccionada,
            categoriaId: _categoriaSeleccionada!.id,
            empresaId: _empresaSeleccionada?.id,
            notas: _notasController.text.trim().isEmpty
                ? null
                : _notasController.text.trim(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // ✨ CAMBIO: Guardar directamente en repositorio y ESPERAR
          await _gastosRepository.insertGasto(nuevoGasto);
        }

        // ✨ AHORA SÍ: Guardar adjuntos nuevos (el gasto ya existe en BD)
        for (var adjunto in _adjuntos) {
          if (adjunto.gastoId == 'temporal') {
            // Es un adjunto nuevo, guardarlo
            final adjuntoConGastoId = adjunto.copyWith(gastoId: gastoId);
            await _gastosRepository.insertAdjunto(adjuntoConGastoId);
          }
        }

        // Cerrar loading
        Navigator.of(context).pop();

        // ✨ AHORA SÍ: Disparar evento del Bloc para recargar la lista
        if (_isEditMode) {
          final fecha = widget.gastoParaEditar!.fecha;
          context.read<GastosBloc>().add(
            LoadGastos(mes: fecha.month, anio: fecha.year),
          );
        } else {
          context.read<GastosBloc>().add(
            LoadGastos(
              mes: _fechaSeleccionada.month,
              anio: _fechaSeleccionada.year,
            ),
          );
        }

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Gasto actualizado correctamente'
                  : 'Gasto agregado correctamente',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Regresar a la pantalla anterior
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pop(context, true);
        });
      } catch (e) {
        // Cerrar loading si está abierto
        Navigator.of(context).pop();

        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Gasto' : 'Agregar Gasto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Campo: Nombre con Autocomplete
            Autocomplete<GastoSugerenciaModel>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<GastoSugerenciaModel>.empty();
                }

                final sugerencias = await _gastosRepository.buscarSugerencias(
                  textEditingValue.text,
                );

                return sugerencias;
              },
              displayStringForOption: (GastoSugerenciaModel option) {
                return option.displayText;
              },
              onSelected: (GastoSugerenciaModel selection) {
                _nombreController.text = selection.nombre;
                _onSugerenciaSeleccionada(selection);
              },
              fieldViewBuilder:
                  (
                    BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    if (_nombreController.text.isNotEmpty &&
                        textEditingController.text.isEmpty &&
                        _isEditMode) {
                      textEditingController.text = _nombreController.text;
                    }

                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Nombre del gasto *',
                        hintText: 'Ej: Compra semanal',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        _nombreController.text = value;
                        if (_sugerenciaSeleccionada &&
                            value != _nombreController.text) {
                          setState(() {
                            _sugerenciaSeleccionada = false;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                    );
                  },
              optionsViewBuilder:
                  (
                    BuildContext context,
                    AutocompleteOnSelected<GastoSugerenciaModel> onSelected,
                    Iterable<GastoSugerenciaModel> options,
                  ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 200,
                            maxWidth: MediaQuery.of(context).size.width - 32,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final GastoSugerenciaModel option = options
                                  .elementAt(index);
                              return InkWell(
                                onTap: () {
                                  onSelected(option);
                                },
                                child: ListTile(
                                  leading: Icon(Icons.history, size: 20),
                                  title: Text(
                                    option.nombre,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    option.displayText.split(' - ')[1],
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
            ),
            SizedBox(height: 16),

            // Campo: Importe
            TextFormField(
              controller: _importeController,
              decoration: InputDecoration(
                labelText: 'Importe *',
                hintText: 'Ej: 45.50',
                prefixText: '€ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El importe es obligatorio';
                }
                final importe = double.tryParse(value);
                if (importe == null || importe <= 0) {
                  return 'Ingresa un importe válido';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Campo: Fecha
            InkWell(
              onTap: () => _seleccionarFecha(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Fecha *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Campo: Categoría
            BlocBuilder<CategoriasBloc, CategoriasState>(
              builder: (context, state) {
                if (state is CategoriasLoaded) {
                  return DropdownButtonFormField<CategoriaModel>(
                    value: _categoriaSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Categoría *',
                      border: OutlineInputBorder(),
                    ),
                    hint: Text('Selecciona una categoría'),
                    items: state.categorias.map((categoria) {
                      return DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria.nombre),
                      );
                    }).toList(),
                    onChanged: (categoria) {
                      setState(() {
                        _categoriaSeleccionada = categoria;
                        if (!_sugerenciaSeleccionada) {
                          _empresaSeleccionada = null;
                        }
                      });

                      if (categoria != null) {
                        context.read<EmpresasBloc>().add(
                          LoadEmpresasPorCategoria(categoriaId: categoria.id),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'La categoría es obligatoria';
                      }
                      return null;
                    },
                  );
                }
                return CircularProgressIndicator();
              },
            ),
            SizedBox(height: 16),

            // Campo: Empresa
            BlocBuilder<EmpresasBloc, EmpresasState>(
              builder: (context, state) {
                if (_categoriaSeleccionada == null) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Empresa',
                      border: OutlineInputBorder(),
                      enabled: false,
                    ),
                    child: Text(
                      'Primero selecciona una categoría',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                if (state is EmpresasLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is EmpresasLoaded) {
                  if (state.empresas.isEmpty) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Empresa',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        'No hay empresas registradas para esta categoría',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    );
                  }

                  return DropdownButtonFormField<EmpresaModel>(
                    value: _empresaSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Empresa (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    hint: Text('Selecciona una empresa'),
                    items: state.empresas.map((empresa) {
                      return DropdownMenuItem(
                        value: empresa,
                        child: Text(empresa.nombre),
                      );
                    }).toList(),
                    onChanged: (empresa) {
                      setState(() {
                        _empresaSeleccionada = empresa;
                      });
                    },
                  );
                }

                return SizedBox.shrink();
              },
            ),
            SizedBox(height: 16),

            // Campo: Notas
            TextFormField(
              controller: _notasController,
              decoration: InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Observaciones adicionales',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24),

            // ✨ NUEVO: Galería de adjuntos
            AdjuntosGallery(
              adjuntos: _adjuntos,
              onEliminar: _eliminarAdjunto,
              onAgregar: _mostrarOpcionesAdjunto,
            ),
            SizedBox(height: 24),

            // Botón: Guardar
            ElevatedButton(
              onPressed: _guardarGasto,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isEditMode ? 'Actualizar Gasto' : 'Guardar Gasto',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
