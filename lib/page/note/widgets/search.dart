import 'package:mynote/provider/note.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchNoteWidget extends StatelessWidget {
  const SearchNoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16.0,
        right: 16.0
      ),
      child: SizedBox(
        height: 56.0,
        child: TextFormField(
          controller: context.read<NoteNotifier>().searchC,
          style: const TextStyle(
            fontSize: 14.0
          ),
          onChanged: (String val) {
            context.read<NoteNotifier>().searchNote();
          },
          decoration: InputDecoration(
            hintText: "Search by title",
            hintStyle: const TextStyle(
              fontSize: 14.0
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.blue
              )
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.blue
              )
            ),
          )
        ),
      ),
    );
  }
}

// class SearchNoteWidget extends StatefulWidget {
//   const SearchNoteWidget({super.key});

//   @override
//   State<SearchNoteWidget> createState() => SearchNoteWidgetState();
// }

// class SearchNoteWidgetState extends State<SearchNoteWidget> {

//   @override 
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }