// pages/settings_page.dart
// Page paramètres mobile — profil, modification, déconnexion
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/couleurs.dart';
import '../models/signup.dart';
import '../widgets/custom_button.dart';

class SettingsPage extends StatefulWidget {
  final SignUpData user;
  final VoidCallback? onUserUpdated;

  const SettingsPage({super.key, required this.user, this.onUserUpdated});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late SignUpData _user;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _user = widget.user;

    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Logout ────────────────────────────────────────────────────────
  void _logout() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Déconnexion'),
        content: const Text(
          'Vous allez être redirigé vers la page de connexion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  // ── Ouvrir la modale d'édition ────────────────────────────────────
  void _openEditProfile() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        user: _user,
        onSaved: (updated) {
          setState(() => _user = updated);
          widget.onUserUpdated?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.white, size: 16),
                  SizedBox(width: 10),
                  Text('Profil mis à jour'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark =
        themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverHeader(isDark),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),
                    _buildInfoCard(isDark),
                    const SizedBox(height: 16),
                    _buildActionsCard(isDark, themeProvider),
                    const SizedBox(height: 16),
                    _buildDangerCard(isDark),
                    const SizedBox(height: 16),
                    _buildAppInfoCard(isDark),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sliver header avec avatar et nom ─────────────────────────────
  Widget _buildSliverHeader(bool isDark) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      foregroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Paramètres',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeaderBackground(isDark),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  Widget _buildHeaderBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
            AppColors.medicalDarkBlue,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.white.withAlpha(60),
                        AppColors.white.withAlpha(30),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.white.withAlpha(150),
                      width: 2.5,
                    ),
                  ),
                  child: _user.photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            _user.photoUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            _initials(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                ),
                // Badge édition
                GestureDetector(
                  onTap: _openEditProfile,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withAlpha(40),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_user.prenom} ${_user.nom}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _user.poste,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.white.withAlpha(230),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials() {
    final p = _user.prenom.isNotEmpty ? _user.prenom[0].toUpperCase() : '';
    final n = _user.nom.isNotEmpty ? _user.nom[0].toUpperCase() : '';
    return '$p$n';
  }

  // ── Carte infos profil ────────────────────────────────────────────
  Widget _buildInfoCard(bool isDark) {
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(label: 'Informations personnelles', isDark: isDark),
          const SizedBox(height: 4),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Nom complet',
            value: '${_user.prenom} ${_user.nom}',
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _InfoRow(
            icon: Icons.work_outline,
            label: 'Poste / Spécialité',
            value: _user.poste,
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _user.email,
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Téléphone',
            value: _user.telephone,
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Années de service',
            value:
                '${_user.anneeService} an${int.tryParse(_user.anneeService ?? '0') == 1 ? '' : 's'}',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ── Carte actions ─────────────────────────────────────────────────
  Widget _buildActionsCard(bool isDark, ThemeProvider themeProvider) {
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(label: 'Préférences', isDark: isDark),
          const SizedBox(height: 4),
          // Modifier le profil
          _ActionRow(
            icon: Icons.edit_outlined,
            label: 'Modifier le profil',
            isDark: isDark,
            onTap: _openEditProfile,
            showArrow: true,
          ),
          _Divider(isDark: isDark),
          // Thème
          _ThemeRow(isDark: isDark, themeProvider: themeProvider),
          _Divider(isDark: isDark),
          // Notifications (placeholder)
          _ActionRow(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            value: 'Activées',
            isDark: isDark,
            onTap: () {},
            showArrow: true,
          ),
        ],
      ),
    );
  }

  // ── Carte danger ──────────────────────────────────────────────────
  Widget _buildDangerCard(bool isDark) {
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(label: 'Compte', isDark: isDark),
          const SizedBox(height: 4),
          _ActionRow(
            icon: Icons.lock_reset_outlined,
            label: 'Changer le mot de passe',
            isDark: isDark,
            onTap: () {},
            showArrow: true,
          ),
          _Divider(isDark: isDark),
          // Déconnexion
          InkWell(
            onTap: _logout,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Container(
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
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Se déconnecter',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.error.withAlpha(150),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Carte app info ────────────────────────────────────────────────
  Widget _buildAppInfoCard(bool isDark) {
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(label: 'À propos', isDark: isDark),
          const SizedBox(height: 4),
          _InfoRow(
            icon: Icons.medical_services_outlined,
            label: 'Application',
            value: 'ClinImage AI',
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _InfoRow(
            icon: Icons.tag,
            label: 'Version',
            value: '3.0.0',
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _InfoRow(
            icon: Icons.science_outlined,
            label: 'Modèle IA',
            value: 'ONNX v3',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// MODAL BOTTOM SHEET — ÉDITION PROFIL
// ════════════════════════════════════════════════════════════════
class _EditProfileSheet extends StatefulWidget {
  final SignUpData user;
  final ValueChanged<SignUpData> onSaved;

  const _EditProfileSheet({required this.user, required this.onSaved});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomCtrl;
  late TextEditingController _prenomCtrl;
  late TextEditingController _posteCtrl;
  late TextEditingController _telCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _anneeCtrl;

  final List<String> _postes = [
    'Radiologue',
    'Médecin généraliste',
    'Cardiologue',
    'Neurologue',
    'Pédiatre',
    'Gynécologue',
    'Chirurgien',
    'Infirmier',
    'Technicien en imagerie',
    'Autre',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: widget.user.nom);
    _prenomCtrl = TextEditingController(text: widget.user.prenom);
    _posteCtrl = TextEditingController(text: widget.user.poste);
    _telCtrl = TextEditingController(text: widget.user.telephone);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _anneeCtrl = TextEditingController(text: widget.user.anneeService ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _nomCtrl,
      _prenomCtrl,
      _posteCtrl,
      _telCtrl,
      _emailCtrl,
      _anneeCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      widget.onSaved(
        SignUpData(
          id: widget.user.id,
          nom: _nomCtrl.text.trim(),
          prenom: _prenomCtrl.text.trim(),
          poste: _posteCtrl.text.trim(),
          telephone: _telCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          anneeService: _anneeCtrl.text.trim(),
          photoUrl: widget.user.photoUrl,
          password: widget.user.password,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark =
        themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final sheetBg = isDark ? AppColors.darkSurface : AppColors.white;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkDivider
                  : AppColors.grey.withAlpha(80),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Modifier le profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Form
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            ctrl: _prenomCtrl,
                            label: 'Prénom',
                            icon: Icons.person_outline,
                            isDark: isDark,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            ctrl: _nomCtrl,
                            label: 'Nom',
                            icon: Icons.person_outline,
                            isDark: isDark,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Requis' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Poste dropdown
                    DropdownButtonFormField<String>(
                      value: _postes.contains(_posteCtrl.text)
                          ? _posteCtrl.text
                          : null,
                      decoration: _inputDecoration(
                        'Poste / Spécialité',
                        Icons.work_outline,
                        isDark,
                      ),
                      dropdownColor: isDark
                          ? AppColors.darkCard
                          : AppColors.white,
                      items: _postes
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                p,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _posteCtrl.text = v ?? ''),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      ctrl: _emailCtrl,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      isDark: isDark,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      ctrl: _telCtrl,
                      label: 'Téléphone',
                      icon: Icons.phone_outlined,
                      isDark: isDark,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (v.length < 8) return 'Numéro invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      ctrl: _anneeCtrl,
                      label: 'Années de service',
                      icon: Icons.calendar_today_outlined,
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (int.tryParse(v) == null) return 'Valeur invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'Enregistrer les modifications',
                        onPressed: _save,
                        isLoading: _isSaving,
                        icon: Icons.check,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
      decoration: _inputDecoration(label, icon, isDark),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: isDark ? AppColors.darkTextSecondary : AppColors.grey,
        size: 20,
      ),
      filled: true,
      fillColor: isDark ? AppColors.darkBackground : AppColors.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: TextStyle(
        color: isDark ? AppColors.darkTextSecondary : AppColors.grey,
        fontSize: 13,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// WIDGETS UTILITAIRES
// ════════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _Card({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(isDark ? 40 : 12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionTitle({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: isDark ? AppColors.darkTextSecondary : AppColors.grey,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: (isDark ? AppColors.darkDivider : AppColors.divider).withAlpha(
        120,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(isDark ? 40 : 18),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isDark;
  final VoidCallback onTap;
  final bool showArrow;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.value,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(isDark ? 40 : 18),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            if (showArrow) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: isDark ? AppColors.darkTextSecondary : AppColors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final bool isDark;
  final ThemeProvider themeProvider;

  const _ThemeRow({required this.isDark, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(isDark ? 40 : 18),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Thème',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          // Toggle 3 états
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeChip(
                  icon: Icons.light_mode,
                  active: themeProvider.themeMode == ThemeMode.light,
                  isDark: isDark,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                  tooltip: 'Clair',
                ),
                _ThemeChip(
                  icon: Icons.brightness_auto,
                  active: themeProvider.themeMode == ThemeMode.system,
                  isDark: isDark,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                  tooltip: 'Auto',
                ),
                _ThemeChip(
                  icon: Icons.dark_mode,
                  active: themeProvider.themeMode == ThemeMode.dark,
                  isDark: isDark,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                  tooltip: 'Sombre',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;
  final String tooltip;

  const _ThemeChip({
    required this.icon,
    required this.active,
    required this.isDark,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: active
                ? (isDark ? AppColors.darkCard : AppColors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.black.withAlpha(20),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 16,
            color: active
                ? AppColors.primary
                : (isDark ? AppColors.darkTextSecondary : AppColors.grey),
          ),
        ),
      ),
    );
  }
}
