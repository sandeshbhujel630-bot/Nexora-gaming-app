import 'package:flutter/material.dart';

// --- प्रिमियम कलर थिम (Liga 1 Inspired) ---
const Color kPrimary = Color(0xFF0D1B3E); // Deep Navy
const Color kAccent = Color(0xFFC9A227);  // Gold
const Color kBackground = Color(0xFF040B1D);
const Color kSurface = Color(0xFF15264B);
const Color kTextPrimary = Colors.white;
const Color kTextSecondary = Colors.white70;

void main() => runApp(NexoraUltraApp());

class NexoraUltraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexora Liga Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        colorScheme: ColorScheme.fromSeed(seedColor: kAccent, secondary: kAccent),
      ),
      home: LoginScreen(),
    );
  }
}

// --- १. LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [kPrimary, kBackground],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: kAccent, width: 3),
                  boxShadow: [BoxShadow(color: kAccent.withOpacity(0.3), blurRadius: 20)],
                ),
                child: Icon(Icons.bolt, size: 80, color: kAccent),
              ),
              SizedBox(height: 30),
              Text("NEXORA LIGA", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
              Text("The Ultimate Gaming Arena", style: TextStyle(color: kAccent, fontSize: 14)),
              SizedBox(height: 50),
              _customField("Email Address", Icons.email_outlined),
              SizedBox(height: 20),
              _customField("Password", Icons.lock_outline, isPassword: true),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showDialog(context, "Password Recovery", "Instructions sent to your mail."),
                  child: Text("Forgot Password?", style: TextStyle(color: kAccent)),
                ),
              ),
              SizedBox(height: 30),
              _actionButton("SIGN IN", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MainNavigation()));
              }),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("New here? "),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen())),
                    child: Text("Create Account", style: TextStyle(color: kAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customField(String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword ? _isObscured : false,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: kAccent),
        suffixIcon: isPassword ? IconButton(icon: Icon(Icons.visibility), onPressed: () => setState(() => _isObscured = !_isObscured)) : null,
        filled: true,
        fillColor: kSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}

// --- २. SIGNUP SCREEN ---
class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Text("Join the Arena", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            _simpleField("Full Name", Icons.person),
            SizedBox(height: 15),
            _simpleField("Mobile Number", Icons.phone),
            SizedBox(height: 15),
            _simpleField("Email", Icons.email),
            SizedBox(height: 15),
            _simpleField("Password", Icons.lock, obscure: true),
            SizedBox(height: 40),
            _actionButton("REGISTER NOW", () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Widget _simpleField(String h, IconData i, {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: h,
        prefixIcon: Icon(i, color: kAccent),
        filled: true,
        fillColor: kSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}

// --- ३. MAIN NAVIGATION (Dashboard + Profile + Wallet) ---
class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  final List<Widget> _pages = [Dashboard(), WalletPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (v) => setState(() => _index = v),
        selectedItemColor: kAccent,
        backgroundColor: kSurface,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// --- ४. DASHBOARD (PRO FEATURES) ---
class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NEXORA ARENA"),
        backgroundColor: kPrimary,
        actions: [
          IconButton(icon: Icon(Icons.admin_panel_settings, color: kAccent), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPanel()))),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          // Banner Slider
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: [kAccent, Colors.orange]),
            ),
            child: Center(child: Text("LIVE TOURNAMENT: \$5000", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimary))),
          ),
          SizedBox(height: 30),
          Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kAccent)),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _menuIcon(Icons.sports_esports, "Games"),
              _menuIcon(Icons.emoji_events, "Results"),
              _menuIcon(Icons.group, "Teams"),
              _menuIcon(Icons.support_agent, "Support"),
            ],
          ),
          SizedBox(height: 30),
          Text("Active Matches", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _matchCard("PUBG Mobile", "10:30 PM", "Entry: \$10"),
          _matchCard("Free Fire", "11:00 PM", "Entry: Free"),
        ],
      ),
    );
  }

  Widget _menuIcon(IconData i, String l) {
    return Column(children: [CircleAvatar(backgroundColor: kSurface, child: Icon(i, color: kAccent)), SizedBox(height: 5), Text(l, style: TextStyle(fontSize: 12))]);
  }

  Widget _matchCard(String title, String time, String price) {
    return Card(
      color: kSurface,
      margin: EdgeInsets.only(top: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.videogame_asset, color: kAccent),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time),
        trailing: ElevatedButton(onPressed: () {}, child: Text(price)),
      ),
    );
  }
}

// --- ५. WALLET PAGE ---
class WalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Wallet"), backgroundColor: kPrimary),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(40),
            width: double.infinity,
            color: kSurface,
            child: Column(children: [
              Text("Total Balance", style: TextStyle(color: kAccent)),
              Text("\$2,450.00", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                _historyTile("Deposit via QR", "+\$500", Colors.green),
                _historyTile("Tournament Entry", "-\$20", Colors.red),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _historyTile(String t, String amt, Color c) {
    return ListTile(title: Text(t), trailing: Text(amt, style: TextStyle(color: c, fontWeight: FontWeight.bold)));
  }
}

// --- ६. ADMIN PANEL (ULTIMATE CONTROL) ---
class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Control Center"), backgroundColor: Colors.redAccent),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(20),
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          _adminCard(Icons.qr_code_2, "Update QR", () => _showDialog(context, "Admin", "QR Uploading...")),
          _adminCard(Icons.notifications_active, "Broadcast", () {}),
          _adminCard(Icons.manage_accounts, "User List", () {}),
          _adminCard(Icons.monetization_on, "Payouts", () {}),
          _adminCard(Icons.settings, "App Config", () {}),
          _adminCard(Icons.analytics, "Statistics", () {}),
        ],
      ),
    );
  }

  Widget _adminCard(IconData i, String l, VoidCallback t) {
    return InkWell(
      onTap: t,
      child: Container(
        decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 40, color: kAccent), SizedBox(height: 10), Text(l)]),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("User Profile & Settings"));
  }
}

void _showDialog(BuildContext context, String t, String m) {
  showDialog(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: kSurface,
      title: Text(t, style: TextStyle(color: kAccent)),
      content: Text(m),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text("OK"))],
    ),
  );
}

Widget _actionButton(String label, VoidCallback action) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAccent,
      minimumSize: Size(double.infinity, 55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
    ),
    onPressed: action,
    child: Text(label, style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
  );
}

