import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import 'package:mynote/provider/note.dart';

import 'package:mynote/enum/enum.dart';

import 'package:mynote/page/note/add_note.dart';
import 'package:mynote/page/note/widgets/list/pin.dart';
import 'package:mynote/page/note/widgets/list/default.dart';
import 'package:mynote/page/note/widgets/drawer.dart';
import 'package:mynote/page/note/widgets/search.dart';

import 'package:mynote/shared/widgets/dialog.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => NotePageState();
}

class NotePageState extends State<NotePage> {

  final GlobalKey<ScaffoldState> key = GlobalKey(); 

  late NoteNotifier noteNotifier;

  QuillController qc = QuillController.basic();

  Future<void> getData() async {
    if(!mounted) return;
      noteNotifier.getNotes();
  }

  Future<void> logout() async {

    GDialog.logout(
      title: "Are you sure want to logout ?"
    );

  }

  @override 
  void initState() {
    super.initState();

    noteNotifier = context.read<NoteNotifier>();

    noteNotifier.searchC = TextEditingController();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {

    noteNotifier.searchC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      drawer: const DrawerNoteWidget(),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool scrollable) {
          return [
            
            SliverAppBar(
              title: const Text("Note",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              automaticallyImplyLeading: false,
              leading: InkWell(
                onTap: () {
                  key.currentState!.openDrawer();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.menu,
                    size: 18.0,
                  ),
                ),
              ),
              centerTitle: true,
              actions: [

                Container(
                  margin: const EdgeInsets.only(
                    left: 18.0,
                    right: 18.0
                  ),
                  child: InkWell(
                    onTap: () async {
                      final data = await Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => const AddNotePage()
                        ),
                      );
                      if(data != null) {
                        getData();
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.add,
                        size: 18.0,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),

              ],
            ),
            
            const SliverToBoxAdapter(
              child: SearchNoteWidget()
            ),

          ];
        }, 
        body: RefreshIndicator.adaptive(
          onRefresh: () {
            return Future.sync(() {
              getData();
            });
          },
          child: Consumer<NoteNotifier>(
            builder: (__, notifier, _) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [

                  if(notifier.providerState == ProviderState.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(),
                      )
                    ),
                  
                  if(notifier.providerState == ProviderState.empty) 
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text("Add some note")
                      )
                    ),

                  if(notifier.notes.where((el) => el["pinned"] == "true").toList().isNotEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 8.0, 
                          left: 14.0, 
                          right: 14.0
                        ),
                        child: Text('Pinned',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                    ),

                  if(notifier.notes.where((el) => el["pinned"] == "true").toList().isNotEmpty)
                    ListPinned(notifier: notifier, getData: getData),

                  if(notifier.notes.where((el) => el["pinned"] == "true").toList().isNotEmpty && notifier.notes.where((el) => el["pinned"] != "true").toList().isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 18.0,
                          right: 18.0
                        ),
                        child: const Divider(
                          color: Colors.grey,
                          height: 10.0,
                          thickness: 1.0,
                        ),
                      ),
                    ),

                  ListDefault(
                    notifier: notifier, 
                    getData: getData
                  )
              
                ],
              );
            },
          )
        )
      )
    );
  }
}
