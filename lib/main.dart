import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wather_app_batch05/pages/settings_page.dart';
import 'package:wather_app_batch05/pages/weather_page.dart';
import 'package:wather_app_batch05/providers/weather_provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => WeatherProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'MerriweatherSans',

        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: WeatherPage.routeName,
      routes: {
        WeatherPage.routeName: (_) => WeatherPage(),
        SettingsPage.routeName: (_) => SettingsPage(),
      },
    );
  }
}
