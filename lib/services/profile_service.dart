import 'package:gallery/package.dart';

class ProfileService extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  String _firstName = '';
  String _lastName  = '';
  bool   _isLoading = false;
  String? _error;

  ProfileService() {
    _loadProfile();
  }

  String get firstName => _firstName;
  String get lastName  => _lastName;
  bool   get isLoading => _isLoading;
  String? get error    => _error;

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      _error = 'Not signed in';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await _db.collection('users').doc(user.uid).set({
          'firstName': '',
          'lastName': '',
        });
        _firstName = '';
        _lastName  = '';
      } else {
        final data = doc.data()!;
        _firstName = data['firstName'] ?? '';
        _lastName  = data['lastName'] ?? '';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      _error = 'Not signed in';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      await _db.collection('users').doc(user.uid).update({
        'firstName': firstName,
        'lastName': lastName,
      });
      // apply locally
      _firstName = firstName;
      _lastName  = lastName;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
