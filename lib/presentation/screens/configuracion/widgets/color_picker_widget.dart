import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ColorPickerWidget extends StatelessWidget {
  final String colorSeleccionado;
  final Function(String) onColorSelected;

  static const List<Map<String, dynamic>> coloresDisponibles = [
    {'nombre': 'Verde', 'hex': '#4CAF50'},
    {'nombre': 'Azul', 'hex': '#2196F3'},
    {'nombre': 'Rojo', 'hex': '#F44336'},
    {'nombre': 'Púrpura', 'hex': '#9C27B0'},
    {'nombre': 'Naranja', 'hex': '#FF9800'},
    {'nombre': 'Marrón', 'hex': '#795548'},
    {'nombre': 'Gris Azulado', 'hex': '#607D8B'},
    {'nombre': 'Índigo', 'hex': '#3F51B5'},
    {'nombre': 'Rosa', 'hex': '#E91E63'},
    {'nombre': 'Amarillo', 'hex': '#FFEB3B'},
    {'nombre': 'Cian', 'hex': '#00BCD4'},
    {'nombre': 'Verde Oscuro', 'hex': '#388E3C'},
    {'nombre': 'Naranja Oscuro', 'hex': '#F57C00'},
    {'nombre': 'Rojo Oscuro', 'hex': '#D32F2F'},
    {'nombre': 'Azul Oscuro', 'hex': '#1976D2'},
    {'nombre': 'Púrpura Oscuro', 'hex': '#7B1FA2'},
  ];

  const ColorPickerWidget({
    Key? key,
    required this.colorSeleccionado,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: coloresDisponibles.map((color) {
              final hexColor = color['hex'] as String;
              final isSelected = colorSeleccionado == hexColor;

              return GestureDetector(
                onTap: () => onColorSelected(hexColor),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(int.parse(hexColor.replaceFirst('#', '0xff'))),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.textPrimary : Colors.transparent,
                      width: isSelected ? 3 : 0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
