import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rutaya/data/repositories/message_repository_impl.dart';
import 'package:rutaya/domain/repositories/message_repository.dart';
import 'application/login_use_case.dart';
import 'ui/pages/main/main_page.dart';
import 'core/routes/app_routes.dart';
import 'domain/entities/destination.dart';
import 'application/register_use_case.dart';
import 'application/get_home_data_use_case.dart';
import 'application/alter_favorite_use_case.dart';
import 'application/get_travel_dates_use_case.dart';
import 'application/save_travel_dates_use_case.dart';
import 'application/send_message_use_case.dart';
import 'application/get_user_preferences.dart';
import 'application/save_user_preferences_use_case.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/home_repository_impl.dart';
import 'data/repositories/travels_repository_impl.dart';
import 'data/repositories/preferences_repository_impl.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/repositories/home_repository.dart';
import 'domain/repositories/travels_repository.dart';
import 'domain/repositories/preferences_repository.dart';
import 'data/api/user_api.dart';
import 'data/api/home_api.dart';
import 'data/api/travel_api.dart';
import 'data/api/preference_api.dart';
import 'data/api/message_api.dart';

final getIt = GetIt.instance;

void main() {
  // Data Layer - APIs
  getIt.registerLazySingleton<UserApi>(() => UserApi());
  getIt.registerLazySingleton<HomeApi>(() => HomeApi());
  getIt.registerLazySingleton<TravelApi>(() => TravelApi());
  getIt.registerLazySingleton<MessageApi>(() => MessageApi());
  getIt.registerLazySingleton<PreferenceApi>(() => PreferenceApi());

  // Data Layer - Repositories
  getIt.registerLazySingleton<UserRepository>(() =>
      UserRepositoryImpl(getIt<UserApi>())
  );
  getIt.registerLazySingleton<HomeRepository>(() =>
      HomeRepositoryImpl(getIt<HomeApi>())
  );
  getIt.registerLazySingleton<TravelsRepository>(() =>
      TravelsRepositoryImpl(getIt<TravelApi>())
  );
  getIt.registerLazySingleton<MessageRepository>(() =>
      MessageRepositoryImpl(getIt<MessageApi>())
  );
  getIt.registerLazySingleton<PreferencesRepository>(() =>
      PreferencesRepositoryImpl(getIt<PreferenceApi>())
  );

  // Domain Layer (use cases)
  getIt.registerLazySingleton<RegisterUseCase>(() =>
      RegisterUseCase(getIt<UserRepository>())
  );
  getIt.registerLazySingleton<LoginUseCase>(() =>
      LoginUseCase(getIt<UserRepository>())
  );
  getIt.registerLazySingleton<GetHomeDataUseCase>(() =>
      GetHomeDataUseCase(getIt<HomeRepository>())
  );
  getIt.registerLazySingleton<AlterFavoriteUseCase>(() =>
      AlterFavoriteUseCase(getIt<HomeRepository>())
  );
  getIt.registerLazySingleton<GetTravelDatesUseCase>(() =>
      GetTravelDatesUseCase(getIt<TravelsRepository>())
  );
  getIt.registerLazySingleton<SaveTravelDatesUseCase>(() =>
      SaveTravelDatesUseCase(getIt<TravelsRepository>())
  );
  getIt.registerLazySingleton<SendMessageUseCase>(() =>
      SendMessageUseCase(getIt<MessageRepository>())
  );
  getIt.registerLazySingleton<GetUserPreferences>(() =>
      GetUserPreferences(getIt<PreferencesRepository>())
  );
  getIt.registerLazySingleton<SaveUserPreferencesUseCase>(() =>
      SaveUserPreferencesUseCase(getIt<PreferencesRepository>())
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'RutasYa!',
        debugShowCheckedModeBanner: false, // Esto quita el banner de "Debug"
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFD0000),
            primary: const Color(0xFFF6211F),
          ),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.loading,  // Cambiado a la ruta de bienvenida
        routes: AppRoutes.routes,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.main) {
            final args = settings.arguments as Map<String, dynamic>?;
            final index = args?['initialIndex'] ?? 0;
            final destination = args?['destination'] as Destination?;
            return MaterialPageRoute(
              builder: (_) => MainPage(initialIndex: index, destination: destination),
            );
          }
          return null;
        }
    );
  }
}
