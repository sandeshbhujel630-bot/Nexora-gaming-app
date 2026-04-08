import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';

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
        cardTheme: CardThemeData(color: const Color(0xFF1E2228), elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (snapshot.hasData) {
          return snapshot.data?.email == adminEmail ? const AdminPanel() : const UserHome();
        }
        return const LoginPage();
      },
    );
  }
}

// --- 1. USER PANEL ---
class UserHome extends StatefulWidget {
  const UserHome({super.key});
  @override State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [const DiamondStore(), const TournamentList(), const WalletPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NEXORA GAMING", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
        actions: [IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orangeAccent,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Topup'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'Matches'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
        ],
      ),
    );
  }
}

// --- DIAMOND STORE ---
class DiamondStore extends StatelessWidget {
  const DiamondStore({super.key});

  final List<Map<String, String>> diamonds = const [
    {"item": "115 💎", "price": "95"}, {"item": "240 💎", "price": "190"},
    {"item": "355 💎", "price": "295"}, {"item": "480 💎", "price": "400"},
    {"item": "610 💎", "price": "500"}, {"item": "725 💎", "price": "600"},
    {"item": "850 💎", "price": "700"}, {"item": "965 💎", "price": "800"},
    {"item": "1090 💎", "price": "900"}, {"item": "1240 💎", "price": "980"},
    {"item": "2090 💎", "price": "1680"}, {"item": "2530 💎", "price": "2080"},
    {"item": "5540 💎", "price": "4400"}, {"item": "Weekly Membership", "price": "200"},
    {"item": "Monthly Membership", "price": "995"}, {"item": "Level Up Pass", "price": "190"},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: diamonds.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.diamond, color: Colors.cyanAccent),
            title: Text(diamonds[index]['item']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text("Rs ${diamonds[index]['price']}", style: const TextStyle(color: Colors.greenAccent, fontSize: 16)),
            onTap: () => _showOrderDialog(context, diamonds[index]['item']!, diamonds[index]['price']!),
          ),
        );
      },
    );
  }

  void _showOrderDialog(BuildContext context, String item, String price) {
    final uidController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Topup $item"),
        content: TextField(controller: uidController, decoration: const InputDecoration(hintText: "Enter Free Fire UID")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('orders').add({
                'user': FirebaseAuth.instance.currentUser?.email,
                'uid': uidController.text,
                'item': item,
                'price': price,
                'status': 'Pending',
                'time': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Placed Successfully!")));
            },
            child: const Text("Order Now"),
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
              margin: const EdgeInsets.all(10),
              child: Column(
                children: [
                  ListTile(
                    title: Text(match['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                    subtitle: Text("Time: ${match['time']}\nPrize: Rs ${match['prize']}"),
                    trailing: Text("Entry: Rs ${match['entry']}", style: const TextStyle(fontSize: 15, color: Colors.greenAccent)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Contact Admin to Join!"))),
                      child: const Text("JOIN MATCH"),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// --- WALLET PAGE ---
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Wallet & Transaction History (Coming Soon)", style: TextStyle(color: Colors.grey)));
  }
}

// --- 2. ADMIN PANEL ---
class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});
  @override State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _adminTab = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ADMIN DASHBOARD"), backgroundColor: Colors.redAccent, actions: [IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))]),
      body: _adminTab == 0 ? const AdminOrders() : const AdminTournament(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _adminTab,
        onTap: (i) => setState(() => _adminTab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add Match'),
        ],
      ),
    );
  }
}

class AdminOrders extends StatelessWidget {
  const AdminOrders({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').orderBy('time', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var order = snapshot.data!.docs[index];
            return Card(
              child: ListTile(
                title: Text("UID: ${order['uid']} (${order['item']})"),
                subtitle: Text("From: ${order['user']}\nStatus: ${order['status']}"),
                trailing: order['status'] == 'Pending' 
                  ? IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => order.reference.update({'status': 'Done ✅'}))
                  : const Icon(Icons.verified, color: Colors.blue),
              ),
            );
          },
        );
      },
    );
  }
}

class AdminTournament extends StatelessWidget {
  const AdminTournament({super.key});
  @override
  Widget build(BuildContext context) {
    final title = TextEditingController();
    final prize = TextEditingController();
    final entry = TextEditingController();
    final time = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Add New Tournament", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(controller: title, decoration: const InputDecoration(labelText: "Match Title (e.g. Solo Match)")),
            TextField(controller: prize, decoration: const InputDecoration(labelText: "Prize Pool")),
            TextField(controller: entry, decoration: const InputDecoration(labelText: "Entry Fee")),
            TextField(controller: time, decoration: const InputDecoration(labelText: "Time (e.g. 7 PM)")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('tournaments').add({
                  'title': title.text, 'prize': prize.text, 'entry': entry.text, 'time': time.text,
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tournament Added!")));
              },
              child: const Text("Publish Match"),
            )
          ],
        ),
      ),
    );
  }
}

// --- LOGIN PAGE ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text("NEXORA GAMING", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
        const SizedBox(height: 40),
        TextField(controller: _email, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
        const SizedBox(height: 15),
        TextField(controller: _pass, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()), obscureText: true),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.orangeAccent),
          onPressed: () => FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim()), 
          child: const Text("LOGIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
        ),
        TextButton(onPressed: () => FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim()), child: const Text("Create New Account")),
      ])),
    );
  }
}

