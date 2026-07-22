import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/screens/phone_input_screen.dart';
import '../features/auth/screens/otp_verify_screen.dart';
import '../features/auth/screens/profile_setup_screen.dart';
import '../features/groups/screens/group_list_screen.dart';
import '../features/messaging/screens/group_chat_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const phoneInput = '/auth/phone';
  static const otpVerify = '/auth/otp';
  static const profileSetup = '/auth/profile-setup';
  static const groupList = '/groups';
  static const groupChat = '/groups/:groupId';
  static const profile = '/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  final userStream = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final user = userStream.valueOrNull;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == AppRoutes.splash;

      if (isSplash) {
        return user != null ? AppRoutes.groupList : AppRoutes.phoneInput;
      }
      if (user == null && !isAuthRoute) return AppRoutes.phoneInput;
      if (user != null && isAuthRoute && state.matchedLocation != AppRoutes.profileSetup) {
        return AppRoutes.groupList;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.phoneInput,
        builder: (context, state) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerify,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpVerifyScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.groupList,
        builder: (context, state) => const GroupListScreen(),
      ),
      GoRoute(
        path: AppRoutes.groupChat,
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          final groupName = state.extra as String? ?? 'Groupe';
          return GroupChatScreen(groupId: groupId, groupName: groupName);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const _PlaceholderScreen(label: 'Profil'),
      ),
    ],
  );
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text(label)),
    );
  }
}
