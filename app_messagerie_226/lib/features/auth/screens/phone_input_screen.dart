import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';

class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _fullNumber => '+226${_controller.text.trim()}';

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Numéro requis';
    final digits = value.trim().replaceAll(' ', '');
    if (!RegExp(r'^\d{8}$').hasMatch(digits)) {
      return '8 chiffres requis après +226';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).sendOtp(_fullNumber);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (_, next) {
      if (next.step == AuthStep.codeSent) {
        context.go(AppRoutes.otpVerify, extra: _fullNumber);
      }
      if (next.step == AuthStep.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Erreur'), backgroundColor: Colors.red),
        );
      }
    });

    final isLoading = authState.step == AuthStep.loading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Text('Unité 226',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Entrez votre numéro de téléphone burkinabè',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  decoration: const InputDecoration(
                    prefixText: '+226 ',
                    prefixStyle: TextStyle(fontWeight: FontWeight.bold),
                    labelText: 'Numéro de téléphone',
                    hintText: 'XX XX XX XX',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Recevoir le code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
