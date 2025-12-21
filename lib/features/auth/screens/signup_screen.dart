import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.signup,
          style: TextStyle(
            fontSize: ResponsiveHelper.getSubtitleFontSize(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getHorizontalPadding(context),
                  vertical: ResponsiveHelper.getVerticalPadding(context),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.getFormWidth(context),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppStrings.createAccount,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getTitleFontSize(
                              context,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getSpacing(context, 8),
                        ),
                        Text(
                          AppStrings.fillDetails,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getSubtitleFontSize(
                              context,
                            ),
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getSpacing(context, 32),
                        ),
                        CustomTextField(
                          label: AppStrings.name,
                          controller: _nameController,
                          validator: (value) =>
                              Validators.validateRequired(value, 'Name'),
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getSpacing(context, 16),
                        ),
                        CustomTextField(
                          label: AppStrings.email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getSpacing(context, 16),
                        ),
                        CustomTextField(
                          label: AppStrings.phone,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: Validators.validatePhone,
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getSpacing(context, 16),
                        ),
                        CustomTextField(
                          label: AppStrings.address,
                          controller: _addressController,
                          keyboardType: TextInputType.streetAddress,
                          validator: null,
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getSpacing(context, 16),
                        ),
                        CustomTextField(
                          label: AppStrings.password,
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: Validators.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getSpacing(context, 24),
                        ),
                        CustomButton(
                          text: AppStrings.signup,
                          onPressed: _signup,
                          isLoading: isLoading,
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getSpacing(context, 16),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.alreadyHaveAccount + ' ',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getBodyFontSize(
                                  context,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                AppStrings.login,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getBodyFontSize(
                                    context,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
