import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> refreshAccessToken() async {
  final dio = Dio();
  final clientId     = dotenv.env['CLIENT_ID']!;
  final clientSecret = dotenv.env['CLIENT_SECRET']!;
  final refreshToken = dotenv.env['REFRESH_TOKEN']!;
  String tokenUrl = dotenv.env['ENDPOINT']!;
  final response = await dio.post(
    tokenUrl,
    options: Options(contentType: Headers.formUrlEncodedContentType),
    data: {
      'client_id': clientId,
      'client_secret': clientSecret,
      'refresh_token': refreshToken,
      'grant_type': 'refresh_token',
    },
  );

  if (response.statusCode == 200) {
    final data = response.data;
    final newToken = data['access_token'] as String;
    return newToken;
  } else {
    throw Exception(
      'Failed to refresh token: ${response.statusCode} ${response.statusMessage}',
    );
  }
}
