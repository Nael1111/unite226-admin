import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/group_controller.dart';
import '../models/group_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';

class GroupListScreen extends ConsumerWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsStreamProvider);
    final myGroupIds = ref.watch(myGroupIdsProvider).valueOrNull ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unité 226'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(
              child: Text('Aucun groupe disponible pour le moment.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _GroupCard(
              group: groups[i],
              isMember: myGroupIds.contains(groups[i].id),
            ),
          );
        },
      ),
    );
  }
}

class _GroupCard extends ConsumerWidget {
  final Group group;
  final bool isMember;

  const _GroupCard({required this.group, required this.isMember});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(groupControllerProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isMember
            ? () => context.push('/groups/${group.id}')
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar groupe
              CircleAvatar(
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(
                  group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(group.name,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        if (!group.writingEnabled)
                          const Icon(Icons.volume_off, size: 16, color: AppTheme.textSecondary),
                      ],
                    ),
                    if (group.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(group.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                    const SizedBox(height: 4),
                    Text('${group.membersCount} membre${group.membersCount > 1 ? 's' : ''}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Bouton rejoindre / ouvrir
              isMember
                  ? const Icon(Icons.chevron_right, color: AppTheme.primary)
                  : TextButton(
                      onPressed: () async {
                        await controller.joinGroup(group.id);
                        if (context.mounted) {
                          context.push('/groups/${group.id}');
                        }
                      },
                      child: const Text('Rejoindre'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
