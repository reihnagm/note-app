import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:mynote/provider/auth.dart';
import 'package:mynote/provider/note.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
];

List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider(create: (_) => AuthNotifier()),
  ChangeNotifierProvider(create: (_) => NoteNotifier()),
];