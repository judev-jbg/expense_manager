import 'package:flutter/material.dart';

class ColorPickerWidget extends StatelessWidget {
  final String colorSeleccionado;
  final Function(String) onColorSelected;

  // Paleta de colores predefinidos
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: coloresDisponibles.map((color) {
            final hexColor = color['hex'] as String;
            final isSelected = colorSeleccionado == hexColor;

            return GestureDetector(
              onTap: () => onColorSelected(hexColor),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(int.parse(hexColor.replaceFirst('#', '0xff'))),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
