import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      body: BlocBuilder<CategoriasBloc, CategoriasState>(
        builder: (context, state) {
          if (state is CategoriasLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is CategoriasLoaded) {
            if (state.categorias.isEmpty) {
              return Center(child: Text('No hay categorías registradas'));
            }

            return ListView.builder(
              padding: EdgeInsets.all(8),
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
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error al cargar categorías',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(state.message),
                ],
              ),
            );
          }

          return Center(child: Text('Estado inicial'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCrear(context),
        child: Icon(Icons.add),
        tooltip: 'Agregar categoría',
      ),
    );
  }

  Widget _buildCategoriaCard(BuildContext context, CategoriaModel categoria) {
    final color = Color(int.parse(categoria.color.replaceFirst('#', '0xff')));
    final icono = IconPickerDialog.getIconData(categoria.icono);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: color, size: 28),
        ),
        title: Text(
          categoria.nombre,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _mostrarDialogoEditar(context, categoria),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _mostrarDialogoEliminar(context, categoria),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoCrear(BuildContext context) async {
    final categoriasState = context.read<CategoriasBloc>().state;
    int ordenSiguiente = 1;

    if (categoriasState is CategoriasLoaded) {
      ordenSiguiente = categoriasState.categorias.length + 1;
    }

    final categoria = await showDialog<CategoriaModel>(
      context: context,
      builder: (context) => CategoriaFormDialog(ordenSiguiente: ordenSiguiente),
    );

    if (categoria != null) {
      context.read<CategoriasBloc>().add(AddCategoria(categoria: categoria));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Categoría creada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _mostrarDialogoEditar(
    BuildContext context,
    CategoriaModel categoria,
  ) async {
    final categoriaEditada = await showDialog<CategoriaModel>(
      context: context,
      builder: (context) => CategoriaFormDialog(
        categoria: categoria,
        ordenSiguiente: 0, // No se usa en modo edición
      ),
    );

    if (categoriaEditada != null) {
      context.read<CategoriasBloc>().add(
        UpdateCategoria(categoria: categoriaEditada),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Categoría actualizada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _mostrarDialogoEliminar(BuildContext context, CategoriaModel categoria) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Eliminar categoría'),
          content: Text(
            '¿Estás seguro de que deseas eliminar "${categoria.nombre}"?\n\n'
            'ADVERTENCIA: También se eliminarán todos los gastos asociados a esta categoría.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                context.read<CategoriasBloc>().add(
                  DeleteCategoria(id: categoria.id),
                );
                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Categoría eliminada correctamente'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
