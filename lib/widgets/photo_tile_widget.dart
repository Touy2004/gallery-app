import 'package:gallery/package.dart';

class PhotoTile extends StatelessWidget {
  final Albums file;
  final List<Albums> allItems;
  final int index;
  const PhotoTile({
    super.key,
    required this.file,
    required this.allItems,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final url = 'https://lh3.googleusercontent.com/d/${file.id}?alt=media';
    return GestureDetector(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) =>
                      PhotoGalleryScreen(items: allItems, initialIndex: index),
            ),
          ),
      child: Hero(
        tag: file.id,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: Colors.grey[800],
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => const ColoredBox(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
