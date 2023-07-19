// ignore: unused_import
import 'package:texapon/models/zone.dart';

class Site {
  final String siteId;
  final String name;

  const Site({
    required this.siteId,
    required this.name,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      siteId: json['id_site'],
      name: json['name'],
    );
  }
}
