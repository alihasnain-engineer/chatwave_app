import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> chats = [
    {
      "name": "Majesty",
      "lastMessage": "Bro send me the file",
      "time": "1:46 PM",
      "unread": 2,
    },
    {
      "name": "Ahsan Dev",
      "lastMessage": "Okay I will check",
      "time": "12:10 PM",
      "unread": 0,
    },
    {
      "name": "Client (Website)",
      "lastMessage": "Great work!",
      "time": "Yesterday",
      "unread": 1,
    },
  ];

  Future<void> refreshChats() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      chats.insert(0, {
        "name": "New Demo Chat",
        "lastMessage": "This is new refreshed chat",
        "time": "Now",
        "unread": 1,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2e9f7),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xfff2e9f7),
        title: const Text("Chats",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          PopupMenuButton(
            itemBuilder: (context) => const [
              PopupMenuItem(child: Text("New group")),
              PopupMenuItem(child: Text("New broadcast")),
              PopupMenuItem(child: Text("Linked devices")),
              PopupMenuItem(child: Text("Settings")),
            ],
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: refreshChats,
        child: chats.isEmpty
            ? const Center(child: Text("No chats available"))
            : ListView(
          children: [
            // Archive row
            ListTile(
              leading: const Icon(Icons.archive, color: Colors.deepPurple),
              title: const Text("Archived"),
              trailing: const Text("1"),
              onTap: () {},
            ),

            const Divider(),

            // Dummy chat list
            ...chats.map(
                  (chat) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade300,
                  child: Text(chat["name"][0],
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(chat["name"],
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(chat["lastMessage"]),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(chat["time"],
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    chat["unread"] > 0
                        ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle),
                      child: Text(
                        chat["unread"].toString(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    )
                        : const SizedBox(),
                  ],
                ),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple.shade200,
        child: const Icon(Icons.add),
        onPressed: () {
          setState(() {
            chats.add({
              "name": "Demo User",
              "lastMessage": "New chat created",
              "time": "Now",
              "unread": 0,
            });
          });
        },
      ),
    );
  }
}
