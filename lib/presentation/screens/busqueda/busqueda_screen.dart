import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../data/models/categoria_model.dart';
import '../../../data/models/empresa_model.dart';
import '../../../data/models/gasto_con_detalles_model.dart';
import '../../../data/repositories/gastos_repository_impl.dart';
import '../../bloc/categorias/categorias_bloc.dart';
import '../../bloc/categorias/categorias_state.dart';
import '../../bloc/empresas/empresas_bloc.dart';
import '../../bloc/empresas/empresas_event.dart';
import '../../bloc/empresas/empresas_state.dart';
import '../home/widgets/gasto_card.dart';

class BusquedaScreen extends StatefulWidget {
  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final _searchController = TextEditingController();
  final _gastosRepository = GastosRepositoryImpl();

  bool _buscando = false;
  List<GastoConDetallesModel> _resultados = [];

  // Filtros
  CategoriaModel? _categoriaFiltro;
  EmpresaModel? _empresaFiltro;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  // Estadísticas de búsqueda
  double _totalBusqueda = 0;
  int _cantidadResultados = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    setState(() {
      _buscando = true;
    });

    try {
      final resultados = await _gastosRepository.buscarGastosConFiltros(
        textoBusqueda: _searchController.text.trim().isNotEmpty
            ? _searchController.text.trim()
            : null,
        categoriaId: _categoriaFiltro?.id,
        empresaId: _empresaFiltro?.id,
        fechaDesde: _fechaDesde,
        fechaHasta: _fechaHasta,
      );

      // Calcular total
      final total = resultados.fold<double>(
        0,
        (sum, gasto) => sum + gasto.gasto.importe,
      );

      setState(() {
        _resultados = resultados;
        _totalBusqueda = total;
        _cantidadResultados = resultados.length;
        _buscando = false;
      });
    } catch (e) {
      setState(() {
        _buscando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al buscar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _searchController.clear();
      _categoriaFiltro = null;
      _empresaFiltro = null;
      _fechaDesde = null;
      _fechaHasta = null;
      _resultados = [];
      _totalBusqueda = 0;
      _cantidadResultados = 0;
    });
  }

  Future<void> _seleccionarFechaDesde() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaDesde ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: Locale('es', 'ES'),
    );

    if (fecha != null) {
      setState(() {
        _fechaDesde = fecha;
      });
      _buscar();
    }
  }

  Future<void> _seleccionarFechaHasta() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaHasta ?? DateTime.now(),
      firstDate: _fechaDesde ?? DateTime(2000),
      lastDate: DateTime.now(),
      locale: Locale('es', 'ES'),
    );

    if (fecha != null) {
      setState(() {
        _fechaHasta = fecha;
      });
      _buscar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buscar y Filtrar')),
      body: Column(
        children: [
          // Barra de búsqueda
          _buildSearchBar(),

          // Filtros
          _buildFiltros(),

          // Resumen de resultados
          if (_cantidadResultados > 0) _buildResumenResultados(),

          // Resultados
          Expanded(child: _buildResultados()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o notas...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _buscar();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onChanged: (value) {
          // Buscar automáticamente después de 500ms de inactividad
          Future.delayed(Duration(milliseconds: 500), () {
            if (_searchController.text == value) {
              _buscar();
            }
          });
        },
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Spacer(),
              if (_categoriaFiltro != null ||
                  _empresaFiltro != null ||
                  _fechaDesde != null ||
                  _fechaHasta != null)
                TextButton.icon(
                  icon: Icon(Icons.clear_all, size: 16),
                  label: Text('Limpiar', style: TextStyle(fontSize: 12)),
                  onPressed: _limpiarFiltros,
                ),
            ],
          ),
          SizedBox(height: 8),

          // Filtros en horizontal scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filtro de categoría
                _buildFiltroChip(
                  label: _categoriaFiltro?.nombre ?? 'Categoría',
                  isSelected: _categoriaFiltro != null,
                  onTap: _mostrarSelectorCategoria,
                ),
                SizedBox(width: 8),

                // Filtro de empresa
                _buildFiltroChip(
                  label: _empresaFiltro?.nombre ?? 'Empresa',
                  isSelected: _empresaFiltro != null,
                  onTap: _mostrarSelectorEmpresa,
                ),
                SizedBox(width: 8),

                // Filtro de fecha desde
                _buildFiltroChip(
                  label: _fechaDesde != null
                      ? 'Desde: ${DateFormat('dd/MM/yy').format(_fechaDesde!)}'
                      : 'Fecha desde',
                  isSelected: _fechaDesde != null,
                  onTap: _seleccionarFechaDesde,
                ),
                SizedBox(width: 8),

                // Filtro de fecha hasta
                _buildFiltroChip(
                  label: _fechaHasta != null
                      ? 'Hasta: ${DateFormat('dd/MM/yy').format(_fechaHasta!)}'
                      : 'Fecha hasta',
                  isSelected: _fechaHasta != null,
                  onTap: _seleccionarFechaHasta,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFiltroChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[400]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 4),
              Icon(Icons.check_circle, size: 14, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResumenResultados() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$_cantidadResultados resultado(s)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          Text(
            'Total: €${_totalBusqueda.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultados() {
    if (_buscando) {
      return Center(child: CircularProgressIndicator());
    }

    if (_resultados.isEmpty) {
      // Determinar mensaje apropiado
      String mensaje;
      IconData icono;

      if (_searchController.text.isEmpty &&
          _categoriaFiltro == null &&
          _empresaFiltro == null &&
          _fechaDesde == null &&
          _fechaHasta == null) {
        mensaje =
            'Usa la barra de búsqueda o los filtros\npara encontrar gastos';
        icono = Icons.search;
      } else {
        mensaje = 'No se encontraron resultados';
        icono = Icons.search_off;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _resultados.length,
      itemBuilder: (context, index) {
        return GastoCard(gastoConDetalles: _resultados[index]);
      },
    );
  }

  void _mostrarSelectorCategoria() {
    final categoriasState = context.read<CategoriasBloc>().state;

    if (categoriasState is! CategoriasLoaded) return;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona una categoría',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Opción "Todas"
              ListTile(
                leading: Icon(Icons.clear_all),
                title: Text('Todas las categorías'),
                onTap: () {
                  setState(() {
                    _categoriaFiltro = null;
                    _empresaFiltro = null; // Reset empresa también
                  });
                  Navigator.pop(context);
                  _buscar();
                },
              ),
              Divider(),

              // Lista de categorías
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categoriasState.categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = categoriasState.categorias[index];
                    return ListTile(
                      leading: Icon(
                        Icons.circle,
                        color: Color(
                          int.parse(categoria.color.replaceFirst('#', '0xff')),
                        ),
                      ),
                      title: Text(categoria.nombre),
                      trailing: _categoriaFiltro?.id == categoria.id
                          ? Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _categoriaFiltro = categoria;
                          _empresaFiltro = null; // Reset empresa
                        });
                        Navigator.pop(context);

                        // Cargar empresas de esta categoría
                        context.read<EmpresasBloc>().add(
                          LoadEmpresasPorCategoria(categoriaId: categoria.id),
                        );

                        _buscar();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarSelectorEmpresa() {
    if (_categoriaFiltro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Primero selecciona una categoría'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final empresasState = context.read<EmpresasBloc>().state;

    if (empresasState is! EmpresasLoaded) {
      // Cargar empresas primero
      context.read<EmpresasBloc>().add(
        LoadEmpresasPorCategoria(categoriaId: _categoriaFiltro!.id),
      );
      return;
    }

    if (empresasState.empresas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay empresas en esta categoría'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona una empresa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Opción "Todas"
              ListTile(
                leading: Icon(Icons.clear_all),
                title: Text('Todas las empresas'),
                onTap: () {
                  setState(() {
                    _empresaFiltro = null;
                  });
                  Navigator.pop(context);
                  _buscar();
                },
              ),
              Divider(),

              // Lista de empresas
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: empresasState.empresas.length,
                  itemBuilder: (context, index) {
                    final empresa = empresasState.empresas[index];
                    return ListTile(
                      leading: Icon(Icons.business),
                      title: Text(empresa.nombre),
                      trailing: _empresaFiltro?.id == empresa.id
                          ? Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _empresaFiltro = empresa;
                        });
                        Navigator.pop(context);
                        _buscar();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
