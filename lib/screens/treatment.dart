// This is the login page widget
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;

// ignore: unused_import
import '../constants/constants.dart';
import '../models/agent.dart';
import '../models/treatment.dart';
import '../models/vidange.dart';
import 'confirm_drain_creation.dart';

class TreatmentDetailsPage extends HookWidget {
  const TreatmentDetailsPage(
      {Key? key,
      required this.treatment,
      required this.agent,
      required this.updateTreatments})
      : super(key: key);

  final Treatment treatment;
  final Function(
    int treatmentId,
    int regime,
    DateTime? dateEstimativeProchaineVidange,
  ) updateTreatments;
  final Agent agent;
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // Build method for the widget
  @override
  Widget build(BuildContext context) {
    final vidanges = useState<List<Vidange>>([]);

    getVidanges() async {
      try {
        final response = await http.get(
          Uri.parse("$baseUrl/v1/vidanges/treatment/${treatment.id}"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': "Bearer ${agent.token}"
          },
        );
        print(response.body);
        if (response.statusCode == 200) {
          vidanges.value = parseVidangesToList(response.body).reversed.toList();
        } else {
          print("Echec");
        }
      } catch (e) {
        print(e);
      }
    }

    useEffect(() {
      getVidanges();
      return () {};
    }, []);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0170BC),
          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    "${agent.prenom} ${agent.nom}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                )
              ],
            )
          ],
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: const Color.fromARGB(34, 0, 0, 0)),
                    borderRadius: BorderRadius.circular(24)),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/tower.png",
                      height: 120,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(treatment.generator.site.siteId,
                            style: const TextStyle(
                                color: Color(0xFF0071BC),
                                fontWeight: FontWeight.w400,
                                fontSize: 14)),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          treatment.generator.site.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF0071BC),
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("Régime actuel",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(
                          height: 2,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.settings,
                              color: Color(0xFF0071BC),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text("H${treatment.generator.regimeFonctionnement}")
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        const Text("Estimation date à vidanger",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          treatment.dateEstimativeProchaineVidange
                                  ?.toLocal()
                                  .toString() ??
                              "Aucune",
                          style: const TextStyle(
                              color: Color(0xFF0071BC),
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              vidanges.value.isNotEmpty &&
                      DateTime.now()
                              .difference(vidanges.value.first.dateExec)
                              .inDays >
                          4
                  ? ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ConfirmDrainCreationPage(
                              treatment: treatment,
                              agent: agent,
                              updateTreatments: updateTreatments,
                            ),
                          ),
                        );
                      },
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                                horizontal: 32.0, vertical: 16.0),
                          ),
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xFF0170BC))),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Ajouter une vidange",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 20,
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                itemCount: vidanges.value.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color.fromARGB(34, 0, 0, 0)),
                        borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Date de la vidange",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                            vidanges.value[index].dateExec.toLocal().toString(),
                            style: const TextStyle(
                                color: Color(0xFF0071BC),
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        const SizedBox(
                          height: 4,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        const Text(
                          "Nombre d'heures vidangé",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          vidanges.value[index].nbreHeures.toString(),
                          style: const TextStyle(
                              color: Color(0xFF0071BC),
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        const Text(
                          "Heures de retard",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          vidanges.value[index].nbreHeuresRetard.toString(),
                          style: const TextStyle(
                              color: Color(0xFF0071BC),
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ))));
  }
}
