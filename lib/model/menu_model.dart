class Menu {
  String id;
  final String name;
  final String image;
  final String imageFileName;

  Menu(
      {this.id = '',
      required this.name,
      this.image = '',
      this.imageFileName = ''});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'imageFileName': imageFileName,
      };

  static Menu fromJson(Map<String, dynamic> json) => Menu(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        image: json['image'] ?? '',
        imageFileName: json['imageFileName'] ?? '',
      );
}
