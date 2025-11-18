import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/models/categoria_model.dart';
import 'icon_picker_dialog.dart';
import 'color_picker_widget.dart';

class CategoriaFormDialog extends StatefulWidget {
  final CategoriaModel? categoria; // null si es nueva, con datos si es edición
  final int ordenSiguiente; // Para nuevas categorías

  const CategoriaFormDialog({
    Key? key,
    this.categoria,
    required this.ordenSiguiente,
  }) : super(key: key);

  @override
  State<CategoriaFormDialog> createState() => _CategoriaFormDialogState();
}

class _CategoriaFormDialogState extends State<CategoriaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  late String _iconoSeleccionado;
  late String _colorSeleccionado;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.categoria != null;

    if (_isEditMode) {
      _nombreController.text = widget.categoria!.nombre;
      _iconoSeleccionado = widget.categoria!.icono;
      _colorSeleccionado = widget.categoria!.color;
    } else {
      _iconoSeleccionado = 'help_outline';
      _colorSeleccionado = '#4CAF50';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _mostrarSelectorIconos() async {
    final icono = await showDialog<String>(
      context: context,
      builder: (context) => IconPickerDialog(),
    );

    if (icono != null) {
      setState(() {
        _iconoSeleccionado = icono;
      });
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final uuid = Uuid();
      final ahora = DateTime.now();

      final categoria = CategoriaModel(
        id: _isEditMode ? widget.categoria!.id : uuid.v4(),
        nombre: _nombreController.text.trim(),
        icono: _iconoSeleccionado,
        color: _colorSeleccionado,
        orden: _isEditMode ? widget.categoria!.orden : widget.ordenSiguiente,
        createdAt: _isEditMode ? widget.categoria!.createdAt : ahora,
        updatedAt: ahora,
      );

      Navigator.pop(context, categoria);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                Text(
                  _isEditMode ? 'Editar Categoría' : 'Nueva Categoría',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                // Campo: Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre *',
                    hintText: 'Ej: Restaurantes',
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

                // Selector de Icono
                Text(
                  'Icono',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: _mostrarSelectorIconos,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          IconPickerDialog.getIconData(_iconoSeleccionado),
                          size: 32,
                          color: Color(
                            int.parse(
                              _colorSeleccionado.replaceFirst('#', '0xff'),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Toca para cambiar el icono',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Selector de Color
                ColorPickerWidget(
                  colorSeleccionado: _colorSeleccionado,
                  onColorSelected: (color) {
                    setState(() {
                      _colorSeleccionado = color;
                    });
                  },
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
