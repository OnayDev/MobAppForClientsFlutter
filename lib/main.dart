import 'package:flutter/material.dart';

import './core/theme/app_theme.dart';
import './features/auth/auth_page.dart';
import '/store/auth_store.dart';
import 'package:flutter_client_oi/features/webview/web_view_page.dart';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final auth = AuthStore();

  @override
  void dispose() {
    auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => AuthPage(auth: auth),
        '/main': (_) => WebViewPage(authStore: auth),
      },
    );
  }
}
