import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/profile_setup_screen.dart';
import '../features/auth/screens/pending_approval_screen.dart';
import '../features/groups/screens/group_list_screen.dart';
import '../features/messaging/screens/group_chat_screen.dart';
import '../features/profile/screens/profile_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/auth/login';
  static const profileSetup = '/auth/profile-setup';
  static const pending = '/auth/pending';
  static const groupList = '/groups';
  static const groupChat = '/groups/:groupId';
  static const profile = '/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  final userStream = ref.watch(currentUserProvider);
  final profileAsync = userStream.valueOrNull != null
      ? ref.watch(userProfileProvider(userStream.valueOrNull!.uid))
      : null;

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final user = userStream.valueOrNull;
      final loc = state.matchedLocation;

      if (userStream.isLoading) return null;

      if (user == null) {
        return loc == AppRoutes.login ? null : AppRoutes.login;
      }

      final profile = profileAsync?.valueOrNull;

      if (profileAsync == null || profileAsync.isLoading) return AppRoutes.splash;

      if (profile == null) {
        return loc == AppRoutes.profileSetup ? null : AppRoutes.profileSetup;
      }

      if (profile['accountStatus'] == 'pending' || profile['accountStatus'] == 'banned') {
        return loc == AppRoutes.pending ? null : AppRoutes.pending;
      }

      if (loc == AppRoutes.login || loc == AppRoutes.profileSetup ||
          loc == AppRoutes.pending || loc == AppRoutes.splash) {
        return AppRoutes.groupList;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, __) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.pending,
        builder: (_, __) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: AppRoutes.groupList,
        builder: (_, __) => const GroupListScreen(),
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
        builder: (_, __) => const ProfileScreen(),
      ),
    ],
  );
});
