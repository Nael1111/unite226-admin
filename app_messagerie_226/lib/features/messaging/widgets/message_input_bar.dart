import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../controllers/message_controller.dart';
import '../models/message_model.dart';
import '../../../core/theme.dart';
import '../../../core/services/cloudinary_service.dart';

class MessageInputBar extends ConsumerStatefulWidget {
  final String groupId;
  final dynamic replyToMessage;
  final VoidCallback onMessageSent;

  const MessageInputBar({
    super.key,
    required this.groupId,
    this.replyToMessage,
    required this.onMessageSent,
  });

  @override
  ConsumerState<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends ConsumerState<MessageInputBar> {
  final _textCtrl = TextEditingController();
  final _picker = ImagePicker();
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isSending = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _sendText() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    _textCtrl.clear();
    final isLink = Uri.tryParse(text)?.hasScheme ?? false;
    await ref.read(messageControllerProvider).sendMessage(
          groupId: widget.groupId,
          content: text,
          type: isLink ? MessageType.link : MessageType.text,
          replyToMessageId: widget.replyToMessage?.id,
        );
    widget.onMessageSent();
    setState(() => _isSending = false);
  }

  Future<void> _pickAndSendImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    setState(() => _isSending = true);
    final url = await ref
        .read(cloudinaryServiceProvider)
        .uploadGroupImage(File(picked.path), widget.groupId);
    await ref.read(messageControllerProvider).sendMessage(
          groupId: widget.groupId,
          content: url,
          type: MessageType.image,
          replyToMessageId: widget.replyToMessage?.id,
        );
    widget.onMessageSent();
    setState(() => _isSending = false);
  }

  Future<void> _pickAndSendVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _isSending = true);
    final url = await ref
        .read(cloudinaryServiceProvider)
        .uploadGroupVideo(File(picked.path), widget.groupId);
    await ref.read(messageControllerProvider).sendMessage(
          groupId: widget.groupId,
          content: url,
          type: MessageType.video,
          replyToMessageId: widget.replyToMessage?.id,
        );
    widget.onMessageSent();
    setState(() => _isSending = false);
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      if (path == null) return;
      setState(() { _isRecording = false; _isSending = true; });
      final url = await ref
          .read(cloudinaryServiceProvider)
          .uploadGroupVoice(File(path), widget.groupId);
      await ref.read(messageControllerProvider).sendMessage(
            groupId: widget.groupId,
            content: url,
            type: MessageType.voice,
            replyToMessageId: widget.replyToMessage?.id,
          );
      widget.onMessageSent();
      setState(() => _isSending = false);
    } else {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) return;
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -1))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _isSending ? null : () => _showAttachMenu(context),
              color: AppTheme.textSecondary,
            ),
            Expanded(
              child: TextField(
                controller: _textCtrl,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 4),
            _isSending
                ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : ValueListenableBuilder(
                    valueListenable: _textCtrl,
                    builder: (_, value, __) {
                      final hasText = value.text.trim().isNotEmpty;
                      return hasText
                          ? IconButton(
                              icon: const Icon(Icons.send),
                              color: AppTheme.primary,
                              onPressed: _sendText,
                            )
                          : IconButton(
                              icon: Icon(_isRecording
                                  ? Icons.stop_circle
                                  : Icons.mic),
                              color: _isRecording ? Colors.red : AppTheme.primary,
                              onPressed: _toggleRecording,
                            );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _showAttachMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image'),
              onTap: () { Navigator.pop(context); _pickAndSendImage(); }),
          ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Vidéo'),
              onTap: () { Navigator.pop(context); _pickAndSendVideo(); }),
        ]),
      ),
    );
  }
}
