// analyse.dart
// Version mobile/desktop - 2 barres de confiance, historique avec suppression, dark/light theme
import 'dart:io';
import 'package:clinimage_ai/models/analyse.dart';
import 'package:clinimage_ai/pages/parametre_page.dart';
import 'package:clinimage_ai/providers/theme_provider.dart';
import 'package:clinimage_ai/services/onnxruntime_service.dart';
import 'package:clinimage_ai/services/sql/history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../utils/couleurs.dart';
import '../models/signup.dart';
import '../models/history_item.dart';
import '../widgets/custom_button.dart';
import '../services/network_connectivity_service.dart';

class MedicalAnalysisPage extends StatefulWidget {
  const MedicalAnalysisPage({super.key});

  @override
  State<MedicalAnalysisPage> createState() => _MedicalAnalysisPageState();
}

class _MedicalAnalysisPageState extends State<MedicalAnalysisPage>
    with TickerProviderStateMixin {
  File? _selectedImage;
  bool _isAnalyzing = false;
  AnalysisResult? _primaryResult;
  AnalysisResult? _secondaryResult;
  late bool _isModelLoaded = false;
  late SignUpData _currentUser;
  List<HistoryItem> _historyItems = [];
  bool _isHistoryExpanded = true;

  late AnimationController _historyAnimationController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _pulseController;
  late AnimationController _confidenceController1;
  late AnimationController _confidenceController2;
  late Animation<double> _confidenceAnimation1;
  late Animation<double> _confidenceAnimation2;

  final HistoryDatabaseService _historyDb = HistoryDatabaseService();
  late NetworkConnectivityService _connectivityService;
  bool _isOnline = true;

  // ── Mock results ──────────────────────────────────────────────────
  final Map<String, AnalysisResult> _mockResults = {
    'invalid': AnalysisResult(
      diseaseName: 'INVALID',
      confidence: 0.0,
      description:
          "L'analyse a échoué : format non pris en charge ou qualité insuffisante.",
      recommendation: 'Veuillez utiliser une radiographie thoracique valide.',
      symptoms: [],
      color: AppColors.error,
      severity: 'critical',
      icon: '❌',
    ),
    'autre': AnalysisResult(
      diseaseName: 'AUTRE',
      confidence: 0.0,
      description: 'Pathologie non classifiée par le modèle.',
      recommendation: 'Consultez un spécialiste pour un diagnostic précis.',
      symptoms: [],
      color: AppColors.info,
      severity: 'moderate',
      icon: '🔬',
    ),
    'tuberculosis': AnalysisResult(
      diseaseName: 'Tuberculose Pulmonaire',
      confidence: 0.0,
      description:
          'Présence de cavernes apicales bilatérales avec infiltrats nodulaires. Image typique de tuberculose pulmonaire active avec excavation.',
      recommendation:
          '• Isolement respiratoire strict\n• Traitement antituberculeux quadrithérapie (RHZE)\n• Déclaration obligatoire à l\'ARS\n• Dépistage des cas contacts',
      symptoms: [
        'Toux chronique > 3 semaines',
        'Amaigrissement',
        'Sueurs nocturnes',
        'Hémoptysie',
        'Asthénie sévère',
      ],
      color: AppColors.error,
      severity: 'critical',
      icon: '🦠',
    ),
    'covid19': AnalysisResult(
      diseaseName: 'COVID-19',
      confidence: 0.0,
      description:
          'Opacités en verre dépoli bilatérales à prédominance périphérique et basale. Signes caractéristiques d\'une infection à SARS-CoV-2.',
      recommendation:
          '• Isolement immédiat\n• Test PCR de confirmation\n• Surveillance de la saturation O2\n• Traitement symptomatique',
      symptoms: [
        'Fièvre',
        'Toux sèche',
        'Dyspnée',
        'Perte d\'odorat/goût',
        'Fatigue intense',
      ],
      color: AppColors.warning,
      severity: 'high',
      icon: '🦠',
    ),
    'pneumonia': AnalysisResult(
      diseaseName: 'Pneumonie',
      confidence: 0.0,
      description:
          'Opacités alvéolaires bilatérales prédominant aux bases pulmonaires. Signes radiologiques de pneumonie communautaire.',
      recommendation:
          '• Hospitalisation recommandée\n• Antibiothérapie IV\n• Prélèvements bactériologiques\n• Oxygénothérapie si nécessaire',
      symptoms: [
        'Toux productive',
        'Fièvre élevée',
        'Dyspnée',
        'Douleur thoracique',
        'Expectorations purulentes',
      ],
      color: AppColors.warning,
      severity: 'high',
      icon: '🫁',
    ),
    'normal': AnalysisResult(
      diseaseName: 'NORMAL',
      confidence: 0.0,
      description:
          'Radiographie thoracique normale. Champs pulmonaires clairs, silhouette cardiaque normale.',
      recommendation:
          '• Pas de traitement spécifique\n• Contrôle dans 1 an\n• Maintien des mesures préventives',
      symptoms: ['Absence de symptômes', 'Examen clinique normal'],
      color: AppColors.success,
      severity: 'low',
      icon: '✅',
    ),
  };

  // ── Lifecycle ──────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _connectivityService = NetworkConnectivityService();
    _connectivityService.init();
    _connectivityService.addListener(_onConnectivityChanged);

    _loadModel();
    initUserData(
      SignUpData(
        id: 'user_1',
        nom: 'Martin',
        prenom: 'Sophie',
        photoUrl: null,
        poste: 'Radiologue Senior',
        telephone: '01 23 45 67 89',
        email: 'sophie.martin@clinimage.com',
        anneeService: '5',
        password: 'password123',
      ),
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _confidenceController1 = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _confidenceController2 = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _confidenceAnimation1 = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(_confidenceController1);
    _confidenceAnimation2 = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(_confidenceController2);

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _historyAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _onConnectivityChanged() {
    setState(() => _isOnline = _connectivityService.isConnected);
    if (_isOnline) _syncHistoryWithServer();
  }

  Future<void> _syncHistoryWithServer() async {
    await _historyDb.syncWithServer(_currentUser.id, (item) async {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true, 'id': DateTime.now().millisecondsSinceEpoch};
    });
    await _loadHistory();
  }

  void initUserData(SignUpData userData) async {
    setState(() {
      _currentUser = userData;
      _currentUser.id = 'user_1';
    });
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await _historyDb.getHistoryItemsForUser(_currentUser.id);
    setState(() => _historyItems = items);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _confidenceController1.dispose();
    _confidenceController2.dispose();
    _historyAnimationController.dispose();
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  Future<void> _openSettings() async {
    HapticFeedback.lightImpact();
    // On pousse SettingsPage et on attend un éventuel retour
    // Si l'utilisateur a modifié son profil, onUserUpdated est appelé
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          user: _currentUser,
          onUserUpdated: () {
            // Rien ici : la mise à jour arrive via le callback ci-dessous
          },
        ),
      ),
    );
    // Recharge l'historique au retour (au cas où des suppressions auraient eu lieu)
    await _loadHistory();
  }

  // ── Actions ───────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _primaryResult = null;
        _secondaryResult = null;
      });
      _animationController.reset();
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _loadModel() async {
    try {
      await OnnxService.loadModel();
      setState(() => _isModelLoaded = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur chargement modèle: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null || !_isModelLoaded) return;
    setState(() => _isAnalyzing = true);

    try {
      final result = await OnnxService.analyzeImage(_selectedImage!);
      if (result['success']) {
        final predictions = result['predictions'] as List;
        final topPredictions = predictions.take(2).toList();
        final primaryResult = _mapPrediction(topPredictions[0]);
        final secondaryResult = topPredictions.length > 1
            ? _mapPrediction(topPredictions[1])
            : null;

        setState(() {
          _primaryResult = primaryResult;
          _secondaryResult = secondaryResult;
          _isAnalyzing = false;
          _animationController.forward();

          _confidenceAnimation1 =
              Tween<double>(begin: 0, end: primaryResult.confidence).animate(
                CurvedAnimation(
                  parent: _confidenceController1,
                  curve: Curves.easeOutCubic,
                ),
              );
          if (secondaryResult != null) {
            _confidenceAnimation2 =
                Tween<double>(
                  begin: 0,
                  end: secondaryResult.confidence,
                ).animate(
                  CurvedAnimation(
                    parent: _confidenceController2,
                    curve: Curves.easeOutCubic,
                  ),
                );
          }
          _confidenceController1.forward();
          _confidenceController2.forward();
        });

        await _historyDb.saveAnalysis(
          userId: _currentUser.id,
          imageFile: _selectedImage!,
          diseaseName: primaryResult.diseaseName,
          confidence: primaryResult.confidence,
          severity: primaryResult.severity,
          notes: secondaryResult != null
              ? 'Alt: ${secondaryResult.diseaseName} (${(secondaryResult.confidence * 100).toStringAsFixed(1)}%)'
              : null,
        );
        await _loadHistory();
        if (_isOnline) _syncHistoryWithServer();
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur analyse: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  AnalysisResult _mapPrediction(Map<String, dynamic> prediction) {
    final label = prediction['label']?.toString().toLowerCase() ?? '';
    final confidence = prediction['confidence'] as double;
    if (label.contains('tuberculosis')) {
      return _mockResults['tuberculosis']!.copyWith(confidence: confidence);
    } else if (label.contains('covid19')) {
      return _mockResults['covid19']!.copyWith(confidence: confidence);
    } else if (label.contains('pneumonia')) {
      return _mockResults['pneumonia']!.copyWith(confidence: confidence);
    } else if (label.contains('normal')) {
      return _mockResults['normal']!.copyWith(confidence: confidence);
    } else if (label.contains('invalid')) {
      return _mockResults['invalid']!.copyWith(confidence: confidence);
    } else {
      return _mockResults['autre']!.copyWith(confidence: confidence);
    }
  }

  void _resetAnalysis() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedImage = null;
      _primaryResult = null;
      _secondaryResult = null;
      _isAnalyzing = false;
    });
    _animationController.reset();
    _confidenceController1.reset();
    _confidenceController2.reset();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
              HapticFeedback.mediumImpact();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  // ── Suppression d'un item ─────────────────────────────────────────
  Future<void> _deleteHistoryItem(HistoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer cette analyse ?'),
        content: Text(
          'L\'analyse "${item.diseaseName}" sera supprimée définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _historyDb.deleteHistoryItem(item.id);
      await _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analyse supprimée'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Supprimer tout l'historique ───────────────────────────────────
  Future<void> _deleteAllHistory() async {
    if (_historyItems.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tout supprimer ?'),
        content: Text(
          'Les ${_historyItems.length} analyses seront supprimées définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Tout supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      for (final item in _historyItems) {
        await _historyDb.deleteHistoryItem(item.id);
      }
      await _loadHistory();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────
  String _getSeverityLabel(String severity) {
    switch (severity) {
      case 'critical':
        return 'URGENCE';
      case 'high':
        return 'ÉLEVÉ';
      case 'moderate':
        return 'MODÉRÉ';
      case 'low':
        return 'FAIBLE';
      default:
        return 'NORMAL';
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'moderate':
        return AppColors.info;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.success;
    }
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      default:
        return Icons.brightness_auto;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays == 1) return "Hier";
    if (diff.inDays < 7) return "Il y a ${diff.inDays} j";
    if (diff.inDays < 30) return "Il y a ${(diff.inDays / 7).floor()} sem.";
    return "${date.day}/${date.month}/${date.year}";
  }

  void _exportResults() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: AppColors.white),
            SizedBox(width: 12),
            Text('Rapport exporté avec succès'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark =
        themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(themeProvider, isDark, isDesktop),
      body: isDesktop
          ? Row(
              children: [
                _buildHistorySidebar(isDark),
                Expanded(child: _buildMainContent(isDark)),
              ],
            )
          : Column(
              children: [
                Expanded(child: _buildMainContent(isDark)),
                _buildMobileHistoryBar(isDark),
              ],
            ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    ThemeProvider themeProvider,
    bool isDark,
    bool isDesktop,
  ) {
    return AppBar(
      title: const Text('Analyse Médicale'),
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.primary,
      centerTitle: false,
      actions: [
        // Indicateur connectivité
        Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: (_isOnline ? AppColors.success : AppColors.error).withAlpha(
              30,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isOnline ? AppColors.success : AppColors.error,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isOnline ? Icons.wifi : Icons.wifi_off,
                size: 14,
                color: _isOnline ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                _isOnline ? 'En ligne' : 'Hors ligne',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _isOnline ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ),

        // Bouton thème — desktop seulement
        if (isDesktop)
          PopupMenuButton<ThemeMode>(
            icon: Icon(
              _getThemeIcon(themeProvider.themeMode),
              color: AppColors.primary,
            ),
            onSelected: (mode) {
              Provider.of<ThemeProvider>(
                context,
                listen: false,
              ).setThemeMode(mode);
              HapticFeedback.lightImpact();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    Icon(Icons.light_mode, size: 20, color: Colors.amber),
                    SizedBox(width: 12),
                    Text('Mode clair'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    Icon(Icons.dark_mode, size: 20, color: Colors.indigo),
                    SizedBox(width: 12),
                    Text('Mode sombre'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20, color: Colors.grey),
                    SizedBox(width: 12),
                    Text('Système'),
                  ],
                ),
              ),
            ],
          ),

        // Bouton paramètres → SettingsPage
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          color: AppColors.primary,
          tooltip: 'Paramètres',
          onPressed: _openSettings,
        ),

        if (_selectedImage != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetAnalysis,
            tooltip: 'Nouvelle analyse',
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // MAIN CONTENT
  // ════════════════════════════════════════════════════════════════
  Widget _buildMainContent(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).cardColor,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bannière hors-ligne
                  if (!_isOnline)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withAlpha(80),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_off, color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mode hors ligne actif',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                                Text(
                                  'Les analyses seront sauvegardées localement.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildImageUploadSection(isDark),
                  const SizedBox(height: 24),
                  if (_selectedImage != null && _isAnalyzing)
                    _buildAnalyzingSection(isDark),
                  if (_primaryResult != null)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildResultsSection(isDark),
                      ),
                    ),
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Upload section ────────────────────────────────────────────────
  Widget _buildImageUploadSection(bool isDark) {
    final cardBg = isDark ? AppColors.darkCard : AppColors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(isDark ? 40 : 20),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withAlpha(isDark ? 40 : 25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.upload_file,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Télécharger l\'image',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'JPEG, PNG • Max 25 MB',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_selectedImage == null) ...[
            Row(
              children: [
                if (Platform.isIOS || Platform.isAndroid)
                  Expanded(
                    child: _buildUploadButton(
                      icon: Icons.camera_alt,
                      label: 'Appareil photo',
                      onPressed: () => _pickImage(ImageSource.camera),
                      color: AppColors.primary,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildUploadButton(
                    icon: Icons.photo_library,
                    label: 'Galerie',
                    onPressed: () => _pickImage(ImageSource.gallery),
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ] else ...[
            Stack(
              children: [
                Hero(
                  tag: 'medical_image',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      _selectedImage!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withAlpha(30),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Image chargée',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Changer',
                    onPressed: _resetAnalysis,
                    icon: Icons.edit,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) => Transform.scale(
                      scale: _isAnalyzing
                          ? 1 + _pulseController.value * 0.04
                          : 1.0,
                      child: PrimaryButton(
                        text: _isAnalyzing ? 'Analyse...' : 'Analyser',
                        onPressed: _analyzeImage,
                        icon: Icons.analytics,
                        isLoading: _isAnalyzing,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withAlpha(80)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Analyzing indicator ───────────────────────────────────────────
  Widget _buildAnalyzingSection(bool isDark) {
    final cardBg = isDark ? AppColors.darkCard : AppColors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(isDark ? 40 : 15),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 4,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Analyse en cours',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Notre IA analyse votre image...',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStep('Prétraitement', true, isDark),
              _buildStepConnector(true),
              _buildStep('Analyse IA', true, isDark),
              _buildStepConnector(false),
              _buildStep('Diagnostic', false, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String label, bool isActive, bool isDark) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive
                ? LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  )
                : null,
            color: isActive
                ? null
                : (isDark ? AppColors.darkSurface : AppColors.lightGrey),
          ),
          child: Icon(
            isActive ? Icons.check : Icons.hourglass_empty,
            size: 18,
            color: isActive
                ? AppColors.white
                : (isDark ? AppColors.darkTextSecondary : AppColors.grey),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive
                ? AppColors.primary
                : (isDark ? AppColors.darkTextSecondary : AppColors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 36,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(colors: [AppColors.primary, AppColors.secondary])
            : null,
        color: isActive ? null : AppColors.grey.withAlpha(60),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // RESULTS
  // ════════════════════════════════════════════════════════════════
  Widget _buildResultsSection(bool isDark) {
    final primary = _primaryResult!;
    final cardBg = isDark ? AppColors.darkCard : AppColors.white;

    return Column(
      children: [
        // En-tête résultats
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          builder: (context, v, child) => Transform.translate(
            offset: Offset(0, 40 * (1 - v)),
            child: Opacity(opacity: v, child: child),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(70),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: AppColors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Résultats d\'analyse',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Diagnostic assisté par IA',
                        style: TextStyle(fontSize: 12, color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'v3.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.white.withAlpha(230),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── 2 barres de confiance ─────────────────────────────────────
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          builder: (context, v, child) => Opacity(opacity: v, child: child),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withAlpha(isDark ? 40 : 15),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.bar_chart,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Niveaux de confiance',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Les deux hypothèses diagnostiques les plus probables',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildConfidenceBar(
                  title: _primaryResult!.diseaseName,
                  subtitle: 'Diagnostic principal',
                  confidence: _primaryResult!.confidence,
                  color: _primaryResult!.color,
                  animation: _confidenceAnimation1,
                  isPrimary: true,
                  isDark: isDark,
                ),
                if (_secondaryResult != null) ...[
                  const SizedBox(height: 16),
                  _buildConfidenceBar(
                    title: _secondaryResult!.diseaseName,
                    subtitle: 'Hypothèse secondaire',
                    confidence: _secondaryResult!.confidence,
                    color: _secondaryResult!.color,
                    animation: _confidenceAnimation2,
                    isPrimary: false,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Diagnostic principal détaillé ─────────────────────────────
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          builder: (context, v, child) => Transform.translate(
            offset: Offset(0, 30 * (1 - v)),
            child: Opacity(opacity: v, child: child),
          ),
          child: _buildDiagnosisCard(primary, isPrimary: true, isDark: isDark),
        ),

        if (_secondaryResult != null) ...[
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, v, child) => Transform.translate(
              offset: Offset(0, 20 * (1 - v)),
              child: Opacity(opacity: v, child: child),
            ),
            child: _buildDiagnosisCard(
              _secondaryResult!,
              isPrimary: false,
              isDark: isDark,
            ),
          ),
        ],

        const SizedBox(height: 24),

        // ── Actions ────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: Platform.isAndroid ? 'Analyse' : 'Nouvelle analyse',
                onPressed: _resetAnalysis,
                icon: Icons.refresh,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                text: Platform.isAndroid ? 'Exp. PDF' : 'Export PDF',
                onPressed: _exportResults,
                icon: Icons.picture_as_pdf,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Barre de confiance ────────────────────────────────────────────
  Widget _buildConfidenceBar({
    required String title,
    required String subtitle,
    required double confidence,
    required Color color,
    required Animation<double> animation,
    required bool isPrimary,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: isPrimary ? 10 : 8,
              height: isPrimary ? 10 : 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isPrimary ? 14 : 13,
                      fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) => Text(
                '${(animation.value * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) => ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: animation.value,
              backgroundColor: color.withAlpha(isDark ? 50 : 30),
              color: color,
              minHeight: isPrimary ? 10 : 7,
            ),
          ),
        ),
      ],
    );
  }

  // ── Carte de diagnostic ───────────────────────────────────────────
  Widget _buildDiagnosisCard(
    AnalysisResult result, {
    required bool isPrimary,
    required bool isDark,
  }) {
    final cardBg = isDark ? AppColors.darkCard : AppColors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isPrimary
              ? result.color.withAlpha(100)
              : (isDark ? AppColors.darkDivider : AppColors.divider),
          width: isPrimary ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? result.color.withAlpha(40)
                : AppColors.black.withAlpha(isDark ? 40 : 12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: result.color.withAlpha(isDark ? 30 : 15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [result.color, result.color.withAlpha(200)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: result.color.withAlpha(70),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    result.icon,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(
                                result.severity,
                              ).withAlpha(35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _getSeverityLabel(result.severity),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _getSeverityColor(result.severity),
                              ),
                            ),
                          ),
                          if (isPrimary) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: result.color.withAlpha(isDark ? 60 : 35),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 10,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Principal',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.diseaseName,
                        style: TextStyle(
                          fontSize: isPrimary ? 20 : 17,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Confiance: ${(result.confidence * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: result.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBlock(
                  icon: Icons.description,
                  title: 'Description clinique',
                  content: result.description,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  isDark: isDark,
                ),
                if (result.symptoms.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildSymptomsBlock(result.symptoms, isDark),
                ],
                const SizedBox(height: 12),
                _buildInfoBlock(
                  icon: Icons.medical_services,
                  title: 'Recommandations',
                  content: result.recommendation,
                  color: result.color,
                  isList: true,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required bool isDark,
    bool isList = false,
  }) {
    final blockBg = isDark ? AppColors.darkSurface : AppColors.lightGrey;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: blockBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isList)
            ...content
                .split('\n')
                .where((l) => l.trim().isNotEmpty)
                .map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•', style: TextStyle(color: color, fontSize: 11)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            line.replaceFirst('•', '').trim(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
          else
            Text(
              content,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSymptomsBlock(List<String> symptoms, bool isDark) {
    final blockBg = isDark ? AppColors.darkSurface : AppColors.lightGrey;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: blockBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_hospital,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Symptômes observés',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: symptoms
                .map(
                  (s) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.grey.withAlpha(50),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.fiber_manual_record,
                          size: 5,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          s,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // HISTORIQUE DESKTOP SIDEBAR
  // ════════════════════════════════════════════════════════════════
  Widget _buildHistorySidebar(bool isDark) {
    final bg = isDark ? AppColors.darkSurface : AppColors.white;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;
    final unsyncedCount = _historyItems
        .where((i) => !(i.synced ?? false))
        .length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isHistoryExpanded ? 300 : 76,
      decoration: BoxDecoration(
        color: bg,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(isDark ? 60 : 20),
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header sidebar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: _isHistoryExpanded
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (_isHistoryExpanded)
                  Row(
                    children: [
                      Text(
                        'Historique',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (unsyncedCount > 0) ...[
                        const SizedBox(width: 8),
                        _buildBadge('$unsyncedCount', AppColors.warning),
                      ],
                    ],
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isHistoryExpanded && _historyItems.isNotEmpty)
                      Tooltip(
                        message: 'Tout supprimer',
                        child: InkWell(
                          onTap: _deleteAllHistory,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.delete_sweep,
                              size: 18,
                              color: AppColors.error.withAlpha(180),
                            ),
                          ),
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        _isHistoryExpanded
                            ? Icons.chevron_left
                            : Icons.chevron_right,
                        color: AppColors.primary,
                      ),
                      onPressed: () => setState(
                        () => _isHistoryExpanded = !_isHistoryExpanded,
                      ),
                      tooltip: _isHistoryExpanded ? 'Réduire' : 'Étendre',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste historique
          Expanded(
            child: _isHistoryExpanded
                ? (_historyItems.isEmpty
                      ? _buildEmptyHistory(isDark)
                      : ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: _historyItems.length,
                          itemBuilder: (context, i) =>
                              _buildHistoryTile(_historyItems[i], isDark),
                        ))
                : _buildCollapsedHistory(isDark),
          ),

          // Section utilisateur
          _buildUserSection(isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            size: 40,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.grey.withAlpha(120),
          ),
          const SizedBox(height: 10),
          Text(
            'Aucune analyse',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Historique réduit (icônes) ────────────────────────────────────
  Widget _buildCollapsedHistory(bool isDark) {
    if (_historyItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Icon(
          Icons.history,
          size: 28,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.grey.withAlpha(120),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _historyItems.length,
      itemBuilder: (context, i) {
        final item = _historyItems[i];
        final color = _getSeverityColor(item.severity);

        return Tooltip(
          message:
              '${item.diseaseName} — ${(item.confidence * 100).toStringAsFixed(0)}%\n${_formatDate(item.date)}',
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                InkWell(
                  onTap: () => _showHistoryDetail(item),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withAlpha(isDark ? 40 : 20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withAlpha(80),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(Icons.analytics, size: 22, color: color),
                  ),
                ),
                if (!(item.synced ?? false))
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Tuile historique étendu ────────────────────────────────────────
  Widget _buildHistoryTile(HistoryItem item, bool isDark) {
    final color = _getSeverityColor(item.severity);
    final tileBg = isDark ? AppColors.darkBackground : AppColors.lightGrey;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(30),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: AppColors.error, size: 20),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text('Supprimer ?'),
            content: Text('Supprimer l\'analyse "${item.diseaseName}" ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        await _historyDb.deleteHistoryItem(item.id);
        await _loadHistory();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          onTap: () => _showHistoryDetail(item),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withAlpha(isDark ? 40 : 20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.analytics, size: 18, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.diseaseName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!(item.synced ?? false))
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.sync_problem,
                                size: 12,
                                color: AppColors.warning,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            _formatDate(item.date),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(item.confidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bouton suppression explicite
                InkWell(
                  onTap: () => _deleteHistoryItem(item),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHistoryDetail(HistoryItem item) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.diseaseName} — ${_formatDate(item.date)}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Section utilisateur ───────────────────────────────────────────
  Widget _buildUserSection(bool isDark) {
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;

    return Container(
      padding: EdgeInsets.all(_isHistoryExpanded ? 14 : 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: dividerColor)),
      ),
      child: _isHistoryExpanded
          ? Column(
              children: [
                Row(
                  children: [
                    _buildAvatar(size: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_currentUser.prenom} ${_currentUser.nom}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _currentUser.poste,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FutureBuilder<Map<String, dynamic>>(
                  future: _historyDb.getStatsForUser(_currentUser.id),
                  builder: (context, snap) {
                    final stats =
                        snap.data ?? {'total': 0, 'synced': 0, 'pending': 0};
                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatChip(
                            '${stats['total']}',
                            'Analyses',
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatChip(
                            '${stats['pending']}',
                            'En attente',
                            isDark,
                            isWarning: (stats['pending'] as int) > 0,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _logout,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.error,
                          AppColors.error.withAlpha(200),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: AppColors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Déconnexion',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _buildAvatar(size: 34),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _logout,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.logout,
                      size: 18,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAvatar({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Icon(Icons.person, color: AppColors.white, size: size * 0.55),
      ),
    );
  }

  Widget _buildStatChip(
    String value,
    String label,
    bool isDark, {
    bool isWarning = false,
  }) {
    final chipBg = isDark ? AppColors.darkBackground : AppColors.lightGrey;
    final valueColor = isWarning ? AppColors.warning : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // MOBILE HISTORY BAR
  // ════════════════════════════════════════════════════════════════
  Widget _buildMobileHistoryBar(bool isDark) {
    final bg = isDark ? AppColors.darkSurface : AppColors.white;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;
    final unsyncedCount = _historyItems
        .where((i) => !(i.synced ?? false))
        .length;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: dividerColor)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(isDark ? 50 : 15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          GestureDetector(
            onTap: () =>
                setState(() => _isHistoryExpanded = !_isHistoryExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.grey.withAlpha(80),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Historique récent',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (unsyncedCount > 0) ...[
                        const SizedBox(width: 8),
                        _buildBadge('$unsyncedCount', AppColors.warning),
                      ],
                      const SizedBox(width: 8),
                      Icon(
                        _isHistoryExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      if (_historyItems.isNotEmpty) ...[
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: InkWell(
                            onTap: _deleteAllHistory,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.delete_sweep,
                                size: 16,
                                color: AppColors.error.withAlpha(180),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Liste horizontale
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isHistoryExpanded
                ? SizedBox(
                    height: 98,
                    child: _historyItems.isEmpty
                        ? Center(
                            child: Text(
                              'Aucune analyse pour le moment',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            itemCount: _historyItems.length > 8
                                ? 8
                                : _historyItems.length,
                            itemBuilder: (context, i) =>
                                _buildMobileHistoryChip(
                                  _historyItems[i],
                                  isDark,
                                ),
                          ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHistoryChip(HistoryItem item, bool isDark) {
    final color = _getSeverityColor(item.severity);
    final chipBg = isDark ? AppColors.darkBackground : AppColors.lightGrey;

    return GestureDetector(
      onTap: () => _showHistoryDetail(item),
      onLongPress: () => _deleteHistoryItem(item),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.diseaseName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!(item.synced ?? false))
                  Icon(Icons.sync_problem, size: 10, color: AppColors.warning),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              '${(item.confidence * 100).toStringAsFixed(0)}% de confiance',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            Text(
              _formatDate(item.date),
              style: TextStyle(
                fontSize: 9,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
