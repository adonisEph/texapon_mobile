class Agent {
  final int id;
  final String nom;
  final String prenom;
  final String poste;
  final String matriculeAgent;
  final String token;

  const Agent({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.matriculeAgent,
    required this.poste,
    required this.token,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      matriculeAgent: json['matricule_agent'],
      poste: json['poste'],
      token: json['token'],
    );
  }
}
