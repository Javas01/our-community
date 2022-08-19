import 'package:flutter/material.dart';
import 'package:our_community/components/create_post_component.dart';
import 'package:our_community/screens/settings_screen.dart';
import 'package:our_community/screens/list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  String _sortValue = 'Upvotes';
  late List screens;
  ValueNotifier<bool> resetValueNotifier = ValueNotifier(false);

  @override
  void initState() {
    screens = [
      ListScreen(resetValueNotifier: resetValueNotifier, sortValue: _sortValue),
      const Scaffold(),
      const SettingsScreen()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('Our Community'),
        leading: null,
        actions: [
          PopupMenuButton(
            icon: _sortValue == 'Upvotes'
                ? const Icon(Icons.arrow_circle_up_rounded)
                : const Icon(Icons.access_time_rounded),
            initialValue: _sortValue,
            onSelected: (value) => setState(() {
              setState(() {
                _sortValue = value.toString();
                screens[0] = ListScreen(
                  resetValueNotifier: resetValueNotifier,
                  sortValue: value.toString(),
                );
              });
            }),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: 'Upvotes',
                child: Text('Upvotes'),
              ),
              const PopupMenuItem(
                value: 'Recent',
                child: Text('Recent'),
              ),
            ],
          )
        ],
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
        currentIndex: currentIndex,
        onTap: (value) {
          if (value == 0 &&
              currentIndex == 0 &&
              resetValueNotifier.value == false) {
            resetValueNotifier.value = true;
            setState(() {
              screens[0] = ListScreen(
                  resetValueNotifier: resetValueNotifier,
                  sortValue: _sortValue);
            });
          }
          if (value == 1) {
            if (currentIndex == 2) {
              setState(() {
                currentIndex = 0;
              });
            }
            showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return const CreatePostModal(isEdit: false);
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
