import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth_provider.dart';
import '../../data/services/providers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_snackbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureText = true;

  /// null while checking; true on a fresh install with no accounts yet.
  bool? _needsSetup;
  bool _creatingAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    final needsSetup = await ref.read(authRepositoryProvider).needsInitialSetup();
    if (mounted) setState(() => _needsSetup = needsSetup);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authStateProvider.notifier).login(
              _emailController.text,
              _passwordController.text,
            );
      } catch (e) {
        if (mounted) {
          AppSnackBar.error(context, e.toString().replaceAll('Exception: ', ''));
        }
      }
    }
  }

  void _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _creatingAdmin = true);
    try {
      await ref.read(authRepositoryProvider).createInitialAdmin(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
      await ref.read(authStateProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _creatingAdmin = false);
    }
  }

  Widget _buildFeatureRow(IconData icon, String text, int index) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: (300 + index * 100).ms, duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildDesktopLayout(Widget loginFormCard, ThemeData theme) {
    return Row(
      children: [
        // Left Column - Decorative Info Panel
        Expanded(
          flex: 11,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.85),
                  theme.colorScheme.secondary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  left: -100,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150,
                  right: -50,
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.04),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(64.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.lock_person_rounded,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'ClassVault',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
                          const SizedBox(height: 48),
                          const Text(
                            'Academic attendance management\nsimplified for everyone.',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 24),
                          Text(
                            'ClassVault lets administrators, faculty, and students monitor, mark, and analyze class attendances in real-time. Powering educational workflows with absolute precision.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.5,
                            ),
                          ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                          const SizedBox(height: 48),
                          _buildFeatureRow(Icons.check_circle_outline_rounded, 'Real-time Attendance Marking', 0),
                          const SizedBox(height: 16),
                          _buildFeatureRow(Icons.upload_file_rounded, 'Bulk Student CSV Imports', 1),
                          const SizedBox(height: 16),
                          _buildFeatureRow(Icons.trending_up_rounded, 'Automated Semester Promotions', 2),
                          const SizedBox(height: 16),
                          _buildFeatureRow(Icons.analytics_outlined, 'Defaulters & Subject Analytics', 3),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right Column - Login Form
        Expanded(
          flex: 9,
          child: Container(
            color: theme.colorScheme.surface,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: loginFormCard,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width > 960;

    final formCard = Card(
      elevation: isDesktop ? 0 : 4,
      color: isDesktop ? Colors.transparent : null,
      shadowColor: isDark ? Colors.black45 : Colors.black12,
      shape: isDesktop ? const RoundedRectangleBorder(side: BorderSide.none) : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 0 : 32.0,
          vertical: isDesktop ? 0 : 40.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or Title
              Icon(
                Icons.lock_person_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
              const SizedBox(height: 16),
              Text(
                'ClassVault',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Attendance Management System',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
              const SizedBox(height: 32),

              if (_needsSetup == null)
                const Center(child: CircularProgressIndicator())
              else if (_needsSetup!)
                ..._buildSetupFields(theme)
              else
                ..._buildLoginFields(authState.isLoading),
            ],
          ),
        ),
      ),
    );

    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: Stack(
        children: [
          isDesktop
              ? _buildDesktopLayout(formCard, theme)
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: formCard,
                    ),
                  ),
                ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Tooltip(
                message: themeMode == ThemeMode.dark ? 'Light Mode' : 'Dark Mode',
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    ref.read(themeModeProvider.notifier).state =
                        themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _passwordField({required int delayMs}) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          tooltip: _obscureText ? 'Show password' : 'Hide password',
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (_needsSetup == true && value.length < 8) {
          return 'Use at least 8 characters';
        }
        return null;
      },
    ).animate().fadeIn(delay: delayMs.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _progressLabel(String label, bool busy) {
    return busy
        ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
        : Text(label);
  }

  List<Widget> _buildLoginFields(bool isLoading) {
    return [
      // Email / roll number input
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email or Roll Number',
          prefixIcon: Icon(Icons.person_outline_rounded),
        ),
        validator: (v) => Validators.required(v, label: 'Email or roll number'),
      ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
      const SizedBox(height: 16),
      _passwordField(delayMs: 250),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: isLoading ? null : _submit,
        child: _progressLabel('Login', isLoading),
      ).animate().fadeIn(delay: 300.ms, duration: 400.ms).scaleXY(begin: 0.95, end: 1.0),
    ];
  }

  List<Widget> _buildSetupFields(ThemeData theme) {
    return [
      Text(
        'Welcome! Create the administrator account to get started.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium,
      ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
      const SizedBox(height: 24),
      TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Full Name',
          prefixIcon: Icon(Icons.badge_outlined),
        ),
        validator: (v) => Validators.required(v, label: 'Name'),
      ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
      const SizedBox(height: 16),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email Address',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        validator: Validators.email,
      ).animate().fadeIn(delay: 225.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
      const SizedBox(height: 16),
      _passwordField(delayMs: 250),
      const SizedBox(height: 16),
      TextFormField(
        controller: _confirmPasswordController,
        obscureText: _obscureText,
        decoration: const InputDecoration(
          labelText: 'Confirm Password',
          prefixIcon: Icon(Icons.lock_outlined),
        ),
        validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
      ).animate().fadeIn(delay: 275.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: _creatingAdmin ? null : _createAdmin,
        child: _progressLabel('Create Administrator', _creatingAdmin),
      ).animate().fadeIn(delay: 300.ms, duration: 400.ms).scaleXY(begin: 0.95, end: 1.0),
    ];
  }
}
