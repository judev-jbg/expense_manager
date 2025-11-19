import 'package:flutter/material.dart';
import 'vista_mensual_tab.dart';
import 'vista_anual_tab.dart';
import '../recurrentes/recurrentes_screen.dart';

class AnalisisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Análisis de Gastos'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_month), text: 'Mensual'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Anual'),
            ],
          ),
        ),
        body: TabBarView(children: [VistaMensualTab(), VistaAnualTab()]),
        // ✨ NUEVO: Bottom Navigation Bar para volver
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.pop(context);
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => RecurrentesScreen()),
              );
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Gastos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Análisis',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.repeat),
              label: 'Recurrentes',
            ),
          ],
        ),
      ),
    );
  }
}
