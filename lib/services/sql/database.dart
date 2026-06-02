import 'package:clinimage_ai/models/signup.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert';
import 'dart:io' show Platform;

// ============================================================
// MODÈLE UTILISATEUR (lecture depuis la base)
// ============================================================
class UserModel {
  final int? id;
  final String nom;
  final String prenom;
  final String? photoUrl;
  final String poste;
  final String telephone;
  final String email;
  final String anneeService;
  final String passwordHash; // mot de passe hashé SHA-256
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    this.id,
    required this.nom,
    required this.prenom,
    this.photoUrl,
    required this.poste,
    required this.telephone,
    required this.email,
    required this.anneeService,
    required this.passwordHash,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Depuis une map SQLite ──────────────────────────────
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      prenom: map['prenom'] as String,
      photoUrl: map['photo_url'] as String?,
      poste: map['poste'] as String,
      telephone: map['telephone'] as String,
      email: map['email'] as String,
      anneeService: map['annee_service'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // ── Vers une map SQLite ────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'prenom': prenom,
      'photo_url': photoUrl,
      'poste': poste,
      'telephone': telephone,
      'email': email,
      'annee_service': anneeService,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ── Copie avec modifications ───────────────────────────
  UserModel copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? photoUrl,
    String? poste,
    String? telephone,
    String? email,
    String? anneeService,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      photoUrl: photoUrl ?? this.photoUrl,
      poste: poste ?? this.poste,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      anneeService: anneeService ?? this.anneeService,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, nom: $nom, prenom: $prenom, email: $email, poste: $poste)';
}

// ============================================================
// SERVICE BASE DE DONNÉES
// ============================================================
class DatabaseService {
  static Database? _database;
  static const String _dbName = 'clinimage_ai.db';
  static const int _dbVersion = 1;
  static const String _tableName = 'users';
  static bool _initialized = false;

  // ── Singleton ─────────────────────────────────────────
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // ── Initialisation FFI pour desktop ────────────────────
  static Future<void> initializeFfi() async {
    if (_initialized) return;

    if (!Platform.isAndroid && !Platform.isIOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      debugPrint('✅ FFI Database initialisé pour desktop');
    }
    _initialized = true;
  }

  // ── Accès à la base ───────────────────────────────────
  Future<Database> get database async {
    await initializeFfi();
    _database ??= await _initDatabase();
    return _database!;
  }

  // ── Initialisation ────────────────────────────────────
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ── Création des tables ───────────────────────────────
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        nom           TEXT    NOT NULL,
        prenom        TEXT    NOT NULL,
        photo_url     TEXT,
        poste         TEXT    NOT NULL,
        telephone     TEXT    NOT NULL,
        email         TEXT    NOT NULL UNIQUE,
        annee_service TEXT    NOT NULL,
        password_hash TEXT    NOT NULL,
        created_at    TEXT    NOT NULL,
        updated_at    TEXT    NOT NULL
      )
    ''');

    debugPrint('✅ Table $_tableName créée');
  }

  // ── Migration future ──────────────────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Ajouter les migrations ici si besoin
    debugPrint('🔄 Migration DB: v$oldVersion → v$newVersion');
  }

  // ============================================================
  // HASH MOT DE PASSE
  // ============================================================
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ============================================================
  // CREATE — Créer un utilisateur
  // ============================================================
  Future<UserModel> createUser(SignUpData data) async {
    final db = await database;

    // Vérifier si l'email existe déjà
    final existing = await getUserByEmail(data.email);
    if (existing != null) {
      throw Exception('Un compte avec cet email existe déjà.');
    }

    final now = DateTime.now();
    final user = UserModel(
      nom: data.nom,
      prenom: data.prenom,
      photoUrl: data.photoUrl,
      poste: data.poste,
      telephone: data.telephone,
      email: data.email.toLowerCase().trim(),
      anneeService: data.anneeService,
      passwordHash: _hashPassword(data.password),
      createdAt: now,
      updatedAt: now,
    );

    final id = await db.insert(
      _tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    debugPrint('✅ Utilisateur créé — id: $id, email: ${user.email}');
    return user.copyWith(id: id);
  }

  // ============================================================
  // READ — Lire un utilisateur par email
  // ============================================================
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  // ── Lire par ID ───────────────────────────────────────
  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  // ── Lire tous les utilisateurs ────────────────────────
  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'created_at DESC');
    return maps.map((m) => UserModel.fromMap(m)).toList();
  }

  // ============================================================
  // LOGIN — Vérifier les identifiants
  // ============================================================
  Future<UserModel?> login(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user == null) return null;

    final hash = _hashPassword(password);
    if (user.passwordHash != hash) return null;

    debugPrint('✅ Login réussi — ${user.prenom} ${user.nom}');
    return user;
  }

  // ============================================================
  // UPDATE — Mettre à jour le profil
  // ============================================================
  Future<UserModel> updateUser(UserModel user) async {
    final db = await database;
    final updated = user.copyWith(updatedAt: DateTime.now());

    await db.update(
      _tableName,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );

    debugPrint('✅ Utilisateur mis à jour — id: ${user.id}');
    return updated;
  }

  // ── Mettre à jour uniquement la photo ─────────────────
  Future<void> updatePhotoUrl(int userId, String photoUrl) async {
    final db = await database;
    await db.update(
      _tableName,
      {'photo_url': photoUrl, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
    debugPrint('✅ Photo mise à jour — userId: $userId');
  }

  // ── Mettre à jour le mot de passe ─────────────────────
  Future<bool> updatePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = await getUserById(userId);
    if (user == null) return false;

    // Vérifier l'ancien mot de passe
    if (user.passwordHash != _hashPassword(oldPassword)) {
      throw Exception('Ancien mot de passe incorrect.');
    }

    final db = await database;
    await db.update(
      _tableName,
      {
        'password_hash': _hashPassword(newPassword),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    debugPrint('✅ Mot de passe mis à jour — userId: $userId');
    return true;
  }

  // ============================================================
  // DELETE — Supprimer un utilisateur
  // ============================================================
  Future<void> deleteUser(int userId) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [userId]);
    debugPrint('✅ Utilisateur supprimé — id: $userId');
  }

  // ============================================================
  // UTILITAIRES
  // ============================================================

  // ── Vérifier si un email existe ───────────────────────
  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  // ── Fermer la base ────────────────────────────────────
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      debugPrint('🔒 Base de données fermée.');
    }
  }

  // ── Supprimer la base (reset complet) ─────────────────
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
    debugPrint('🗑️ Base de données supprimée.');
  }
}
