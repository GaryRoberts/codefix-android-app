import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'challenge.dart';
import 'recovery.dart';
import 'register.dart';
import 'prize.dart';
import 'help.dart';
import 'edit_account.dart';
import 'change_password.dart';
import 'activation.dart';

 bool activeSession = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  final prefs = await SharedPreferences.getInstance();
        String active=prefs.getString("email");

        if(active!=null)
        {
         activeSession=true;
        }

        

        runApp(MyApp());
        
}

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
  };
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeFix',
      debugShowCheckedModeBanner: false,
       theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.black,
            accentColor: Colors.grey,
            fontFamily: 'Nunito'
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
          ),
      home:activeSession?HomePage():LoginPage(),

      routes: <String, WidgetBuilder> {
    '/login': (BuildContext context) => new LoginPage(),
    '/register' : (BuildContext context) => new Register(),
    '/activation' : (BuildContext context) => new Activation(),
    '/homepage' : (BuildContext context) => new HomePage(),
    '/challenge' : (BuildContext context) => new Challenge(),
    '/prize' : (BuildContext context) => new Prize(),
    '/help' : (BuildContext context) => new Help(),
    '/edit' : (BuildContext context) => new Edit(),
    '/recovery' : (BuildContext context) => new Recovery(),
    '/change_password' : (BuildContext context) => new ChangePassword()
    
  },
    );
  }
}

 Future getSessionStatus(BuildContext context) async {
        final prefs = await SharedPreferences.getInstance();
        String active=prefs.getString("email");

        if(active!=null)
        {
         activeSession=false;
        }
        
      }