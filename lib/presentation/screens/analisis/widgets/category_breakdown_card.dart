import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/analisis_categoria_model.dart';
import '../../configuracion/widgets/icon_picker_dialog.dart';

class CategoryBreakdownCard extends StatelessWidget {
  final List<AnalisisCategoriaModel> analisis;
  final double totalMes;

  const CategoryBreakdownCard({
    Key? key,
    required this.analisis,
    required this.totalMes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (analisis.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Desgloce por categoria',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ...analisis.map((categoria) {
            return _buildCategoriaItem(categoria);
          }),
        ],
      ),
    );
  }

  Widget _buildCategoriaItem(AnalisisCategoriaModel categoria) {
    final porcentaje = totalMes > 0
        ? (categoria.totalGastado / totalMes * 100)
        : 0;

    final color = Color(
      int.parse(categoria.categoriaColor.replaceFirst('#', '0xff')),
    );

    final icono = IconPickerDialog.getIconData(categoria.categoriaIcono);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              // Icono circular
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, color: color, size: 20),
              ),
              SizedBox(width: AppSpacing.md),

              // Nombre y cantidad
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoria.categoriaNombre,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${categoria.cantidadGastos} gasto${categoria.cantidadGastos != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Total y porcentaje
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '€${categoria.totalGastado.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${porcentaje.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: porcentaje / 100,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
