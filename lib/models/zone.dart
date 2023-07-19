import 'package:texapon/models/site.dart';

class Zone {
  final int zoneId;
  final String? nameZone;
  final List<Site> sites;

  const Zone({
    required this.zoneId,
    required this.nameZone,
    required this.sites,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      zoneId: json['zone_id'],
      nameZone: json['name_zone'],
      sites: json['sites'],
    );
  }
}
