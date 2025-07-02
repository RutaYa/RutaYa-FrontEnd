import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rutaya/application/save_tour_package_use_case.dart';
import 'package:rutaya/data/repositories/message_repository_impl.dart';
import 'package:rutaya/domain/repositories/message_repository.dart';
import 'application/login_use_case.dart';
import 'ui/pages/main/main_page.dart';
import 'core/routes/app_routes.dart';
import 'domain/entities/destination.dart';
//use cases
import 'application/save_travel_dates_use_case.dart';
import 'application/register_use_case.dart';
import 'application/get_home_data_use_case.dart';
import 'application/alter_favorite_use_case.dart';
import 'application/get_travel_dates_use_case.dart';
import 'application/pay_tour_package_use_case.dart';
import 'application/delete_tour_package_use_case.dart';
import 'application/send_message_use_case.dart';
import 'application/edit_profile_use_case.dart';
import 'application/change_password_use_case.dart';
import 'application/get_user_preferences.dart';
import 'application/save_user_preferences_use_case.dart';
import 'application/get_tour_packages_use_case.dart';
import 'application/rate_destination_use_case.dart';
import 'application/rate_package_use_case.dart';
import 'application/get_rated_destinations_use_case.dart';
import 'application/get_rated_packages_use_case.dart';
import 'application/get_community_rate_use_case.dart';
import 'application/delete_destination_rate_use_case.dart';
import 'application/delete_tour_rate_use_case.dart';
//repository impl
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/home_repository_impl.dart';
import 'data/repositories/travels_repository_impl.dart';
import 'data/repositories/preferences_repository_impl.dart';
import 'data/repositories/tour_repository_impl.dart';
import 'data/repositories/rate_repository_impl.dart';
//repository
import 'domain/repositories/user_repository.dart';
import 'domain/repositories/home_repository.dart';
import 'domain/repositories/travels_repository.dart';
import 'domain/repositories/preferences_repository.dart';
import 'domain/repositories/tour_repository.dart';
import 'domain/repositories/rate_repository.dart';
//api
import 'data/api/user_api.dart';
import 'data/api/home_api.dart';
import 'data/api/travel_api.dart';
import 'data/api/preference_api.dart';
import 'data/api/message_api.dart';
import 'data/api/tour_api.dart';
import 'data/api/rate_api.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final getIt = GetIt.instance;

void main() {
  // Data Layer - APIs
  getIt.registerLazySingleton<UserApi>(() => UserApi());
  getIt.registerLazySingleton<HomeApi>(() => HomeApi());
  getIt.registerLazySingleton<TravelApi>(() => TravelApi());
  getIt.registerLazySingleton<MessageApi>(() => MessageApi());
  getIt.registerLazySingleton<PreferenceApi>(() => PreferenceApi());
  getIt.registerLazySingleton<TourApi>(() => TourApi());
  getIt.registerLazySingleton<RateApi>(() => RateApi());

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
  getIt.registerLazySingleton<TourRepository>(() =>
      TourRepositoryImpl(getIt<TourApi>())
  );
  getIt.registerLazySingleton<RateRepository>(() =>
      RateRepositoryImpl(getIt<RateApi>())
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
  getIt.registerLazySingleton<EditProfileUseCase>(() =>
      EditProfileUseCase(getIt<UserRepository>())
  );
  getIt.registerLazySingleton<ChangePasswordUseCase>(() =>
      ChangePasswordUseCase(getIt<UserRepository>())
  );
  getIt.registerLazySingleton<SaveTourPackageUseCase>(() =>
      SaveTourPackageUseCase(getIt<TourRepository>())
  );
  getIt.registerLazySingleton<PayTourPackageUseCase>(() =>
      PayTourPackageUseCase(getIt<TourRepository>())
  );
  getIt.registerLazySingleton<DeleteTourPackageUseCase>(() =>
      DeleteTourPackageUseCase(getIt<TourRepository>())
  );
  getIt.registerLazySingleton<GetTourPackagesUseCase>(() =>
      GetTourPackagesUseCase(getIt<TourRepository>())
  );
  getIt.registerLazySingleton<RatePackageUseCase>(() =>
      RatePackageUseCase(getIt<RateRepository>())
  );
  getIt.registerLazySingleton<RateDestinationUseCase>(() =>
      RateDestinationUseCase(getIt<RateRepository>())
  );
  getIt.registerLazySingleton<GetRatedPackagesUseCase>(() =>
      GetRatedPackagesUseCase(getIt<RateRepository>())
  );
  getIt.registerLazySingleton<GetRatedDestinationsUseCase>(() =>
      GetRatedDestinationsUseCase(getIt<RateRepository>())
  );
  getIt.registerLazySingleton<GetCommunityRateUseCase>(() =>
      GetCommunityRateUseCase(getIt<RateRepository>())
  );

  getIt.registerLazySingleton<DeleteDestinationRateUseCase>(() =>
      DeleteDestinationRateUseCase(getIt<RateRepository>())
  );
  getIt.registerLazySingleton<DeleteTourRateUseCase>(() =>
      DeleteTourRateUseCase(getIt<RateRepository>())
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
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Español
          Locale('en', 'US'), // Inglés como respaldo
        ],
        locale: const Locale('es', 'ES'),
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
