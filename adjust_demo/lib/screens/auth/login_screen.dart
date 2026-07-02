import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../navigation/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/snackbar.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/primary_button.dart';

/// Sign-in screen.
///
/// Validates email/password locally, then delegates to [AuthProvider.login]
/// (which fakes the request). On success, [GoRouter]'s redirect sends the user
/// to Home. Registration and forgot-password are reachable from here.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.home);
    } else {
      AppSnackbar.error(context, auth.error ?? AppStrings.loginFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = context.select<AuthProvider, bool>((a) => a.isBusy);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSizes.xl),
                    const BrandLogo(size: 80),
                    Gaps.h32,
                    Text(
                      AppStrings.welcomeBack,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Gaps.h4,
                    Text(
                      AppStrings.signInToContinue,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Gaps.h32,
                    AppTextField(
                      controller: _emailController,
                      label: AppStrings.email,
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: Validators.email,
                    ),
                    Gaps.h16,
                    PasswordField(
                      controller: _passwordController,
                      label: AppStrings.password,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      validator: Validators.password,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    Gaps.h8,
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => AppSnackbar.info(
                          context,
                          AppStrings.forgotPasswordInfo,
                        ),
                        child: const Text(AppStrings.forgotPassword),
                      ),
                    ),
                    Gaps.h8,
                    PrimaryButton(
                      label: AppStrings.login,
                      isLoading: isBusy,
                      onPressed: _submit,
                    ),
                    Gaps.h24,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAccount,
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: isBusy
                              ? null
                              : () => context.push(AppRoutes.register),
                          child: const Text(AppStrings.register),
                        ),
                      ],
                    ),
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
