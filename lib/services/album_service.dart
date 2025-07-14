import 'package:gallery/package.dart';

class AlbumService extends ChangeNotifier {
  final Dio _dio;
  List<Albums> _album = [];
  String? _nextPageToken;
  bool _isLoading = false;
  String? _error;

  AlbumService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://www.googleapis.com',
              sendTimeout: const Duration(milliseconds: 120000),
              receiveTimeout: const Duration(milliseconds: 120000),
            ),
          );

  List<Albums> get album => _album;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get nextPageToken => _nextPageToken;
  Future<void> fetchAlbum({
    required String folderId,
    int pageSize = 100,
  }) async {
    _setLoading(true);
    final token = await refreshAccessToken();
    try {
      final resp = await _dio.get(
        '/drive/v3/files',
        queryParameters: {
          'q': "'$folderId' in parents and trashed=false",
          'pageSize': pageSize,
          'fields':
              'nextPageToken, files(id, name, mimeType, createdTime, thumbnailLink)',
          if (_nextPageToken != null) 'pageToken': _nextPageToken,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (resp.statusCode == 200) {
        _nextPageToken = resp.data['nextPageToken'];
        _album =
            (resp.data['files'] as List)
                .map((f) => Albums.fromJson(f as Map<String, dynamic>))
                .toList();
      } else {
        _error = 'Error ${resp.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<Albums?> uploadImage({
    required File imageFile,
    required String folderId,
    String? description,
  }) async {
    _setLoading(true);

    final token = await refreshAccessToken();

    try {
      final meta = {
        'name': imageFile.path.split('/').last,
        if (description != null) 'description': description,
        'parents': [folderId],
      };

      // 3️⃣ build multipart form
      final form = FormData.fromMap({
        'metadata': MultipartFile.fromString(
          jsonEncode(meta),
          filename: 'metadata.json',
          contentType: MediaType('application', 'json'),
        ),
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType.parse(
            lookupMimeType(imageFile.path) ?? 'application/octet-stream',
          ),
        ),
      });

      final resp = await _dio.post(
        '/upload/drive/v3/files',
        queryParameters: {
          'uploadType': 'multipart',
          'fields': 'id,name,mimeType,createdTime,thumbnailLink',
        },
        data: form,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final created = Albums.fromJson(resp.data as Map<String, dynamic>);
        _album.insert(0, created); // show it at top
        return created;
      } else {
        _error = 'Upload failed (${resp.statusCode})';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }

    return null;
  }

  void reset() {
    _album = [];
    _nextPageToken = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
