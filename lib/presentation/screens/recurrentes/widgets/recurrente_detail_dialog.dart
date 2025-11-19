import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/configuracion_recurrencia_model.dart';
import '../../../../data/models/instancia_recurrente_model.dart';

class RecurrenteDetailDialog extends StatelessWidget {
  final ConfiguracionRecurrenciaModel configuracion;
  final List<InstanciaRecurrenteModel> instancias;
  final VoidCallback onEliminar;
  final VoidCallback onActualizar;

  const RecurrenteDetailDialog({
    Key? key,
    required this.configuracion,
    required this.instancias,
    required this.onEliminar,
    required this.onActualizar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ordenar instancias por fecha (más recientes primero)
    final instanciasOrdenadas = List<InstanciaRecurrenteModel>.from(instancias)
      ..sort((a, b) => b.fechaEsperada.compareTo(a.fechaEsperada));

    return Dialog(
      child: Container(
        constraints: BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.orange.shade200),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.repeat, color: Colors.orange.shade700),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          configuracion.nombreGasto,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '€${configuracion.importeBase.toStringAsFixed(2)} • ${configuracion.descripcionFrecuencia}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Inicio: ${DateFormat('dd/MM/yyyy').format(configuracion.fechaInicio)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Historial
            Expanded(
              child: instanciasOrdenadas.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No hay instancias generadas aún',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: instanciasOrdenadas.length,
                      itemBuilder: (context, index) {
                        return _buildInstanciaCard(instanciasOrdenadas[index]);
                      },
                    ),
            ),

            // Botones de acción
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.delete, color: Colors.red),
                    label: Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: onEliminar,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstanciaCard(InstanciaRecurrenteModel instancia) {
    Color colorEstado;
    IconData iconoEstado;

    switch (instancia.estado) {
      case EstadoInstancia.PENDIENTE:
        colorEstado = Colors.orange;
        iconoEstado = Icons.schedule;
        break;
      case EstadoInstancia.CONFIRMADA:
        colorEstado = Colors.green;
        iconoEstado = Icons.check_circle;
        break;
      case EstadoInstancia.OMITIDA:
        colorEstado = Colors.grey;
        iconoEstado = Icons.cancel;
        break;
      case EstadoInstancia.SALTADA:
        colorEstado = Colors.red;
        iconoEstado = Icons.error;
        break;
    }

    final esFutura = instancia.fechaEsperada.isAfter(DateTime.now());

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorEstado.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(iconoEstado, color: colorEstado, size: 20),
        ),
        title: Text(
          DateFormat('dd/MM/yyyy').format(instancia.fechaEsperada),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              instancia.estado.name,
              style: TextStyle(
                fontSize: 12,
                color: colorEstado,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (instancia.estado == EstadoInstancia.PENDIENTE &&
                instancia.intentosNotificacion > 0)
              Text(
                'Intentos de notificación: ${instancia.intentosNotificacion}',
                style: TextStyle(fontSize: 11, color: Colors.orange),
              ),
            if (instancia.estado == EstadoInstancia.CONFIRMADA &&
                instancia.fechaConfirmacion != null)
              Text(
                'Confirmado: ${DateFormat('dd/MM/yyyy').format(instancia.fechaConfirmacion!)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: esFutura && instancia.estado == EstadoInstancia.PENDIENTE
            ? Chip(
                label: Text('Próximo', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.blue.shade100,
                labelPadding: EdgeInsets.symmetric(horizontal: 8),
              )
            : null,
      ),
    );
  }
}
