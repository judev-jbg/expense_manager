import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/empresa_model.dart';
import '../../bloc/empresas/empresas_bloc.dart';
import '../../bloc/empresas/empresas_event.dart';
import '../../bloc/empresas/empresas_state.dart';
import '../../bloc/categorias/categorias_bloc.dart';
import '../../bloc/categorias/categorias_state.dart';
import 'widgets/empresa_form_dialog.dart';
import 'widgets/icon_picker_dialog.dart';

class EmpresasCrudScreen extends StatefulWidget {
  @override
  State<EmpresasCrudScreen> createState() => _EmpresasCrudScreenState();
}

class _EmpresasCrudScreenState extends State<EmpresasCrudScreen> {
  String? _categoriaFiltroId;

  @override
  void initState() {
    super.initState();
    context.read<EmpresasBloc>().add(LoadAllEmpresas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filtro por categoría
          _buildFiltroCategoria(),

          // Lista de empresas
          Expanded(
            child: BlocBuilder<EmpresasBloc, EmpresasState>(
              builder: (context, state) {
                if (state is EmpresasLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is EmpresasLoaded) {
                  if (state.empresas.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildListaAgrupada(state.empresas);
                }

                if (state is EmpresasError) {
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
                          'Error al cargar empresas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioCrear(context),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnPrimary,
        child: Icon(Icons.add),
        tooltip: 'Agregar empresa',
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
              Icons.business_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            _categoriaFiltroId != null
                ? 'No hay empresas en esta categoría'
                : 'No hay empresas registradas',
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

  Widget _buildFiltroCategoria() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: BlocBuilder<CategoriasBloc, CategoriasState>(
        builder: (context, state) {
          if (state is CategoriasLoaded) {
            return Row(
              children: [
                Icon(
                  Icons.filter_list,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _categoriaFiltroId,
                        isExpanded: true,
                        hint: Text(
                          'Todas las categorías',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(
                              'Todas las categorías',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ),
                          ...state.categorias.map((categoria) {
                            return DropdownMenuItem(
                              value: categoria.id,
                              child: Text(
                                categoria.nombre,
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (categoriaId) {
                          setState(() {
                            _categoriaFiltroId = categoriaId;
                          });

                          if (categoriaId == null) {
                            context.read<EmpresasBloc>().add(LoadAllEmpresas());
                          } else {
                            context.read<EmpresasBloc>().add(
                              LoadEmpresasPorCategoria(categoriaId: categoriaId),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildListaAgrupada(List<EmpresaModel> empresas) {
    final categoriasState = context.read<CategoriasBloc>().state;
    if (categoriasState is! CategoriasLoaded) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final Map<String, List<EmpresaModel>> empresasPorCategoria = {};

    for (var empresa in empresas) {
      if (!empresasPorCategoria.containsKey(empresa.categoriaId)) {
        empresasPorCategoria[empresa.categoriaId] = [];
      }
      empresasPorCategoria[empresa.categoriaId]!.add(empresa);
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: empresasPorCategoria.length,
      itemBuilder: (context, index) {
        final categoriaId = empresasPorCategoria.keys.elementAt(index);
        final empresasCategoria = empresasPorCategoria[categoriaId]!;

        final categoria = categoriasState.categorias.firstWhere(
          (cat) => cat.id == categoriaId,
        );

        return _buildGrupoCategoria(
          categoria.nombre,
          categoria.icono,
          categoria.color,
          empresasCategoria,
        );
      },
    );
  }

  Widget _buildGrupoCategoria(
    String nombreCategoria,
    String iconoCategoria,
    String colorCategoria,
    List<EmpresaModel> empresas,
  ) {
    final color = Color(int.parse(colorCategoria.replaceFirst('#', '0xff')));
    final icono = IconPickerDialog.getIconData(iconoCategoria);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de categoría
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          margin: EdgeInsets.only(top: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icono, color: color, size: 18),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                nombreCategoria,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${empresas.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de empresas
        ...empresas.map((empresa) => _buildEmpresaCard(empresa)).toList(),

        SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildEmpresaCard(EmpresaModel empresa) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: empresa.activa
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.textLight.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.business,
            color: empresa.activa ? AppColors.primary : AppColors.textLight,
            size: 20,
          ),
        ),
        title: Text(
          empresa.nombre,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: empresa.activa ? AppColors.textPrimary : AppColors.textLight,
          ),
        ),
        subtitle: empresa.activa
            ? null
            : Text(
                'Inactiva',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: () => _mostrarFormularioEditar(context, empresa),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _mostrarConfirmarEliminar(context, empresa),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarFormularioCrear(BuildContext context) async {
    final empresa = await showModalBottomSheet<EmpresaModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          EmpresaFormDialog(categoriaIdInicial: _categoriaFiltroId),
    );

    if (empresa != null) {
      context.read<EmpresasBloc>().add(AddEmpresa(empresa: empresa));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Empresa creada correctamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    }
  }

  void _mostrarFormularioEditar(BuildContext context, EmpresaModel empresa) async {
    final empresaEditada = await showModalBottomSheet<EmpresaModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmpresaFormDialog(empresa: empresa),
    );

    if (empresaEditada != null) {
      context.read<EmpresasBloc>().add(UpdateEmpresa(empresa: empresaEditada));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Empresa actualizada correctamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    }
  }

  void _mostrarConfirmarEliminar(
    BuildContext context,
    EmpresaModel empresa,
  ) async {
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
                'Eliminar empresa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),

              // Message
              Text(
                '¿Estás seguro de que deseas eliminar "${empresa.nombre}"?',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppSpacing.md),

              // Info
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Los gastos asociados no se eliminarán, solo quedarán sin empresa asignada.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
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
                        context.read<EmpresasBloc>().add(DeleteEmpresa(id: empresa.id));
                        Navigator.of(dialogContext).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Empresa eliminada correctamente'),
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
