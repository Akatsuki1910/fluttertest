import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/link.dart';

String formatBytes(int bytes, int decimals) {
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class BuildPage extends StatefulWidget {
  const BuildPage({super.key});

  @override
  State<BuildPage> createState() => _BuildPageState();
}

class _BuildPageState extends State<BuildPage> {
  List items = [];

  Future<void> getData() async {
    var response = await http.get(Uri.https(
        'api.github.com', '/repos/Akatsuki1910/fluttertest/actions/artifacts'));

    var jsonResponse = jsonDecode(response.body);

    setState(() {
      items = jsonResponse['artifacts'];
    });
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SelectionArea(
            child: ScrollConfiguration(
                behavior: MyCustomScrollBehavior(),
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const <DataColumn>[
                            DataColumn(label: Expanded(child: Text('Name'))),
                            DataColumn(label: Expanded(child: Text('ID'))),
                            DataColumn(label: Expanded(child: Text('Byte'))),
                            DataColumn(
                                label: Expanded(child: Text('Created At'))),
                            DataColumn(label: Expanded(child: Text('DL'))),
                          ],
                          rows: items
                              .map((item) => DataRow(cells: <DataCell>[
                                    DataCell(Text(item['name'])),
                                    DataCell(Text(item['node_id'])),
                                    DataCell(Text(
                                        formatBytes(item['size_in_bytes'], 2))),
                                    DataCell(Text(DateFormat('yyyy/M/d h:m:s')
                                        .format(DateTime.parse(
                                            item['created_at'])))),
                                    DataCell(Link(
                                      uri: Uri.parse(
                                          'https://github.com/Akatsuki1910/fluttertest/actions/runs/${item['workflow_run']['id']}/artifacts/${item['id']}'),
                                      target: LinkTarget.blank,
                                      builder: (context, followLink) {
                                        return MouseRegion(
                                            cursor: item['expired']
                                                ? SystemMouseCursors.forbidden
                                                : SystemMouseCursors.click,
                                            child: ElevatedButton(
                                                onPressed: item['expired']
                                                    ? null
                                                    : followLink,
                                                child: const Text('Download')));
                                      },
                                    )),
                                  ]))
                              .toList(),
                        ))))));
  }
}
