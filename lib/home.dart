import 'package:flutter/material.dart';
import 'profile.dart';
import 'feed.dart';
import 'camera.dart';
import 'search.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // เริ่มต้นที่หน้า Home (Feed)

  final List<Widget> _screens = [
    FeedScreen(), // 🔥 Home ทำหน้าที่เป็น Feed
    CameraScreen(),
    SearchScreen(),
    ProfileScreen(), // หน้า Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          _selectedIndex == 0
              ? AppBar(
                title: const Text(
                  "FEED",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                centerTitle: true,
                elevation: 3,
              )
              : null, // ❌ ไม่แสดง AppBar ถ้าไม่ใช่หน้า Home
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      elevation: 5,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ), // 🔥 ปุ่ม Home ใช้เป็น Feed
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Camera"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ), // หน้าโปรไฟล์
      ],
    );
  }
}
