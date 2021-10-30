import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:web_socket_channel/io.dart';

void main() async {

  // channel.stream.listen((message) {
  //   final decodedMessage = jsonDecode(message);
  //   final serverTimeAsEpoch = decodedMessage['time'];
  //   final serverTime = DateTime.fromMillisecondsSinceEpoch(serverTimeAsEpoch * 1000);
  //   print(serverTime);
  //   // disconnect from web socket
  //   // channel.sink.close();
  // });

  // channel.sink.add('{"time": 1}');
  
  print('List of active symbols:');
  await get_symbol();
  get_tick();
}

Future <dynamic> get_symbol(){
  dynamic symbols = [];
  final channel = IOWebSocketChannel.connect('wss://ws.binaryws.com/websockets/v3?app_id=1089');

  channel.stream.listen((message) {
    final decodedMessage = jsonDecode(message);
    final activeSymbol = decodedMessage['active_symbols'];

    for (int i = 0; i < 10; i++){
      // return print(activeSymbol[i]["symbol"]);
      symbols.insert(i , activeSymbol[i]['symbol']);
    }
  });
  channel.sink.add('{"active_symbols": "brief"}');  
  return Future(()=>print(symbols));
}

void get_tick(){
  final channel = IOWebSocketChannel.connect('wss://ws.binaryws.com/websockets/v3?app_id=1089');

  channel.stream.listen((tick) {
    final decodedMessage = jsonDecode(tick);
    final symbolName = decodedMessage['tick']['symbol'];
    final quotePrice = decodedMessage['tick']['quote'];
    final serverTimeAsEpoch = decodedMessage['tick']['epoch'];
    final serverTime =
        DateTime.fromMillisecondsSinceEpoch(serverTimeAsEpoch * 1000);

    print('Name: $symbolName Price: $quotePrice Date and Time: $serverTime');
  });

  print('Enter symbol (Example: R_50, R_25)');
  String? symbol = stdin.readLineSync();
  channel.sink.add('{"ticks": "$symbol", "subscribe": 1}');
}