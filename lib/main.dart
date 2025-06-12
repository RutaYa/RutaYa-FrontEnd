import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'application/login_use_case.dart';
import 'core/routes/app_routes.dart';
import 'application/register_use_case.dart';
import 'application/get_home_data_use_case.dart';
import 'application/alter_favorite_use_case.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/home_repository_impl.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/repositories/home_repository.dart';
import 'data/api/user_api.dart';
import 'data/api/home_api.dart';

final getIt = GetIt.instance;

void main() {
  // Data Layer - APIs
  getIt.registerLazySingleton<UserApi>(() => UserApi());
  getIt.registerLazySingleton<HomeApi>(() => HomeApi());

  // Data Layer - Repositories
  getIt.registerLazySingleton<UserRepository>(() =>
      UserRepositoryImpl(getIt<UserApi>())
  );
  getIt.registerLazySingleton<HomeRepository>(() =>
      HomeRepositoryImpl(getIt<HomeApi>())
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
    );
  }
}
