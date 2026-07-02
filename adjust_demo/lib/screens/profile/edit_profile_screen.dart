import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../utils/snackbar.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/user_avatar.dart';

/// Lets the user edit their (fake) name and email.
///
/// Validates input, saves through [AuthProvider.updateProfile] (which persists
/// locally) and pops back to the profile.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _email = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.editProfile)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            if (user != null)
              Center(child: UserAvatar(user: user, size: 96)),
            Gaps.h32,
            AppTextField(
              controller: _name,
              label: AppStrings.name,
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: Validators.name,
            ),
            Gaps.h16,
            AppTextField(
              controller: _email,
              label: AppStrings.email,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: Validators.email,
              onFieldSubmitted: (_) => _save(),
            ),
            Gaps.h32,
            PrimaryButton(
              label: AppStrings.save,
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await context
        .read<AuthProvider>()
        .updateProfile(name: _name.text.trim(), email: _email.text.trim());
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.success(context, 'Profile updated');
    context.pop();
  }
}
