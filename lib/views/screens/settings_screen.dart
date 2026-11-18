import 'package:flutter/material.dart';
import 'package:mini_reseau_social/controllers/auth_controller.dart';
import 'package:mini_reseau_social/controllers/settings_controller.dart';
import 'package:mini_reseau_social/core/constants/app_constants.dart';
import 'package:mini_reseau_social/core/utils/validators.dart';
import 'package:mini_reseau_social/views/widgets/feedback.dart';
import 'package:mini_reseau_social/views/widgets/user_avatar.dart';
import 'package:provider/provider.dart';

/// Paramètres : modification du profil et déconnexion (F1).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsController>(
      create: (context) => SettingsController(
        user: context.read<AuthController>().currentUser!,
        userService: context.read(),
        storageService: context.read(),
        photoPicker: context.read(),
      ),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _save(SettingsController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final success = await controller.save();
    if (!mounted) return;
    showMessage(
      context,
      success ? 'Profil mis à jour.' : controller.errorMessage ?? 'Échec.',
    );
  }

  Future<void> _signOut() async {
    final auth = context.read<AuthController>();
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                UserAvatar(
                  name: controller.userName,
                  photoUrl: controller.photoSource,
                  radius: 48,
                ),
                IconButton.filledTonal(
                  tooltip: 'Changer la photo',
                  onPressed: controller.isBusy ? null : controller.pickPhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: controller.nameInput,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: Validators.requiredField,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.bioInput,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: AppConstants.maxBioLength,
                  decoration: const InputDecoration(
                    labelText: 'Biographie',
                    alignLabelWithHint: true,
                  ),
                  validator: Validators.maxLength(AppConstants.maxBioLength),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: controller.isBusy ? null : () => _save(controller),
            child: controller.isBusy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enregistrer'),
          ),
          const Divider(height: 48),
          OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}
