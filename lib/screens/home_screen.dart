import 'package:flutter/material.dart';
import 'package:our_community/components/create_post_component.dart';
import 'package:our_community/screens/settings_screen.dart';
import 'list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final screens = [
    const ListScreen(),
    const Scaffold(),
    const SettingsScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        // actions: [
        //   PopupMenuButton(
        //       itemBuilder: (context) => <PopupMenuEntry>[
        //             PopupMenuItem(
        //               value: 'one',
        //               child: IconButton(
        //                   iconSize: 10,
        //                   onPressed: () {},
        //                   icon: const Icon(Icons.sort)),
        //             )
        //           ]),
        // ],
        backgroundColor: Colors.lightBlueAccent,
        elevation: 1,
        title: const Text("Our Community"),
        leading: null,
      ),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        backgroundColor: Colors.lightBlueAccent,
        selectedItemColor: Colors.white,
        currentIndex: currentIndex,
        onTap: (value) {
          if (value == 1) {
            showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return const CreatePostModal();
                });
          } else {
            setState(() {
              currentIndex = value;
            });
          }
        },
      ),
    );
  }
}
