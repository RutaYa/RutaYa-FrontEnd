import 'dart:convert';
import 'package:http/http.dart' as http;
import 'common/api_constants.dart';
import '../../domain/entities/destination_rate.dart';
import '../../domain/entities/package_rate.dart';
import '../repositories/local_storage_service.dart';

class RateApi {
  final localStorageService = LocalStorageService();
  final String baseUrl = ApiConstants.baseUrl;

  // CREAR CALIFICACIÓN PARA DESTINO
  Future<bool> createRatedDestination({
    required int destinationId,
    required int stars,
    required String comment,
    required String createdAt,
  }) async {

    final userId = await localStorageService.getCurrentUserId();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rate-destinations/add/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'destinationId': destinationId,
          'stars': stars,
          'comment': comment,
          'created_at': createdAt,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception en createRatedDestination: $e');
      return false;
    }
  }

  // CREAR CALIFICACIÓN PARA PAQUETE TURÍSTICO
  Future<bool> createRatedPackage({
    required int tourPackageId,
    required int stars,
    required String comment,
    required String createdAt,
  }) async {

    final userId = await localStorageService.getCurrentUserId();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rate-package/add/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'tourPackageId': tourPackageId,
          'stars': stars,
          'comment': comment,
          'created_at': createdAt,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception en createRatedPackage: $e');
      return false;
    }
  }

  // OBTENER TODAS LAS CALIFICACIONES DE DESTINOS
  Future<List<DestinationRate>> getRatedDestinations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rate-destinations/list/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> rates = responseData['rates'];

        return rates.map((rateJson) => DestinationRate.fromJson(rateJson)).toList();
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener calificaciones de destinos: $e');
      return [];
    }
  }

  // OBTENER TODAS LAS CALIFICACIONES DE PAQUETES TURÍSTICOS
  Future<List<PackageRate>> getRatedPackages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rate-package/list/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> rates = responseData['rates'];

        return rates.map((rateJson) => PackageRate.fromJson(rateJson)).toList();
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener calificaciones de paquetes: $e');
      return [];
    }
  }
}