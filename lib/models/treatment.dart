import 'dart:convert';

import 'generator.dart';

class Treatment {
  final int id;
  final String etatTraitements;
  DateTime? dateEstimativeProchaineVidange;
  Generator generator;

  Treatment({
    required this.id,
    required this.etatTraitements,
    required this.dateEstimativeProchaineVidange,
    required this.generator,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'],
      etatTraitements: json['EtatTraitement'],
      dateEstimativeProchaineVidange:
          json['date_estimative_prochaine_vidange'] != null
              ? DateTime.parse(json['date_estimative_prochaine_vidange'])
              : null,
      generator: Generator.fromJson(json['generator']),
    );
  }
}

List<Treatment> parseTreatmentsToList(String jsonString) {
  final parsed = json.decode(jsonString).cast<Map<String, dynamic>>();
  return parsed.map<Treatment>((json) => Treatment.fromJson(json)).toList();
}
