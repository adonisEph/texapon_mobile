import 'package:texapon/models/site.dart';

class Generator {
  final int id;
  final String serialNumber;
  final String modelGenerator;
  final String capacity;
  final Site site;
  int regimeFonctionnement;

  Generator({
    required this.id,
    required this.serialNumber,
    required this.modelGenerator,
    required this.capacity,
    required this.site,
    required this.regimeFonctionnement,
  });

  factory Generator.fromJson(Map<String, dynamic> json) {
    return Generator(
      id: json['id'],
      serialNumber: json['serial_number'],
      modelGenerator: json['model_generator'],
      capacity: json['capacity'],
      site: Site.fromJson(json['Site']),
      regimeFonctionnement: json['regime_fonctionnement'],
    );
  }
}
