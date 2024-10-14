import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiPage extends HookWidget {
  const ApiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController(text: '');
    final textController2 = useTextEditingController(text: '');
    final resText = useState('');
    final resText2 = useState('');
    final channel = useState<WebSocketChannel?>(null);

    useEffect(() {
      final v = channel.value;
      if (v != null) {
        v.stream.listen((message) {
          resText2.value = message.toString();
        });
      }

      return () {
        channel.value?.sink.close(status.goingAway);
      };
    }, [channel]);

    final text = useListenableSelector(
      textController,
      () => textController.text,
    );
    final text2 = useListenableSelector(
      textController2,
      () => textController2.text,
    );

    final getData = useCallback(() async {
      var response = await http.get(Uri.parse(text));

      resText.value = response.body;
    }, [text]);

    final wsConnect = useCallback(() async {
      final wsUrl = Uri.parse(text2);
      channel.value = WebSocketChannel.connect(wsUrl);

      await channel.value?.ready;
    }, [text2]);

    return Column(children: [
      TextField(
        controller: textController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'API',
        ),
      ),
      ElevatedButton(
        onPressed: getData,
        child: const Text('叩く'),
      ),
      Text(text),
      Text(resText.value),
      TextField(
        controller: textController2,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'WS',
        ),
      ),
      Row(children: [
        ElevatedButton(
          onPressed: wsConnect,
          child: const Text('Connect'),
        ),
        ElevatedButton(
          onPressed: channel.value != null
              ? () {
                  channel.value?.sink.add(DateTime.now().toString());
                }
              : null,
          child: const Text('Send'),
        ),
      ]),
      Text(text2),
      Text(resText2.value),
    ]);
  }
}
