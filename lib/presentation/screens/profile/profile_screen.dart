import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitos_app/config/config.dart';
import 'package:habitos_app/domain/entities/user_profile.dart';
import 'package:habitos_app/presentation/providers/providers.dart';
import 'package:habitos_app/presentation/views/profile/profile_view.dart';
import 'package:habitos_app/presentation/widgets/shared/bottom_nav_bar.dart';
import 'package:habitos_app/presentation/screens/pairing/pair_watch_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) context.go(AppConstants.authRoute);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.pending),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _openEditProfile(
      BuildContext context, WidgetRef ref, UserProfile? profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(profile: profile),
    );
  }

  void _openThemePicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(themeModeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Tema de la app',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            _ThemeOptionTile(
              icon: Icons.brightness_auto_rounded,
              label: 'Predeterminado del sistema',
              selected: current == ThemeMode.system,
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.of(context).pop();
              },
            ),
            _ThemeOptionTile(
              icon: Icons.light_mode_rounded,
              label: 'Claro',
              selected: current == ThemeMode.light,
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.of(context).pop();
              },
            ),
            _ThemeOptionTile(
              icon: Icons.dark_mode_rounded,
              label: 'Oscuro',
              selected: current == ThemeMode.dark,
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(AppConstants.homeRoute);
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => context.go(AppConstants.homeRoute),
          ),
          title: const Text('Tu Perfil'),
          backgroundColor: AppTheme.surface,
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded),
              onSelected: (value) {
                if (value == 'edit') {
                  _openEditProfile(context, ref, profile);
                } else if (value == 'theme') {
                  _openThemePicker(context, ref);
                } else if (value == 'pair_watch') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PairWatchScreen()),
                  );
                } else if (value == 'logout') {
                  _confirmLogout(context, ref);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Editar perfil'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'theme',
                  child: Row(children: [
                    Icon(Icons.dark_mode_outlined, size: 18, color: AppTheme.primary),
                    SizedBox(width: 10),
                    Text('Tema de la app'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'pair_watch',
                  child: Row(children: [
                    Icon(Icons.watch_outlined, size: 18, color: AppTheme.primary),
                    SizedBox(width: 10),
                    Text('Vincular smartwatch'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(children: [
                    Icon(Icons.logout_rounded, size: 18, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                  ]),
                ),
              ],
            ),
          ],
        ),
        body: const ProfileView(),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      ),
    );
  }
}

// ── Sheet de edición de perfil ────────────────────────────────────────────────

class _EditProfileSheet extends ConsumerStatefulWidget {
  final UserProfile? profile;
  const _EditProfileSheet({this.profile});

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _ageCtrl;
  bool _isSaving = false;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameCtrl   = TextEditingController(text: widget.profile?.name ?? '');
    _heightCtrl = TextEditingController(
        text: widget.profile?.heightCm?.toStringAsFixed(0) ?? '');
    _weightCtrl = TextEditingController(
        text: widget.profile?.weightKg?.toStringAsFixed(0) ?? '');
    _ageCtrl    = TextEditingController(
        text: widget.profile?.ageYears?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _heightCtrl.dispose();
    _weightCtrl.dispose(); _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name   = _nameCtrl.text.trim();
    final height = double.tryParse(_heightCtrl.text.trim());
    final weight = double.tryParse(_weightCtrl.text.trim());
    final age    = int.tryParse(_ageCtrl.text.trim());

    setState(() {
      _nameError = name.isEmpty ? 'El nombre es obligatorio' : null;
    });
    if (_nameError != null) return;

    setState(() => _isSaving = true);
    await ref.read(profileProvider.notifier).update(
      name: name,
      heightCm: height,
      weightKg: weight,
      ageYears: age,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        left: 20, right: 20, top: 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2)),
          )),
          const Text('Editar perfil',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 20),

          _buildField('Nombre', _nameCtrl, TextInputType.name,
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              }),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _buildField('Altura (cm)', _heightCtrl,
                TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _buildField('Peso (kg)', _weightCtrl,
                TextInputType.number)),
          ]),
          const SizedBox(height: 12),
          _buildField('Edad', _ageCtrl, TextInputType.number),
          const SizedBox(height: 24),

          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.divider),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppTheme.textSecondary)),
            )),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5,
                          color: Colors.white))
                  : const Text('Guardar',
                      style: TextStyle(fontWeight: FontWeight.w600)),
            )),
          ]),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      TextInputType keyboard, {String? errorText, ValueChanged<String>? onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13,
          fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl, keyboardType: keyboard,
        onChanged: onChanged,
        decoration: InputDecoration(
          errorText: errorText,
          filled: true, fillColor: AppTheme.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.divider)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.divider)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    ]);
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? AppTheme.primary : AppTheme.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? AppTheme.primary : AppTheme.textPrimary,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppTheme.primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}