import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/categoria_model.dart';
import '../../bloc/categorias/categorias_bloc.dart';
import '../../bloc/categorias/categorias_event.dart';
import '../../bloc/categorias/categorias_state.dart';
import 'widgets/categoria_form_dialog.dart';
import 'widgets/icon_picker_dialog.dart';

class CategoriasCrudScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<CategoriasBloc, CategoriasState>(
        builder: (context, state) {
          if (state is CategoriasLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is CategoriasLoaded) {
            if (state.categorias.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: state.categorias.length,
              itemBuilder: (context, index) {
                final categoria = state.categorias[index];
                return _buildCategoriaCard(context, categoria);
              },
            );
          }

          if (state is CategoriasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Error al cargar categorías',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    state.message,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Text(
              'Estado inicial',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioCrear(context),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnPrimary,
        child: Icon(Icons.add),
        tooltip: 'Agregar categoría',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.category_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No hay categorías registradas',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Toca el botón + para agregar una',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaCard(BuildContext context, CategoriaModel categoria) {
    final color = Color(int.parse(categoria.color.replaceFirst('#', '0xff')));
    final icono = IconPickerDialog.getIconData(categoria.icono);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: color, size: 24),
        ),
        title: Text(
          categoria.nombre,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: () => _mostrarFormularioEditar(context, categoria),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _mostrarConfirmarEliminar(context, categoria),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarFormularioCrear(BuildContext context) async {
    final categoriasState = context.read<CategoriasBloc>().state;
    int ordenSiguiente = 1;

    if (categoriasState is CategoriasLoaded) {
      ordenSiguiente = categoriasState.categorias.length + 1;
    }

    final categoria = await showModalBottomSheet<CategoriaModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoriaFormDialog(ordenSiguiente: ordenSiguiente),
    );

    if (categoria != null) {
      context.read<CategoriasBloc>().add(AddCategoria(categoria: categoria));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Categoría creada correctamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    }
  }

  void _mostrarFormularioEditar(
    BuildContext context,
    CategoriaModel categoria,
  ) async {
    final categoriaEditada = await showModalBottomSheet<CategoriaModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoriaFormDialog(
        categoria: categoria,
        ordenSiguiente: 0,
      ),
    );

    if (categoriaEditada != null) {
      context.read<CategoriasBloc>().add(
        UpdateCategoria(categoria: categoriaEditada),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Categoría actualizada correctamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    }
  }

  void _mostrarConfirmarEliminar(BuildContext context, CategoriaModel categoria) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.textLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Icon
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              SizedBox(height: AppSpacing.md),

              // Title
              Text(
                'Eliminar categoría',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),

              // Message
              Text(
                '¿Estás seguro de que deseas eliminar "${categoria.nombre}"?',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppSpacing.sm),

              // Warning
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'También se eliminarán todos los gastos asociados.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
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
                      onPressed: () {
                        context.read<CategoriasBloc>().add(
                          DeleteCategoria(id: categoria.id),
                        );
                        Navigator.of(dialogContext).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Categoría eliminada correctamente'),
                            backgroundColor: AppColors.accent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text('Eliminar'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }
}
