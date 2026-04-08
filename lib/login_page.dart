import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart'; // AdminPanel र UserHome यहीँ छ भने यो चाहिन्छ

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  // यहाँ आफ्नो नयाँ Admin Email राख्नुहोस्
  final String adminEmail = "sandeshbhujel630@gmail.com"; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("NEXORA GAMING", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
            const SizedBox(height: 40),
            TextField(controller: _email, style: TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Email", labelStyle: TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent)))),
            const SizedBox(height: 15),
            TextField(controller: _pass, obscureText: true, style: TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Password", labelStyle: TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent)))),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.orangeAccent),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _email.text.trim(), 
                    password: _pass.text.trim()
                  );
                  // लगइन सफल भएपछि AuthWrapper ले आफैँ Admin वा User मा लैजान्छ
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
                }
              }, 
              child: const Text("LOGIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
            ),
            TextButton(
              onPressed: () => FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim()), 
              child: const Text("Create New Account", style: TextStyle(color: Colors.orangeAccent))
            ),
          ],
        ),
      ),
    );
  }
}

