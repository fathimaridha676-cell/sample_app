import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_form_page.dart';
import 'admin_home_page.dart';
import 'super_admin_home_page.dart';
import 'rider_home_page.dart';
import 'chef_home_page.dart';
import 'waiter_home_page.dart';
import 'user_home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final role = prefs.getString('role');

    if (!mounted) return;

    if (isLoggedIn && role != null) {
      Widget homePage;
      switch (role) {
        case 'Admin':
          homePage = const AdminHomePage();
          break;
        case 'Super Admin':
          homePage = const SuperAdminHomePage();
          break;
        case 'Rider':
          homePage = const RiderHomePage();
          break;
        case 'Chef':
          homePage = const ChefHomePage();
          break;
        case 'Waiter':
          homePage = const WaiterHomePage();
          break;
        default:
          homePage = const UserHomePage();
          break;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => homePage),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserFormPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
