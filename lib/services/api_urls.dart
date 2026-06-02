class ApiUrls {
  // Base URL (modifiez selon votre environnement)
  static const String base = 'http://127.0.0.1:8000/api';

  // Endpoints
  static const String login = '$base/utilisateurs/login/';
  static const String signup = '$base/utilisateurs/';
  static const String profile = '$base/utilisateurs/profile';
  static const String uploadPhoto = '$base/utilisateurs/photo';

  // Exemple : ajoutez d'autres endpoints si nécessaire
}
