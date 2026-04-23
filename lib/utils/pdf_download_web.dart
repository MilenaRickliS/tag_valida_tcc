// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

void downloadPdfWeb(List<int> bytes, String filename) {
  final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);

  final blob = html.Blob([data], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..style.display = 'none'
    ..download = filename;

  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();

  html.Url.revokeObjectUrl(url);
}