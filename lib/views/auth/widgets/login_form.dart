import 'package:flutter/material.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../utils/constants.dart';
import '../../../utils/validators.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class LoginForm extends StatefulWidget {
  final AuthViewModel authVM;
  final VoidCallback onLoginSuccess;

  const LoginForm({
    super.key,
    required this.authVM,
    required this.onLoginSuccess,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.authVM.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success) {
      widget.onLoginSuccess();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.authVM.errorMessage ?? 'Login failed'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'you@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: AppSizes.md),
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            validator: Validators.password,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          CustomButton(
            label: 'Sign In',
            isLoading: widget.authVM.isLoading,
            onPressed: _handleLogin,
            icon: Icons.login_rounded,
          ),
        ],
      ),
    );
  }
}
