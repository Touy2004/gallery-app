import 'package:gallery/package.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  static const _policyText = '''
**Privacy Policy**

1. **Data Collection**  
We do not collect any personal data unless you explicitly provide it. All data you enter (e.g., profile information) stays on your device or in your chosen cloud storage.

2. **Usage Data**  
We may collect anonymous usage statistics (such as which screens are viewed most often) to help us improve the app. No personally identifiable information is stored.

3. **Third-Party Services**  
This app uses Google Drive APIs to upload and manage your files. Please refer to Google's own privacy policy for how they handle your data: https://policies.google.com/privacy

4. **Security**  
All network communication is done over HTTPS. We do not store your OAuth tokens on our servers; they remain on your device.

5. **Changes to This Policy**  
We may update this policy occasionally. In-app notifications will alert you to any major changes.

_Last updated: July 14, 2025_
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText(
            _policyText,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
        ),
      ),
    );
  }
}
