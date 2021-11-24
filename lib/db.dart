part of tremor_tracking;

class ResultsDatabase {
  static final ResultsDatabase instance = ResultsDatabase._init();
  static Database? _database;

  ResultsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('results.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final numType = 'FLOAT NOT NULL';
    final textType = 'TEXT NOT NULL';
    final intType = 'INT NOT NULL';

    await db.execute('''
    CREATE TABLE $resultsTable (
      ${ResultFields.id} $idType,
      ${ResultFields.dateTime} $textType,
      ${ResultFields.frequency} $numType,
      ${ResultFields.magnitude} $numType,
      ${ResultFields.pointColor} $intType
    )
    ''');
  }

  Future<Result> create(Result result) async {
    final db = await instance.database;
    final id = await db.insert(resultsTable, result.toJson());
    return result.copy(id: id);
  }

  Future<Result> readResult(int id) async {
    final db = await instance.database;
    final maps = await db
        .query(resultsTable, columns: ResultFields.values, where: '${ResultFields.id}= ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Result.fromJson(maps.first);
    } else {
      throw Exception('id $id not found');
    }
  }

  Future<List<Result>> readAllResults() async {
    final db = await instance.database;
    final results = await db.query(resultsTable);

    return results.map((json) => Result.fromJson(json)).toList();
  }

  Future<List<Result>> readAllRightResults() async {
    final db = await instance.database;
    final results =
        await db.query(resultsTable, where: '${ResultFields.pointColor}= ?', whereArgs: [0xFF2196F3]);

    return results.map((json) => Result.fromJson(json)).toList();
  }

  Future<List<Result>> readAllLeftResults() async {
    final db = await instance.database;
    final results =
        await db.query(resultsTable, where: '${ResultFields.pointColor}= ?', whereArgs: [0xFF9C27B0]);

    return results.map((json) => Result.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    _database = null;
    db.close();
  }
}
