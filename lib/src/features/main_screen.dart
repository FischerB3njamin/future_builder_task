import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController zip = TextEditingController();
  Future<http.Response>? cityFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: zip,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Postleitzahl"),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () => setState(() {
                  cityFuture = getCityFromZip(zip.text);
                }),
                child: const Text("Suche"),
              ),
              const SizedBox(height: 32),
              FutureBuilder<http.Response>(
                future: cityFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text("Fehler aufgetreten");
                  } else if (snapshot.hasData) {
                    final data = snapshot.data?.body ?? '';
                    return data.length >
                            3 // empty data -> result is empty list ('[]')
                        ? Text(jsonDecode(data).first['name'] ??
                            'Unbekannter Name')
                        : const Text('Ungültige Postleitzahl');
                  } else {
                    return const Text("Ergebnis: Noch keine PLZ gesucht");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    zip.dispose();
    super.dispose();
  }

  Future<http.Response> getCityFromZip(String zip) {
    return http
        .get(Uri.parse("https://openplzapi.org/de/Localities?postalCode=$zip"));
  }
}
