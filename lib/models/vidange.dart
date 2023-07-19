import 'dart:convert';

class Vidange {
  final int id;
  final DateTime dateExec;
  final int nbreHeures;
  final int nbreHeuresRetard;
  final int traitementId;

  const Vidange({
    required this.id,
    required this.dateExec,
    required this.nbreHeures,
    required this.nbreHeuresRetard,
    required this.traitementId,
  });

  factory Vidange.fromJson(Map<String, dynamic> json) {
    return Vidange(
      id: json['id'],
      dateExec: DateTime.parse(json['date_exec']),
      nbreHeuresRetard: json['nbre_heures_retard'],
      nbreHeures: json['nbre_heures'],
      traitementId: json['traitement_id'],
    );
  }
}

List<Vidange> parseVidangesToList(String jsonString) {
  final parsed = json.decode(jsonString).cast<Map<String, dynamic>>();
  return parsed.map<Vidange>((json) => Vidange.fromJson(json)).toList();
}
