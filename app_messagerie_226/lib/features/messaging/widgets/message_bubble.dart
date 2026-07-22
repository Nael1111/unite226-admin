import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message_model.dart';
import '../../../core/theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final List<Message> allMessages;
  final VoidCallback onReply;
  final VoidCallback onPin;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.allMessages,
    required this.onReply,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    final nameColor = message.displayColor.isNotEmpty && message.displayColor != '#000000'
        ? Color(int.parse(message.displayColor.replaceFirst('#', '0xFF')))
        : AppTheme.primary;

    return GestureDetector(
      onLongPress: () => _showActions(context),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isMe ? AppTheme.primary : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom de l'expéditeur (masqué pour ses propres messages)
              if (!isMe)
                Text(message.displayName,
                    style: TextStyle(color: nameColor, fontWeight: FontWeight.bold, fontSize: 12)),

              // Message cité (réponse)
              if (message.replyToMessageId != null) _buildReplyPreview(),

              // Épinglé
              if (message.isPinned)
                const Row(children: [
                  Icon(Icons.push_pin, size: 12, color: Colors.amber),
                  SizedBox(width: 4),
                  Text('Épinglé', style: TextStyle(fontSize: 10, color: Colors.amber)),
                ]),

              const SizedBox(height: 2),

              // Contenu selon le type
              _buildContent(context, isMe),

              // Heure
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isMe) {
    final textColor = isMe ? Colors.white : AppTheme.textPrimary;
    switch (message.type) {
      case MessageType.text:
        return Text(message.content, style: TextStyle(color: textColor));
      case MessageType.link:
        return GestureDetector(
          onTap: () => _launchUrl(message.content),
          child: Text(message.content,
              style: TextStyle(color: isMe ? Colors.white : Colors.blue, decoration: TextDecoration.underline)),
        );
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(message.content, fit: BoxFit.cover, height: 180),
        );
      case MessageType.voice:
        return Row(children: [
          Icon(Icons.play_circle_outline, color: isMe ? Colors.white : AppTheme.primary),
          const SizedBox(width: 8),
          Text('Message vocal', style: TextStyle(color: textColor)),
        ]);
      case MessageType.video:
        return Row(children: [
          Icon(Icons.videocam_outlined, color: isMe ? Colors.white : AppTheme.primary),
          const SizedBox(width: 8),
          Text('Vidéo', style: TextStyle(color: textColor)),
        ]);
    }
  }

  Widget _buildReplyPreview() {
    final replied = allMessages.where((m) => m.id == message.replyToMessageId).firstOrNull;
    if (replied == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: AppTheme.primary, width: 3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(replied.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        Text(replied.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
      ]),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.reply), title: const Text('Répondre'), onTap: () { Navigator.pop(context); onReply(); }),
          ListTile(
            leading: Icon(message.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            title: Text(message.isPinned ? 'Désépingler' : 'Épingler'),
            onTap: () { Navigator.pop(context); onPin(); },
          ),
        ]),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
