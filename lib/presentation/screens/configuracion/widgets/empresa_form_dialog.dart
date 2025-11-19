import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/models/categoria_model.dart';
import '../../../../data/models/empresa_model.dart';
import '../../../bloc/categorias/categorias_bloc.dart';
import '../../../bloc/categorias/categorias_state.dart';

class EmpresaFormDialog extends StatefulWidget {
  final EmpresaModel? empresa; // null si es nueva, con datos si es edición
  final String? categoriaIdInicial; // Para pre-seleccionar categoría

  const EmpresaFormDialog({Key? key, this.empresa, this.categoriaIdInicial})
    : super(key: key);

  @override
  State<EmpresaFormDialog> createState() => _EmpresaFormDialogState();
}

class _EmpresaFormDialogState extends State<EmpresaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  CategoriaModel? _categoriaSeleccionada;
  bool _activa = true;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.empresa != null;

    if (_isEditMode) {
      _nombreController.text = widget.empresa!.nombre;
      _activa = widget.empresa!.activa;
      _cargarCategoriaInicial();
    } else if (widget.categoriaIdInicial != null) {
      _cargarCategoriaInicial();
    }
  }

  void _cargarCategoriaInicial() {
    // Esperar a que las categorías estén cargadas
    Future.delayed(Duration(milliseconds: 100), () {
      final categoriasState = context.read<CategoriasBloc>().state;
      if (categoriasState is CategoriasLoaded) {
        final categoriaId = _isEditMode
            ? widget.empresa!.categoriaId
            : widget.categoriaIdInicial;

        if (categoriaId != null) {
          final categoria = categoriasState.categorias.firstWhere(
            (cat) => cat.id == categoriaId,
            orElse: () => categoriasState.categorias.first,
          );

          if (mounted) {
            setState(() {
              _categoriaSeleccionada = categoria;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _guardar() {
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

      final uuid = Uuid();
      final ahora = DateTime.now();

      final empresa = EmpresaModel(
        id: _isEditMode ? widget.empresa!.id : uuid.v4(),
        nombre: _nombreController.text.trim(),
        categoriaId: _categoriaSeleccionada!.id,
        activa: _activa,
        createdAt: _isEditMode ? widget.empresa!.createdAt : ahora,
        updatedAt: ahora,
      );

      Navigator.pop(context, empresa);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16),
        constraints: BoxConstraints(maxHeight: 500),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                Text(
                  _isEditMode ? 'Editar Empresa' : 'Nueva Empresa',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                // Campo: Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre *',
                    hintText: 'Ej: Mercadona',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Campo: Categoría
                BlocBuilder<CategoriasBloc, CategoriasState>(
                  builder: (context, state) {
                    if (state is CategoriasLoaded) {
                      return DropdownButtonFormField<CategoriaModel>(
                        initialValue: _categoriaSeleccionada,
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
                          });
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

                // Campo: Activa
                SwitchListTile(
                  title: Text('Empresa activa'),
                  subtitle: Text(
                    _activa
                        ? 'Aparecerá en los formularios de gastos'
                        : 'No aparecerá en los formularios',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _activa,
                  onChanged: (value) {
                    setState(() {
                      _activa = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(height: 24),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _guardar,
                      child: Text(_isEditMode ? 'Actualizar' : 'Crear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
