import 'package:uuid/uuid.dart';
import '../../data/models/configuracion_recurrencia_model.dart';
import '../../data/models/instancia_recurrente_model.dart';
import '../../core/database/database_helper.dart';

/// Servicio para generar instancias recurrentes
class GeneradorInstanciasService {
  final _databaseHelper = DatabaseHelper();
  final _uuid = Uuid();

  /// Genera las próximas N instancias para una configuración
  /// Por defecto genera 3 meses hacia adelante
  Future<List<InstanciaRecurrenteModel>> generarProximasInstancias(
    ConfiguracionRecurrenciaModel configuracion, {
    int cantidadInstancias = 3,
  }) async {
    final instancias = <InstanciaRecurrenteModel>[];
    final ahora = DateTime.now();

    // Obtener la última instancia existente para esta configuración
    final instanciasExistentes = await _databaseHelper
        .getInstanciasPorConfiguracion(configuracion.id);

    DateTime proximaFecha;

    if (instanciasExistentes.isEmpty) {
      // Primera vez: calcular desde fecha de inicio
      proximaFecha = _calcularProximaFechaDesde(
        configuracion.fechaInicio,
        configuracion,
      );
    } else {
      // Ya hay instancias: calcular desde la última
      final ultimaInstancia = InstanciaRecurrenteModel.fromMap(
        instanciasExistentes.first,
      );
      proximaFecha = _calcularProximaFechaDesde(
        ultimaInstancia.fechaEsperada,
        configuracion,
      );
    }

    // Generar N instancias
    for (int i = 0; i < cantidadInstancias; i++) {
      // Verificar si está dentro del rango (fechaFin)
      if (configuracion.fechaFin != null &&
          proximaFecha.isAfter(configuracion.fechaFin!)) {
        break;
      }

      // Calcular fecha de notificación (N días después de la fecha esperada)
      final fechaNotificacion = proximaFecha.add(
        Duration(days: configuracion.notificarDiasDespues),
      );

      final instancia = InstanciaRecurrenteModel(
        id: _uuid.v4(),
        configuracionRecurrenciaId: configuracion.id,
        fechaEsperada: proximaFecha,
        fechaNotificacion: fechaNotificacion,
        estado: EstadoInstancia.PENDIENTE,
        createdAt: ahora,
        updatedAt: ahora,
      );

      instancias.add(instancia);

      // Calcular siguiente fecha
      proximaFecha = _calcularProximaFechaDesde(proximaFecha, configuracion);
    }

    return instancias;
  }

  /// Calcula la próxima fecha basándose en una fecha de referencia
  DateTime _calcularProximaFechaDesde(
    DateTime fechaReferencia,
    ConfiguracionRecurrenciaModel configuracion,
  ) {
    switch (configuracion.frecuencia) {
      case FrecuenciaRecurrencia.SEMANAL:
        return _calcularProximaFechaSemanal(fechaReferencia, configuracion);

      case FrecuenciaRecurrencia.MENSUAL:
        return _calcularProximaFechaMensual(fechaReferencia, configuracion);

      case FrecuenciaRecurrencia.BIMENSUAL:
        return _calcularProximaFechaBimensual(fechaReferencia, configuracion);

      case FrecuenciaRecurrencia.ANUAL:
        return _calcularProximaFechaAnual(fechaReferencia, configuracion);

      case FrecuenciaRecurrencia.CUSTOM:
        return _calcularProximaFechaCustom(fechaReferencia, configuracion);
    }
  }

  /// Calcula próxima fecha para frecuencia SEMANAL
  DateTime _calcularProximaFechaSemanal(
    DateTime fechaReferencia,
    ConfiguracionRecurrenciaModel configuracion,
  ) {
    final diaSemanaObjetivo = configuracion.diaSemana!; // 0=Lunes, 6=Domingo
    final diaSemanaActual = (fechaReferencia.weekday - 1) % 7;

    int diasHastaProximo;
    if (diaSemanaActual < diaSemanaObjetivo) {
      diasHastaProximo = diaSemanaObjetivo - diaSemanaActual;
    } else {
      diasHastaProximo = 7 - diaSemanaActual + diaSemanaObjetivo;
    }

    return fechaReferencia.add(Duration(days: diasHastaProximo));
  }

  /// Calcula próxima fecha para frecuencia MENSUAL
  DateTime _calcularProximaFechaMensual(
    DateTime fechaReferencia,
    ConfiguracionRecurrenciaModel configuracion,
  ) {
    final diaObjetivo = configuracion.diaDelMes!;

    // Calcular mes siguiente
    int mesProximo = fechaReferencia.month + 1;
    int anioProximo = fechaReferencia.year;

    if (mesProximo > 12) {
      mesProximo = 1;
      anioProximo++;
    }

    // Ajustar día si el mes no tiene suficientes días
    final ultimoDiaDelMes = DateTime(anioProximo, mesProximo + 1, 0).day;
    final diaFinal = diaObjetivo > ultimoDiaDelMes
        ? ultimoDiaDelMes
        : diaObjetivo;

    return DateTime(anioProximo, mesProximo, diaFinal);
  }

  /// Calcula próxima fecha para frecuencia BIMENSUAL (cada 2 meses)
  DateTime _calcularProximaFechaBimensual(
    DateTime fechaReferencia,
    ConfiguracionRecurrenciaModel configuracion,
  ) {
    final diaObjetivo = configuracion.diaDelMes!;

    // Calcular 2 meses después
    int mesProximo = fechaReferencia.month + 2;
    int anioProximo = fechaReferencia.year;

    while (mesProximo > 12) {
      mesProximo -= 12;
      anioProximo++;
    }

    // Ajustar día si el mes no tiene suficientes días
    final ultimoDiaDelMes = DateTime(anioProximo, mesProximo + 1, 0).day;
    final diaFinal = diaObjetivo > ultimoDiaDelMes
        ? ultimoDiaDelMes
        : diaObjetivo;

    return DateTime(anioProximo, mesProximo, diaFinal);
  }

  /// Calcula próxima fecha para frecuencia ANUAL
  DateTime _calcularProximaFechaAnual(
    DateTime fechaReferencia,
    ConfiguracionRecurrenciaModel configuracion,
  ) {
    final diaObjetivo = configuracion.diaDelMes!;
    final mesObjetivo = fechaReferencia.month;

    int anioProximo = fechaReferencia.year + 1;

    // Ajustar día si el mes no tiene suficientes días (ej: 29 feb)
    final ultimoDiaDelMes = DateTime(anioProximo, mesObjetivo + 1, 0).day;
    final diaFinal = diaObjetivo > ultimoDiaDelMes
        ? ultimoDiaDelMes
        : diaObjetivo;

    return DateTime(anioProximo, mesObjetivo, diaFinal);
  }

  /// Calcula próxima fecha para frecuencia CUSTOM (cada N días)
  DateTime _calcularProximaFechaCustom(
    DateTime fechaReferencia,
    ConfiguracionRecurrenciaModel configuracion,
  ) {
    final intervalo = configuracion.intervaloCustom!;
    return fechaReferencia.add(Duration(days: intervalo));
  }

  /// Guarda las instancias en la base de datos
  Future<void> guardarInstancias(
    List<InstanciaRecurrenteModel> instancias,
  ) async {
    for (var instancia in instancias) {
      await _databaseHelper.insertInstanciaRecurrente(instancia.toMap());
    }
  }

  /// Genera y guarda las próximas instancias
  Future<void> generarYGuardarInstancias(
    ConfiguracionRecurrenciaModel configuracion, {
    int cantidadInstancias = 3,
  }) async {
    final instancias = await generarProximasInstancias(
      configuracion,
      cantidadInstancias: cantidadInstancias,
    );

    await guardarInstancias(instancias);
  }
}
