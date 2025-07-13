import 'package:gallery/package.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _openProfile(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  void _openPolicy(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PolicyScreen()));
  }

  void _openAboutUs(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AboutUsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildTile(
            context,
            icon: Icons.person,
            label: 'Profile',
            onTap: () => _openProfile(context),
          ),
          _buildDivider(),
          _buildTile(
            context,
            icon: Icons.policy,
            label: 'Privacy Policy',
            onTap: () => _openPolicy(context),
          ),
          _buildDivider(),
          _buildTile(
            context,
            icon: Icons.info,
            label: 'About Us',
            onTap: () => _openAboutUs(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.white24),
    );
  }
}
