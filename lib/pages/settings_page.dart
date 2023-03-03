import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wather_app_batch05/providers/weather_provider.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings_page';

  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) => ListView(
          padding: const EdgeInsets.all(8),
          children: [
            SwitchListTile(
              title: const Text('Show temperature in Fahrenheit', style: TextStyle(color: Colors.white),),
              subtitle: const Text('Default is celsius', style: TextStyle(color: Colors.white),),
              value: provider.isFahenheit,
              onChanged: (value) async {
                provider.setTempUnit(value);
                await provider.setPreferenceTempUnitValue(value);
                provider.getWeatherData();
              },
            )
          ],
        ),
      ),
    );
  }
}
