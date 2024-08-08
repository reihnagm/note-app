import 'dart:io';
import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';

import 'package:path_provider/path_provider.dart';

import 'package:intl/intl.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress_v2/video_compress_v2.dart';

import 'package:mynote/common/global.dart';
import 'package:mynote/page/auth/login.dart';

import 'package:mynote/provider/auth.dart';
import 'package:mynote/provider/note.dart';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class GDialog {
  
  static customShowDialog({
    required String title,
    double fontSizeTitle = 16
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title,
            style: TextStyle(
              fontSize: fontSizeTitle
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      }
    );
  }

  static confirmPinNote({
    required String title, 
    required String noteId,
    double fontSizeTitle = 16
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text.rich(
            TextSpan(
              children: [

              const TextSpan(
                text: 'Do you want to pin this ',
                style: TextStyle(
                  fontSize: 16.0
                ),
              ),

              TextSpan(
                text: "$title ?",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0
                ),
              ),

            ]
          ),
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),

          TextButton(
            onPressed: () async {

              await navigatorKey.currentContext!.read<NoteNotifier>().pinned(
                noteId: noteId,
              );

              Navigator.of(navigatorKey.currentContext!).pop();

            },
            child: const Text('Ok'),
          ),

        ],
      );
    });
  }

  static confirmUnpinNote({
    required String title, 
    required String noteId,
    double fontSizeTitle = 16
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text.rich(
            TextSpan(
              children: [

              const TextSpan(
                text: 'Do you want to unpin this ',
                style: TextStyle(
                  fontSize: 16.0
                ),
              ),

              TextSpan(
                text: "$title ?",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0
                ),
              ),

            ]
          ),
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),

          TextButton(
            onPressed: () async {
              
              await navigatorKey.currentContext!.read<NoteNotifier>().unpinned(
                noteId: noteId,
              );

              Navigator.of(navigatorKey.currentContext!).pop();

            },
            child: const Text('Ok'),
          ),

        ],
      );
    });
  }

  static confirmDel({
    required String contentId,
    required String noteId,
    required String title,
    double fontSizeTitle = 16
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
         return AlertDialog(
          title: Text.rich(
            TextSpan(
              children: [

                const TextSpan(
                  text: 'Are you sure want to delete ',
                  style: TextStyle(
                    fontSize: 16.0
                  ),
                ),

                TextSpan(
                  text: "$title ?",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0
                  ),
                ),

              ]
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {

                await navigatorKey.currentContext!.read<NoteNotifier>().destroyNote(
                  contentId: contentId, 
                  noteId: noteId
                );

                Navigator.of(navigatorKey.currentContext!).pop();

              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  static quillToolbar({required QuillController controller}) {

    Future<File> uint8ListToFile(Uint8List uint8List, String fileName) async {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      String timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      String uniqueFileName = '${timestamp}_$fileName';

      File file = File('$tempPath/$uniqueFileName');

      return await file.writeAsBytes(uint8List);
    }

    Future<void> insertImage() async {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {

        navigatorKey.currentContext!.read<NoteNotifier>().setStateLoading(true);

        Uint8List? result = await FlutterImageCompress.compressWithFile(
          image.path,
          format: CompressFormat.jpeg,
          quality: 30,
        );
        
        const String cloudName = "dilzovvfk";
        CloudinaryPublic cloudinary = CloudinaryPublic(cloudName, 'noteapp', cache: false);

        File file = await uint8ListToFile(result!, 'img.jpg');

        try {

          CloudinaryResponse? response = await cloudinary.uploadFileInChunks(
            CloudinaryFile.fromFile(file.path, identifier: 'jpg'),
            onProgress: (count, total) {
              var progress = (count / total) * 100;

              navigatorKey.currentContext!.read<NoteNotifier>().setStateProgress(progress.toStringAsFixed(0));
            },
          );

          final index = controller.selection.baseOffset;
          final length = controller.selection.extentOffset - index;

          controller.replaceText(
            index,
            length, 
            BlockEmbed.image(response!.secureUrl), 
            TextSelection.collapsed(offset: index + 1)
          );

          navigatorKey.currentContext!.read<NoteNotifier>().setStateLoading(false);
          navigatorKey.currentContext!.read<NoteNotifier>().clearProgress();
        
        } catch(e) {
          debugPrint(e.toString());
        }

      }
    }

    Future<void> insertVideo() async {
      final picker = FilePicker.platform;
      final FilePickerResult? video = await picker.pickFiles(type: FileType.video, allowMultiple: false);
      if (video != null) {

        navigatorKey.currentContext!.read<NoteNotifier>().setStateLoading(true);

        MediaInfo? mediaInfo = await VideoCompressV2.compressVideo(
          video.xFiles.first.path,
          quality: VideoQuality.Res640x480Quality, 
          deleteOrigin: false,
        );

        const String cloudName = "dilzovvfk";
        CloudinaryPublic cloudinary = CloudinaryPublic(cloudName, 'noteapp', cache: false);

        try {
          CloudinaryResponse? response = await cloudinary.uploadFileInChunks(
            CloudinaryFile.fromFile(mediaInfo!.file!.path, identifier: 'mp4'),
            onProgress: (count, total) {
              var progress = (count / total) * 100;

              navigatorKey.currentContext!.read<NoteNotifier>().setStateProgress(progress.toStringAsFixed(0));
            },
          );

          // final bytes = await  video.xFiles.first.readAsBytes();
          // final base64Video = base64Encode(bytes);
          // final uri = 'data:video/mp4;base64,$base64Video';

          final index = controller.selection.baseOffset;
          final length = controller.selection.extentOffset - index;

          controller.replaceText(
            index,
            length,
            BlockEmbed.video(response!.secureUrl),
            TextSelection.collapsed(offset: index + 1),
          );

          navigatorKey.currentContext!.read<NoteNotifier>().setStateLoading(false);
          navigatorKey.currentContext!.read<NoteNotifier>().clearProgress();
          
        } catch(e) {
          debugPrint(e.toString());
        }
        
      }
    }

    return showModalBottomSheet(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return QuillToolbar.simple(
          configurations: QuillSimpleToolbarConfigurations(
            controller: controller,
            showSuperscript: false,
            showSubscript: false,
            sharedConfigurations: const QuillSharedConfigurations(),
            customButtons: [
              QuillToolbarCustomButtonOptions(
                icon: const Icon(Icons.image),
                onPressed: () {
                  insertImage();

                  Navigator.pop(context);
                }
              ),
              QuillToolbarCustomButtonOptions(
                icon: const Icon(Icons.video_library),
                onPressed: () {
                  insertVideo();

                  Navigator.pop(context);
                },
              ),
            ]
          ),
        );
      },
    );
    
  }

  static logout({
    required String title,
    double fontSizeTitle = 16
  }) async {
    return showDialog(
      context: navigatorKey.currentContext!, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title,
            style: TextStyle(
              fontSize: fontSizeTitle
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              }, 
              child: const Text('Cancel')
            ),
            TextButton(
              onPressed: () {

                context.read<AuthNotifier>().destoryToken();
    
                Navigator.pushAndRemoveUntil(navigatorKey.currentContext!,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) {
                    return false;
                  },
                );

              }, 
              child: const Text('Yes')
            ),
          ],
        );
      },
    );
  }

}