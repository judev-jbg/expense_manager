import 'package:flutter/material.dart';
import 'categorias_crud_screen.dart';
import 'empresas_crud_screen.dart';

class ConfiguracionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Categorías y Empresas
      child: Scaffold(
        appBar: AppBar(
          title: Text('Configuración'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.category), text: 'Categorías'),
              Tab(icon: Icon(Icons.business), text: 'Empresas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [CategoriasCrudScreen(), EmpresasCrudScreen()],
        ),
      ),
    );
  }
}
