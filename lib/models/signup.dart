class SignUpData {
  String id; // ID unique pour chaque utilisateur
  final String nom;
  final String prenom;
  String? photoUrl; // URL de la photo de profil
  final String poste;
  final String telephone;
  final String email;
  final String anneeService;
  final String password;

  SignUpData({
    required this.id,
    required this.nom,
    required this.prenom,
    this.photoUrl,
    required this.poste,
    required this.telephone,
    required this.email,
    required this.anneeService,
    required this.password,
  });
}
