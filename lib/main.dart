import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';

// --- CONFIGURATION ---
const String adminEmail = "sandeshbhujel630@gmail.com";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const NexoraProApp());
}

class NexoraProApp extends StatelessWidget {
  const NexoraProApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.orangeAccent,
        scaffoldBackgroundColor: const Color(0xFF0F1216),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data?.email == adminEmail ? const AdminPanel() : const UserHome();
        }
        return const LoginPage();
      },
    );
  }
}

// --- 1. USER HOME ---
class UserHome extends StatefulWidget {
  const UserHome({super.key});
  @override State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [const NoticeBoard(), const DiamondStore(), const TournamentList(), const WalletPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NEXORA GAMING", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
        actions: [
          // माथि + आइकनमा क्लिक गर्दा सिधै वालेट (QR) मा लैजाने
          IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent), onPressed: () => setState(() => _selectedIndex = 3)),
          IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notice'),
          BottomNavigationBarItem(icon: Icon(Icons.diamond), label: 'Topup'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'Matches'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
        ],
      ),
    );
  }
}

// --- NOTICE BOARD ---
class NoticeBoard extends StatelessWidget {
  const NoticeBoard({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('notices').orderBy('time', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var notice = snapshot.data!.docs[index];
            return Card(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: [
                  if (notice['imageUrl'] != "") Image.network(notice['imageUrl']),
                  ListTile(title: Text(notice['title']), subtitle: Text(notice['body'])),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// --- WALLET PAGE (QR & UPLOAD) ---
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});
  @override State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  File? _image;
  final _amount = TextEditingController();
  final _picker = ImagePicker();

  Future _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("Scan QR to Pay", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          // यहाँ आफ्नो QR Code को लिङ्क हाल्नुहोस्
          Image.network("https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=NexoraGamingPay", height: 200),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150, width: double.infinity,
              decoration: BoxDecoration(border: Border.all(color: Colors.orangeAccent), borderRadius: BorderRadius.circular(10)),
              child: _image == null ? const Icon(Icons.add_a_photo, size: 50) : Image.file(_image!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 15),
          TextField(controller: _amount, decoration: const InputDecoration(labelText: "Enter Amount (Rs)", border: OutlineInputBorder())),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, minimumSize: const Size(double.infinity, 50)),
            onPressed: () {
              // यहाँ Upload Logic थप्नुपर्छ
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Sent for Approval!")));
            },
            child: const Text("SUBMIT PAYMENT", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }
}

// --- TOURNAMENT LIST ---
class TournamentList extends StatelessWidget {
  const TournamentList({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tournaments').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var match = snapshot.data!.docs[index];
            return Card(
              child: ListTile(
                title: Text(match['title']),
                subtitle: Text("Prize: Rs ${match['prize']} | Entry: Rs ${match['entry']}"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showMatchDetails(context, match),
              ),
            );
          },
        );
      },
    );
  }

  void _showMatchDetails(BuildContext context, DocumentSnapshot match) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(match['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(),
            const Text("Rewards (Position 1-20):", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(match['rewards']), // Admin ले टाइप गरेको Reward List यहाँ देखिन्छ
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () => Navigator.pop(context),
              child: const Text("JOIN NOW"),
            )
          ],
        ),
      ),
    );
  }
}

// --- 2. ADMIN PANEL ---
class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});
  @override State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ADMIN DASHBOARD"), backgroundColor: Colors.red),
      body: _tab == 0 ? const AdminMatches() : const AdminPayments(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: 'Matches'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Payments'),
        ],
      ),
    );
  }
}

// Admin Matches Form
class AdminMatches extends StatelessWidget {
  const AdminMatches({super.key});
  @override
  Widget build(BuildContext context) {
    final title = TextEditingController();
    final rewards = TextEditingController(); // १ देखि २० सम्मको रिवार्ड यहाँ लेख्ने
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: "Match Title")),
          TextField(controller: rewards, maxLines: 5, decoration: const InputDecoration(labelText: "Rewards (e.g. 1st: 500, 2nd: 300...)")),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {
            FirebaseFirestore.instance.collection('tournaments').add({
              'title': title.text, 'rewards': rewards.text, 'prize': '1000', 'entry': '50',
            });
          }, child: const Text("Add Tournament"))
        ],
      ),
    );
  }
}

// Admin Payments View
class AdminPayments extends StatelessWidget {
  const AdminPayments({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Pending Payment Requests will appear here"));
  }
}

// --- LOGIN PAGE ---
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final pass = TextEditingController();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("NEXORA", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: pass.text),
              child: const Text("LOGIN"),
            ),
          ],
        ),
      ),
    );
  }
}

// नोट: DiamondStore पहिलेकै जस्तै छ, माथि ठाउँ अभावले यहाँ थपिएन।
class DiamondStore extends StatelessWidget {
  const DiamondStore({super.key});
  @override
  Widget build(BuildContext context) { return const Center(child: Text("Diamond Store")); }
}


