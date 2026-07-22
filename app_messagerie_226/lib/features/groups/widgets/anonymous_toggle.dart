import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/anonymous_controller.dart';
import '../../../core/theme.dart';

class AnonymousToggle extends ConsumerWidget {
  final String groupId;

  const AnonymousToggle({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(anonymousStateProvider(groupId));

    return memberAsync.when(
      loading: () => const SizedBox(width: 40),
      error: (_, __) => const SizedBox(width: 40),
      data: (data) {
        final isAnonymous = data?['isAnonymous'] as bool? ?? false;
        final label = data?['anonymousLabel'] as String? ?? '';
        final colorHex = data?['anonymousColor'] as String? ?? '';

        Color? anonymousColor;
        if (colorHex.isNotEmpty) {
          try {
            anonymousColor =
                Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
          } catch (_) {}
        }

        return GestureDetector(
          onTap: () => _showToggleDialog(context, ref, isAnonymous, label, anonymousColor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAnonymous ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: isAnonymous
                      ? (anonymousColor ?? Colors.white)
                      : Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  isAnonymous ? (label.isNotEmpty ? label : 'Inconnu') : 'Visible',
                  style: TextStyle(
                    fontSize: 12,
                    color: isAnonymous
                        ? (anonymousColor ?? Colors.white)
                        : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showToggleDialog(
    BuildContext context,
    WidgetRef ref,
    bool isAnonymous,
    String label,
    Color? color,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isAnonymous ? 'Désactiver le mode Inconnu ?' : 'Activer le mode Inconnu ?'),
        content: Text(
          isAnonymous
              ? 'Votre vrai nom sera visible dans ce groupe.'
              : 'Vous apparaîtrez sous un pseudonyme anonyme dans ce groupe. Votre identité reste connue des administrateurs.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAnonymous ? Colors.grey : AppTheme.primary,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(anonymousControllerProvider)
                  .toggleAnonymous(groupId, !isAnonymous);
            },
            child: Text(isAnonymous ? 'Désactiver' : 'Activer'),
          ),
        ],
      ),
    );
  }
}
