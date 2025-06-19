import 'dart:convert';
import 'package:http/http.dart' as http;
import 'common/api_constants.dart';
import '../repositories/local_storage_service.dart';
import '../../domain/entities/tour_package.dart';

class TourApi {
  final localStorageService = LocalStorageService();
  final String baseUrl = ApiConstants.baseUrl;

  Future<bool> saveTourPackage(TourPackage tourPackage) async {
    try {
      final userId = await localStorageService.getCurrentUserId();

      final response = await http.post(
        Uri.parse('$baseUrl/tour/add/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'title': tourPackage.title,
          'description': tourPackage.description,
          'start_date': tourPackage.startDate,
          'days': tourPackage.days,
          'quantity': tourPackage.quantity,
          'price': tourPackage.price,
          'itinerary': tourPackage.itinerary.map((item) => item.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Paquete turístico guardado exitosamente');
        return true;
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al guardar paquete turístico: $e');
      return false;
    }
  }

  Future<List<TourPackage>> getTourPackages() async {
    try {
      final userId = await localStorageService.getCurrentUserId();

      final response = await http.get(
        Uri.parse('$baseUrl/tour/user/$userId/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((packageJson) => TourPackage.fromJson(packageJson)).toList();
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener paquetes turísticos: $e');
      return [];
    }
  }

  Future<bool> payTourPackage(int tourId) async {
    try {
      final userId = await localStorageService.getCurrentUserId();

      final response = await http.put(
        Uri.parse('$baseUrl/tour/pay/$tourId/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Paquete turístico pagado exitosamente');
        return true;
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al pagar paquete turístico: $e');
      return false;
    }
  }

  Future<bool> deleteTourPackage(int tourId) async {
    try {
      final userId = await localStorageService.getCurrentUserId();

      if (userId == null) {
        print('Error: No se encontró el userId');
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/tour/delete/$tourId/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Paquete turístico eliminado exitosamente');
        return true;
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al eliminar paquete turístico: $e');
      return false;
    }
  }
}