import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

/// Clase Singleton para gestionar la base de datos SQLite local
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Constantes de la base de datos
  static const String _databaseName = 'gestor_gastos.db';
  static const int _databaseVersion = 1; // ✨ CAMBIO: Incrementar versión

  // Nombres de tablas
  static const String tableCategorias = 'categorias';
  static const String tableEmpresas = 'empresas';
  static const String tableGastos = 'gastos';
  static const String tableAdjuntos = 'adjuntos'; // ✨ NUEVO

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// Obtiene la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade, // ✨ NUEVO: Manejar migraciones
    );
  }

  /// Habilita las foreign keys
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Crea las tablas al crear la base de datos por primera vez
  Future<void> _onCreate(Database db, int version) async {
    // Tabla: categorias
    await db.execute('''
      CREATE TABLE $tableCategorias (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL UNIQUE,
        icono TEXT NOT NULL,
        color TEXT NOT NULL,
        orden INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Tabla: empresas
    await db.execute('''
      CREATE TABLE $tableEmpresas (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        categoria_id TEXT NOT NULL,
        activa INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (categoria_id) REFERENCES $tableCategorias(id) ON DELETE CASCADE,
        UNIQUE(nombre, categoria_id)
      )
    ''');

    // Tabla: gastos
    await db.execute('''
      CREATE TABLE $tableGastos (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        importe REAL NOT NULL,
        fecha INTEGER NOT NULL,
        categoria_id TEXT NOT NULL,
        empresa_id TEXT,
        notas TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (categoria_id) REFERENCES $tableCategorias(id) ON DELETE CASCADE,
        FOREIGN KEY (empresa_id) REFERENCES $tableEmpresas(id) ON DELETE SET NULL
      )
    ''');

    // ✨ NUEVO: Tabla: adjuntos
    await db.execute('''
      CREATE TABLE $tableAdjuntos (
        id TEXT PRIMARY KEY,
        gasto_id TEXT NOT NULL,
        ruta_local TEXT NOT NULL,
        tipo TEXT NOT NULL,
        nombre_archivo TEXT NOT NULL,
        tamanio INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (gasto_id) REFERENCES $tableGastos(id) ON DELETE CASCADE
      )
    ''');

    // Índices para optimizar búsquedas
    await db.execute('''
      CREATE INDEX idx_gastos_fecha ON $tableGastos(fecha)
    ''');

    await db.execute('''
      CREATE INDEX idx_gastos_categoria ON $tableGastos(categoria_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_gastos_nombre ON $tableGastos(nombre)
    ''');

    // ✨ NUEVO: Índice para adjuntos
    await db.execute('''
      CREATE INDEX idx_adjuntos_gasto ON $tableAdjuntos(gasto_id)
    ''');

    // Insertar categorías iniciales
    await _insertSeedData(db);
  }

  // ✨ NUEVO: Manejar migración de versión 1 a versión 2
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar tabla de adjuntos
      await db.execute('''
        CREATE TABLE $tableAdjuntos (
          id TEXT PRIMARY KEY,
          gasto_id TEXT NOT NULL,
          ruta_local TEXT NOT NULL,
          tipo TEXT NOT NULL,
          nombre_archivo TEXT NOT NULL,
          tamanio INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (gasto_id) REFERENCES $tableGastos(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_adjuntos_gasto ON $tableAdjuntos(gasto_id)
      ''');
    }
  }

  /// Inserta las categorías predefinidas
  Future<void> _insertSeedData(Database db) async {
    final uuid = Uuid();
    final now = DateTime.now().millisecondsSinceEpoch;

    final categoriasIniciales = [
      {
        'id': uuid.v4(),
        'nombre': 'Supermercado',
        'icono': 'shopping_cart',
        'color': '#4CAF50',
        'orden': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': uuid.v4(),
        'nombre': 'Transporte',
        'icono': 'directions_bus',
        'color': '#2196F3',
        'orden': 2,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': uuid.v4(),
        'nombre': 'Salud',
        'icono': 'local_hospital',
        'color': '#F44336',
        'orden': 3,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': uuid.v4(),
        'nombre': 'Vestimenta',
        'icono': 'checkroom',
        'color': '#9C27B0',
        'orden': 4,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': uuid.v4(),
        'nombre': 'Entretenimiento',
        'icono': 'movie',
        'color': '#FF9800',
        'orden': 5,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': uuid.v4(),
        'nombre': 'Servicios del hogar',
        'icono': 'home',
        'color': '#795548',
        'orden': 6,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': uuid.v4(),
        'nombre': 'Combustible',
        'icono': 'local_gas_station',
        'color': '#607D8B',
        'orden': 7,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': uuid.v4(),
        'nombre': 'Coche',
        'icono': 'directions_car',
        'color': '#3F51B5',
        'orden': 8,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': uuid.v4(),
        'nombre': 'Alquiler',
        'icono': 'key',
        'color': '#E91E63',
        'orden': 9,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': uuid.v4(),
        'nombre': 'Gustitos',
        'icono': 'cake',
        'color': '#FFEB3B',
        'orden': 10,
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (var categoria in categoriasIniciales) {
      await db.insert(tableCategorias, categoria);
    }
  }

  // ============================================================
  // MÉTODOS CRUD PARA CATEGORÍAS
  // ============================================================

  /// Obtiene todas las categorías ordenadas
  Future<List<Map<String, dynamic>>> getAllCategorias() async {
    final db = await database;
    return await db.query(tableCategorias, orderBy: 'orden ASC');
  }

  /// Obtiene una categoría por ID
  Future<Map<String, dynamic>?> getCategoriaById(String id) async {
    final db = await database;
    final results = await db.query(
      tableCategorias,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Inserta una nueva categoría
  Future<int> insertCategoria(Map<String, dynamic> categoria) async {
    final db = await database;
    return await db.insert(tableCategorias, categoria);
  }

  /// Actualiza una categoría existente
  Future<int> updateCategoria(Map<String, dynamic> categoria) async {
    final db = await database;
    return await db.update(
      tableCategorias,
      categoria,
      where: 'id = ?',
      whereArgs: [categoria['id']],
    );
  }

  /// Elimina una categoría
  Future<int> deleteCategoria(String id) async {
    final db = await database;
    return await db.delete(tableCategorias, where: 'id = ?', whereArgs: [id]);
  }

  // ============================================================
  // MÉTODOS CRUD PARA EMPRESAS
  // ============================================================

  /// Obtiene todas las empresas activas de una categoría
  Future<List<Map<String, dynamic>>> getEmpresasPorCategoria(
    String categoriaId,
  ) async {
    final db = await database;
    return await db.query(
      tableEmpresas,
      where: 'categoria_id = ? AND activa = 1',
      whereArgs: [categoriaId],
      orderBy: 'nombre ASC',
    );
  }

  /// Obtiene todas las empresas (activas e inactivas)
  Future<List<Map<String, dynamic>>> getAllEmpresas() async {
    final db = await database;
    return await db.query(tableEmpresas, orderBy: 'nombre ASC');
  }

  /// Obtiene una empresa por ID
  Future<Map<String, dynamic>?> getEmpresaById(String id) async {
    final db = await database;
    final results = await db.query(
      tableEmpresas,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Inserta una nueva empresa
  Future<int> insertEmpresa(Map<String, dynamic> empresa) async {
    final db = await database;
    return await db.insert(tableEmpresas, empresa);
  }

  /// Actualiza una empresa existente
  Future<int> updateEmpresa(Map<String, dynamic> empresa) async {
    final db = await database;
    return await db.update(
      tableEmpresas,
      empresa,
      where: 'id = ?',
      whereArgs: [empresa['id']],
    );
  }

  /// Elimina una empresa
  Future<int> deleteEmpresa(String id) async {
    final db = await database;
    return await db.delete(tableEmpresas, where: 'id = ?', whereArgs: [id]);
  }

  // ============================================================
  // MÉTODOS CRUD PARA GASTOS
  // ============================================================

  /// Obtiene gastos de un mes específico
  Future<List<Map<String, dynamic>>> getGastosPorMes(int mes, int anio) async {
    final db = await database;

    // Calcular timestamps del inicio y fin del mes
    final inicioMes = DateTime(anio, mes, 1).millisecondsSinceEpoch;
    final finMes = DateTime(
      anio,
      mes + 1,
      0,
      23,
      59,
      59,
    ).millisecondsSinceEpoch;

    return await db.query(
      tableGastos,
      where: 'fecha >= ? AND fecha <= ?',
      whereArgs: [inicioMes, finMes],
      orderBy: 'fecha DESC',
    );
  }

  /// Obtiene todos los gastos (para búsquedas generales)
  Future<List<Map<String, dynamic>>> getAllGastos() async {
    final db = await database;
    return await db.query(tableGastos, orderBy: 'fecha DESC');
  }

  /// Busca nombres de gastos que coincidan con un query (para autocompletado)
  Future<List<Map<String, dynamic>>> buscarNombresGastos(String query) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT DISTINCT 
        g.nombre,
        g.categoria_id,
        c.nombre as categoria_nombre,
        g.empresa_id,
        e.nombre as empresa_nombre,
        g.notas
      FROM $tableGastos g
      INNER JOIN $tableCategorias c ON g.categoria_id = c.id
      LEFT JOIN $tableEmpresas e ON g.empresa_id = e.id
      WHERE g.nombre LIKE ?
      ORDER BY g.fecha DESC
      LIMIT 10
    ''',
      ['%$query%'],
    );
  }

  /// Obtiene un gasto por ID
  Future<Map<String, dynamic>?> getGastoById(String id) async {
    final db = await database;
    final results = await db.query(
      tableGastos,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Inserta un nuevo gasto
  Future<int> insertGasto(Map<String, dynamic> gasto) async {
    final db = await database;
    return await db.insert(tableGastos, gasto);
  }

  /// Actualiza un gasto existente
  Future<int> updateGasto(Map<String, dynamic> gasto) async {
    final db = await database;
    return await db.update(
      tableGastos,
      gasto,
      where: 'id = ?',
      whereArgs: [gasto['id']],
    );
  }

  /// Elimina un gasto
  Future<int> deleteGasto(String id) async {
    final db = await database;
    return await db.delete(tableGastos, where: 'id = ?', whereArgs: [id]);
  }

  /// Calcula el total gastado en un mes
  Future<double> getTotalMes(int mes, int anio) async {
    final db = await database;

    final inicioMes = DateTime(anio, mes, 1).millisecondsSinceEpoch;
    final finMes = DateTime(
      anio,
      mes + 1,
      0,
      23,
      59,
      59,
    ).millisecondsSinceEpoch;

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(importe), 0) as total
      FROM $tableGastos
      WHERE fecha >= ? AND fecha <= ?
    ''',
      [inicioMes, finMes],
    );

    return (result.first['total'] as num).toDouble();
  }

  // ============================================================
  // ✨ NUEVOS: MÉTODOS CRUD PARA ADJUNTOS
  // ============================================================

  /// Obtiene todos los adjuntos de un gasto
  Future<List<Map<String, dynamic>>> getAdjuntosPorGasto(String gastoId) async {
    final db = await database;
    return await db.query(
      tableAdjuntos,
      where: 'gasto_id = ?',
      whereArgs: [gastoId],
      orderBy: 'created_at ASC',
    );
  }

  /// Inserta un nuevo adjunto
  Future<int> insertAdjunto(Map<String, dynamic> adjunto) async {
    final db = await database;
    return await db.insert(tableAdjuntos, adjunto);
  }

  /// Elimina un adjunto
  Future<int> deleteAdjunto(String id) async {
    final db = await database;
    return await db.delete(tableAdjuntos, where: 'id = ?', whereArgs: [id]);
  }

  /// Elimina todos los adjuntos de un gasto
  Future<int> deleteAdjuntosPorGasto(String gastoId) async {
    final db = await database;
    return await db.delete(
      tableAdjuntos,
      where: 'gasto_id = ?',
      whereArgs: [gastoId],
    );
  }

  // ============================================================
  // MÉTODOS DE UTILIDAD
  // ============================================================

  /// Cierra la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Elimina la base de datos (útil para testing o reset completo)
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
