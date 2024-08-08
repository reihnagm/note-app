
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:mynote/enum/enum.dart';
import 'package:mynote/page/note/edit_note.dart';
import 'package:mynote/provider/note.dart';
import 'package:mynote/common/date.dart';

class ListItemDetail extends StatefulWidget {
  final String noteId;
  final String contentId;
  final Function getData;

  const ListItemDetail({
    required this.noteId,
    required this.contentId,
    required this.getData,
    super.key
  });

  @override
  State<ListItemDetail> createState() => ListItemDetailState();
}

class ListItemDetailState extends State<ListItemDetail> {

  late NoteNotifier noteNotifier;

  Future<void> getData() async {

    if(!mounted) return;
      await noteNotifier.getNote(
        noteId: widget.noteId
      );
  }

  @override
  void initState() {
    super.initState();

    noteNotifier = context.read<NoteNotifier>();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
         title: const SizedBox(),
        automaticallyImplyLeading: false,
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                    builder: (context) => EditNotePage(
                      noteId: widget.noteId,
                      contentId: widget.contentId
                    )
                  ),
                );
                          
                if(data != null) {
                  getData();
                  widget.getData();
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.edit,
                  size: 18.0,
                  color: Colors.blue,
                ),
              ),
            ),
          ),

        ],
      ),
      body: context.watch<NoteNotifier>().providerState == ProviderState.loading 
      ? const SizedBox() 
      : SingleChildScrollView(
          child: Container(
          margin: const EdgeInsets.only(
            left: 16.0,
            right: 16.0
          ),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
            
              Text(noteNotifier.note["parent_title"].toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0
                ),
              ),
                    
              const SizedBox(height: 6.0),
                                                
              Text(noteNotifier.note["created_at"] == null 
              ? "..." 
              : DateHelper.dateWithTime(DateTime.parse(noteNotifier.note["created_at"])),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 9.0,
                ),
              ),
          
              const SizedBox(height: 6.0),
                                                
            ],
          ),
          isThreeLine: true,
          contentPadding: EdgeInsets.zero,
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
          
              const SizedBox(height: 6.0),
          
              HtmlWidget(
                noteNotifier.note["content"].toString(),
                customStylesBuilder: (element) {
                  if (element.localName == 'body') {
                    return {
                      'margin': '0', 
                      'padding': '0'
                    };
                  }
                  return null;
                },
                customWidgetBuilder: (element) {
                  if (element.isVideo) {
                    final videoUrl = element.attributes['src'];
                    if (videoUrl != null) {
                      return ChewieWidget(
                        videoUrl: videoUrl,
                      );
                    }
                  }
                  return null;
                },
              ),
            
            ],
          )
        )),
      )
      
    ); 
  }
}

class ChewieWidget extends StatefulWidget {
  final String videoUrl;

  const ChewieWidget({
    super.key, 
    required this.videoUrl
  });

  @override
  ChewieWidgetState createState() => ChewieWidgetState();
}

class ChewieWidgetState extends State<ChewieWidget> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
    ..initialize().then((_) {
      setState(() {});
    });

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      looping: false,
    );
  }

  @override
  void dispose() {
    chewieController.dispose();
    videoPlayerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (videoPlayerController.value.isPlaying)
          Image.network(widget.videoUrl),
        if (videoPlayerController.value.isInitialized)
          AspectRatio(
            aspectRatio: videoPlayerController.value.aspectRatio,
            child: Chewie(controller: chewieController)),
        if (!videoPlayerController.value.isInitialized)
          const Center(
            child: CircularProgressIndicator()
          ),
      ],
    );
  }
}