import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart'; // Add this import

import '../components/article_screen.dart';
import '../components/news_data.dart';

// TODO: Replace with your App Group ID
const String appGroupId = '<YOUR APP GROUP>'; // Add from here
const String iOSWidgetName = 'NewAppWidget';
const String androidWidgetName = 'NewAppWidget'; // To here.

class MyHomeWidgetPage extends StatefulWidget {
  const MyHomeWidgetPage({super.key});
  @override
  State<MyHomeWidgetPage> createState() => _MyHomeWidgetPageState();
}

void updateHeadline(NewsArticle newHeadline) {
  // Add from here
  // Save the headline data to the widget
  HomeWidget.saveWidgetData<String>('headline_title', newHeadline.title);
  HomeWidget.saveWidgetData<String>(
      'headline_description', newHeadline.description);
  HomeWidget.updateWidget(
    iOSName: iOSWidgetName,
    androidName: androidWidgetName,
  );
} // To here.

class _MyHomeWidgetPageState extends State<MyHomeWidgetPage> {
  @override // Add from here
  void initState() {
    super.initState();

    HomeWidget.setAppGroupId(appGroupId);

    // Mock read in some data and update the headline
    final newHeadline = getNewsStories()[0];
    updateHeadline(newHeadline);
  } // To here.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Top Stories'),
            centerTitle: false,
            titleTextStyle: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        body: ListView.separated(
          separatorBuilder: (context, idx) {
            return const Divider();
          },
          itemCount: getNewsStories().length,
          itemBuilder: (context, idx) {
            final article = getNewsStories()[idx];
            return ListTile(
              key: Key('$idx ${article.hashCode}'),
              title: Text(article.title),
              subtitle: Text(article.description),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ArticleScreen(article: article);
                    },
                  ),
                );
              },
            );
          },
        ));
  }
}
