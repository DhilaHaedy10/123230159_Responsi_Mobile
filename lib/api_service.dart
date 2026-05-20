import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://kitsu.io/api/edge/anime/?page[limit]=20&page[offset]=0';

  static Future<List<dynamic>> fetchAllAnimes() async {
    final response = await http.get(Uri.parse('$_baseUrl/animes'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat daftar anime');
    }
  }

  static Future<Map<String, dynamic>> fetchAnimesDetail(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/anime?id=$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat detail anime');
    }
  }
}