
import 'dart:convert';
import 'package:http/http.dart' as http;

class VersionService {
  static const url =
      'https://dev.onayipoteka.kz/clientCabinet/version.json';

  static Future<String?> getVersion() async {
    try {
      final uri = Uri.parse(url).replace(
        queryParameters: {
          't': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Cache-Control': 'no-cache, no-store',
          'Pragma': 'no-cache',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final version = data['version'];

      return version is String && version.isNotEmpty
          ? version
          : null;
    } catch (_) {
      return null;
    }
  }
}
