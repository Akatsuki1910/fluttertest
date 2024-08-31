import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

final uri = Uri.parse('https://github.com/Akatsuki1910/fluttertest');

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Link(
        uri: uri,
        target: LinkTarget.blank,
        builder: (context, followLink) {
          return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ElevatedButton(
                  onPressed: followLink, child: const Text('GitHub')));
        },
      ),
    );
  }
}
