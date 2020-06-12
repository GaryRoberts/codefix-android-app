import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Help extends StatefulWidget {
  @override
  _Help createState() => _Help();
  static String tag = 'help';
}

class _Help extends State<Help>
    with SingleTickerProviderStateMixin {
  

  @override
  Widget build(BuildContext context) {
     final db = Firestore.instance;
    Size size = MediaQuery.of(context).size;


    var other = 2;
    var scaffold = new Scaffold(
          appBar: new AppBar(
             automaticallyImplyLeading: true,
        //`true` if you want Flutter to automatically add Back Button when needed,
        //or `false` if you want to force your own back button every where
        title: Text('Help'),
        leading: IconButton(icon:Icon(Icons.arrow_back),
          onPressed:() => Navigator.of(context).pushNamed('/homepage'),
        )
         
          ),

          body:
              
           Stack(
             
                 children: <Widget>[
                    Center(
                    child: new Image.asset(
                      'assets/images/login_bg.jpg',
                      width: size.width,
                      height: size.height,
                      fit: BoxFit.fill,
                    ),
                  ), 

         Container(




               ),
                ]
             ), 

          );


    return new MaterialApp(
            theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.black,
            accentColor: Colors.grey,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
          ),
          
          
      home: new Container(
        child: scaffold,
      ),
    );
  }
}



void main() {
   runApp(new Help());
 
}