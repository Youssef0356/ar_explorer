import 'dart:io';

void main() {
  final pubCache = Platform.environment['PUB_CACHE'] ?? '${Platform.environment['LOCALAPPDATA']}\\Pub\\Cache';
  final dir = Directory('$pubCache\\hosted\\pub.dev');
  if (!dir.existsSync()) {
    print('No pub cache found at $pubCache');
    return;
  }
  final showcaseDirs = dir.listSync().where((d) => d.path.contains('showcaseview')).toList();
  if (showcaseDirs.isNotEmpty) {
    final showcaseFile = File('${showcaseDirs.last.path}\\lib\\src\\showcase.dart');
    if (showcaseFile.existsSync()) {
      print(showcaseFile.readAsStringSync().substring(0, 2500));
    }
  }
}
