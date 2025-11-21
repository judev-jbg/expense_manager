import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
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
    final instanciasOrdenadas = List<InstanciaRecurrenteModel>.from(instancias)
      ..sort((a, b) => b.fechaEsperada.compareTo(a.fechaEsperada));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: EdgeInsets.only(top: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.repeat,
                        color: AppColors.accent,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            configuracion.nombreGasto,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '€ ${configuracion.importeBase.toStringAsFixed(2)} • ${configuracion.descripcionFrecuencia}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Inicio: ${DateFormat('dd/MM/yyyy').format(configuracion.fechaInicio)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          Divider(color: AppColors.background, height: 1),

          // Historial título
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Text(
              'Historial de instancias',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Lista de instancias
          Flexible(
            child: instanciasOrdenadas.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: AppColors.textLight,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'No hay instancias generadas aún',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    shrinkWrap: true,
                    itemCount: instanciasOrdenadas.length,
                    itemBuilder: (context, index) {
                      return _buildInstanciaCard(instanciasOrdenadas[index]);
                    },
                  ),
          ),

          // Botón eliminar
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: ElevatedButton.icon(
              icon: Icon(Icons.delete_outline),
              label: Text('Eliminar gasto recurrente'),
              onPressed: onEliminar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textOnPrimary,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstanciaCard(InstanciaRecurrenteModel instancia) {
    Color colorEstado;
    IconData iconoEstado;

    switch (instancia.estado) {
      case EstadoInstancia.PENDIENTE:
        colorEstado = AppColors.accent;
        iconoEstado = Icons.schedule;
        break;
      case EstadoInstancia.CONFIRMADA:
        colorEstado = AppColors.success;
        iconoEstado = Icons.check_circle;
        break;
      case EstadoInstancia.OMITIDA:
        colorEstado = AppColors.textLight;
        iconoEstado = Icons.cancel;
        break;
      case EstadoInstancia.SALTADA:
        colorEstado = AppColors.error;
        iconoEstado = Icons.error;
        break;
    }

    final esFutura = instancia.fechaEsperada.isAfter(DateTime.now());

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(iconoEstado, color: colorEstado, size: 20),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(instancia.fechaEsperada),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  instancia.estado.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorEstado,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (instancia.estado == EstadoInstancia.PENDIENTE &&
                    instancia.intentosNotificacion > 0)
                  Text(
                    'Intentos: ${instancia.intentosNotificacion}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
              ],
            ),
          ),
          if (esFutura && instancia.estado == EstadoInstancia.PENDIENTE)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                'Próximo',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
