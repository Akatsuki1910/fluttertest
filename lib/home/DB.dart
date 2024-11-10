import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DBPage extends StatefulWidget {
  const DBPage({super.key});

  @override
  State<DBPage> createState() => _DBPageState();
}

class _DBPageState extends State<DBPage> {
  Timestamp t = Timestamp.now();

  Future<void> get() async {
    final d = FirebaseFirestore.instance.collection('test');
    final doc = await d.doc('test1').get();
    setState(() {
      t = doc.get('t');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder(
          stream: FirebaseFirestore.instance.snapshotsInSync(),
          builder: (context, _) {
            return Text(
              'Latest Snapshot: ${DateTime.now()}',
              style: Theme.of(context).textTheme.bodySmall,
            );
          },
        ),
        ElevatedButton(
          onPressed: get,
          child: const Text('Get'),
        ),
        Text(t.toDate().toString()),
      ],
    );
  }
}
