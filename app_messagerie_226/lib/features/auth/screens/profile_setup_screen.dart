import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../../core/services/cloudinary_service.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _picker = ImagePicker();

  File? _profilePhoto;
  File? _idCardFront;
  File? _idCardBack;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(_ImageTarget target) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() {
      switch (target) {
        case _ImageTarget.profile:
          _profilePhoto = File(picked.path);
        case _ImageTarget.idFront:
          _idCardFront = File(picked.path);
        case _ImageTarget.idBack:
          _idCardBack = File(picked.path);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idCardFront == null || _idCardBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les deux faces de la pièce d\'identité sont obligatoires'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(firebaseAuthProvider).currentUser!;
      final uid = user.uid;
      final cloudinary = ref.read(cloudinaryServiceProvider);

      final idFrontUrl = await cloudinary.uploadIdCard(_idCardFront!, uid, 'front');
      final idBackUrl = await cloudinary.uploadIdCard(_idCardBack!, uid, 'back');
      String? profilePhotoUrl;
      if (_profilePhoto != null) {
        profilePhotoUrl = await cloudinary.uploadProfilePhoto(_profilePhoto!, uid);
      }

      await ref.read(firestoreProvider).collection('users').doc(uid).set({
        'phoneNumber': user.phoneNumber,
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'idCardFrontUrl': idFrontUrl,
        'idCardBackUrl': idBackUrl,
        'profilePhotoUrl': profilePhotoUrl ?? '',
        'role': 'user',
        'accountStatus': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) context.go(AppRoutes.groupList);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compléter votre profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo de profil
                Center(
                  child: GestureDetector(
                    onTap: () => _pickImage(_ImageTarget.profile),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      backgroundImage: _profilePhoto != null ? FileImage(_profilePhoto!) : null,
                      child: _profilePhoto == null
                          ? const Icon(Icons.camera_alt, size: 32, color: AppTheme.primary)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(child: Text('Photo de profil (optionnelle)')),
                const SizedBox(height: 24),

                // Prénom
                TextFormField(
                  controller: _firstNameCtrl,
                  decoration: const InputDecoration(labelText: 'Prénom *'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Prénom requis' : null,
                ),
                const SizedBox(height: 16),

                // Nom
                TextFormField(
                  controller: _lastNameCtrl,
                  decoration: const InputDecoration(labelText: 'Nom *'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nom requis' : null,
                ),
                const SizedBox(height: 32),

                // Pièce d'identité
                Text('Pièce d\'identité *', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                const Text('Recto et verso obligatoires', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _IdCardPicker(label: 'Recto', file: _idCardFront, onTap: () => _pickImage(_ImageTarget.idFront))),
                    const SizedBox(width: 12),
                    Expanded(child: _IdCardPicker(label: 'Verso', file: _idCardBack, onTap: () => _pickImage(_ImageTarget.idBack))),
                  ],
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Terminer l\'inscription'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _ImageTarget { profile, idFront, idBack }

class _IdCardPicker extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onTap;

  const _IdCardPicker({required this.label, required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: file != null ? AppTheme.primary : Colors.grey),
          borderRadius: BorderRadius.circular(12),
          image: file != null ? DecorationImage(image: FileImage(file!), fit: BoxFit.cover) : null,
        ),
        child: file == null
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(color: Colors.grey)),
              ])
            : null,
      ),
    );
  }
}
