import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/link.dart';

final uri = Uri.parse('https://github.com/Akatsuki1910/fluttertest');
final webPage = Uri.parse('https://akatsuki1910.github.io/fluttertest/');

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Wrap(
      spacing: 10,
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Link(
          uri: uri,
          target: LinkTarget.blank,
          builder: (context, followLink) {
            return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton(
                    onPressed: followLink, child: const Text('GitHub')));
          },
        ),
        Link(
          uri: webPage,
          target: LinkTarget.blank,
          builder: (context, followLink) {
            return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton(
                    onPressed: followLink, child: const Text('Web Page')));
          },
        ),
        SvgPicture.network(
          'https://github.com/Akatsuki1910/fluttertest/actions/workflows/build.yml/badge.svg',
        ),
      ],
    ));
  }
}
