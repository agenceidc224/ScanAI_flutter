import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';

class OnnxService {
  // ─────────────────────────────────────────────
  // État interne statique
  // ─────────────────────────────────────────────
  static OrtSession? _session;
  static List<String>? _labels;

  // ⚠️ Doit correspondre à l'input_size de votre modèle
  // Vérifiez dans le script Python : img_size = model.input_shape[1]
  static const int inputSize = 300; // EfficientNetB3 = 300
  static const int inputChannels = 3;

  static bool get isLoaded => _session != null;

  // ─────────────────────────────────────────────
  // Charger le modèle
  // ─────────────────────────────────────────────
  static Future<void> loadModel() async {
    try {
      // Initialiser l'environnement OnnxRuntime
      OrtEnv.instance.init();

      // Charger le fichier .onnx depuis les assets
      final modelBytes = await rootBundle.load('assets/model/model.onnx');
      final modelData = modelBytes.buffer.asUint8List();

      // Créer la session
      final sessionOptions = OrtSessionOptions();
      _session = OrtSession.fromBuffer(modelData, sessionOptions);

      // Charger les labels
      try {
        final labelsRaw = await rootBundle.loadString('assets/model/label.txt');
        _labels = labelsRaw.split('\n').where((l) => l.isNotEmpty).toList();
        print('✅ Labels chargés: $_labels');
      } catch (e) {
        print('⚠️ Aucun fichier labels trouvé: $e');
        _labels = [];
      }

      // Afficher les infos du modèle
      final inputNames = _session!.inputNames;
      final outputNames = _session!.outputNames;
      print('✅ Modèle ONNX chargé avec succès');
      print('   Inputs  : $inputNames');
      print('   Outputs : $outputNames');
    } catch (e) {
      print('❌ Erreur chargement modèle: $e');
      throw Exception('Impossible de charger le modèle: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Prétraitement de l'image
  // ─────────────────────────────────────────────
  static Future<img.Image> _preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Impossible de décoder l\'image');
    }

    image = img.copyResize(image, width: inputSize, height: inputSize);
    return image;
  }

  // ─────────────────────────────────────────────
  // Image → Float32List normalisé [0, 1]
  // ─────────────────────────────────────────────
  static Float32List _imageToFloat32List(img.Image image) {
    final buffer = Float32List(inputSize * inputSize * inputChannels);
    int idx = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        buffer[idx++] = pixel.r / 255.0; // R
        buffer[idx++] = pixel.g / 255.0; // G
        buffer[idx++] = pixel.b / 255.0; // B
      }
    }

    return buffer;
  }

  // ─────────────────────────────────────────────
  // Softmax (si le modèle retourne des logits bruts)
  // ─────────────────────────────────────────────
  static Float32List _softmax(Float32List logits) {
    final maxVal = logits.reduce((a, b) => a > b ? a : b);
    double sum = 0.0;
    final expValues = Float32List(logits.length);

    for (int i = 0; i < logits.length; i++) {
      expValues[i] = math.exp(logits[i] - maxVal);
      sum += expValues[i];
    }

    return Float32List.fromList(expValues.map((v) => v / sum).toList());
  }

  // ─────────────────────────────────────────────
  // Analyse principale
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    if (_session == null) {
      throw Exception('Modèle non chargé. Appelez loadModel() d\'abord.');
    }

    try {
      // 1. Prétraitement
      final image = await _preprocessImage(imageFile);
      final inputFlat = _imageToFloat32List(image);

      // 2. Créer le tensor d'entrée ONNX shape [1, H, W, C]
      final inputTensor = OrtValueTensor.createTensorWithDataList(inputFlat, [
        1,
        inputSize,
        inputSize,
        inputChannels,
      ]);

      // 3. Préparer les inputs (nom récupéré depuis le modèle)
      final inputName = _session!.inputNames.first;
      final inputs = {inputName: inputTensor};

      // 4. Inférence
      final outputs = await _session!.runAsync(OrtRunOptions(), inputs);

      // 5. Libérer le tensor d'entrée
      inputTensor.release();

      // 6. Récupérer les scores
      final outputData = outputs?.first?.value;
      if (outputData == null) {
        throw Exception('Pas de sortie du modèle');
      }

      // outputData est List<List<double>> shape [1, numClasses]
      final rawScores = (outputData as List).first as List;
      Float32List scores = Float32List.fromList(
        rawScores.map((v) => (v as double).toDouble()).toList(),
      );

      // 7. Libérer les outputs
      outputs?.forEach((o) => o?.release());

      // 8. Softmax si nécessaire (logits bruts)
      final sum = scores.fold<double>(0.0, (acc, v) => acc + v);
      if ((sum - 1.0).abs() > 0.05) {
        print('⚠️ Logits détectés (somme=$sum) → softmax appliqué');
        scores = _softmax(scores);
      }

      // 9. Résultats triés
      final numClasses = scores.length;
      final results = List<Map<String, dynamic>>.generate(numClasses, (i) {
        return {
          'index': i,
          'label': (_labels != null && i < _labels!.length)
              ? _labels![i]
              : 'Classe $i',
          'confidence': scores[i],
        };
      });

      results.sort(
        (a, b) =>
            (b['confidence'] as double).compareTo(a['confidence'] as double),
      );

      return {
        'success': true,
        'predictions': results,
        'topPrediction': results.isNotEmpty ? results.first : null,
      };
    } catch (e) {
      print('❌ Erreur analyse: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ─────────────────────────────────────────────
  // Libérer les ressources
  // ─────────────────────────────────────────────
  static void close() {
    _session?.release();
    _session = null;
    OrtEnv.instance.release();
    print('🔒 Session ONNX libérée.');
  }
}
