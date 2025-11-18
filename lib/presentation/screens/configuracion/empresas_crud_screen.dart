import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/empresa_model.dart';
import '../../../data/repositories/empresas_repository_impl.dart';
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
    // Cargar todas las empresas al inicio
    context.read<EmpresasBloc>().add(LoadAllEmpresas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filtro por categoría
          _buildFiltroCategoria(),

          // Lista de empresas
          Expanded(
            child: BlocBuilder<EmpresasBloc, EmpresasState>(
              builder: (context, state) {
                if (state is EmpresasLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is EmpresasLoaded) {
                  if (state.empresas.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            _categoriaFiltroId != null
                                ? 'No hay empresas en esta categoría'
                                : 'No hay empresas registradas',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Toca el botón + para agregar una',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Agrupar empresas por categoría
                  return _buildListaAgrupada(state.empresas);
                }

                if (state is EmpresasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Error al cargar empresas',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Center(child: Text('Estado inicial'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCrear(context),
        child: Icon(Icons.add),
        tooltip: 'Agregar empresa',
      ),
    );
  }

  Widget _buildFiltroCategoria() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: BlocBuilder<CategoriasBloc, CategoriasState>(
        builder: (context, state) {
          if (state is CategoriasLoaded) {
            return Row(
              children: [
                Icon(Icons.filter_list, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _categoriaFiltroId,
                    decoration: InputDecoration(
                      labelText: 'Filtrar por categoría',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text('Todas las categorías'),
                      ),
                      ...state.categorias.map((categoria) {
                        return DropdownMenuItem(
                          value: categoria.id,
                          child: Text(categoria.nombre),
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
              ],
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildListaAgrupada(List<EmpresaModel> empresas) {
    // Obtener categorías
    final categoriasState = context.read<CategoriasBloc>().state;
    if (categoriasState is! CategoriasLoaded) {
      return Center(child: CircularProgressIndicator());
    }

    // Agrupar empresas por categoría
    final Map<String, List<EmpresaModel>> empresasPorCategoria = {};

    for (var empresa in empresas) {
      if (!empresasPorCategoria.containsKey(empresa.categoriaId)) {
        empresasPorCategoria[empresa.categoriaId] = [];
      }
      empresasPorCategoria[empresa.categoriaId]!.add(empresa);
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(icono, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                nombreCategoria,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${empresas.length}',
                  style: TextStyle(
                    fontSize: 12,
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

        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEmpresaCard(EmpresaModel empresa) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.business,
          color: empresa.activa ? Colors.blue : Colors.grey,
        ),
        title: Text(
          empresa.nombre,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: empresa.activa ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: empresa.activa
            ? null
            : Text(
                'Inactiva',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _mostrarDialogoEditar(context, empresa),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _mostrarDialogoEliminar(context, empresa),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoCrear(BuildContext context) async {
    final empresa = await showDialog<EmpresaModel>(
      context: context,
      builder: (context) =>
          EmpresaFormDialog(categoriaIdInicial: _categoriaFiltroId),
    );

    if (empresa != null) {
      context.read<EmpresasBloc>().add(AddEmpresa(empresa: empresa));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Empresa creada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _mostrarDialogoEditar(BuildContext context, EmpresaModel empresa) async {
    final empresaEditada = await showDialog<EmpresaModel>(
      context: context,
      builder: (context) => EmpresaFormDialog(empresa: empresa),
    );

    if (empresaEditada != null) {
      context.read<EmpresasBloc>().add(UpdateEmpresa(empresa: empresaEditada));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Empresa actualizada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _mostrarDialogoEliminar(
    BuildContext context,
    EmpresaModel empresa,
  ) async {
    // Contar gastos asociados
    final repository = EmpresasRepositoryImpl();
    // Necesitamos crear un método para contar gastos por empresa

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Eliminar empresa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de que deseas eliminar "${empresa.nombre}"?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Los gastos asociados no se eliminarán, solo quedarán sin empresa asignada.',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                context.read<EmpresasBloc>().add(DeleteEmpresa(id: empresa.id));
                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Empresa eliminada correctamente'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
