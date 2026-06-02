// Modèle historique
class HistoryItem {
  final String id;
  final String userId;
  final String imageUrl;
  final String diseaseName;
  final double confidence;
  final DateTime date; // Ajout du champ de sévérité
  final String severity;
  final String? notes;
  final bool? synced; // Indique si l'item est synchronisé avec le serveur
  String serverId; // ID côté serveur (null si pas encore synchronisé)

  HistoryItem({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.diseaseName,
    required this.confidence,
    required this.date,
    required this.severity,
    this.notes,
    this.synced,
    this.serverId = '',
  });
}
