import 'package:flutter/material.dart';

import 'package:mynote/common/date.dart';

import 'package:mynote/provider/note.dart';
import 'package:mynote/shared/widgets/dialog.dart';
import 'package:mynote/page/note/edit_note.dart';
import 'package:mynote/page/note/widgets/list/detail.dart';

class ListPinned extends StatefulWidget {
  final NoteNotifier notifier;
  final Function getData;

  const ListPinned({
    required this.notifier,
    required this.getData,
    super.key  
  });

  @override
  State<ListPinned> createState() => ListPinnedState();
}

class ListPinnedState extends State<ListPinned> {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverList.builder(
        itemCount: widget.notifier.notes.where((el) => el["pinned"] == "true").toList().length,
        itemBuilder: (_, int i) {
      
        final note = widget.notifier.notes.where((el) => el["pinned"] == "true").toList()[i];

        return Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0)
            )
          ),
          child: InkWell(
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0)
            ),
            onTap: () {
              Navigator.push(context, 
                MaterialPageRoute(builder: (context) {
                  return ListItemDetail(
                    noteId: note["note_id"],
                    contentId: note["content_id"],
                    getData: widget.getData,
                  );
                })
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
              
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    
                      Text(note["parent_title"],
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0
                        ),
                      ),
              
                      const SizedBox(height: 6.0),
                                                        
                      Text(DateHelper.dateWithTime(DateTime.parse(note["created_at"])),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9.0,
                        ),
                      ),
                                                        
                    ],
                  ),
                  contentPadding: EdgeInsets.zero,
                  trailing: PopupMenuButton(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: "/delete",
                          child: Text('Delete',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black
                            ),
                          )
                        ),
                        const PopupMenuItem(
                          value: "/edit",
                          child: Text('Edit',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black
                            ),
                          )
                        ),
                        PopupMenuItem(
                          value: "/pin",
                          child: note["pinned"] == "true" 
                          ? const Text('Unpin',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black
                              ),
                            )
                          : const Text('Pin',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black
                              ),
                          ),
                        )
                      ];
                    },
                    onSelected: (value) async {
                      if(value == "/pin") {
                        if(note["pinned"] == "true") {
                  
                          await GDialog.confirmUnpinNote(
                            title: note["parent_title"],
                            noteId: note["note_id"]
                          );
                  
                        } else {
                  
                          await GDialog.confirmPinNote(
                            title: note["parent_title"],
                            noteId: note["note_id"]
                          );
                  
                        }
                      } 
                      if(value == "/delete") {
                        await GDialog.confirmDel(
                          title: note["parent_title"],
                          contentId: note["content_id"],
                          noteId: note["note_id"]
                        );
                      }
                      if(value == "/edit") {
                        final data = await Navigator.push(context,
                          MaterialPageRoute(
                            builder: (context) => EditNotePage(
                              noteId: note["note_id"],
                              contentId: note["content_id"]
                            )
                          ),
                        );
                                  
                        if(data != null) {
                          widget.getData();
                        }
                      }
                    },
                  )
                  
                ),
              
                // Positioned(
                //   bottom: 0.0,
                //   right: 0.0,
                //   child: Container(
                //     width: 70.0,
                //     padding: const EdgeInsets.all(8.0),
                //     decoration: BoxDecoration(
                //       color: note["pinned"] == "true"  
                //       ? Colors.green[600] 
                //       : Colors.blue[600],
                //       borderRadius: BorderRadius.circular(10.0)
                //     ),
                //     child: Bouncing(
                //       onPress: () {},
                //       onLongPress: () async {
            
                //         
            
                //       },
                //       child: note["pinned"] == "true" 
                //       ? const Text('Hold to unpin',
                //           textAlign: TextAlign.center,
                //           style: TextStyle(
                //             fontSize: 9.0,
                //             fontWeight: FontWeight.bold,
                //             color: Colors.white
                //           ),
                //         )
                //       : const Text('Hold to pin',
                //           textAlign: TextAlign.center,
                //           style: TextStyle(
                //             fontSize: 9.0,
                //             fontWeight: FontWeight.bold,
                //             color: Colors.white
                //           ),
                //        ),
                //     ),
                //   ),
                // )
              
                ],
              ),
            ),
          ),
        );
    },
  ),
);
  }
}