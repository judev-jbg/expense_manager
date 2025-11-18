import 'package:flutter/material.dart';

class IconPickerDialog extends StatelessWidget {
  // Lista de iconos disponibles para categorías
  static const List<Map<String, dynamic>> iconosDisponibles = [
    {'nombre': 'shopping_cart', 'icon': Icons.shopping_cart},
    {'nombre': 'directions_bus', 'icon': Icons.directions_bus},
    {'nombre': 'local_hospital', 'icon': Icons.local_hospital},
    {'nombre': 'checkroom', 'icon': Icons.checkroom},
    {'nombre': 'movie', 'icon': Icons.movie},
    {'nombre': 'home', 'icon': Icons.home},
    {'nombre': 'local_gas_station', 'icon': Icons.local_gas_station},
    {'nombre': 'directions_car', 'icon': Icons.directions_car},
    {'nombre': 'key', 'icon': Icons.key},
    {'nombre': 'cake', 'icon': Icons.cake},
    {'nombre': 'restaurant', 'icon': Icons.restaurant},
    {'nombre': 'local_cafe', 'icon': Icons.local_cafe},
    {'nombre': 'phone', 'icon': Icons.phone},
    {'nombre': 'wifi', 'icon': Icons.wifi},
    {'nombre': 'electric_bolt', 'icon': Icons.electric_bolt},
    {'nombre': 'water_drop', 'icon': Icons.water_drop},
    {'nombre': 'school', 'icon': Icons.school},
    {'nombre': 'sports_soccer', 'icon': Icons.sports_soccer},
    {'nombre': 'fitness_center', 'icon': Icons.fitness_center},
    {'nombre': 'local_pharmacy', 'icon': Icons.local_pharmacy},
    {'nombre': 'pets', 'icon': Icons.pets},
    {'nombre': 'flight', 'icon': Icons.flight},
    {'nombre': 'hotel', 'icon': Icons.hotel},
    {'nombre': 'beach_access', 'icon': Icons.beach_access},
    {'nombre': 'account_balance', 'icon': Icons.account_balance},
    {'nombre': 'savings', 'icon': Icons.savings},
    {'nombre': 'credit_card', 'icon': Icons.credit_card},
    {'nombre': 'payments', 'icon': Icons.payments},
    {'nombre': 'laptop', 'icon': Icons.laptop},
    {'nombre': 'smartphone', 'icon': Icons.smartphone},
    {'nombre': 'headphones', 'icon': Icons.headphones},
    {'nombre': 'local_laundry_service', 'icon': Icons.local_laundry_service},
    {'nombre': 'spa', 'icon': Icons.spa},
    {'nombre': 'mood', 'icon': Icons.mood},
    {'nombre': 'star', 'icon': Icons.star},
    {'nombre': 'favorite', 'icon': Icons.favorite},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Selecciona un icono'),
      content: Container(
        width: double.maxFinite,
        height: 400,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: iconosDisponibles.length,
          itemBuilder: (context, index) {
            final icono = iconosDisponibles[index];
            return InkWell(
              onTap: () {
                Navigator.pop(context, icono['nombre']);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icono['icon'] as IconData,
                  size: 32,
                  color: Colors.blue.shade700,
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
      ],
    );
  }

  // Método helper para obtener el IconData desde el nombre
  static IconData? getIconData(String nombreIcono) {
    try {
      final icono = iconosDisponibles.firstWhere(
        (i) => i['nombre'] == nombreIcono,
      );
      return icono['icon'] as IconData;
    } catch (e) {
      return Icons.help_outline; // Icono por defecto si no se encuentra
    }
  }
}
