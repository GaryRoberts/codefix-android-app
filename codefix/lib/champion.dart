import 'package:codefix/challenge.dart';
import 'package:codefix/home_page.dart';
import 'package:codefix/prize.dart';
import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codefix/login_page.dart';
import 'package:shake/shake.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:animated_text_kit/animated_text_kit.dart';


class Congrats extends StatefulWidget {
  @override
  _Congrats createState() => _Congrats();
  static String tag = 'congrats';
}


class _Congrats extends State<Congrats>
    with SingleTickerProviderStateMixin {
  
  //GifController _animationCtrl;
 @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
       await getSession(context);
    });

      ShakeDetector detector = ShakeDetector.autoStart(onPhoneShake: () {
         Navigator.push(context, MaterialPageRoute(builder: (context) => Prize()));
    });
    detector.startListening();
     
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;


    var other = 2;
       return WillPopScope(
      onWillPop: () async {
    MoveToBackground.moveTaskToBack();
         return false;
      },
    child:Scaffold(
          appBar: new AppBar(
                title: Text('Well Done !!!')
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
             child:Center(
             child: Column(
               children: <Widget>[
             SizedBox(
                    width: 260.0,
                    child: ScaleAnimatedTextKit(
                      onTap: () {
                          print("Tap Event");
                        },
                      text: [
                        firstName,
                        "You won credit",
                        "Keep it up"
                        ],
                      textStyle: TextStyle(
                          fontSize: 50.0,
                          fontFamily: "Canterbury",
                          color: Colors.green
                      ),
                  
                      textAlign: TextAlign.center,
                      alignment: AlignmentDirectional.topStart 
                    ),
                  ),

                 Hero(
                tag: 'hero',
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 150.0,
                  
                  child: Image.asset('assets/images/win.gif'),
                 ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                     
                    },
                    padding: EdgeInsets.all(12),
                    color: Colors.green,
                    child: Text('Back to home', style: TextStyle(color: Colors.white)),
                    
                  ),
                ),

                 Text('SHAKE PHONE TO ACCESS PRIZE !', style: TextStyle(color: Colors.white))

               ]) )),
                ]
             ), 

       ));

  }

String email;
String firstName;

   Future<void> getSession(BuildContext context) async {
        final prefs = await SharedPreferences.getInstance();
        String active=prefs.getString("email");
        
        if(active==null)
        {
          
         Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())); 
        }
        else
        {
            setState(() {
             email=prefs.getString("email");
             firstName="Congrats"+prefs.getString("firstName");
  
           });
    
        }
        
      }

}
      

  
void toast(String message)
{
  Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
    );
}


void main() {
   runApp(new Congrats());
 
}