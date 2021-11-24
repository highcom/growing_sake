class Brand {
  final int id;
  final String name;
  final int breweryId;

  Brand({required this.id, required this.name, required this.breweryId});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(id: json['id'], name: json['name'], breweryId: json['breweryId']);
  }
}