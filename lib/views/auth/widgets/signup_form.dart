import 'package:flutter/material.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../utils/constants.dart';
import '../../../utils/validators.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class SignupForm extends StatefulWidget {
  final AuthViewModel authVM;
  final VoidCallback onSignupSuccess;

  const SignupForm({
    super.key,
    required this.authVM,
    required this.onSignupSuccess,
  });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.authVM.signUp(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success) {
      widget.onSignupSuccess();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.authVM.errorMessage ?? 'Signup failed'),
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
            controller: _nameController,
            label: 'Full Name',
            hintText: 'John Doe',
            prefixIcon: Icons.person_outline,
            validator: (v) => Validators.required(v, 'Full Name'),
          ),
          const SizedBox(height: AppSizes.md),
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
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
          const SizedBox(height: AppSizes.md),
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirm,
            validator: (v) =>
                Validators.confirmPassword(v, _passwordController.text),
            suffix: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscureConfirm = !_obscureConfirm);
              },
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          CustomButton(
            label: 'Create Account',
            isLoading: widget.authVM.isLoading,
            onPressed: _handleSignup,
            icon: Icons.person_add_outlined,
          ),
        ],
      ),
    );
  }
}
