import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String appId = 'f3281018';
  final String appKey = 'fd6b58158e2b75191f60caa1c9862812';

  Future<Map<String, dynamic>> searchRecipes(String query,
      {Map<String, dynamic>? filters}) async {
    final uri = Uri.https(
      'api.edamam.com',
      '/search',
      {
        'q': query,
        'app_id': appId,
        'app_key': appKey,
        'from': '0',
        'to': '10',
        if (filters != null) ...filters,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar receitas');
    }
  }
}
