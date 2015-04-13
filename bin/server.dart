// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:force/force_serverside.dart';

void main(List<String> args) {
  var parser = new ArgParser()
      ..addOption('port', abbr: 'p', defaultsTo: '6060');

  var result = parser.parse(args);

  var port = int.parse(result['port'], onError: (val) {
    stdout.writeln('Could not parse port value "$val" into a number.');
    exit(1);
  });
  
  Force force = new Force();
  var _handlerws = webSocketHandler((webSocket) => force.handle(new StreamSocket(webSocket)));
  
  /*
   * Do some force related stuff
   */
  force.on("add", (msg, sender) {
    print(msg.json);
    sender.send("update", msg.json);
  });
  
  // static handlers
  var staticHandler = createStaticHandler('build/web', 
          defaultDocument: 'index.html');
  
  var handler = new Cascade()
      .add(staticHandler)
      .add(_handlerws)
      .handler;
  
  io.serve(handler, 'localhost', port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}
