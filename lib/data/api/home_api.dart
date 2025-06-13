import 'dart:convert';
import 'package:http/http.dart' as http;
import 'common/api_constants.dart';
import '../../domain/entities/home_response.dart';
import '../repositories/local_storage_service.dart';

class HomeApi {
  final localStorageService = LocalStorageService();
  final String baseUrl = ApiConstants.baseUrl;

  Future<HomeResponse?> getHomeData() async {
    final userId = await localStorageService.getCurrentUserId();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/home/$userId/'), // Corregido: usar interpolación en lugar de {userId}
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return HomeResponse.fromJson(data);
      } else {
        // Para debug, imprime el error
        print('Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception en HomeApi.getHomeData: $e');
      return null;
    }
  }

  Future<bool> alterFavorite(int destinationId, bool isFavorite) async {

    final userId = await localStorageService.getCurrentUserId();

    if (userId == null) return false;

    // Determinar URL y método según el estado del favorito
    final url = Uri.parse(
      isFavorite
          ? '$baseUrl/favorites/remove/'
          : '$baseUrl/favorites/add/',
    );

    final method = isFavorite ? 'DELETE' : 'POST';

    final body = json.encode({
      "userId": userId,
      "destinationId": destinationId,
    });

    try {
      http.Response response;

      // Ejecutar la solicitud HTTP adecuada
      if (method == 'POST') {
        print("Estoy agregando porque no estaba agregado");
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: body,
        );
      } else {
        print("Estoy elimnando porque estaba agregado");
        response = await http.delete(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: body,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception en HomeApi.alterFavorite: $e');
      return false;
    }
  }

}