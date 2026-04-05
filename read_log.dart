import 'dart:io';

void main() async {
  final file = File(r'c:\Users\Youssef356\Documents\Mobile development\ar_explorer\.dart_tool\build_log.txt');
  final bytes = await file.readAsBytes();
  // Decode as UTF-16 LE
  final text = utf16leDecode(bytes);
  File(r'c:\Users\Youssef356\Documents\Mobile development\ar_explorer\.dart_tool\build_log_utf8.txt').writeAsStringSync(text);
}

String utf16leDecode(List<int> bytes) {
  StringBuffer buffer = StringBuffer();
  for (int i = 0; i < bytes.length; i += 2) {
    if (i + 1 < bytes.length) {
      int codeUnit = bytes[i] | (bytes[i+1] << 8);
      buffer.writeCharCode(codeUnit);
    }
  }
  return buffer.toString();
}
