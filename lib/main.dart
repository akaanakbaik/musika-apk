import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'provider_setup.dart';
import 'app.dart';
import 'providers/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderSetup());
}

class ProviderSetup extends StatelessWidget {
  const ProviderSetup({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProviderSetup(
      child: FutureBuilder<SettingsProvider>(
        future: _initSettings(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MusikaApp(settings: snapshot.data!);
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }

  Future<SettingsProvider> _initSettings() async {
    final settings = SettingsProvider();
    await settings.initialize();
    return settings;
  }
}
