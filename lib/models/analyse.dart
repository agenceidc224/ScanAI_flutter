// ============ MODÈLE DE RÉSULTAT D'ANALYSE ============
import 'dart:ui';

class AnalysisResult {
  final String diseaseName;
  final double confidence;
  final String description;
  final String recommendation;
  final List<String> symptoms;
  final Color color;
  final String severity; // 'low', 'moderate', 'high', 'critical'
  final String icon;

  AnalysisResult({
    required this.diseaseName,
    required this.confidence,
    required this.description,
    required this.recommendation,
    required this.symptoms,
    required this.color,
    required this.severity,
    required this.icon,
  });

  AnalysisResult copyWith({
    String? diseaseName,
    double? confidence,
    String? description,
    String? recommendation,
    List<String>? symptoms,
    Color? color,
    String? severity,
    String? icon,
  }) {
    return AnalysisResult(
      diseaseName: diseaseName ?? this.diseaseName,
      confidence: confidence ?? this.confidence,
      description: description ?? this.description,
      recommendation: recommendation ?? this.recommendation,
      symptoms: symptoms ?? this.symptoms,
      color: color ?? this.color,
      severity: severity ?? this.severity,
      icon: icon ?? this.icon,
    );
  }
}
