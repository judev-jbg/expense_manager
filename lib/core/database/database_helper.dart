import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

/// Clase Singleton para gestionar la base de datos SQLite local
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Constantes de la base de datos
  static const String _databaseName = 'gestor_gastos.db';
  static const int _databaseVersion = 1;

  // Nombres de tablas
  static const String tableCategorias = 'categorias';
  static const String tableEmpresas = 'empresas';
  static const String tableGastos = 'gastos';
  static const String tableAdjuntos = 'adjuntos';
  static const String tableConfiguracionesRecurrencia =
      'configuraciones_recurrencia';
  static const String tableInstanciasRecurrentes = 'instancias_recurrentes';

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

    // ✨ NUEVO: Tabla: configuraciones_recurrencia
    await db.execute('''
      CREATE TABLE $tableConfiguracionesRecurrencia (
        id TEXT PRIMARY KEY,
        nombre_gasto TEXT NOT NULL,
        importe_base REAL NOT NULL,
        categoria_id TEXT NOT NULL,
        empresa_id TEXT,
        frecuencia TEXT NOT NULL,
        intervalo_custom INTEGER,
        dia_del_mes INTEGER,
        dia_semana INTEGER,
        fecha_inicio INTEGER NOT NULL,
        fecha_fin INTEGER,
        notificar_dias_despues INTEGER NOT NULL DEFAULT 1,
        activa INTEGER NOT NULL DEFAULT 1,
        notas_plantilla TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (categoria_id) REFERENCES $tableCategorias(id) ON DELETE CASCADE,
        FOREIGN KEY (empresa_id) REFERENCES $tableEmpresas(id) ON DELETE SET NULL
      )
    ''');

    // ✨ NUEVO: Tabla: instancias_recurrentes
    await db.execute('''
      CREATE TABLE $tableInstanciasRecurrentes (
        id TEXT PRIMARY KEY,
        configuracion_recurrencia_id TEXT NOT NULL,
        fecha_esperada INTEGER NOT NULL,
        fecha_notificacion INTEGER NOT NULL,
        fecha_confirmacion INTEGER,
        gasto_id TEXT,
        importe_real REAL,
        estado TEXT NOT NULL,
        intentos_notificacion INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (configuracion_recurrencia_id) REFERENCES $tableConfiguracionesRecurrencia(id) ON DELETE CASCADE,
        FOREIGN KEY (gasto_id) REFERENCES $tableGastos(id) ON DELETE SET NULL
      )
    ''');

    // ✨ NUEVO: Índices para instancias recurrentes
    await db.execute('''
      CREATE INDEX idx_instancias_estado ON $tableInstanciasRecurrentes(estado)
    ''');

    await db.execute('''
      CREATE INDEX idx_instancias_fecha_notif ON $tableInstanciasRecurrentes(fecha_notificacion)
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

    if (oldVersion < 3) {
      // Agregar tablas de recurrencia
      await db.execute('''
        CREATE TABLE $tableConfiguracionesRecurrencia (
          id TEXT PRIMARY KEY,
          nombre_gasto TEXT NOT NULL,
          importe_base REAL NOT NULL,
          categoria_id TEXT NOT NULL,
          empresa_id TEXT,
          frecuencia TEXT NOT NULL,
          intervalo_custom INTEGER,
          dia_del_mes INTEGER,
          dia_semana INTEGER,
          fecha_inicio INTEGER NOT NULL,
          fecha_fin INTEGER,
          notificar_dias_despues INTEGER NOT NULL DEFAULT 1,
          activa INTEGER NOT NULL DEFAULT 1,
          notas_plantilla TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          FOREIGN KEY (categoria_id) REFERENCES $tableCategorias(id) ON DELETE CASCADE,
          FOREIGN KEY (empresa_id) REFERENCES $tableEmpresas(id) ON DELETE SET NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE $tableInstanciasRecurrentes (
          id TEXT PRIMARY KEY,
          configuracion_recurrencia_id TEXT NOT NULL,
          fecha_esperada INTEGER NOT NULL,
          fecha_notificacion INTEGER NOT NULL,
          fecha_confirmacion INTEGER,
          gasto_id TEXT,
          importe_real REAL,
          estado TEXT NOT NULL,
          intentos_notificacion INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          FOREIGN KEY (configuracion_recurrencia_id) REFERENCES $tableConfiguracionesRecurrencia(id) ON DELETE CASCADE,
          FOREIGN KEY (gasto_id) REFERENCES $tableGastos(id) ON DELETE SET NULL
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_instancias_estado ON $tableInstanciasRecurrentes(estado)
      ''');

      await db.execute('''
        CREATE INDEX idx_instancias_fecha_notif ON $tableInstanciasRecurrentes(fecha_notificacion)
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

  // ============================================================
  // ✨ NUEVOS: MÉTODOS PARA ANÁLISIS
  // ============================================================

  /// Obtiene el análisis de gastos por categoría de un mes
  Future<List<Map<String, dynamic>>> getAnalisisPorCategoriaMes(
    int mes,
    int anio,
  ) async {
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

    return await db.rawQuery(
      '''
      SELECT 
        c.id as categoria_id,
        c.nombre as categoria_nombre,
        c.icono as categoria_icono,
        c.color as categoria_color,
        SUM(g.importe) as total_gastado,
        COUNT(g.id) as cantidad_gastos
      FROM $tableGastos g
      INNER JOIN $tableCategorias c ON g.categoria_id = c.id
      WHERE g.fecha >= ? AND g.fecha <= ?
      GROUP BY c.id, c.nombre, c.icono, c.color
      ORDER BY total_gastado DESC
    ''',
      [inicioMes, finMes],
    );
  }

  /// Obtiene el análisis de gastos por mes de un año
  Future<List<Map<String, dynamic>>> getAnalisisPorMesAnio(int anio) async {
    final db = await database;

    final inicioAnio = DateTime(anio, 1, 1).millisecondsSinceEpoch;
    final finAnio = DateTime(anio, 12, 31, 23, 59, 59).millisecondsSinceEpoch;

    // Crear una lista de todos los meses del año
    final List<Map<String, dynamic>> resultado = [];

    for (int mes = 1; mes <= 12; mes++) {
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

      resultado.add({
        'mes': mes,
        'anio': anio,
        'total': (result.first['total'] as num).toDouble(),
      });
    }

    return resultado;
  }

  /// Obtiene el gasto más alto de un mes
  Future<Map<String, dynamic>?> getMayorGastoMes(int mes, int anio) async {
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
      SELECT 
        g.*,
        c.nombre as categoria_nombre
      FROM $tableGastos g
      INNER JOIN $tableCategorias c ON g.categoria_id = c.id
      WHERE g.fecha >= ? AND g.fecha <= ?
      ORDER BY g.importe DESC
      LIMIT 1
    ''',
      [inicioMes, finMes],
    );

    return result.isNotEmpty ? result.first : null;
  }

  // ============================================================
  // ✨ NUEVOS: MÉTODOS PARA BÚSQUEDA Y FILTROS
  // ============================================================

  /// Busca gastos con filtros avanzados
  Future<List<Map<String, dynamic>>> buscarGastosConFiltros({
    String? textoBusqueda,
    String? categoriaId,
    String? empresaId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final db = await database;

    // Construir query dinámicamente
    String query =
        '''
      SELECT 
        g.*,
        c.nombre as categoria_nombre,
        e.nombre as empresa_nombre
      FROM $tableGastos g
      INNER JOIN $tableCategorias c ON g.categoria_id = c.id
      LEFT JOIN $tableEmpresas e ON g.empresa_id = e.id
      WHERE 1=1
    ''';

    List<dynamic> args = [];

    // Filtro de texto (busca en nombre y notas)
    if (textoBusqueda != null && textoBusqueda.isNotEmpty) {
      query += ' AND (g.nombre LIKE ? OR g.notas LIKE ?)';
      args.add('%$textoBusqueda%');
      args.add('%$textoBusqueda%');
    }

    // Filtro de categoría
    if (categoriaId != null) {
      query += ' AND g.categoria_id = ?';
      args.add(categoriaId);
    }

    // Filtro de empresa
    if (empresaId != null) {
      query += ' AND g.empresa_id = ?';
      args.add(empresaId);
    }

    // Filtro de fecha desde
    if (fechaDesde != null) {
      query += ' AND g.fecha >= ?';
      args.add(fechaDesde.millisecondsSinceEpoch);
    }

    // Filtro de fecha hasta
    if (fechaHasta != null) {
      query += ' AND g.fecha <= ?';
      args.add(fechaHasta.millisecondsSinceEpoch);
    }

    query += ' ORDER BY g.fecha DESC, g.created_at DESC';

    return await db.rawQuery(query, args);
  }

  // ============================================================
  // ✨ NUEVOS: MÉTODOS CRUD PARA CONFIGURACIONES RECURRENTES
  // ============================================================

  /// Obtiene todas las configuraciones de recurrencia activas
  Future<List<Map<String, dynamic>>> getAllConfiguracionesRecurrencia({
    bool soloActivas = false,
  }) async {
    final db = await database;
    String where = soloActivas ? 'activa = 1' : '';
    return await db.query(
      tableConfiguracionesRecurrencia,
      where: where.isEmpty ? null : where,
      orderBy: 'created_at DESC',
    );
  }

  /// Obtiene una configuración por ID
  Future<Map<String, dynamic>?> getConfiguracionRecurrenciaById(
    String id,
  ) async {
    final db = await database;
    final results = await db.query(
      tableConfiguracionesRecurrencia,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Inserta una nueva configuración de recurrencia
  Future<int> insertConfiguracionRecurrencia(
    Map<String, dynamic> configuracion,
  ) async {
    final db = await database;
    return await db.insert(tableConfiguracionesRecurrencia, configuracion);
  }

  /// Actualiza una configuración de recurrencia
  Future<int> updateConfiguracionRecurrencia(
    Map<String, dynamic> configuracion,
  ) async {
    final db = await database;
    return await db.update(
      tableConfiguracionesRecurrencia,
      configuracion,
      where: 'id = ?',
      whereArgs: [configuracion['id']],
    );
  }

  /// Elimina una configuración de recurrencia
  Future<int> deleteConfiguracionRecurrencia(String id) async {
    final db = await database;
    return await db.delete(
      tableConfiguracionesRecurrencia,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // ✨ NUEVOS: MÉTODOS CRUD PARA INSTANCIAS RECURRENTES
  // ============================================================

  /// Obtiene todas las instancias de una configuración
  Future<List<Map<String, dynamic>>> getInstanciasPorConfiguracion(
    String configuracionId,
  ) async {
    final db = await database;
    return await db.query(
      tableInstanciasRecurrentes,
      where: 'configuracion_recurrencia_id = ?',
      whereArgs: [configuracionId],
      orderBy: 'fecha_esperada DESC',
    );
  }

  /// Obtiene instancias pendientes que deben notificarse hoy
  Future<List<Map<String, dynamic>>> getInstanciasPendientesHoy() async {
    final db = await database;
    final hoy = DateTime.now();
    final inicioDia = DateTime(
      hoy.year,
      hoy.month,
      hoy.day,
    ).millisecondsSinceEpoch;
    final finDia = DateTime(
      hoy.year,
      hoy.month,
      hoy.day,
      23,
      59,
      59,
    ).millisecondsSinceEpoch;

    return await db.query(
      tableInstanciasRecurrentes,
      where:
          'estado = ? AND fecha_notificacion >= ? AND fecha_notificacion <= ?',
      whereArgs: ['PENDIENTE', inicioDia, finDia],
      orderBy: 'fecha_notificacion ASC',
    );
  }

  /// Obtiene instancias que necesitan re-notificación (intentos < 3)
  Future<List<Map<String, dynamic>>> getInstanciasParaRenotificacion() async {
    final db = await database;
    final hoy = DateTime.now();
    final dosDiasAtras = hoy.subtract(Duration(days: 2)).millisecondsSinceEpoch;

    return await db.query(
      tableInstanciasRecurrentes,
      where:
          'estado = ? AND intentos_notificacion > 0 AND intentos_notificacion < 3 AND updated_at <= ?',
      whereArgs: ['PENDIENTE', dosDiasAtras],
    );
  }

  /// Inserta una nueva instancia recurrente
  Future<int> insertInstanciaRecurrente(Map<String, dynamic> instancia) async {
    final db = await database;
    return await db.insert(tableInstanciasRecurrentes, instancia);
  }

  /// Actualiza una instancia recurrente
  Future<int> updateInstanciaRecurrente(Map<String, dynamic> instancia) async {
    final db = await database;
    return await db.update(
      tableInstanciasRecurrentes,
      instancia,
      where: 'id = ?',
      whereArgs: [instancia['id']],
    );
  }

  /// Marca instancias con 3+ intentos como SALTADA
  Future<int> marcarInstanciasVencidasComoSaltadas() async {
    final db = await database;
    return await db.update(
      tableInstanciasRecurrentes,
      {
        'estado': 'SALTADA',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'intentos_notificacion >= 3 AND estado = ?',
      whereArgs: ['PENDIENTE'],
    );
  }
}
