import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../agregar_gasto/agregar_gasto_screen.dart';
import '../../../../data/models/gasto_con_detalles_model.dart';
import '../../../../data/models/adjunto_model.dart';
import '../../../bloc/gastos/gastos_bloc.dart';
import '../../../bloc/gastos/gastos_event.dart';
import '../../../../data/repositories/gastos_repository_impl.dart';

class GastoCard extends StatelessWidget {
  final GastoConDetallesModel gastoConDetalles;

  const GastoCard({Key? key, required this.gastoConDetalles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gasto = gastoConDetalles.gasto;
    final fechaFormateada = DateFormat('dd/MM/yyyy').format(gasto.fecha);
    final isRecurrente = gasto.configuracionRecurrenciaId != null;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () => _mostrarDetalleGasto(context),
          onDoubleTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AgregarGastoScreen(gastoParaEditar: gasto),
              ),
            );
          },
          onLongPress: () => _mostrarBottomSheetEliminar(context, gasto.id),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Icono de categoría circular con gradiente
                _buildCategoryIcon(isRecurrente),

                SizedBox(width: AppSpacing.md),

                // Info del gasto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              gasto.nombre,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // Indicador de adjuntos
                          FutureBuilder<int>(
                            future: _contarAdjuntos(gasto.id),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data! > 0) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.attach_file,
                                        size: 12,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        '${snapshot.data}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        gastoConDetalles.categoriaNombre,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          if (gastoConDetalles.empresaNombre != null) ...[
                            Text(
                              '${gastoConDetalles.empresaNombre} -',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textLight,
                              ),
                            ),
                            SizedBox(width: 3),
                          ],

                          Text(
                            fechaFormateada,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Importe
                Text(
                  '€ ${gasto.importe.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isRecurrente ? AppColors.accent : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(bool isRecurrente) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: isRecurrente
            ? AppColors.accentGradient.withOpacity(0.3)
            : LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.primary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isRecurrente ? Icons.repeat_outlined : Icons.receipt_long,
        color: isRecurrente ? AppColors.accent : AppColors.primary,
        size: 24,
      ),
    );
  }

  Future<int> _contarAdjuntos(String gastoId) async {
    try {
      final repository = GastosRepositoryImpl();
      final adjuntos = await repository.getAdjuntosPorGasto(gastoId);
      return adjuntos.length;
    } catch (e) {
      return 0;
    }
  }

  void _mostrarDetalleGasto(BuildContext context) async {
    final gasto = gastoConDetalles.gasto;
    final repository = GastosRepositoryImpl();
    final adjuntos = await repository.getAdjuntosPorGasto(gasto.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header con título
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detalle del gasto',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(bottomSheetContext).pop(),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del gasto
                      _buildDetailRow(
                        icon: Icons.receipt_long,
                        label: 'Nombre',
                        value: gasto.nombre,
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Importe
                      _buildDetailRow(
                        icon: Icons.euro,
                        label: 'Importe',
                        value: '€ ${gasto.importe.toStringAsFixed(2)}',
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Fecha
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Fecha',
                        value: DateFormat('dd/MM/yyyy').format(gasto.fecha),
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Categoría y Empresa
                      _buildDetailRow(
                        icon: Icons.category,
                        label: 'Categoría',
                        value: gastoConDetalles.empresaNombre != null
                            ? '${gastoConDetalles.categoriaNombre} - ${gastoConDetalles.empresaNombre}'
                            : gastoConDetalles.categoriaNombre,
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Notas (solo si existen)
                      if (gasto.notas != null && gasto.notas!.isNotEmpty) ...[
                        _buildNotasSection(gasto.notas!),
                        SizedBox(height: AppSpacing.md),
                      ],

                      // Adjuntos (solo si existen)
                      if (adjuntos.isNotEmpty) ...[
                        _buildAdjuntosSection(context, adjuntos),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.md),

              // Botón de editar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(bottomSheetContext).pop();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AgregarGastoScreen(gastoParaEditar: gasto),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  icon: Icon(Icons.edit),
                  label: Text('Editar gasto'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotasSection(String notas) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Notas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            notas,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjuntosSection(BuildContext context, List<AdjuntoModel> adjuntos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_file,
              color: AppColors.primary,
              size: 20,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Adjuntos (${adjuntos.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1,
          ),
          itemCount: adjuntos.length,
          itemBuilder: (context, index) {
            final adjunto = adjuntos[index];
            return _buildAdjuntoThumbnail(context, adjunto);
          },
        ),
      ],
    );
  }

  Widget _buildAdjuntoThumbnail(BuildContext context, AdjuntoModel adjunto) {
    return GestureDetector(
      onTap: () => _previsualizarAdjunto(context, adjunto),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.textLight.withValues(alpha: 0.3),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: adjunto.esImagen
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(adjunto.rutaLocal),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            color: AppColors.textLight,
                          ),
                        );
                      },
                    ),
                    // Overlay sutil para indicar que es tocable
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  color: AppColors.error.withValues(alpha: 0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 32,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'PDF',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        adjunto.tamanioFormateado,
                        style: TextStyle(
                          fontSize: 8,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _previsualizarAdjunto(BuildContext context, AdjuntoModel adjunto) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con título y botón cerrar
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        adjunto.nombreArchivo,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),

              // Contenido
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppRadius.lg),
                  ),
                ),
                child: adjunto.esImagen
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(AppRadius.lg),
                        ),
                        child: InteractiveViewer(
                          child: Image.file(
                            File(adjunto.rutaLocal),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                padding: EdgeInsets.all(AppSpacing.xl),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 64,
                                      color: AppColors.textLight,
                                    ),
                                    SizedBox(height: AppSpacing.md),
                                    Text(
                                      'No se pudo cargar la imagen',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: 64,
                              color: AppColors.error,
                            ),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              adjunto.nombreArchivo,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              adjunto.tamanioFormateado,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'Vista previa de PDF no disponible',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarBottomSheetEliminar(BuildContext context, String gastoId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Eliminar gasto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                '¿Estás seguro de que deseas eliminar este gasto?',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: BorderSide(color: AppColors.textLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<GastosBloc>().add(
                          DeleteGasto(id: gastoId),
                        );
                        Navigator.of(bottomSheetContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: AppColors.textOnPrimary),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }
}
