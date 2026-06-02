import 'dart:io';
import 'package:clinimage_ai/models/history_item.dart';
// import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';

// ============================================================
// MODÈLE ÉTENDU POUR LA BASE DE DONNÉES
// ============================================================
class HistoryItemDB {
  final String id;
  final int userId; // lié à l'utilisateur connecté
  final String imagePath; // chemin local du fichier image
  final String diseaseName;
  final double confidence;
  final DateTime date;
  final String severity;
  final String? notes; // notes optionnelles du médecin

  HistoryItemDB({
    required this.id,
    required this.userId,
    required this.imagePath,
    required this.diseaseName,
    required this.confidence,
    required this.date,
    required this.severity,
    this.notes,
  });

  // ── Depuis SQLite ──────────────────────────────────────
  factory HistoryItemDB.fromMap(Map<String, dynamic> map) {
    return HistoryItemDB(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      imagePath: map['image_path'] as String,
      diseaseName: map['disease_name'] as String,
      confidence: map['confidence'] as double,
      date: DateTime.parse(map['date'] as String),
      severity: map['severity'] as String,
      notes: map['notes'] as String?,
    );
  }

  // ── Vers SQLite ────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'image_path': imagePath,
      'disease_name': diseaseName,
      'confidence': confidence,
      'date': date.toIso8601String(),
      'severity': severity,
      'notes': notes,
    };
  }

  // ── Convertir vers HistoryItem (pour l'UI) ─────────────
  HistoryItem toHistoryItem() {
    return HistoryItem(
      id: id,
      imageUrl: imagePath,
      diseaseName: diseaseName,
      confidence: confidence,
      date: date,
      severity: severity,
      userId: userId.toString(),
    );
  }
}

// ============================================================
// SERVICE HISTORIQUE
// ============================================================
/*class HistoryDatabaseService {
  static Database? _database;
  static const String _dbName = 'clinimage_ai.db'; // même DB que users
  static const int _dbVersion = 1;
  static const String _tableName = 'history';

  // ── Singleton ─────────────────────────────────────────
  static final HistoryDatabaseService _instance =
      HistoryDatabaseService._internal();
  factory HistoryDatabaseService() => _instance;
  HistoryDatabaseService._internal();

  // ── Accès à la base ───────────────────────────────────
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id           TEXT    PRIMARY KEY,
        user_id      INTEGER NOT NULL,
        image_path   TEXT    NOT NULL,
        disease_name TEXT    NOT NULL,
        confidence   REAL    NOT NULL,
        date         TEXT    NOT NULL,
        severity     TEXT    NOT NULL,
        notes        TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    debugPrint('✅ Table $_tableName créée');
  }

  // ============================================================
  // GESTION DES IMAGES SUR DISQUE
  // ============================================================

  /// Copie l'image dans le dossier permanent de l'app
  /// et retourne le chemin local
  Future<String> _saveImageLocally({
    required String historyId,
    required File imageFile,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(join(appDir.path, 'history_images'));

    // Créer le dossier s'il n'existe pas
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // Extension du fichier original
    final ext = imageFile.path.split('.').last;
    final fileName = 'analysis_${historyId}.$ext';
    final destPath = join(imagesDir.path, fileName);

    // Copier le fichier
    await imageFile.copy(destPath);
    debugPrint('✅ Image sauvegardée : $destPath');
    return destPath;
  }

  /// Supprimer l'image du disque
  Future<void> _deleteImageLocally(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
      debugPrint('🗑️ Image supprimée : $imagePath');
    }
  }

  // ============================================================
  // CREATE — Sauvegarder une analyse
  // ============================================================
  Future<HistoryItemDB> saveAnalysis({
    required int userId,
    required File imageFile,
    required String diseaseName,
    required double confidence,
    required String severity,
    String? notes,
  }) async {
    final db = await database;

    // Générer un ID unique
    final id = '${userId}_${DateTime.now().millisecondsSinceEpoch}';

    // Sauvegarder l'image localement
    final imagePath = await _saveImageLocally(
      historyId: id,
      imageFile: imageFile,
    );

    final item = HistoryItemDB(
      id: id,
      userId: userId,
      imagePath: imagePath,
      diseaseName: diseaseName,
      confidence: confidence,
      date: DateTime.now(),
      severity: severity,
      notes: notes,
    );

    await db.insert(
      _tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('✅ Analyse sauvegardée — id: $id, maladie: $diseaseName');
    return item;
  }

  // ============================================================
  // READ — Récupérer l'historique d'un utilisateur
  // ============================================================
  Future<List<HistoryItemDB>> getHistoryForUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return maps.map((m) => HistoryItemDB.fromMap(m)).toList();
  }

  /// Convertit directement en List<HistoryItem> pour l'UI
  Future<List<HistoryItem>> getHistoryItemsForUser(int userId) async {
    final items = await getHistoryForUser(userId);
    return items.map((i) => i.toHistoryItem()).toList();
  }

  // ── Récupérer un item par ID ───────────────────────────
  Future<HistoryItemDB?> getHistoryItemById(String id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return HistoryItemDB.fromMap(maps.first);
  }

  // ── Récupérer par maladie ──────────────────────────────
  Future<List<HistoryItemDB>> getHistoryByDisease({
    required int userId,
    required String diseaseName,
  }) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'user_id = ? AND disease_name = ?',
      whereArgs: [userId, diseaseName],
      orderBy: 'date DESC',
    );
    return maps.map((m) => HistoryItemDB.fromMap(m)).toList();
  }

  // ── Statistiques ───────────────────────────────────────
  Future<Map<String, dynamic>> getStatsForUser(int userId) async {
    final db = await database;

    // Total analyses
    final total =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM $_tableName WHERE user_id = ?',
            [userId],
          ),
        ) ??
        0;

    // Répartition par maladie
    final byDisease = await db.rawQuery(
      '''
      SELECT disease_name, COUNT(*) as count, AVG(confidence) as avg_confidence
      FROM $_tableName
      WHERE user_id = ?
      GROUP BY disease_name
      ORDER BY count DESC
    ''',
      [userId],
    );

    // Dernière analyse
    final lastMaps = await db.query(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 1,
    );
    final lastItem = lastMaps.isNotEmpty
        ? HistoryItemDB.fromMap(lastMaps.first)
        : null;

    return {'total': total, 'by_disease': byDisease, 'last_item': lastItem};
  }

  // ============================================================
  // UPDATE — Mettre à jour les notes
  // ============================================================
  Future<void> updateNotes({required String id, required String notes}) async {
    final db = await database;
    await db.update(
      _tableName,
      {'notes': notes},
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint('✅ Notes mises à jour — id: $id');
  }

  // ============================================================
  // DELETE — Supprimer un item
  // ============================================================
  Future<void> deleteHistoryItem(String id) async {
    final db = await database;

    // Récupérer le chemin image avant suppression
    final item = await getHistoryItemById(id);
    if (item != null) {
      await _deleteImageLocally(item.imagePath);
    }

    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    debugPrint('✅ Item supprimé — id: $id');
  }

  // ── Supprimer tout l'historique d'un utilisateur ───────
  Future<void> deleteAllHistoryForUser(int userId) async {
    final db = await database;

    // Récupérer toutes les images avant suppression
    final items = await getHistoryForUser(userId);
    for (final item in items) {
      await _deleteImageLocally(item.imagePath);
    }

    await db.delete(_tableName, where: 'user_id = ?', whereArgs: [userId]);
    debugPrint('✅ Historique supprimé pour userId: $userId');
  }

  // ============================================================
  // UTILITAIRES
  // ============================================================

  /// Taille totale des images stockées pour un utilisateur
  Future<double> getStorageSizeMB(int userId) async {
    final items = await getHistoryForUser(userId);
    double totalBytes = 0;

    for (final item in items) {
      final file = File(item.imagePath);
      if (await file.exists()) {
        totalBytes += await file.length();
      }
    }

    return totalBytes / (1024 * 1024);
  }

  /// Fermer la base
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}*/

class HistoryDatabaseService {
  static final HistoryDatabaseService _instance =
      HistoryDatabaseService._internal();
  factory HistoryDatabaseService() => _instance;
  HistoryDatabaseService._internal();

  static Database? _database;
  static bool _initialized = false;

  // Initialiser pour FFI (nécessaire pour desktop/Windows)
  static void init() {
    if (!_initialized && Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _initialized = true;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    // S'assurer que FFI est initialisé pour desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      init();
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'clinimage_history.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        disease_name TEXT NOT NULL,
        confidence REAL NOT NULL,
        severity TEXT NOT NULL,
        date TEXT NOT NULL,
        image_local_path TEXT,
        notes TEXT,
        synced INTEGER DEFAULT 0,
        server_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_user_synced ON history_items(user_id, synced)
    ''');
  }

  // Sauvegarder une analyse (toujours en local d'abord)
  Future<HistoryItem> saveAnalysis({
    required String userId,
    required File imageFile,
    required String diseaseName,
    required double confidence,
    required String severity,
    String? notes,
  }) async {
    final db = await database;

    // Copier l'image dans le stockage local de l'app
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/analyses_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final localImagePath = '${imagesDir.path}/$fileName';
    await imageFile.copy(localImagePath);

    final id = await db.insert('history_items', {
      'user_id': userId,
      'disease_name': diseaseName,
      'confidence': confidence,
      'severity': severity,
      'date': DateTime.now().toIso8601String(),
      'image_local_path': localImagePath,
      'notes': notes,
      'synced': 0, // Non synchronisé
    });

    return HistoryItem(
      id: id.toString(),
      userId: userId,
      imageUrl: localImagePath,
      diseaseName: diseaseName,
      confidence: confidence,
      date: DateTime.now(),
      severity: severity,
      notes: notes,
      synced: false,
    );
  }

  // Récupérer l'historique pour un utilisateur
  Future<List<HistoryItem>> getHistoryItemsForUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'history_items',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return HistoryItem(
        id: maps[i]['id'].toString(),
        userId: maps[i]['user_id'],
        imageUrl: maps[i]['image_local_path'],
        diseaseName: maps[i]['disease_name'],
        confidence: maps[i]['confidence'],
        date: DateTime.parse(maps[i]['date']),
        severity: maps[i]['severity'],
        notes: maps[i]['notes'],
        synced: maps[i]['synced'] == 1,
        serverId: maps[i]['server_id']?.toString() ?? '',
      );
    });
  }

  // Marquer un élément comme synchronisé
  Future<void> markAsSynced(String id, int serverId) async {
    final db = await database;
    await db.update(
      'history_items',
      {'synced': 1, 'server_id': serverId},
      where: 'id = ?',
      whereArgs: [int.parse(id)],
    );
  }

  // Supprimer un élément et son image
  Future<void> deleteHistoryItem(String id) async {
    final db = await database;

    // Récupérer le chemin de l'image avant suppression
    final List<Map<String, dynamic>> result = await db.query(
      'history_items',
      where: 'id = ?',
      whereArgs: [int.parse(id)],
    );

    if (result.isNotEmpty) {
      final imagePath = result.first['image_local_path'];
      if (imagePath != null) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }
    }

    await db.delete(
      'history_items',
      where: 'id = ?',
      whereArgs: [int.parse(id)],
    );
  }

  // Obtenir les statistiques
  Future<Map<String, dynamic>> getStatsForUser(String userId) async {
    final db = await database;

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM history_items WHERE user_id = ?',
      [userId],
    );

    final syncedResult = await db.rawQuery(
      'SELECT COUNT(*) as synced FROM history_items WHERE user_id = ? AND synced = 1',
      [userId],
    );

    final pendingResult = await db.rawQuery(
      'SELECT COUNT(*) as pending FROM history_items WHERE user_id = ? AND synced = 0',
      [userId],
    );

    return {
      'total': totalResult.first['total'] as int,
      'synced': syncedResult.first['synced'] as int,
      'pending': pendingResult.first['pending'] as int,
    };
  }

  // Obtenir la taille de stockage
  Future<double> getStorageSizeMB(String userId) async {
    final db = await database;
    final items = await getHistoryItemsForUser(userId);

    double totalSize = 0;
    for (var item in items) {
      final file = File(item.imageUrl);
      if (await file.exists()) {
        totalSize += await file.length();
      }
    }

    return totalSize / (1024 * 1024);
  }

  // Synchroniser avec le serveur
  Future<void> syncWithServer(
    String userId,
    Function(Map<String, dynamic>) apiCall,
  ) async {
    final db = await database;

    // Récupérer les éléments non synchronisés
    final List<Map<String, dynamic>> pendingItems = await db.query(
      'history_items',
      where: 'user_id = ? AND synced = 0',
      whereArgs: [userId],
    );

    for (var item in pendingItems) {
      try {
        // Appel API pour synchroniser
        final serverResponse = await apiCall(item);

        if (serverResponse['success'] == true) {
          await db.update(
            'history_items',
            {'synced': 1, 'server_id': serverResponse['id']},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      } catch (e) {
        print('Erreur synchronisation item ${item['id']}: $e');
      }
    }
  }
}
