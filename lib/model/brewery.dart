///
/// 酒舗データクラス
///
class Brewery {
  final int id;
  final String name;
  final int areaId;

  Brewery({required this.id, required this.name, required this.areaId});

  factory Brewery.fromJson(Map<String, dynamic> json) {
    return Brewery(id: json['id'], name: json['name'], areaId: json['areaId']);
  }
}
