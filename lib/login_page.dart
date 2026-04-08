import 'package:flutter/material.dart';
import 'home_page.dart'; // होम पेजको फाइल इम्पोर्ट गरेको

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("NEXORA GAMING", style: TextStyle(color: Colors.orange, fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(decoration: InputDecoration(labelText: "Email", labelStyle: TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)))),
            const SizedBox(height: 20),
            TextField(obscureText: true, decoration: InputDecoration(labelText: "Password", labelStyle: TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)))),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                // लगइन थिच्दा सिधै होमपेजमा लैजाने कोड
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
              },
              child: const Text("LOGIN", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

