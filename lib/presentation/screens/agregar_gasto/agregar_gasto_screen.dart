import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/categoria_model.dart';
import '../../../data/models/empresa_model.dart';
import '../../../data/models/gasto_model.dart';
import '../../bloc/categorias/categorias_bloc.dart';
import '../../bloc/categorias/categorias_state.dart';
import '../../bloc/empresas/empresas_bloc.dart';
import '../../bloc/empresas/empresas_event.dart';
import '../../bloc/empresas/empresas_state.dart';
import '../../bloc/gastos/gastos_bloc.dart';
import '../../bloc/gastos/gastos_event.dart';

class AgregarGastoScreen extends StatefulWidget {
  @override
  State<AgregarGastoScreen> createState() => _AgregarGastoScreenState();
}

class _AgregarGastoScreenState extends State<AgregarGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _importeController = TextEditingController();
  final _notasController = TextEditingController();

  CategoriaModel? _categoriaSeleccionada;
  EmpresaModel? _empresaSeleccionada;
  DateTime _fechaSeleccionada = DateTime.now();

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

  void _guardarGasto() {
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
      final nuevoGasto = GastoModel(
        id: uuid.v4(),
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

      context.read<GastosBloc>().add(AddGasto(gasto: nuevoGasto));

      // Mostrar mensaje de éxito y regresar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gasto agregado correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      // Esperar un momento y regresar
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context, true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Gasto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Campo: Nombre
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del gasto *',
                hintText: 'Ej: Compra semanal',
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
                        _empresaSeleccionada = null; // Reset empresa
                      });

                      // Cargar empresas de esta categoría
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

            // Botón: Guardar
            ElevatedButton(
              onPressed: _guardarGasto,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Guardar Gasto', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
