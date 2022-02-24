///
/// 日本酒の製造地域データクラス
///
class Area {
  final int id;
  final String name;

  Area({required this.id, required this.name});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(id: json['id'], name: json['name']);
  }
}
