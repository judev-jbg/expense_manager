import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../agregar_gasto/agregar_gasto_screen.dart';
import '../../../../data/models/gasto_con_detalles_model.dart';
import '../../../bloc/gastos/gastos_bloc.dart';
import '../../../bloc/gastos/gastos_event.dart';
import '../../../../data/repositories/gastos_repository_impl.dart';

class GastoCard extends StatelessWidget {
  final GastoConDetallesModel gastoConDetalles;

  const GastoCard({Key? key, required this.gastoConDetalles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gasto = gastoConDetalles.gasto;
    final fechaFormateada = DateFormat('dd/MM/yyyy').format(gasto.fecha);
    final isRecurrente = gasto.configuracionRecurrenciaId != null;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AgregarGastoScreen(gastoParaEditar: gasto),
              ),
            );
          },
          onLongPress: () => _mostrarBottomSheetEliminar(context, gasto.id),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Icono de categoría circular con gradiente
                _buildCategoryIcon(isRecurrente),

                SizedBox(width: AppSpacing.md),

                // Info del gasto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              gasto.nombre,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // Indicador de adjuntos
                          FutureBuilder<int>(
                            future: _contarAdjuntos(gasto.id),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data! > 0) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.attach_file,
                                        size: 12,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        '${snapshot.data}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        gastoConDetalles.categoriaNombre,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        fechaFormateada,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // Importe
                Text(
                  '€ ${gasto.importe.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isRecurrente ? AppColors.accent : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(bool isRecurrente) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: isRecurrente
            ? AppColors.accentGradient
            : LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.primary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isRecurrente ? Icons.sync : Icons.sync,
        color: isRecurrente ? AppColors.textOnPrimary : AppColors.accent,
        size: 24,
      ),
    );
  }

  Future<int> _contarAdjuntos(String gastoId) async {
    try {
      final repository = GastosRepositoryImpl();
      final adjuntos = await repository.getAdjuntosPorGasto(gastoId);
      return adjuntos.length;
    } catch (e) {
      return 0;
    }
  }

  void _mostrarBottomSheetEliminar(BuildContext context, String gastoId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
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
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
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
              Text(
                'Eliminar gasto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                '¿Estás seguro de que deseas eliminar este gasto?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: BorderSide(color: AppColors.textLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<GastosBloc>().add(DeleteGasto(id: gastoId));
                        Navigator.of(bottomSheetContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: AppColors.textOnPrimary),
                      ),
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
