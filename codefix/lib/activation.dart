import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pin_code/flutter_pin_code.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codefix/home_page.dart';


class Activation extends StatefulWidget {
 
  @override
  _Activation createState() => new _Activation();
   static String tag = 'activation';
}

final db = Firestore.instance;
int pinCode=0000;
String activationEmail;

class _Activation extends State<Activation> {

 TextEditingController controller = TextEditingController();
  String thisText = "";
  int pinLength = 4;

  bool hasError = false;
  String errorMessage;

  @override
  void initState() {
    super.initState();

 super.initState();
 try{
    Future.delayed(Duration.zero, () async {
       await  getActivationEmail(context);
    });
 }
 catch(e)
 {

 }
   
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
 

  final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 60.0,
        child: Image.asset('assets/images/logo.png'),
      ),
    );



    final pinUI = PinCodeView(
       correctPin: pinCode,
       title: Text(
         'Please insert account activation pin in your email',
         style: TextStyle(color: Colors.blue),
         textAlign: TextAlign.center,
       ),
       subTitle: InkWell(
         onTap: () {},
         child: Text(
           'Resend pin',
           style: TextStyle(color: Colors.blue),
           textAlign: TextAlign.center,
         ),
       ),
       errorMsg: 'Wrong PIN',
       onSuccess: (pin) {
         int error=1;
         var count=0;

         db.collection('student').snapshots().listen((data) =>data.documents.forEach((doc) {
             count++;
            if(doc.data['email']==activationEmail && doc.data['pin']==pin)
            {
                error=0;
                db.collection('student').document(activationEmail).updateData({'status': 'active'});
                toast("Account activated !!!");
                sessionCreate(doc.data['email'],doc.data['firstName'],doc.data['lastName'],doc.data['gender'],doc.data['creditType'],doc.data['wins']);
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage())); 
               
            }

             if(error==1 && count==data.documents.length)
              {
                toast("Account not activated. Try again");
              }
        }));

       },
     );


try{
    return Scaffold(
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
  
      Center( 
        child: ListView(

          children: <Widget>[
             SizedBox(height: 40.0),
            logo,
            SizedBox(height: 30.0),
            pinUI
          ],
        ),
      ),
      ]
     ),
    );
  }
  catch(e)
  {

  }
  
  }

   Future<void> getActivationEmail(BuildContext context) async {
     try{
        final prefs = await SharedPreferences.getInstance();
        String activatedEmail=prefs.getString("activation_email");
        

        if(activatedEmail!=null)
        {
          setState(() {
           activationEmail=activatedEmail;
           });

            db.collection('student').snapshots().listen((data) =>data.documents.forEach((doc) {
            
              if(doc.data['email']==activatedEmail)
              {
                setState(() {
                   pinCode=int.parse(doc.data['pin']);
                  });
              }
            }));

        }
     } 
     catch(e)
     {

     }
        
      }
}



sessionCreate(String email,String firstName,String lastName,String gender,String creditType,String wins) async {
         final prefs = await SharedPreferences.getInstance();
        
          prefs.setString("email",email);
          prefs.setString("firstName",firstName);
          prefs.setString("lastName",lastName);
          prefs.setString("gender",gender);
          prefs.setString("creditType",creditType);
          prefs.setString("wins",wins);
      }


void toast(String message)
{
  Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
    );
}

 
