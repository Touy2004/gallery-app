import 'package:gallery/package.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const _team = [
    {
      'name': 'Alice Nguyen',
      'imageUrl': 'https://via.placeholder.com/150/FFB6C1/000000?text=Alice',
      'role': 'Lead Developer',
    },
    {
      'name': 'Bob Chan',
      'imageUrl': 'https://via.placeholder.com/150/87CEFA/000000?text=Bob',
      'role': 'Backend Engineer',
    },
    {
      'name': 'Charlie Lee',
      'imageUrl': 'https://via.placeholder.com/150/90EE90/000000?text=Charlie',
      'role': 'UI/UX Designer',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('About Us', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        itemCount: _team.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (_, i) {
          final member = _team[i];
          return Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(member['imageUrl']!),
              ),
              const SizedBox(height: 12),
              Text(
                member['name']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                member['role']!,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          );
        },
      ),
    );
  }
}
