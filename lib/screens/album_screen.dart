import 'package:gallery/package.dart';
import 'package:intl/intl.dart';

class AlbumScreen extends StatefulWidget {
  final String fileId;
  final String fileName;
  const AlbumScreen({super.key, required this.fileId, required this.fileName});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<AlbumService>();
      prov.reset();
      prov.fetchAlbum(folderId: widget.fileId);
    });
  }

  Future<void> _onUploadTap() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final prov = context.read<AlbumService>();
    final created = await prov.uploadImage(
      imageFile: file,
      folderId: widget.fileId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          created != null
              ? 'Uploaded "${created.name}"'
              : 'Error: ${prov.error ?? "Unknown"}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AlbumService>();
    
  
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.fileName,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: _onUploadTap,
        child: const Icon(Icons.upload, color: Colors.black),
      ),
      body: _buildBody(prov),
    );
  }

  Widget _buildBody(AlbumService prov) {
    if (prov.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.error != null) {
      return Center(
        child: Text(
          'Error: ${prov.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (prov.album.isEmpty) {
      return const Center(
        child: Text(
          'No photos found.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Group by date
    final now = DateTime.now();
    final Map<String, List<Albums>> grouped = {};
    for (var f in prov.album) {
      final d = f.createdTime.toLocal();
      final key =
          (d.year == now.year && d.month == now.month && d.day == now.day)
              ? 'Today'
              : DateFormat('MMMM d').format(d);
      grouped.putIfAbsent(key, () => []).add(f);
    }

    final sections = grouped.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: sections.length,
      itemBuilder: (_, idx) {
        final title = sections[idx].key;
        final items = sections[idx].value;
        return SectionGrid(title: title, items: items);
      },
    );
  }
}
