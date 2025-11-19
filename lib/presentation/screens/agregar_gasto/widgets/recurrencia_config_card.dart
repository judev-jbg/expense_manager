import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/configuracion_recurrencia_model.dart';

class RecurrenciaConfigCard extends StatefulWidget {
  final Function(FrecuenciaRecurrencia, int?, int?, int?) onConfigChanged;
  final DateTime fechaGasto;

  const RecurrenciaConfigCard({
    Key? key,
    required this.onConfigChanged,
    required this.fechaGasto,
  }) : super(key: key);

  @override
  State<RecurrenciaConfigCard> createState() => _RecurrenciaConfigCardState();
}

class _RecurrenciaConfigCardState extends State<RecurrenciaConfigCard> {
  FrecuenciaRecurrencia _frecuencia = FrecuenciaRecurrencia.MENSUAL;
  int _diaDelMes = 1;
  int _diaSemana = 0;
  int _intervaloCustom = 30;

  @override
  void initState() {
    super.initState();
    // Usar el día del gasto como valor inicial
    _diaDelMes = widget.fechaGasto.day;
    _diaSemana = (widget.fechaGasto.weekday - 1) % 7; // 0=Lunes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificarCambios();
    });
  }

  void _notificarCambios() {
    // Esta función será llamada cuando cambie cualquier valor
    widget.onConfigChanged(
      _frecuencia,
      _diaDelMes,
      _diaSemana,
      _intervaloCustom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.repeat, color: Colors.blue.shade700),
                SizedBox(width: 8),
                Text(
                  'Configuración de Recurrencia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Selector de frecuencia
            Text(
              'Frecuencia',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<FrecuenciaRecurrencia>(
              initialValue: _frecuencia,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                DropdownMenuItem(
                  value: FrecuenciaRecurrencia.MENSUAL,
                  child: Text('Mensual'),
                ),
                DropdownMenuItem(
                  value: FrecuenciaRecurrencia.BIMENSUAL,
                  child: Text('Cada 2 meses'),
                ),
                DropdownMenuItem(
                  value: FrecuenciaRecurrencia.SEMANAL,
                  child: Text('Semanal'),
                ),
                DropdownMenuItem(
                  value: FrecuenciaRecurrencia.ANUAL,
                  child: Text('Anual'),
                ),
                DropdownMenuItem(
                  value: FrecuenciaRecurrencia.CUSTOM,
                  child: Text('Personalizado (días)'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _frecuencia = value;
                  });
                  _notificarCambios();
                }
              },
            ),
            SizedBox(height: 16),

            // Configuración específica según frecuencia
            if (_frecuencia == FrecuenciaRecurrencia.MENSUAL ||
                _frecuencia == FrecuenciaRecurrencia.BIMENSUAL ||
                _frecuencia == FrecuenciaRecurrencia.ANUAL)
              _buildDiaDelMesSelector(),

            if (_frecuencia == FrecuenciaRecurrencia.SEMANAL)
              _buildDiaSemanaSelector(),

            if (_frecuencia == FrecuenciaRecurrencia.CUSTOM)
              _buildIntervaloCustomSelector(),

            SizedBox(height: 16),

            // Información adicional
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recibirás una notificación 1 día después de la fecha esperada para confirmar el pago.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaDelMesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Día del mes',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _diaDelMes,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          items: List.generate(31, (index) {
            final dia = index + 1;
            return DropdownMenuItem(value: dia, child: Text('Día $dia'));
          }),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _diaDelMes = value;
              });
              _notificarCambios();
            }
          },
        ),
      ],
    );
  }

  Widget _buildDiaSemanaSelector() {
    final dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Día de la semana',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _diaSemana,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          items: List.generate(7, (index) {
            return DropdownMenuItem(value: index, child: Text(dias[index]));
          }),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _diaSemana = value;
              });
              _notificarCambios();
            }
          },
        ),
      ],
    );
  }

  Widget _buildIntervaloCustomSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cada cuántos días',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          initialValue: _intervaloCustom.toString(),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Ej: 30',
            suffixText: 'días',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            final intervalo = int.tryParse(value);
            if (intervalo != null && intervalo > 0) {
              setState(() {
                _intervaloCustom = intervalo;
              });
              _notificarCambios();
            }
          },
        ),
      ],
    );
  }
}
