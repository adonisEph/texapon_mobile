// This is the login page widget
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// ignore: unused_import
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:http/http.dart' as http;
// ignore: unused_import
import 'package:texapon/screens/dashboard.dart';
// ignore: unused_import
import 'package:texapon/screens/treatment.dart';

// ignore: unused_import
import '../constants/constants.dart';
import '../models/agent.dart';
import '../models/treatment.dart';
import '../models/vidange.dart';

class ConfirmDrainCreationPage extends HookWidget {
  const ConfirmDrainCreationPage(
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
    // ignore: unused_local_variable
    final vidanges = useState<List<Vidange>>([]);
    final isDrainDone = useState(false);
    final retardOverview = useState(0);
    final regimeOverview = useState(0);
    final drainAlreadyDone = useState(false);
    useState<DateTime>(DateTime.now());
    final dateEstimativeOverview = useState<DateTime?>(null);
    final diff_nbre_heuresOverview = useState(0);
    final nHs_actuels = useTextEditingController();

    sendData() async {
      try {
        final response = await http.post(
            Uri.parse("$baseUrl/v1/vidanges/treatment/${treatment.id}"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': "Bearer ${agent.token}"
            },
            body:
                jsonEncode({'nbre_heures': int.parse(nHs_actuels.value.text)}));
        if (response.statusCode == 201) {
          print("Success");
        } else {
          print("Echec");
        }
      } catch (e) {
        print(e);
      }
    }

    getOverview() async {
      try {
        final response = await http.post(
            Uri.parse(
                "$baseUrl/v1/vidanges/overview/treatment/${treatment.id}"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': "Bearer ${agent.token}"
            },
            body:
                jsonEncode({'nbre_heures': int.parse(nHs_actuels.value.text)}));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print(data);
          retardOverview.value = data["retard"];
          regimeOverview.value = data["regime"];
          dateEstimativeOverview.value =
              DateTime.parse(data["date_estimative_prochaine_vidange"]);
          diff_nbre_heuresOverview.value = data["diff_nbre_heures"];

          return response.statusCode;
        } else if (response.statusCode == 401) {
          drainAlreadyDone.value = true;
        } else {
          print("Echec");
        }
        return response.statusCode;
      } catch (e) {
        return 500;
      }
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0170BC),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.account_circle_sharp,
                size: 32,
              ),
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
              const Text(
                "Ajouter la vidange",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 40,
              ),
              Form(
                key: formKey,
                child: TextFormField(
                    controller: nHs_actuels,
                    validator: (value) {
                      if (value == "") {
                        return "Champ obligatoire";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      hintText: "Entrez le nombre d'heures actuelle",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50)),
                    )),
              ),
              Row(
                children: [
                  Switch(
                    value: isDrainDone.value,
                    onChanged: (value) {
                      isDrainDone.value = value;
                    },
                  ),
                  const Text("Confirmer vidange éffectuée")
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              isDrainDone.value
                  ? ElevatedButton(
                      onPressed: () {
                        // Envoyer la requête de connexion au serveur
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        getOverview().then((statusCode) {
                          if (statusCode == 401) {
                            showBarModalBottomSheet(
                                context: context,
                                builder: (context) => IntrinsicHeight(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: const [
                                            Icon(
                                              Icons.info,
                                              size: 64,
                                              color: Colors.orange,
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                                "Impossible de faire la vidange deux fois le même jour"),
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ));
                          }
                          if (statusCode == 200) {
                            showBarModalBottomSheet(
                                context: context,
                                builder: (context) => IntrinsicHeight(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Icon(
                                                  Icons.info,
                                                  size: 64,
                                                  color: Colors.orange,
                                                ),
                                              ],
                                            ),
                                            const Text(
                                              "Voulez-vous vraiment enregistrer cette vidange?",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Text(
                                              "Nouveau regime du générateur",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text(regimeOverview.value
                                                .toString()),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            const Text(
                                              "Différence de nombre d'heures",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text(diff_nbre_heuresOverview.value
                                                .toString()),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            const Text(
                                              "Date prochaine vidange",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text(dateEstimativeOverview.value
                                                .toString()),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            const Text(
                                              "Heures de retard",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text(retardOverview.value
                                                .toString()),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                sendData().then(
                                                  (_) => {
                                                    updateTreatments(
                                                        treatment.id,
                                                        regimeOverview.value,
                                                        dateEstimativeOverview
                                                            .value),
                                                    Navigator.of(context).pop(),
                                                    Navigator.of(context).pop(),
                                                    Navigator.of(context).pop()
                                                  },
                                                );
                                              },
                                              style: ButtonStyle(
                                                  shape:
                                                      MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0),
                                                    ),
                                                  ),
                                                  padding: MaterialStateProperty
                                                      .all<EdgeInsetsGeometry>(
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 32.0,
                                                        vertical: 16.0),
                                                  ),
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          const Color(
                                                              0xFF0170BC))),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Ajouter une vidange",
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ));
                          }
                        });
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Enregistrer",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ))));
  }
}
