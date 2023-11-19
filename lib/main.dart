import 'package:flutter/material.dart';
import 'package:lets_chat/pages/home_page.dart';
import 'package:lets_chat/pages/login_page.dart';
import 'package:lets_chat/pages/register_page.dart';

import 'package:lets_chat/pages/splash_page.dart';
import 'package:lets_chat/providers/authentication_provider.dart';
import 'package:lets_chat/services/navigation_service.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(SplashPage(
    key: UniqueKey(),
    onInitializationComplete: () {
      runApp(MainApp(),);
    },
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<AuthenticationProvider>(create:(BuildContext context){
        return AuthenticationProvider();
      },)
    ],
    child: MaterialApp(
      title: "let's Chat",
      theme: ThemeData(
        backgroundColor: const Color.fromARGB(36, 35, 49, 1),
        scaffoldBackgroundColor: const Color.fromARGB(36, 35, 49, 1),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromRGBO(30, 29, 37, 1.0),
        ),
      ),
      navigatorKey:NavigationService.navigatorKey,
      initialRoute: '/login',
      routes: {
        '/login':(BuildContext context)=>const LoginPage(),
        '/home':(BuildContext context)=>const HomePage(),
        '/register':(BuildContext context)=>const RegisterPage() ,
      },
    ),);
  }
}
