import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/pages/home_page.dart';
import 'package:proyecto_final/pages/messages_page.dart';
import 'package:proyecto_final/pages/profile_page.dart';
import 'package:proyecto_final/pages/schedule_page.dart';
import 'package:proyecto_final/pages/search_page.dart';

class HomeNavigationBarPage extends StatefulWidget {
  const HomeNavigationBarPage({super.key});

  @override
  State<HomeNavigationBarPage> createState() => _HomeNavigationBarPageState();
}

class _HomeNavigationBarPageState extends State<HomeNavigationBarPage> {
  int index = 0;

  final screens = [
    HomePage(),
    SearchPage(),
    MessagesPage(),
    SchedulePage(),
    ProfilePage(),
  ];

  final items = <Widget>[
    Icon(Icons.home, size: 30),
    Icon(Icons.search, size: 30),
    Icon(Icons.message, size: 30),
    Icon(Icons.calendar_month, size: 30),
    Icon(Icons.person, size: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: screens[index],
        //extendBody: true,
        bottomNavigationBar: Theme(
          data: Theme.of(
            context,
          ).copyWith(iconTheme: IconThemeData(color: Colors.white)),
          child: CurvedNavigationBar(
            color: Color(0xFF0F8555),
            backgroundColor: Colors.transparent,
            height: 60,
            animationDuration: Duration(milliseconds: 300),
            index: index,
            items: items,
            onTap: (index) => setState(() => this.index = index),
          ),
        ),
      ),
    );
  }
}
