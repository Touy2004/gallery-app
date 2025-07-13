import 'package:gallery/package.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _rootFolderId = '1IarLE1DfVgOUOHYu5vs4WuyDgKIRwe7w';

  @override
  void initState() {
    super.initState();
    // load albums on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlbumsService>().fetchFiles(folderId: _rootFolderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AlbumsService>();

    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const DrawerCustom(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Gallery',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed:
                prov.isLoading
                    ? null
                    : () => prov.fetchFiles(folderId: _rootFolderId),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Albums:',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 12),

            // Loading / error / empty states
            if (prov.isLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (prov.error != null) ...[
              Center(
                child: Text(
                  'Error: ${prov.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ] else if (prov.files.isEmpty) ...[
              const Center(
                child: Text(
                  'No Albums found.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ] else ...[
              Expanded(
                child: ListView.separated(
                  itemCount: prov.files.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (_, i) {
                    final file = prov.files[i];
                    return AlbumRow(
                      file: file,
                      onDelete: () => _deleteAlbum(context, file.id, file.name),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => AlbumScreen(
                                    fileId: file.id,
                                    fileName: file.name,
                                  ),
                            ),
                          ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: const FloatingActionButtonWidget(),
    );
  }

  Future<void> _deleteAlbum(
    BuildContext context,
    String id,
    String name,
  ) async {
    final prov = context.read<AlbumsService>();
    // remove locally for instant feedback
    prov.deleteAlbum(id);

    final success = await prov.deleteAlbum(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Deleted "$name"'
              : 'Failed to delete "$name": ${prov.error}',
        ),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
    if (!success) {
      // reload if it failed
      prov.fetchFiles(folderId: _rootFolderId);
    }
  }
}
