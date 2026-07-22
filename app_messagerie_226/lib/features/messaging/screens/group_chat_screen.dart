import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/message_controller.dart';
import '../models/message_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_bar.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../groups/controllers/group_controller.dart';
import '../../groups/widgets/anonymous_toggle.dart';
import '../../../core/theme.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  Message? _replyingTo;

  void _setReply(Message? message) => setState(() => _replyingTo = message);

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesStreamProvider(widget.groupId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final pinnedAsync = ref.watch(pinnedMessagesProvider(widget.groupId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.groupName),
            // Nombre de membres
            Consumer(builder: (context, ref, _) {
              final groups = ref.watch(groupsStreamProvider).valueOrNull ?? [];
              final group = groups.where((g) => g.id == widget.groupId).firstOrNull;
              if (group == null) return const SizedBox.shrink();
              return Text(
                '${group.membersCount} membre${group.membersCount > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              );
            }),
          ],
        ),
        actions: [
          AnonymousToggle(groupId: widget.groupId),
          // Messages épinglés
          pinnedAsync.when(
            data: (pinned) => pinned.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.push_pin_outlined),
                    onPressed: () => _showPinnedMessages(context, pinned),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Liste des messages
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur : $e')),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Aucun message. Soyez le premier à écrire !'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == currentUser?.uid;
                    return MessageBubble(
                      message: msg,
                      isMe: isMe,
                      allMessages: messages,
                      onReply: () => _setReply(msg),
                      onPin: () => ref
                          .read(messageControllerProvider)
                          .pinMessage(widget.groupId, msg.id, !msg.isPinned),
                    );
                  },
                );
              },
            ),
          ),

          // Barre de réponse
          if (_replyingTo != null)
            _ReplyBanner(
              message: _replyingTo!,
              onCancel: () => _setReply(null),
            ),

          // Barre de saisie
          MessageInputBar(
            groupId: widget.groupId,
            replyToMessage: _replyingTo,
            onMessageSent: () => _setReply(null),
          ),
        ],
      ),
    );
  }

  void _showPinnedMessages(BuildContext context, List<Message> pinned) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Messages épinglés', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pinned.length,
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.push_pin, color: AppTheme.primary),
                title: Text(pinned[i].content, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(pinned[i].displayName),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyBanner extends StatelessWidget {
  final Message message;
  final VoidCallback onCancel;

  const _ReplyBanner({required this.message, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primary.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(width: 3, height: 36, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.displayName,
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                Text(message.content, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onCancel),
        ],
      ),
    );
  }
}
