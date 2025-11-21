import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/categoria_model.dart';
import '../../../../data/models/empresa_model.dart';
import '../../../bloc/categorias/categorias_bloc.dart';
import '../../../bloc/categorias/categorias_state.dart';

class EmpresaFormDialog extends StatefulWidget {
  final EmpresaModel? empresa;
  final String? categoriaIdInicial;

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
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
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
                _isEditMode ? 'Editar Empresa' : 'Nueva Empresa',
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
                  hintText: 'Ej: Mercadona',
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

              // Campo: Categoría
              Text(
                'Categoría',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              BlocBuilder<CategoriasBloc, CategoriasState>(
                builder: (context, state) {
                  if (state is CategoriasLoaded) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CategoriaModel>(
                          value: _categoriaSeleccionada,
                          isExpanded: true,
                          hint: Text(
                            'Selecciona una categoría',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                          ),
                          items: state.categorias.map((categoria) {
                            return DropdownMenuItem(
                              value: categoria,
                              child: Text(
                                categoria.nombre,
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            );
                          }).toList(),
                          onChanged: (categoria) {
                            setState(() {
                              _categoriaSeleccionada = categoria;
                            });
                          },
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                },
              ),
              SizedBox(height: AppSpacing.lg),

              // Campo: Activa
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Empresa activa',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _activa
                                ? 'Aparecerá en los formularios de gastos'
                                : 'No aparecerá en los formularios',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _activa,
                      onChanged: (value) {
                        setState(() {
                          _activa = value;
                        });
                      },
                      activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
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
