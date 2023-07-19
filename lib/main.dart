import 'dart:convert';
//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texapon/screens/dashboard.dart';
import "./../constants/constants.dart";
import 'models/agent.dart';

void main() {
  runApp(const MyApp());
}

// This is the top-level widget for the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Build method for the widget
  @override
  Widget build(BuildContext context) {
    // The MaterialApp widget provides some basic configuration for the app,
    // such as the title, theme, and home page
    return MaterialApp(
      title: 'Texapon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

// This is the home page widget, which is not used in this app
class MyHomePage extends HookWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final future = useMemoized(SharedPreferences.getInstance);
    final snapshot = useFuture(future, initialData: null);
    final agent = useState<Agent>(const Agent(
      id: -1,
      prenom: "-1",
      nom: "-1",
      matriculeAgent: "-1",
      poste: "-1",
      token: "-1",
    ));

    logout() {
      agent.value = const Agent(
        id: -1,
        prenom: "-1",
        nom: "-1",
        matriculeAgent: "-1",
        poste: "-1",
        token: "-1",
      );
    }

    setAgent(Agent newagent) {
      agent.value = newagent;
    }

    useEffect(() {
      final prefs = snapshot.data;
      final data = prefs?.getString('agent');
      if (data != null) {
        agent.value =
            Agent.fromJson(jsonDecode(prefs?.getString('agent') as String));
      }

      return null;
    }, [snapshot.data, agent.value]);

    if (agent.value.id == -1) {
      return LoginPage(
        agent: agent.value,
        setAgent: setAgent,
      );
    }
    return DashboardPage(agent: agent.value, logout: logout);
  }
}

// This is the login page widget
class LoginPage extends HookWidget {
  const LoginPage({Key? key, required this.agent, required this.setAgent})
      : super(key: key);
  final Agent agent;
  final Function setAgent;

  // Build method for the widget
  @override
  Widget build(BuildContext context) {
    // The Scaffold widget provides a basic structure for the page,
    // including an app bar and body
    final username = useState<String?>(null);
    final password = useState<String?>(null);
    final hiddenPassword = useState<bool>(true);
    final failedToLogin = useState<bool>(false);

//connection (loggin to database) function
    handleLogin() async {
      //print(username.value);
      //print(password.value);
      if (username.value == null || password.value == null) {
        return;
      }
      try {
        final response = await http.post(
            Uri.parse("$baseUrl/authentification/login"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(
                {"username": username.value, "password": password.value}));
        //print(response.statusCode);
        if (response.statusCode != 201) {
          failedToLogin.value = true;
        } else {
          failedToLogin.value = false;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("agent", response.body);
          setAgent(Agent.fromJson(jsonDecode(response.body)));
        }
      } catch (e) {
        //print(e);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
          // The SafeArea widget ensures that the content is visible even
          // if the device's screen size is small
          child: SingleChildScrollView(
        // The SingleChildScrollView widget allows the content to be scrollable
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          // The Column widget allows the children widgets to be arranged vertically
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 45,
              ),
              const Text(
                "Bienvenue sur",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "TEXAPON-Mobile",
                style: TextStyle(
                    color: Color(0xFF0071BC),
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.4,
                child: const Text("Vidangez vos générateurs en toute sérénité",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                "Identifiez-vous",
                style: TextStyle(
                    color: Color(0xFF0071BC),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),

              failedToLogin.value
                  ? Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: MediaQuery.of(context).size.width / 1.4,
                      child: const Text(
                        "Username ou mot de passe incorrect. Veuillez réessayer",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 30,
              ),
              // The TextField widget creates an input field for the user
              // to enter their username
              TextField(
                  onChanged: (value) {
                    username.value = value;
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    hintText: "Username",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50)),
                  )),
              const SizedBox(
                height: 20,
              ),
              // The TextField widget creates an input field for the user
              // to enter their password
              TextField(
                  onChanged: (value) {
                    password.value = value;
                  },
                  obscureText: hiddenPassword.value,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                        onPressed: () {
                          hiddenPassword.value = !hiddenPassword.value;
                        },
                        icon: hiddenPassword.value
                            ? const Icon(Icons.remove_red_eye)
                            : const Icon(Icons.hide_source_rounded)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    hintText: "Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50)),
                  )),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  // Envoyer la requête de connexion au serveur
                  await handleLogin();
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 16.0),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFF0170BC))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Se connecter",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Image.asset("assets/images/logo.png")
            ],
          ),
        ),
      )),
    );
  }
}
