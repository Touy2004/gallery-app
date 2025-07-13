import 'package:gallery/package.dart';

class PhotoGalleryScreen extends StatelessWidget {
  final List<Albums> items;
  final int initialIndex;

  const PhotoGalleryScreen({
    super.key,
    required this.items,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: PhotoViewGallery.builder(
        pageController: PageController(initialPage: initialIndex),
        itemCount: items.length,
        builder: (ctx, i) {
          final file = items[i];
          final url = "https://lh3.googleusercontent.com/d/${file.id}?alt=media";
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(url),
            heroAttributes: PhotoViewHeroAttributes(tag: file.id),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        loadingBuilder: (ctx, event) => const Center(
          child: CircularProgressIndicator(),
        ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}
