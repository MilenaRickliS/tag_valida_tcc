import 'package:open_filex/open_filex.dart';

Future<void> openPdfFile(String path) async {
  await OpenFilex.open(path);
}