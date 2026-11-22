import 'dart:io';

const Map<String, String> mimeTypes = {
  '.html': 'text/html; charset=utf-8',
  '.htm': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.mjs': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
};

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args[0]) ?? 8080 : 8080;
  final webDir = Directory('build/web');

  if (!await webDir.exists()) {
    print('Error: Directory ${webDir.path} does not exist. Run "flutter build web" first.');
    exit(1);
  }

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('========================================================');
  print('  Banchong Cafe Mobile Web Server is RUNNING');
  print('  - Port: $port');
  print('  - Computer URL: http://localhost:$port');
  print('  - Phone Wi-Fi URL: http://192.168.1.132:$port');
  print('========================================================');

  await for (HttpRequest request in server) {
    try {
      var path = request.uri.path.replaceFirst(RegExp(r'^/+'), '');
      if (path.isEmpty) path = 'index.html';

      var file = File('${webDir.path}/$path');
      if (!await file.exists()) {
        file = File('${webDir.path}/index.html');
      }

      if (await file.exists()) {
        final ext = file.path.contains('.') ? '.${file.path.split('.').last.toLowerCase()}' : '';
        final contentType = mimeTypes[ext] ?? 'application/octet-stream';

        request.response.headers.set('Content-Type', contentType);
        request.response.headers.set('Access-Control-Allow-Origin', '*');
        await request.response.addStream(file.openRead());
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('404 Not Found');
      }
    } catch (e) {
      // ignore client errors
    } finally {
      await request.response.close();
    }
  }
}
