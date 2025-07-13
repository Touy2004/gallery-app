import 'package:gallery/package.dart';

class AuthService extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _auth.currentUser;

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      onError('All fields are required.');
      return;
    }

    _setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user?.uid;
      if (uid == null) throw Exception('User ID is null');

      await _db.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName':  lastName,
        'email':     email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      onSuccess();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          onError('The password is too weak.');
          break;
        case 'email-already-in-use':
          onError('An account already exists for that email.');
          break;
        case 'invalid-email':
          onError('That email address is invalid.');
          break;
        default:
          onError(e.message ?? e.code);
      }
    } catch (e) {
      onError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      onError('Email & password are required.');
      return;
    }

    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      onSuccess();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          onError('No user found for that email.');
          break;
        case 'wrong-password':
          onError('Wrong password.');
          break;
        default:
          onError(e.message ?? e.code);
      }
    } catch (e) {
      onError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
