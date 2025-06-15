import 'package:flutter/material.dart';
import '../../ui/pages/main/main_page.dart';
import '../../ui/pages/home/home_screen.dart';
import '../../ui/pages/chat/chat_screen.dart';
import '../../ui/pages/reservations/reservations_screen.dart';
import '../../ui/pages/community/community_screen.dart';
import '../../ui/pages/profile/profile_screen.dart';
import '../../ui/pages/authentication/login_screen.dart';
import '../../ui/pages/authentication/register_screen.dart';
import '../../ui/pages/loading_screen.dart';
import '../../domain/entities/destination.dart';

class AppRoutes {
  // Rutas de autenticación
  static const String loading = '/loading';
  static const String login = '/login';
  static const String register = '/register';

  static const String main = '/main';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String reservations = '/reservations';
  static const String community = '/community';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    // Rutas de autenticación
    loading: (_) => const LoadingScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),

    // Rutas básicas (sin parámetros)
    home: (_) => const HomeScreen(),
    chat: (_) => const ChatScreen(),
    reservations: (_) => const ReservationsScreen(),
    community: (_) => const CommunityScreen(),
    profile: (_) => const ProfileScreen(),
  };

  // ✅ MÉTODO PRINCIPAL PARA MANEJAR RUTAS CON PARÁMETROS
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    print('🚀 Navegando a: ${settings.name}');
    print('📦 Argumentos: ${settings.arguments}');

    switch (settings.name) {
      case main:
        final args = settings.arguments as Map<String, dynamic>?;
        final initialIndex = args?['initialIndex'] ?? 0;
        final destination = args?['destination'] as Destination?;

        print('🎯 MainPage - Index: $initialIndex, Destination: ${destination?.name}');

        return MaterialPageRoute(
          builder: (_) => MainPage(
            initialIndex: initialIndex,
            destination: destination,
          ),
        );

      case chat:
        final args = settings.arguments as Map<String, dynamic>?;
        final destination = args?['destination'] as Destination?;

        return MaterialPageRoute(
          builder: (_) => ChatScreen(destination: destination),
        );

      default:
        return null; // Para rutas no manejadas dinámicamente
    }
  }
}