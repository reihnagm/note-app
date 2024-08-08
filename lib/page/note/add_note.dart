import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chewie/chewie.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mynote/common/global.dart';
import 'package:mynote/common/nanoid.dart';

import 'package:mynote/main.dart';

import 'package:mynote/provider/note.dart';

import 'package:mynote/shared/widgets/dialog.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:video_player/video_player.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => AddNotePageState();
}

class AddNotePageState extends State<AddNotePage> {

  final formKey = GlobalKey<FormState>();

  late TextEditingController titleC;
  late TextEditingController reminderC;

  late FocusNode titleFn;
  late FocusNode qcFn;
  late FocusNode reminderFn;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTimeOfDay = TimeOfDay.now();

  QuillController qc = QuillController.basic();

  tz.TZDateTime convertTime(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  Future<void> scheduleReminder({ 
    required int id, required String title,
    required String body, required DateTime scheduledDate 
  }) async {

    await flutterLocalNotificationsPlugin.zonedSchedule(id, title, body,
      convertTime(scheduledDate.hour, scheduledDate.minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'notification',
          'notification_channel',
          channelDescription: 'notification_channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> setReminder() async {

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365))
    );

    if(date != null) {

      setState(() => selectedDate = date);

      TimeOfDay? time = await showTimePicker(
        context: navigatorKey.currentContext!, 
        initialTime: selectedTimeOfDay
      );

      if(time != null) {
        setState(() => selectedTimeOfDay = time);

        DateTime selectedReminderDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTimeOfDay.hour,
          selectedTimeOfDay.minute
        );

        setState(() {
          reminderC = TextEditingController(
          text: "${selectedReminderDate.year}-"
            "${selectedReminderDate.month.toString().padLeft(2, '0')}-"
            "${selectedReminderDate.day.toString().padLeft(2, '0')} "
            "${selectedReminderDate.hour.toString().padLeft(2, '0')}:"
            "${selectedReminderDate.minute.toString().padLeft(2, '0')}"
          );
        });

      }

    }
                 
  }

  Future<void> addNote() async {
    
    if(formKey.currentState!.validate()) {

      String id = NanoID.generate();
      String noteId = NanoID.generate();
      String contentId = NanoID.generate();

      String title = titleC.text;

      String date = DateTime.now().toLocal().toString();
    
      String contentJson = jsonEncode(qc.document.toDelta().toJson());

      String content = QuillDeltaToHtmlConverter(qc.document.toDelta().toJson()).convert();

      String reminderDate = reminderC.text;

      try {

        await navigatorKey.currentContext!.read<NoteNotifier>().storeNote(
          id: id, noteId: noteId, contentId: contentId, 
          title: title, content: content, contentJson: contentJson,
          date: date, reminderDate: reminderDate
        );

        if(reminderC.text.isNotEmpty) {

          final selectedScheduleDate = DateTime(
            selectedDate.year, 
            selectedDate.month, 
            selectedDate.day,
            selectedTimeOfDay.hour,
            selectedTimeOfDay.minute
          );

          final DateTime scheduledDate = selectedScheduleDate;

          await scheduleReminder(
            id: 1, title: title, body: "", 
            scheduledDate: scheduledDate
          );
        }

        Navigator.pop(navigatorKey.currentContext!, "refetch_data");

      } catch(e) {
        debugPrint(e.toString());
      }


    } else {

      setState(() {
        qcFn.requestFocus();
      });

      if(titleC.text.isEmpty) {
        setState(() {
          titleFn.requestFocus();
        });
      }

    } 
    

  }



  @override
  void initState() {
    super.initState();

    titleC = TextEditingController();
    reminderC = TextEditingController();

    titleFn = FocusNode();
    qcFn = FocusNode();
    reminderFn = FocusNode();
  }

  @override 
  void dispose() {
    titleC.dispose();
    reminderC.dispose();

    titleFn.dispose();
    qcFn.dispose();
    reminderFn.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Note",
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context, 'back');
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
                await addNote();
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.check,
                  size: 18.0,
                  color: Colors.blue,
                ),
              ),
            ),
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(
          left: 16.0,
          right: 16.0
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
          
                TextFormField(
                  controller: titleC,
                  focusNode: titleFn,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'title cannot be empty';
                    }
                    return null;
                  },
                  style: const TextStyle(
                    fontSize: 16.0
                  ),
                  decoration: const InputDecoration(
                    labelText: "Title",
                    labelStyle: TextStyle(
                      fontSize: 14.0
                    )
                  ),
                ),

                const SizedBox(height: 20.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    Container(
                      width: 100.0,
                      margin: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 8.0
                      ),
                      child: InkWell(
                        onTap: () async {
                          GDialog.quillToolbar(controller: qc);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text("Toolbar"),
                              SizedBox(width: 8.0),
                              Icon(Icons.edit_document,
                                size: 18.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),

                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: context.watch<NoteNotifier>().loadingCallbackImportMediaQuill 
                  ? Stack(
                      clipBehavior:Clip.none,
                      children: [

                        const Center(
                          child: CircularProgressIndicator(),
                        ),

                        Positioned(
                          top: 10.0,
                          left: 0.0,
                          right: 0.0,
                          child: Center(
                            child: Text(
                              "${context.watch<NoteNotifier>().progressCallbackImportMediaQuill}%",
                              style: const TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold
                              ),
                            )
                          )
                        )

                      ],
                    ) 
                  : QuillEditor.basic(
                    focusNode: qcFn,
                    configurations: QuillEditorConfigurations(
                      controller: qc,
                      sharedConfigurations: const QuillSharedConfigurations(),
                      minHeight: 220.0,
                      placeholder: "Add Content",
                      customStyles: const DefaultStyles(
                        placeHolder: DefaultTextBlockStyle(
                          TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey
                          ),
                          VerticalSpacing(0.0, 0.0),
                          VerticalSpacing(0.0, 0.0),
                          BoxDecoration()
                        )
                      ),
                      unknownEmbedBuilder: WidgetEmbedBuilder(),
                      onImagePaste: (imageBytes) {
                        String base64Image = base64Encode(imageBytes);
                        return Future.value(base64Image);
                      },
                    ),
                  ),
                ),

                // TextFormField(
                //   controller: contentC,
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'konten cannot be empty';
                //     }
                //     return null;
                //   },
                //   style: const TextStyle(
                //     fontSize: 16.0
                //   ),
                //   maxLines: null,
                //   minLines: 3,
                //   decoration: const InputDecoration(
                //     floatingLabelBehavior: FloatingLabelBehavior.auto,
                //     labelText: "Konten",
                //     labelStyle: TextStyle(
                //       fontSize: 14.0
                //     )
                //   ),
                // ),

                const SizedBox(height: 20.0),

                TextFormField(
                  controller: reminderC,
                  focusNode: reminderFn,
                  readOnly: true,
                  onTap: setReminder,
                  style: const TextStyle(
                    fontSize: 16.0
                  ),
                  decoration: const InputDecoration(
                    labelText: "Set Reminder (Optional)",
                    labelStyle: TextStyle(
                      fontSize: 14.0
                    )
                  ),
                ),


                // ElevatedButton(
                //   onPressed: () async {
                //     await createChecklist();
                //   },
                //   child: isLoading 
                //   ? const SizedBox(
                //       width: 16.0,
                //       height: 16.0,
                //       child: CircularProgressIndicator(
                //         color: Colors.blue,
                //       ),
                //     ) 
                //   : const Text("Create")
                // )
          
              ],
            )
          ),
        ),
      )
    );
  }
}

class WidgetEmbedBuilder extends EmbedBuilder {
  final Map<String, Future<String>> videoCache = {};
  final Map<String, Future<String>> imageCache = {};

  @override
  String get key => 'image';

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    if (node.value.type == "image") {

      // Uint8List bytes = base64Decode(imageUrl.split(',').last);
      // final future = getImageFuture(imageUrl, bytes);

      String imageUrl = node.value.data;
      final future = getImageFutureV2(imageUrl);

      return FutureBuilder(
        future: future,
        key: ValueKey(imageUrl), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading image"));
            }
            String filePath = snapshot.data as String;
            return Image.network(
              filePath,
            );

          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    }
    if(node.value.type == "video") {
    
      // Uint8List bytes = base64Decode(videoUrl.split(',').last);
      // getVideoFuture(String videoUrl, Uint8List bytes)

      String videoUrl = node.value.data;
      final future = getVideoFutureV2(videoUrl);

      return FutureBuilder(
        future: future,
        key: ValueKey(videoUrl), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading video"));
            }

            String filePath = snapshot.data as String;
            return VideoPlayerWidget(filePath: filePath);
            
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    } 

    return const SizedBox();
  }

  Future<String> getVideoFutureV2(String videoUrl) {
    if (videoCache.containsKey(videoUrl)) {
      return videoCache[videoUrl]!;
    } else {
      final future = Future.value(videoUrl);
      videoCache[videoUrl] = future;
      return future;
    }
  }

   Future<String> getImageFutureV2(String imageUrl) {
    if(imageCache.containsKey(imageUrl)) {
      return imageCache[imageUrl]!;
    } else {
      final future = Future.value(imageUrl);
      imageCache[imageUrl] = future;
      return future;
    }
  }

  // Future<String> getVideoFuture(String videoUrl, Uint8List bytes) {
  //   if (videoCache.containsKey(videoUrl)) {
  //     return videoCache[videoUrl]!;
  //   } else {
  //     final future = writeBytesToFileVideo(bytes);
  //     videoCache[videoUrl] = future;
  //     return future;
  //   }
  // }

  // Future<String> getImageFuture(String imageUrl, Uint8List bytes) {
  //   if(imageCache.containsKey(imageUrl)) {
  //     return imageCache[imageUrl]!;
  //   } else {
  //     final future = writeBytesToFileImage(bytes);
  //     imageCache[imageUrl] = future;
  //     return future;
  //   }
  // }

  Future<String> writeBytesToFileImage(Uint8List bytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_img_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(bytes);
      return tempFile.path;
    } catch (e) {
      throw Exception("Error writing video file: $e");
    }
  }

  Future<String> writeBytesToFileVideo(Uint8List bytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_video_${DateTime.now().millisecondsSinceEpoch}.mp4');
      await tempFile.writeAsBytes(bytes);
      return tempFile.path;
    } catch (e) {
      throw Exception("Error writing video file: $e");
    }
  }

}

class VideoPlayerWidget extends StatefulWidget {
  final String filePath;

  const VideoPlayerWidget({super.key, required this.filePath});

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController controller;
  late ValueNotifier<bool> isInitializedNotifier;
  
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    isInitializedNotifier = ValueNotifier<bool>(false);
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.filePath))
      ..initialize().then((_) {
        isInitializedNotifier.value = true;
      });
  }

  @override
  void dispose() {
    controller.dispose();
    isInitializedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isInitializedNotifier,
      builder: (context, isInitialized, child) {
        return Stack(
          children: [

          if (isInitialized) 
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: Chewie(
                controller: ChewieController(
                  videoPlayerController: controller
                )
              ),
            ),
            
          // if(!isPlaying)
          //   Align(
          //     alignment: Alignment.center,
          //     child: IconButton(
          //       icon: Icon(
          //         controller.value.isPlaying
          //         ? Icons.pause_circle_filled
          //         : Icons.play_circle_filled,
          //         size: 100,
          //         color: Colors.white.withOpacity(0.8),
          //       ),
          //       onPressed: () {
          //         setState(() {
          //           controller.value.isPlaying ? controller.pause() : controller.play();
          //         });
          //       },
          //     ),
          //   )

          ],
        );
      },
    );
  }
}

// typedef EmbedButtonBuilder = Widget Function(
//   QuillController controller,
//   double toolbarIconSize,
//   QuillIconTheme? iconTheme,
//   QuillDialogTheme? dialogTheme,
// );