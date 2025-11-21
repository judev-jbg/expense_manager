import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/categoria_model.dart';
import 'icon_picker_dialog.dart';
import 'color_picker_widget.dart';

class CategoriaFormDialog extends StatefulWidget {
  final CategoriaModel? categoria;
  final int ordenSiguiente;

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Título
              Text(
                _isEditMode ? 'Editar Categoría' : 'Nueva Categoría',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Campo: Nombre
              TextFormField(
                controller: _nombreController,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej: Restaurantes',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintStyle: TextStyle(color: AppColors.textLight),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.error),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.lg),

              // Selector de Icono
              Text(
                'Icono',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: _mostrarSelectorIconos,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(
                              _colorSeleccionado.replaceFirst('#', '0xff'),
                            ),
                          ).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          IconPickerDialog.getIconData(_iconoSeleccionado),
                          size: 24,
                          color: Color(
                            int.parse(
                              _colorSeleccionado.replaceFirst('#', '0xff'),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Toca para cambiar el icono',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textLight,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Selector de Color
              ColorPickerWidget(
                colorSeleccionado: _colorSeleccionado,
                onColorSelected: (color) {
                  setState(() {
                    _colorSeleccionado = color;
                  });
                },
              ),
              SizedBox(height: AppSpacing.xl),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.textLight),
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(_isEditMode ? 'Actualizar' : 'Crear'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
