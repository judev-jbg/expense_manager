import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/gasto_con_detalles_model.dart';
import '../../../bloc/gastos/gastos_bloc.dart';
import '../../../bloc/gastos/gastos_event.dart';

class GastoCard extends StatelessWidget {
  final GastoConDetallesModel gastoConDetalles;

  const GastoCard({Key? key, required this.gastoConDetalles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gasto = gastoConDetalles.gasto;
    final fechaFormateada = DateFormat('dd/MM/yyyy').format(gasto.fecha);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.receipt, color: Colors.blue.shade700),
        ),
        title: Text(
          gasto.nombre,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              '${gastoConDetalles.categoriaNombre}${gastoConDetalles.empresaNombre != null ? ' • ${gastoConDetalles.empresaNombre}' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 2),
            Text(
              fechaFormateada,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            if (gasto.notas != null && gasto.notas!.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                gasto.notas!,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '€${gasto.importe.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ],
        ),
        onLongPress: () {
          // Mostrar diálogo de confirmación para eliminar
          _mostrarDialogoEliminar(context, gasto.id);
        },
      ),
    );
  }

  void _mostrarDialogoEliminar(BuildContext context, String gastoId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Eliminar gasto'),
          content: Text('¿Estás seguro de que deseas eliminar este gasto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Eliminar el gasto usando el Bloc del contexto original
                context.read<GastosBloc>().add(DeleteGasto(id: gastoId));
                Navigator.of(dialogContext).pop();
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
