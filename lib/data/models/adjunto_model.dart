import 'package:equatable/equatable.dart';

/// Modelo de datos para un Adjunto (foto o PDF)
class AdjuntoModel extends Equatable {
  final String id;
  final String gastoId;
  final String rutaLocal;
  final String tipo; // 'image' o 'pdf'
  final String nombreArchivo;
  final int tamanio; // En bytes
  final DateTime createdAt;

  const AdjuntoModel({
    required this.id,
    required this.gastoId,
    required this.rutaLocal,
    required this.tipo,
    required this.nombreArchivo,
    required this.tamanio,
    required this.createdAt,
  });

  /// Crea una instancia desde un Map (de SQLite)
  factory AdjuntoModel.fromMap(Map<String, dynamic> map) {
    return AdjuntoModel(
      id: map['id'] as String,
      gastoId: map['gasto_id'] as String,
      rutaLocal: map['ruta_local'] as String,
      tipo: map['tipo'] as String,
      nombreArchivo: map['nombre_archivo'] as String,
      tamanio: map['tamanio'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// Convierte la instancia a Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gasto_id': gastoId,
      'ruta_local': rutaLocal,
      'tipo': tipo,
      'nombre_archivo': nombreArchivo,
      'tamanio': tamanio,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Determina si es una imagen
  bool get esImagen => tipo == 'image';

  /// Determina si es un PDF
  bool get esPdf => tipo == 'pdf';

  /// Devuelve el tamaño formateado en KB o MB
  String get tamanioFormateado {
    if (tamanio < 1024) {
      return '$tamanio B';
    } else if (tamanio < 1024 * 1024) {
      return '${(tamanio / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(tamanio / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Crea una copia con valores modificados
  AdjuntoModel copyWith({
    String? id,
    String? gastoId,
    String? rutaLocal,
    String? tipo,
    String? nombreArchivo,
    int? tamanio,
    DateTime? createdAt,
  }) {
    return AdjuntoModel(
      id: id ?? this.id,
      gastoId: gastoId ?? this.gastoId,
      rutaLocal: rutaLocal ?? this.rutaLocal,
      tipo: tipo ?? this.tipo,
      nombreArchivo: nombreArchivo ?? this.nombreArchivo,
      tamanio: tamanio ?? this.tamanio,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    gastoId,
    rutaLocal,
    tipo,
    nombreArchivo,
    tamanio,
    createdAt,
  ];

  @override
  String toString() {
    return 'AdjuntoModel(id: $id, nombre: $nombreArchivo, tipo: $tipo, tamaño: $tamanioFormateado)';
  }
}
