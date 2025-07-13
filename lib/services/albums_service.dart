import 'package:gallery/package.dart';

class AlbumsService extends ChangeNotifier {
  final Dio _dio;
  List<Albums> _albums = [];
  String? _nextPageToken;
  bool _isLoading = false;
  String? _error;
  // Albums? _lastFile;
  // Albums? get lastFile => _lastFile;

  AlbumsService({Dio? dio})
    : _dio =
          dio ??
          Dio(BaseOptions(baseUrl: 'https://www.googleapis.com/drive/v3'));

  List<Albums> get files => _albums;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get nextPageToken => _nextPageToken;
  Future<void> fetchFiles({
    int pageSize = 100,
    required String folderId,
  }) async {
    final String accessToken = await refreshAccessToken();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _dio.get(
        '/files',
        queryParameters: {
          'q': "'$folderId' in parents and trashed=false",
          'pageSize': pageSize,
          'fields': 'nextPageToken, files(id, name, mimeType, createdTime)',
          if (_nextPageToken != null) 'pageToken': _nextPageToken,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (resp.statusCode == 200) {
        _nextPageToken = resp.data['nextPageToken'];
        _albums =
            (resp.data['files'] as List)
                .map((f) => Albums.fromJson(f as Map<String, dynamic>))
                .toList();
      } else if (resp.statusCode == 401) {
        _error = 'Unauthorized - try refreshing your login.';
      } else {
        _error = 'Drive API error: ${resp.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<Albums?> createAlbum({
    required String name,
    String parentId = '1IarLE1DfVgOUOHYu5vs4WuyDgKIRwe7w',
  }) async {
    final String accessToken = await refreshAccessToken();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = {
        'name': name,
        'mimeType': 'application/vnd.google-apps.folder',
        'parents': [parentId],
      };

      final resp = await _dio.post(
        '/files',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final newFolder = Albums.fromJson(resp.data as Map<String, dynamic>);
        _albums.insert(0, newFolder);
        notifyListeners();
        return newFolder;
      } else if (resp.statusCode == 401) {
        _error = 'Unauthorized - please sign in again.';
      } else {
        _error = 'Failed to create folder: ${resp.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return null;
  }

  Future<bool> deleteAlbum(String fileId) async {
    final String accessToken = await refreshAccessToken();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _dio.delete(
        '/files/$fileId',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (resp.statusCode == 204) {
        _albums.removeWhere((a) => a.id == fileId);
        notifyListeners();
        return true;
      } else if (resp.statusCode == 401) {
        _error = 'Unauthorized - please sign in again.';
      } else {
        _error = 'Failed to delete: HTTP ${resp.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  void reset() {
    _albums = [];
    _nextPageToken = null;
    notifyListeners();
  }
}
