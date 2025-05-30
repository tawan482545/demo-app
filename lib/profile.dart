import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'login.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String profileImage = "assets/dog.jpg";

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() {
    setState(() {
      _user = _auth.currentUser;
      profileImage = _user?.photoURL ?? "assets/dog.jpg";
    });
  }

  Future<void> uploadProfileImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String userId = _user?.uid ?? "unknown_user";
      String fileName = "profile_$userId.jpg";

      try {
        final ref = FirebaseStorage.instance.ref().child(
          "profile_pictures/$fileName",
        );
        await ref.putFile(file);
        String downloadUrl = await ref.getDownloadURL();

        await _user?.updatePhotoURL(downloadUrl);
        setState(() {
          profileImage = downloadUrl;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("อัปโหลดรูปสำเร็จ!")));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
      }
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Widget _buildProfileOption(String text, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 26),
        title: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey.shade600,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 50, bottom: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade400],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "My Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: uploadProfileImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              profileImage.startsWith("http")
                                  ? NetworkImage(profileImage)
                                  : AssetImage(profileImage) as ImageProvider,
                        ),
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.teal,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  _user?.displayName ?? "User Name",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _user?.email ?? "No email",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    _buildProfileOption(
                      "Edit Profile",
                      Icons.edit,
                      _editProfile,
                    ),
                    _buildProfileOption("Logout", Icons.exit_to_app, _signOut),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    String newName = _user?.displayName ?? "";
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("แก้ไขชื่อผู้ใช้"),
            content: TextField(
              onChanged: (value) => newName = value,
              decoration: InputDecoration(
                labelText: "ชื่อใหม่",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("ยกเลิก"),
              ),
              TextButton(
                onPressed: () async {
                  await _user?.updateDisplayName(newName);
                  await _user?.reload();
                  _getUserData();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("อัปเดตชื่อสำเร็จ!")));
                },
                child: Text("บันทึก"),
              ),
            ],
          ),
    );
  }
}
