import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/controllers/auth_controller.dart';

// Handler pour les messages reçus en background (top-level, hors classe)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase est déjà initialisé dans main.dart
  debugPrint('Message reçu en background: ${message.messageId}');
}

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db;
  final String _uid;

  FcmService(this._db, this._uid);

  Future<void> initialize() async {
    // Demander la permission (iOS + Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Enregistrer le token FCM dans Firestore
    await _saveToken();

    // Écouter les rafraîchissements de token
    _messaging.onTokenRefresh.listen(_saveToken);

    // Message reçu en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App ouverte depuis une notification (background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> _saveToken([String? newToken]) async {
    final token = newToken ?? await _messaging.getToken();
    if (token == null) return;
    await _db.collection('users').doc(_uid).update({'fcmToken': token});
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // En foreground on affiche juste un log — l'UI temps réel Firestore suffit
    debugPrint('Message foreground: ${message.notification?.title}');
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final groupId = message.data['groupId'];
    if (groupId != null) {
      // La navigation sera gérée via le router — on stocke le groupId en attente
      debugPrint('Ouvrir groupe: $groupId');
    }
  }
}

final fcmServiceProvider = Provider<FcmService?>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  return FcmService(ref.watch(firestoreProvider), user.uid);
});
