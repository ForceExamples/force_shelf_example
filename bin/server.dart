// Copyright (c) 2015, ForceUniverse. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:force/force_serverside.dart';

void main(List<String> args) {
  // instantiate Force and hand it over to shelf socket
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
  
  // stack up handlers
  var handler = new Cascade()
      .add(staticHandler)
      .add(_handlerws)
      .handler;
  
  // start shelf
  io.serve(handler, 'localhost', 8080).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}
