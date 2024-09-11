import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 0.8,
      color: Colors.white,
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Horoscope'),
            onTap: () {
              Navigator.pushNamed(context, '/horoscope');
            },
          ),
          // Add other menu options here
        ],
      ),
    );
  }
}
