class Albums {
  final String id;
  final String name;
  final String mimeType;
  final DateTime createdTime;

  Albums({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.createdTime,
  });

  factory Albums.fromJson(Map<String, dynamic> json) => Albums(
        id: json['id'],
        name: json['name'],
        mimeType: json['mimeType'],
        createdTime: DateTime.parse(json['createdTime']),
      );
}