import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL murni tanpa penumpukan endpoint
  static const String _baseUrl = 'https://kitsu.io/api/edge';

  // Ambil daftar anime untuk halaman Home
  static Future<List<dynamic>> fetchAllAnimes() async {
    final response = await http.get(Uri.parse('$_baseUrl/anime?page[limit]=20&page[offset]=0'));
    if (response.statusCode == 200) {
      // final Map<String, dynamic> decodedData = json.decode(response.body);
      return json.decode(response.body)['data']; // Mengembalikan List dari dalam key 'data'
    } else {
      throw Exception('Gagal memuat daftar anime');
    }
  }

  // Ambil detail anime berdasarkan ID berbentuk String
  static Future<Map<String, dynamic>> fetchAnimesDetail(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/anime/$id'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData = json.decode(response.body);
      return decodedData['data']; // Mengembalikan Map Objek tunggal dari dalam key 'data'
    } else {
      throw Exception('Gagal memuat detail anime');
    }
  }
}