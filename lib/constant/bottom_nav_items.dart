import 'package:flutter/material.dart';

class BottomNavItems {
  static const List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: "Dashboard",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.train),
      label: "Kereta",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.airplane_ticket),
      label: "Tiket",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: "Profile",
    ),
  ];
}
