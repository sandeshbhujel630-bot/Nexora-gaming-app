import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  runApp(const NexoraApp());
}

class NexoraApp extends StatelessWidget {
  const NexoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexora Arena',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFE50914),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
      home: const DepositScreen(),
    );
  }
}

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _amountKey = TextEditingController();
  final _txnKey = TextEditingController();
  bool _isLoading = false;

  // Function to process deposit request
  Future<void> _processDeposit() async {
    final amount = _amountKey.text.trim();
    final txnId = _txnKey.text.trim();

    if (amount.isEmpty || txnId.isEmpty) {
      _showToast("कृपया सबै विवरण भर्नुहोस्");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('deposit_requests').add({
        'amount': amount,
        'txn_id': txnId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'userId': 'user_test_123', // Static for now, link to Auth later
      });

      _amountKey.clear();
      _txnKey.clear();
      _showSuccessSheet();
    } catch (e) {
      _showToast("केही समस्या आयो, फेरि प्रयास गर्नुहोस्");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 15),
            const Text("अनुरोध पठाइयो", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("एडमिनले रुजु गरेपछि तपाईँको खातामा पैसा थपिनेछ।", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
              onPressed: () => Navigator.pop(context),
              child: const Text("बुझेँ"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Points"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("१. ९८XXXXXXXX मा रकम पठाउनुहोस्", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: _amountKey,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "पठाएको रकम (Rs.)", prefixIcon: Icon(Icons.money)),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _txnKey,
              decoration: const InputDecoration(hintText: "Transaction ID", prefixIcon: Icon(Icons.numbers)),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _processDeposit,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("REQUEST DEPOSIT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

