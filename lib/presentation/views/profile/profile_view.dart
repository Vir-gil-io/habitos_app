import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitos_app/config/theme/app_theme.dart';
import 'package:habitos_app/presentation/providers/providers.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );
    final name = profile?.name ?? 'Usuario';
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 48,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(name, style: textTheme.headlineMedium),
          Text('Miembro de HabitFlow', style: textTheme.bodyMedium),
          const SizedBox(height: 8),

          // ── Métricas físicas o aviso de datos faltantes ────────────────
          if (profile == null || profile.isMissingPhysicalData)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Completa tu altura, peso y edad desde el menú ⋯ → Editar perfil',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MetricChip(label: '${profile.heightCm!.toStringAsFixed(0)} cm'),
                _MetricChip(label: '${profile.weightKg!.toStringAsFixed(0)} kg'),
                _MetricChip(label: '${profile.ageYears} años'),
              ],
            ),

          const SizedBox(height: 24),

          // This week's progress
          Builder(builder: (context) {
            final activity = ref.watch(wearableActivityProvider).maybeWhen(
              data: (a) => a,
              orElse: () => null,
            );
            final hasData = activity?.hasAnyData ?? false;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("This Week's Progress", style: textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(
                        emoji: '🦶',
                        value: hasData ? '${activity!.weekSteps}' : '—',
                        label: 'pasos',
                      ),
                      _StatChip(
                        emoji: '🔥',
                        value: hasData
                            ? activity!.weekCalories.toStringAsFixed(0)
                            : '—',
                        label: 'cal',
                      ),
                      _StatChip(
                        emoji: '📍',
                        value: hasData
                            ? activity!.weekDistanceKm.toStringAsFixed(1)
                            : '—',
                        label: 'km',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasData
                        ? 'Datos sincronizados desde tu wearable'
                        : 'Conecta tu wearable para ver el progreso semanal',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  const _MetricChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatChip({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}