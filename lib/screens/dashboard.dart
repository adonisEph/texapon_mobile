// This is the login page widget
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// ignore: unused_import
import 'package:texapon/models/generator.dart';
import 'package:texapon/models/treatment.dart';
import 'package:texapon/models/vidange.dart';
import 'package:texapon/screens/treatment.dart';
import '../constants/constants.dart';
import '../models/agent.dart';
import 'package:http/http.dart' as http;

class DashboardPage extends HookWidget {
  const DashboardPage({Key? key, required this.agent, required this.logout})
      : super(key: key);
  final Agent agent;
  final Function logout;
  // Build method for the widget
  @override
  Widget build(BuildContext context) {
    final treatments = useState<List<Treatment>>([]);
    final thisMonthVidanges = useState<List<Vidange>>([]);

    updateTreatments(
      int treatmentId,
      int regime,
      DateTime? dateEstimativeProchaineVidange,
    ) {
      final List<Treatment> data = treatments.value.map((treatment) {
        if (treatment.id == treatmentId) {
          treatment.generator.regimeFonctionnement = regime;
          treatment.dateEstimativeProchaineVidange =
              dateEstimativeProchaineVidange;
        }
        return treatment;
      }).toList();
      treatments.value = data;
    }

    getTreatments() async {
      try {
        final response =
            await http.post(Uri.parse("$baseUrl/v1/traitements/agent"),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                  'Authorization': "Bearer ${agent.token}"
                },
                body: jsonEncode({'agent_id': agent.id}));

        if (response.statusCode == 200) {
          print(response.body);
          List<Treatment> data = parseTreatmentsToList(response.body);
          treatments.value = data;
        }
      } catch (e) {
        print(e);
      }
    }

    int countVidangesWithNonZeroNbreHeuresRetard(List<Vidange> vidanges) {
      int count = 0;

      for (var vidange in vidanges) {
        if (vidange.nbreHeuresRetard != 0) {
          count++;
        }
      }

      return count;
    }

    List<Vidange> filterVidangesByCurrentMonthYear(List<Vidange> vidanges) {
      // Get the current month and year
      DateTime now = DateTime.now();
      int currentMonth = now.month;
      int currentYear = now.year;

      // Filter the Vidange instances based on the criteria
      List<Vidange> filteredVidanges = vidanges.where((vidange) {
        return vidange.dateExec.month == currentMonth &&
            vidange.dateExec.year == currentYear;
      }).toList();

      return filteredVidanges;
    }

    getVidanges() async {
      try {
        final response = await http.get(
          Uri.parse("$baseUrl/v1/get_user_dashboard_data/${agent.id}"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': "Bearer ${agent.token}"
          },
        );
        if (response.statusCode == 200) {
          thisMonthVidanges.value = filterVidangesByCurrentMonthYear(
              parseVidangesToList(response.body).reversed.toList());
          print(thisMonthVidanges);
        }
      } catch (e) {
        print(e);
      }
    }

    useEffect(() {
      getTreatments();
      getVidanges();
      return null;
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
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: 200,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.blueAccent)),
                  onPressed: () {
                    logout();
                  },
                  child: const Text("Déconnexion")),
            )
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xFF00395E),
                        Colors.blue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Mon tableau de bord",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text("Sites vidangés avant 250H ce mois",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14)),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                          (thisMonthVidanges.value.length -
                                  countVidangesWithNonZeroNbreHeuresRetard(
                                      thisMonthVidanges.value))
                              .toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text("Sites vidangés ce mois ci",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(thisMonthVidanges.value.length.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text("Sites vidangés au delà de 250H ce mois ci",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                          countVidangesWithNonZeroNbreHeuresRetard(
                                  thisMonthVidanges.value)
                              .toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ]),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Text("Mes sites",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 194, 43, 33),
                        borderRadius: BorderRadius.circular(100)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          treatments.value.length.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                itemCount: treatments.value.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TreatmentDetailsPage(
                            treatment: treatments.value[index],
                            agent: agent,
                            updateTreatments: updateTreatments),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color.fromARGB(34, 0, 0, 0)),
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/tower.png",
                          height: 100,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(treatments.value[index].generator.site.siteId,
                                style: const TextStyle(
                                    color: Color(0xFF0071BC),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14)),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              treatments.value[index].generator.site.name,
                              style: const TextStyle(
                                  color: Color(0xFF0071BC),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text("Estimation date à vidanger"),
                            Text(
                              treatments.value[index]
                                      .dateEstimativeProchaineVidange
                                      ?.toLocal()
                                      .toString() ??
                                  "Aucune",
                              style: const TextStyle(
                                  color: Color(0xFF0071BC),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ])),
      )),
    );
  }
}
