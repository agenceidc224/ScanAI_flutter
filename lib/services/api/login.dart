import 'dart:convert';
import 'package:clinimage_ai/models/signup.dart';
import 'package:clinimage_ai/services/api_urls.dart';
import 'package:clinimage_ai/services/sql/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool success;
  final int statusCode;
  final String message;
  final String? token;

  AuthResult({
    required this.success,
    required this.statusCode,
    required this.message,
    this.token,
  });
}

class AuthService {
  // ── Sauvegarde du token ───────────────────────────────
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    debugPrint('✅ Token sauvegardé dans SharedPreferences');
  }

  // ── Lecture du token (utile dans le reste de l'app) ───
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // ── Suppression du token (déconnexion) ────────────────
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    debugPrint('🔒 Token supprimé');
  }

  // ── Connexion locale (fallback hors ligne) ────────────
  static Future<AuthResult> _loginLocally(String email, String password) async {
    debugPrint('Vérification des utilisateurs locaux...');
    try {
      final user = await DatabaseService().login(email, password);
      if (user != null) {
        return AuthResult(
          success: true,
          statusCode: 0,
          message: 'Connexion locale réussie.',
        );
      }
      return AuthResult(
        success: false,
        statusCode: 0,
        message: 'Email ou mot de passe incorrect.',
      );
    } catch (error) {
      debugPrint('Erreur de connexion locale : $error');
      return AuthResult(
        success: false,
        statusCode: 0,
        message: 'Erreur de connexion locale.',
      );
    }
  }

  // ── Inscription locale uniquement (hors ligne) ────────
  static Future<AuthResult> _signUpLocally(SignUpData userData) async {
    debugPrint('Inscription locale (hors ligne)...');
    try {
      await DatabaseService().createUser(userData);
      debugPrint('✅ Utilisateur inscrit localement.');
      return AuthResult(
        success: true,
        statusCode: 0,
        message:
            'Compte créé localement. '
            'Vos données seront synchronisées à la prochaine connexion.',
      );
    } catch (error) {
      debugPrint('Erreur inscription locale : $error');
      // L'email existe déjà localement
      if (error.toString().contains('existe déjà')) {
        return AuthResult(
          success: false,
          statusCode: 0,
          message: 'Un compte avec cet email existe déjà.',
        );
      }
      return AuthResult(
        success: false,
        statusCode: 0,
        message: 'Erreur lors de la création du compte local.',
      );
    }
  }

  // ── Connexion ─────────────────────────────────────────
  static Future<AuthResult> login(
    String identifiant,
    String password,
    bool isConnected,
  ) async {
    final uri = Uri.parse(ApiUrls.login);
    debugPrint('Tentative de connexion à: $uri');
    debugPrint('Identifiant: $identifiant, Connecté: $isConnected');

    if (isConnected) {
      try {
        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'identifiant': identifiant, 'password': password}),
        );

        String message = 'Erreur de connexion.';
        String? token;

        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            if (data is Map<String, dynamic>) {
              token = (data['token'] ?? data['access'])?.toString();
              message =
                  (data['detail'] ??
                          data['message'] ??
                          data['non_field_errors'])
                      ?.toString() ??
                  message;
            }
          } catch (_) {
            debugPrint('Réponse non JSON, message brut: ${response.body}');
            message = response.body;
          }
        }

        final success =
            response.statusCode == 200 || response.statusCode == 201;

        if (success && token != null) {
          await _saveToken(token);
        }
        debugPrint(
          'Réponse de connexion: ${response.statusCode} — $message — Token: ${token != null ? "Oui" : "Non"}',
        );
        return AuthResult(
          success: success,
          statusCode: response.statusCode,
          message: success ? 'Connexion réussie.' : message,
          token: token,
        );
      } catch (error) {
        // Erreur réseau → fallback local
        debugPrint('Erreur réseau, fallback local : $error');
        return await _loginLocally(identifiant, password);
      }
    } else {
      debugPrint('Hors ligne — tentative de connexion locale.');
      return await _loginLocally(identifiant, password);
    }
  }

  // ── Inscription ───────────────────────────────────────
  static Future<AuthResult> signUp(
    SignUpData userData,
    bool isConnected,
  ) async {
    debugPrint(
      'Connexion internet requise pour créer un compte. Statut: $isConnected',
    );
    debugPrint('Données d\'inscription reçues : ${userData.email}');
    // Hors ligne → bloquer immédiatement
    if (!isConnected) {
      return AuthResult(
        success: false,
        statusCode: 0,
        message: 'Connexion internet requise pour créer un compte.',
      );
    }

    final uri = Uri.parse(ApiUrls.signup);
    debugPrint('Tentative d\'inscription en ligne à: $uri');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nom': userData.nom,
          'prenom': userData.prenom,
          'poste': userData.poste,
          'telephone': userData.telephone,
          'email': userData.email,
          'annee_service': userData.anneeService,
          'password': userData.password,
          'photoUrl': userData.photoUrl,
        }),
      );

      debugPrint(
        'Réponse inscription: ${response.statusCode} — ${response.body}',
      );

      String message = 'Erreur lors de l\'inscription.';
      String? token;

      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            token = (data['token'] ?? data['access'])?.toString();
            message =
                (data['detail'] ?? data['message'] ?? data['non_field_errors'])
                    ?.toString() ??
                message;
          }
        } catch (_) {
          message = response.body;
        }
      }

      final success = response.statusCode == 200 || response.statusCode == 201;

      // Sauvegarde locale UNIQUEMENT si l'API a confirmé le succès
      if (success) {
        try {
          await DatabaseService().createUser(userData);
          debugPrint('✅ Utilisateur sauvegardé localement.');
        } catch (e) {
          debugPrint('Avertissement — sauvegarde locale: $e');
        }

        if (token != null) {
          await _saveToken(token);
        }
      }

      return AuthResult(
        success: success,
        statusCode: response.statusCode,
        message: success ? 'Inscription réussie.' : message,
        token: token,
      );
    } catch (error) {
      // Erreur réseau → on bloque, pas de fallback local
      debugPrint('Erreur réseau lors de l\'inscription: $error');
      return AuthResult(
        success: false,
        statusCode: 0,
        message: 'Impossible de joindre le serveur. Vérifiez votre connexion.',
      );
    }
  }
}
