import 'package:equatable/equatable.dart';

/// Tipos de frecuencia para gastos recurrentes
enum FrecuenciaRecurrencia { MENSUAL, BIMENSUAL, SEMANAL, ANUAL, CUSTOM }

/// Modelo para configuración de gastos recurrentes
class ConfiguracionRecurrenciaModel extends Equatable {
  final String id;
  final String nombreGasto;
  final double importeBase;
  final String categoriaId;
  final String? empresaId;
  final FrecuenciaRecurrencia frecuencia;
  final int? intervaloCustom; // Solo para CUSTOM (en días)
  final int? diaDelMes; // 1-31, para MENSUAL/BIMENSUAL/ANUAL
  final int? diaSemana; // 0-6 (0=Lunes), para SEMANAL
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final int notificarDiasDespues;
  final bool activa;
  final String? notasPlantilla;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConfiguracionRecurrenciaModel({
    required this.id,
    required this.nombreGasto,
    required this.importeBase,
    required this.categoriaId,
    this.empresaId,
    required this.frecuencia,
    this.intervaloCustom,
    this.diaDelMes,
    this.diaSemana,
    required this.fechaInicio,
    this.fechaFin,
    this.notificarDiasDespues = 1,
    this.activa = true,
    this.notasPlantilla,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una instancia desde un Map (de SQLite)
  factory ConfiguracionRecurrenciaModel.fromMap(Map<String, dynamic> map) {
    return ConfiguracionRecurrenciaModel(
      id: map['id'] as String,
      nombreGasto: map['nombre_gasto'] as String,
      importeBase: map['importe_base'] as double,
      categoriaId: map['categoria_id'] as String,
      empresaId: map['empresa_id'] as String?,
      frecuencia: FrecuenciaRecurrencia.values.firstWhere(
        (e) => e.name == map['frecuencia'],
      ),
      intervaloCustom: map['intervalo_custom'] as int?,
      diaDelMes: map['dia_del_mes'] as int?,
      diaSemana: map['dia_semana'] as int?,
      fechaInicio: DateTime.fromMillisecondsSinceEpoch(
        map['fecha_inicio'] as int,
      ),
      fechaFin: map['fecha_fin'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['fecha_fin'] as int)
          : null,
      notificarDiasDespues: map['notificar_dias_despues'] as int? ?? 1,
      activa: (map['activa'] as int) == 1,
      notasPlantilla: map['notas_plantilla'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Convierte la instancia a Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre_gasto': nombreGasto,
      'importe_base': importeBase,
      'categoria_id': categoriaId,
      'empresa_id': empresaId,
      'frecuencia': frecuencia.name,
      'intervalo_custom': intervaloCustom,
      'dia_del_mes': diaDelMes,
      'dia_semana': diaSemana,
      'fecha_inicio': fechaInicio.millisecondsSinceEpoch,
      'fecha_fin': fechaFin?.millisecondsSinceEpoch,
      'notificar_dias_despues': notificarDiasDespues,
      'activa': activa ? 1 : 0,
      'notas_plantilla': notasPlantilla,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Devuelve descripción legible de la frecuencia
  String get descripcionFrecuencia {
    switch (frecuencia) {
      case FrecuenciaRecurrencia.MENSUAL:
        return 'Mensual (día $diaDelMes)';
      case FrecuenciaRecurrencia.BIMENSUAL:
        return 'Cada 2 meses (día $diaDelMes)';
      case FrecuenciaRecurrencia.SEMANAL:
        final dias = [
          'Lunes',
          'Martes',
          'Miércoles',
          'Jueves',
          'Viernes',
          'Sábado',
          'Domingo',
        ];
        return 'Semanal (${dias[diaSemana ?? 0]})';
      case FrecuenciaRecurrencia.ANUAL:
        return 'Anual (día $diaDelMes)';
      case FrecuenciaRecurrencia.CUSTOM:
        return 'Cada $intervaloCustom días';
    }
  }

  ConfiguracionRecurrenciaModel copyWith({
    String? id,
    String? nombreGasto,
    double? importeBase,
    String? categoriaId,
    String? empresaId,
    FrecuenciaRecurrencia? frecuencia,
    int? intervaloCustom,
    int? diaDelMes,
    int? diaSemana,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? notificarDiasDespues,
    bool? activa,
    String? notasPlantilla,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConfiguracionRecurrenciaModel(
      id: id ?? this.id,
      nombreGasto: nombreGasto ?? this.nombreGasto,
      importeBase: importeBase ?? this.importeBase,
      categoriaId: categoriaId ?? this.categoriaId,
      empresaId: empresaId ?? this.empresaId,
      frecuencia: frecuencia ?? this.frecuencia,
      intervaloCustom: intervaloCustom ?? this.intervaloCustom,
      diaDelMes: diaDelMes ?? this.diaDelMes,
      diaSemana: diaSemana ?? this.diaSemana,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      notificarDiasDespues: notificarDiasDespues ?? this.notificarDiasDespues,
      activa: activa ?? this.activa,
      notasPlantilla: notasPlantilla ?? this.notasPlantilla,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombreGasto,
    importeBase,
    categoriaId,
    empresaId,
    frecuencia,
    intervaloCustom,
    diaDelMes,
    diaSemana,
    fechaInicio,
    fechaFin,
    notificarDiasDespues,
    activa,
    notasPlantilla,
    createdAt,
    updatedAt,
  ];
}
