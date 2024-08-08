import 'package:mynote/shared/widgets/dialog.dart';

import 'package:flutter/material.dart';

class DrawerNoteWidget extends StatelessWidget {
  const DrawerNoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 200.0,
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              children: [
         
              ],
            ),
          ),

          ListTile(
            title: const Text('Logout',
              style: TextStyle(
                fontSize: 14.0
              ),
            ),
            onTap: () async {
              await GDialog.logout(title: "Are you sure want to logout ?");
            }
          ),

        ],
      )
    );
  }
}