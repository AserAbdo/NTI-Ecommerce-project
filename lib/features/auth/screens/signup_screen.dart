import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../services/credentials_storage_service.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
import '../widgets/widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Load saved credentials (email and password only)
    _loadSavedCredentials();
  }

  /// Load previously saved email and password
  Future<void> _loadSavedCredentials() async {
    final email = await CredentialsStorageService.getSavedEmail();
    final password = await CredentialsStorageService.getSavedPassword();

    if (email != null) {
      setState(() {
        _emailController.text = email;
      });
    }
    if (password != null) {
      setState(() {
        _passwordController.text = password;
        _confirmPasswordController.text = password;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError('Passwords do not match');
        return;
      }

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Save credentials for next time
      await CredentialsStorageService.saveCredentials(
        email: email,
        password: password,
      );

      // Proceed with signup
      if (mounted) {
        context.read<AuthCubit>().signUp(
          name: _nameController.text.trim(),
          email: email,
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          password: password,
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: _handleAuthState,
            builder: (context, state) {
              return Column(
                children: [
                  _buildAppBar(isDark),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildHeader(isDark),
                              const SizedBox(height: 24),
                              AuthFormCard(children: _buildFormFields()),
                              const SizedBox(height: 16),
                              _buildTermsText(),
                              const SizedBox(height: 24),
                              AuthGradientButton(
                                text: 'Create Account',
                                onPressed: _signup,
                                isLoading: state is AuthLoading,
                              ),
                              const SizedBox(height: 24),
                              _buildLoginLink(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else if (state is AuthError) {
      _showError(state.message);
    }
  }

  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.login),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join us and start your shopping adventure',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  List<Widget> _buildFormFields() {
    return [
      AuthInputField(
        controller: _nameController,
        label: 'Full Name',
        hint: 'Enter your full name',
        icon: Icons.person_rounded,
        validator: Validators.validateName,
      ),
      const SizedBox(height: 16),
      AuthInputField(
        controller: _emailController,
        label: 'Email Address',
        hint: 'Enter your email',
        icon: Icons.email_rounded,
        keyboardType: TextInputType.emailAddress,
        validator: Validators.validateEmail,
      ),
      const SizedBox(height: 16),
      AuthInputField(
        controller: _phoneController,
        label: 'Phone Number',
        hint: 'Enter your phone number',
        icon: Icons.phone_rounded,
        keyboardType: TextInputType.phone,
        validator: Validators.validatePhone,
      ),
      const SizedBox(height: 16),
      AuthInputField(
        controller: _addressController,
        label: 'Address',
        hint: 'Enter your address',
        icon: Icons.location_on_rounded,
        validator: Validators.validateAddress,
      ),
      const SizedBox(height: 16),
      AuthInputField(
        controller: _passwordController,
        label: 'Password',
        hint: 'Create a password',
        icon: Icons.lock_rounded,
        obscureText: _obscurePassword,
        validator: Validators.validatePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: AppColors.textSecondary,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      const SizedBox(height: 16),
      AuthInputField(
        controller: _confirmPasswordController,
        label: 'Confirm Password',
        hint: 'Re-enter your password',
        icon: Icons.lock_rounded,
        obscureText: _obscureConfirmPassword,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please confirm your password';
          if (value != _passwordController.text)
            return 'Passwords do not match';
          return null;
        },
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: AppColors.textSecondary,
          ),
          onPressed: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
        ),
      ),
    ];
  }

  Widget _buildTermsText() {
    return Text.rich(
      TextSpan(
        text: 'By signing up, you agree to our ',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        children: [
          TextSpan(
            text: 'Terms',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
