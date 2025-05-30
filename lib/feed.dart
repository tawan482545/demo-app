import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPostInput(),
          _buildPost(
            username: "kimmy",
            userImage: "assets/dog.jpg",
            postText:
                "มีใครพบเจอสุนัขแบบในภาพ โปรดแจ้ง เบอร์ติดต่อ 08xxxxxx สุนัขชื่อ กล้วย พันธุ์ลาบราดอร์",
            postImage: "assets/dog.jpg",
          ),
          _buildPost(
            username: "Khole",
            userImage: "assets/dog.jpg",
            postText: "วันนี้พาน้องหมาเดินเล่น",
            postImage: "assets/dog.jpg",
          ),
        ],
      ),
    );
  }

  Widget _buildPostInput() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.add, color: Colors.teal),
          hintText: "What's on your mind?",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.teal),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildPost({
    required String username,
    required String userImage,
    required String postText,
    required String postImage,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(userImage),
                    radius: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.more_vert, color: Colors.grey.shade600),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                postText,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  postImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 180,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.comment, color: Colors.teal.shade400),
                  const SizedBox(width: 5),
                  const Text(
                    "Comment",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
