// lib/features/auth/presentation/screens/school_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:edu_auth_31/features/auth/data/models/verification_models.dart';
import 'package:edu_auth_31/features/auth/presentation/widgets/trust_indicator_widget.dart';

// =============================================================================
// THEME CONSTANTS — Dark Blue / Grey palette
// =============================================================================

class _AppColors {
  _AppColors._();

  static const Color background = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFF1A2A3A);
  static const Color card = Color(0xFF1E3048);
  static const Color accent = Color(0xFF2979FF);
  static const Color accentLight = Color(0xFF448AFF);
  static const Color verified = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color textPrimary = Color(0xFFE8EDF2);
  static const Color textSecondary = Color(0xFF8EAABF);
  static const Color border = Color(0xFF2A3F55);
  static const Color inputFill = Color(0xFF152232);
}

// =============================================================================
// STUB: AppLocalizations — replace with your real gen file
// All strings are Arabic RTL strings matching app_ar.dart keys.
// =============================================================================

class _L {
  _L._();

  static const String appTitle = 'منصة التحقق التعليمية';
  static const String screenTitle = 'التحقق من المدرسة';
  static const String schoolNameLabel = 'اسم المدرسة';
  static const String schoolNameHint = 'مدرسة الرواد الدولية';
  static const String schoolNameRequired = 'يرجى إدخال اسم المدرسة';
  static const String officialEmailLabel = 'البريد الإلكتروني الرسمي';
  static const String officialEmailHint = 'info@school.edu.sa';
  static const String officialEmailRequired = 'يرجى إدخال البريد الإلكتروني';
  static const String officialEmailInvalid = 'صيغة البريد الإلكتروني غير صحيحة';
  static const String verifiedDomain = 'نطاق موثّق ✓';
  static const String websiteLabel = 'الموقع الرسمي (اختياري)';
  static const String websiteHint = 'https://school.edu.sa';
  static const String countryLabel = 'الدولة';
  static const String cityLabel = 'المدينة';
  static const String adminProofTitle = 'إثبات صلاحية المشرف';
  static const String adminProofSubtitle = 'ارفع خطاباً رسمياً أو بطاقة هوية المدرسة';
  static const String uploadDocBtn = 'رفع وثيقة رسمية';
  static const String docUploaded = 'تم رفع الوثيقة';
  static const String verifySchoolBtn = 'التحقق من المدرسة';
  static const String joinAsAdminBtn = 'الانضمام كمشرف';
  static const String trustMeterTitle = 'مؤشر الثقة';
  static const String fillFieldsFirst = 'يرجى ملء جميع الحقول المطلوبة أولاً';
  static const String verificationSent = 'تم إرسال طلب التحقق بنجاح';
  static const String adminJoinSent = 'تم إرسال طلب الانضمام كمشرف';
  static const String country = 'المملكة العربية السعودية';
  static const String city = 'الرياض';
  static const String step = 'الخطوة';
  static const String of = 'من';
  static const String backToHome = 'الرجوع للرئيسية';
}

// =============================================================================
// SchoolVerificationScreen
// =============================================================================

class SchoolVerificationScreen extends StatefulWidget {
  const SchoolVerificationScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const SchoolVerificationScreen(),
    );
  }

  @override
  State<SchoolVerificationScreen> createState() =>
      _SchoolVerificationScreenState();
}

class _SchoolVerificationScreenState extends State<SchoolVerificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _schoolNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _websiteCtrl = TextEditingController();

  bool _isVerifiedDomain = false;
  bool _docUploaded = false;
  bool _isLoading = false;
  double _trustScore = 0.2;
  String _selectedCountry = _L.country;
  String _selectedCity = _L.city;

  // ── lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onEmailChanged);
    _schoolNameCtrl.addListener(_recalcTrustScore);
  }

  @override
  void dispose() {
    _emailCtrl
      ..removeListener(_onEmailChanged)
      ..dispose();
    _schoolNameCtrl
      ..removeListener(_recalcTrustScore)
      ..dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  // ── logic ───────────────────────────────────────────────────────────────────

  void _onEmailChanged() {
    final String email = _emailCtrl.text.toLowerCase();
    final bool dominated =
        email.endsWith('.edu') ||
        email.endsWith('.edu.sa') ||
        email.endsWith('.sch.uk') ||
        email.endsWith('.sch.ae') ||
        email.contains('.edu.') ||
        email.contains('.sch.');

    if (dominated != _isVerifiedDomain) {
      setState(() => _isVerifiedDomain = dominated);
    }
    _recalcTrustScore();
  }

  void _recalcTrustScore() {
    double score = 0.1;
    if (_schoolNameCtrl.text.trim().length > 3) score += 0.2;
    if (_isVerifiedDomain) score += 0.35;
    if (_emailCtrl.text.contains('@')) score += 0.1;
    if (_docUploaded) score += 0.25;
    if (_websiteCtrl.text.startsWith('http')) score += 0.1;
    setState(() => _trustScore = score.clamp(0.0, 1.0));
  }

  void _handleDocUpload() {
    // Simulate file picker — replace with real file_picker in production.
    setState(() {
      _docUploaded = true;
      _recalcTrustScore();
    });
  }

  Future<void> _handleVerifySchool() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate async verification call
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(_L.verificationSent),
        backgroundColor: _AppColors.verified,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Navigate to AdminVerificationScreen
    Navigator.of(context).push(AdminVerificationScreen.route(
      schoolModel: SchoolModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _schoolNameCtrl.text.trim(),
        country: _selectedCountry,
        city: _selectedCity,
        officialEmail: _emailCtrl.text.trim(),
        website: _websiteCtrl.text.trim(),
        trustStatus: _trustScore > 0.8
            ? TrustStatus.verified
            : _trustScore >= 0.5
                ? TrustStatus.partial
                : TrustStatus.unverified,
        trustScore: _trustScore,
      ),
    ));
  }

  void _handleJoinAsAdmin() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(_L.adminJoinSent),
        backgroundColor: _AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.of(context).push(AdminVerificationScreen.route(
      schoolModel: SchoolModel.empty().copyWith(
        name: _schoolNameCtrl.text.trim(),
        officialEmail: _emailCtrl.text.trim(),
      ),
    ));
  }

  // ── build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Theme(
        data: _buildTheme(context),
        child: Scaffold(
          backgroundColor: _AppColors.background,
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Trust meter
                    TrustIndicatorWidget(
                      trustScore: _trustScore,
                      schoolName: _schoolNameCtrl.text.trim(),
                    ),

                    const SizedBox(height: 24),

                    // School info card
                    _SectionCard(
                      title: 'بيانات المدرسة',
                      icon: Icons.school_rounded,
                      child: Column(
                        children: <Widget>[
                          _AppTextField(
                            controller: _schoolNameCtrl,
                            label: _L.schoolNameLabel,
                            hint: _L.schoolNameHint,
                            icon: Icons.business_rounded,
                            validator: (String? v) =>
                                (v == null || v.trim().isEmpty)
                                    ? _L.schoolNameRequired
                                    : null,
                          ),
                          const SizedBox(height: 14),
                          _AppTextField(
                            controller: _emailCtrl,
                            label: _L.officialEmailLabel,
                            hint: _L.officialEmailHint,
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            suffix: _isVerifiedDomain
                                ? _VerifiedDomainBadge()
                                : null,
                            validator: (String? v) {
                              if (v == null || v.trim().isEmpty) {
                                return _L.officialEmailRequired;
                              }
                              if (!v.contains('@') || !v.contains('.')) {
                                return _L.officialEmailInvalid;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _AppTextField(
                            controller: _websiteCtrl,
                            label: _L.websiteLabel,
                            hint: _L.websiteHint,
                            icon: Icons.language_rounded,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _DropdownField(
                                  label: _L.countryLabel,
                                  value: _selectedCountry,
                                  items: const <String>[
                                    'المملكة العربية السعودية',
                                    'الإمارات',
                                    'مصر',
                                    'الكويت',
                                    'قطر',
                                    'البحرين',
                                    'الأردن',
                                  ],
                                  onChanged: (String? v) {
                                    if (v != null) {
                                      setState(() => _selectedCountry = v);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DropdownField(
                                  label: _L.cityLabel,
                                  value: _selectedCity,
                                  items: const <String>[
                                    'الرياض',
                                    'جدة',
                                    'مكة',
                                    'المدينة',
                                    'الدمام',
                                    'أبوظبي',
                                    'دبي',
                                    'القاهرة',
                                  ],
                                  onChanged: (String? v) {
                                    if (v != null) {
                                      setState(() => _selectedCity = v);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Admin proof card
                    _SectionCard(
                      title: _L.adminProofTitle,
                      icon: Icons.verified_user_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _L.adminProofSubtitle,
                            style: const TextStyle(
                              color: _AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _DocUploadButton(
                            uploaded: _docUploaded,
                            onTap: _handleDocUpload,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Verify School button
                    _PrimaryButton(
                      label: _L.verifySchoolBtn,
                      icon: Icons.verified_rounded,
                      color: _AppColors.accent,
                      isLoading: _isLoading,
                      onPressed: _handleVerifySchool,
                    ),

                    const SizedBox(height: 12),

                    // Join as Admin button
                    _SecondaryButton(
                      label: _L.joinAsAdminBtn,
                      icon: Icons.admin_panel_settings_rounded,
                      onPressed: _handleJoinAsAdmin,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _AppColors.surface,
      elevation: 0,
      centerTitle: true,
      title: Column(
        children: <Widget>[
          Text(
            _L.screenTitle,
            style: const TextStyle(
              color: _AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${_L.step} 1 ${_L.of} 3',
            style: const TextStyle(
              color: _AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: _AppColors.textPrimary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: _StepProgressBar(step: 1, totalSteps: 3),
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: _AppColors.background,
      cardColor: _AppColors.card,
      colorScheme: const ColorScheme.dark(
        primary: _AppColors.accent,
        surface: _AppColors.surface,
        onSurface: _AppColors.textPrimary,
        error: _AppColors.error,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.error),
        ),
        labelStyle: const TextStyle(color: _AppColors.textSecondary),
        hintStyle:
            TextStyle(color: _AppColors.textSecondary.withOpacity(0.5)),
      ),
    );
  }
}

// =============================================================================
// AdminVerificationScreen
// =============================================================================

class AdminVerificationScreen extends StatefulWidget {
  const AdminVerificationScreen({super.key, required this.schoolModel});

  final SchoolModel schoolModel;

  static Route<void> route({required SchoolModel schoolModel}) {
    return MaterialPageRoute<void>(
      builder: (_) => AdminVerificationScreen(schoolModel: schoolModel),
    );
  }

  @override
  State<AdminVerificationScreen> createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _adminEmailCtrl = TextEditingController();
  final TextEditingController _adminIdCtrl = TextEditingController();

  bool _docUploaded = false;
  bool _isEmailDomainMatch = false;
  bool _isLoading = false;
  AdminStatus _adminStatus = AdminStatus.pending;

  @override
  void initState() {
    super.initState();
    _adminEmailCtrl.addListener(_checkDomainMatch);
  }

  @override
  void dispose() {
    _adminEmailCtrl
      ..removeListener(_checkDomainMatch)
      ..dispose();
    _adminIdCtrl.dispose();
    super.dispose();
  }

  void _checkDomainMatch() {
    final String schoolDomain = _extractDomain(widget.schoolModel.officialEmail);
    final String adminDomain = _extractDomain(_adminEmailCtrl.text);
    final bool match =
        schoolDomain.isNotEmpty && adminDomain == schoolDomain;
    if (match != _isEmailDomainMatch) {
      setState(() => _isEmailDomainMatch = match);
    }
  }

  String _extractDomain(String email) {
    final int atIndex = email.indexOf('@');
    if (atIndex < 0) return '';
    return email.substring(atIndex + 1).toLowerCase().trim();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _adminStatus = AdminStatus.pending;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم إرسال طلب تحقق المشرف بنجاح'),
        backgroundColor: _AppColors.verified,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Navigate to UserVerificationScreen
    Navigator.of(context).push(UserVerificationScreen.route(
      adminModel: AdminModel(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        schoolId: widget.schoolModel.id,
        verificationDocUrl: _docUploaded ? 'uploaded' : '',
        adminStatus: _adminStatus,
        isEmailDomainMatch: _isEmailDomainMatch,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Theme(
        data: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: _AppColors.background,
          cardColor: _AppColors.card,
          colorScheme: const ColorScheme.dark(
            primary: _AppColors.accent,
            surface: _AppColors.surface,
            onSurface: _AppColors.textPrimary,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: _AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: _AppColors.accent, width: 1.5),
            ),
            labelStyle: const TextStyle(color: _AppColors.textSecondary),
          ),
        ),
        child: Scaffold(
          backgroundColor: _AppColors.background,
          appBar: AppBar(
            backgroundColor: _AppColors.surface,
            elevation: 0,
            centerTitle: true,
            title: Column(
              children: const <Widget>[
                Text(
                  'التحقق من المشرف',
                  style: TextStyle(
                    color: _AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'الخطوة 2 من 3',
                  style: TextStyle(
                      color: _AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: _StepProgressBar(step: 2, totalSteps: 3),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // School info summary
                    _SchoolSummaryCard(schoolModel: widget.schoolModel),

                    const SizedBox(height: 20),

                    // Admin info
                    _SectionCard(
                      title: 'بيانات المشرف',
                      icon: Icons.admin_panel_settings_rounded,
                      child: Column(
                        children: <Widget>[
                          _AppTextField(
                            controller: _adminEmailCtrl,
                            label: 'البريد الإلكتروني للمشرف',
                            hint: 'admin@school.edu.sa',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            suffix: _isEmailDomainMatch
                                ? _VerifiedDomainBadge()
                                : null,
                            validator: (String? v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'يرجى إدخال البريد الإلكتروني'
                                    : null,
                          ),
                          const SizedBox(height: 14),
                          _AppTextField(
                            controller: _adminIdCtrl,
                            label: 'رقم الهوية الوظيفية',
                            hint: 'EMP-2024-001',
                            icon: Icons.badge_rounded,
                            validator: (String? v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'يرجى إدخال رقم الهوية الوظيفية'
                                    : null,
                          ),
                          const SizedBox(height: 14),
                          _DocUploadButton(
                            uploaded: _docUploaded,
                            onTap: () =>
                                setState(() => _docUploaded = true),
                            label: 'رفع هوية المشرف / التفويض الرسمي',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    _PrimaryButton(
                      label: 'إرسال طلب التحقق',
                      icon: Icons.send_rounded,
                      color: _AppColors.accent,
                      isLoading: _isLoading,
                      onPressed: _handleSubmit,
                    ),

                    const SizedBox(height: 12),

                    _SecondaryButton(
                      label: 'رجوع',
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// UserVerificationScreen
// =============================================================================

class UserVerificationScreen extends StatefulWidget {
  const UserVerificationScreen({super.key, required this.adminModel});

  final AdminModel adminModel;

  static Route<void> route({required AdminModel adminModel}) {
    return MaterialPageRoute<void>(
      builder: (_) => UserVerificationScreen(adminModel: adminModel),
    );
  }

  @override
  State<UserVerificationScreen> createState() =>
      _UserVerificationScreenState();
}

class _UserVerificationScreenState extends State<UserVerificationScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _nationalIdCtrl = TextEditingController();
  bool _isLoading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nationalIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_nameCtrl.text.trim().isEmpty || _nationalIdCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى ملء جميع الحقول'),
          backgroundColor: _AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Theme(
        data: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: _AppColors.background,
          cardColor: _AppColors.card,
          colorScheme: const ColorScheme.dark(
            primary: _AppColors.accent,
            surface: _AppColors.surface,
            onSurface: _AppColors.textPrimary,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: _AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: _AppColors.accent, width: 1.5),
            ),
            labelStyle: const TextStyle(color: _AppColors.textSecondary),
          ),
        ),
        child: Scaffold(
          backgroundColor: _AppColors.background,
          appBar: AppBar(
            backgroundColor: _AppColors.surface,
            elevation: 0,
            centerTitle: true,
            title: Column(
              children: const <Widget>[
                Text(
                  'التحقق من المستخدم',
                  style: TextStyle(
                    color: _AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'الخطوة 3 من 3',
                  style: TextStyle(
                      color: _AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: _StepProgressBar(step: 3, totalSteps: 3),
            ),
          ),
          body: SafeArea(
            child: _submitted
                ? _buildSuccessState(context)
                : _buildFormState(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _AppColors.verified.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: _AppColors.verified.withOpacity(0.35), width: 2),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: _AppColors.verified,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'تم إرسال طلبك بنجاح!',
              style: TextStyle(
                color: _AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'سيتم مراجعة بياناتك وإرسال إشعار خلال 24 ساعة',
              style: TextStyle(color: _AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            _PrimaryButton(
              label: _L.backToHome,
              icon: Icons.home_rounded,
              color: _AppColors.accent,
              onPressed: () {
                // Pop all routes back to root
                Navigator.of(context)
                    .popUntil((Route<dynamic> route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SectionCard(
            title: 'بيانات المستخدم',
            icon: Icons.person_rounded,
            child: Column(
              children: <Widget>[
                _AppTextField(
                  controller: _nameCtrl,
                  label: 'الاسم الكامل',
                  hint: 'محمد عبد الله',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                _AppTextField(
                  controller: _nationalIdCtrl,
                  label: 'رقم الهوية الوطنية / الإقامة',
                  hint: '1234567890',
                  icon: Icons.credit_card_rounded,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Admin status info
          _AdminStatusCard(adminModel: widget.adminModel),

          const SizedBox(height: 28),

          _PrimaryButton(
            label: 'إتمام التسجيل',
            icon: Icons.done_all_rounded,
            color: _AppColors.verified,
            isLoading: _isLoading,
            onPressed: _handleSubmit,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// =============================================================================
// SHARED PRIVATE WIDGETS
// =============================================================================

// ── _SectionCard ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.border),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: _AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: _AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── _AppTextField ─────────────────────────────────────────────────────────────

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: _AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _AppColors.textSecondary, size: 20),
        suffixIcon: suffix,
      ),
    );
  }
}

// ── _DropdownField ────────────────────────────────────────────────────────────

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final String safeValue = items.contains(value) ? value : items.first;
    return DropdownButtonFormField<String>(
      value: safeValue,
      onChanged: onChanged,
      dropdownColor: _AppColors.card,
      style: const TextStyle(color: _AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (String item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
    );
  }
}

// ── _VerifiedDomainBadge ──────────────────────────────────────────────────────

class _VerifiedDomainBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _AppColors.verified.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: _AppColors.verified.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(Icons.verified_rounded,
                color: _AppColors.verified, size: 12),
            SizedBox(width: 4),
            Text(
              _L.verifiedDomain,
              style: TextStyle(
                color: _AppColors.verified,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _DocUploadButton ──────────────────────────────────────────────────────────

class _DocUploadButton extends StatelessWidget {
  const _DocUploadButton({
    required this.uploaded,
    required this.onTap,
    this.label,
  });

  final bool uploaded;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: uploaded ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: uploaded
              ? _AppColors.verified.withOpacity(0.08)
              : _AppColors.accent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: uploaded
                ? _AppColors.verified.withOpacity(0.4)
                : _AppColors.accent.withOpacity(0.3),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              uploaded
                  ? Icons.check_circle_rounded
                  : Icons.upload_file_rounded,
              color: uploaded ? _AppColors.verified : _AppColors.accent,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              uploaded
                  ? _L.docUploaded
                  : (label ?? _L.uploadDocBtn),
              style: TextStyle(
                color:
                    uploaded ? _AppColors.verified : _AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _PrimaryButton ────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── _SecondaryButton ──────────────────────────────────────────────────────────

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _AppColors.textSecondary,
          side: const BorderSide(color: _AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _StepProgressBar ──────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.step, required this.totalSteps});

  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: step / totalSteps,
      backgroundColor: _AppColors.border,
      color: _AppColors.accent,
      minHeight: 4,
    );
  }
}

// ── _SchoolSummaryCard ────────────────────────────────────────────────────────

class _SchoolSummaryCard extends StatelessWidget {
  const _SchoolSummaryCard({required this.schoolModel});

  final SchoolModel schoolModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: _AppColors.accent.withOpacity(0.25)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school_rounded,
                color: _AppColors.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  schoolModel.name.isEmpty
                      ? 'المدرسة'
                      : schoolModel.name,
                  style: const TextStyle(
                    color: _AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  schoolModel.officialEmail,
                  style: const TextStyle(
                      color: _AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          TrustIndicatorWidget(
            trustScore: schoolModel.trustScore,
            schoolName: '',
            compact: true,
          ),
        ],
      ),
    );
  }
}

// ── _AdminStatusCard ──────────────────────────────────────────────────────────

class _AdminStatusCard extends StatelessWidget {
  const _AdminStatusCard({required this.adminModel});

  final AdminModel adminModel;

  @override
  Widget build(BuildContext context) {
    final Color color = adminModel.adminStatus == AdminStatus.approved
        ? _AppColors.verified
        : _AppColors.warning;

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          Icon(Icons.admin_panel_settings_rounded, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'حالة المشرف',
                  style: TextStyle(
                    color: _AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  adminModel.adminStatus == AdminStatus.approved
                      ? 'تمت الموافقة'
                      : 'قيد المراجعة',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ),
          if (adminModel.isEmailDomainMatch)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _AppColors.verified.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.link_rounded,
                      color: _AppColors.verified, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'نطاق متطابق',
                    style: TextStyle(
                        color: _AppColors.verified,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
