import 'package:flutter/material.dart';
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

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Desglose por Categoría',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...analisis.map((categoria) {
              return _buildCategoriaItem(categoria);
            }).toList(),
          ],
        ),
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
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              // Icono
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, color: color, size: 20),
              ),
              SizedBox(width: 12),

              // Nombre y cantidad
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoria.categoriaNombre,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${categoria.cantidadGastos} gasto(s)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                      color: color,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${porcentaje.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),

          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: porcentaje / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
