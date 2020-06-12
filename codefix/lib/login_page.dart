import 'package:flutter/material.dart';
import 'package:codefix/home_page.dart';
import 'package:codefix/register.dart';
import 'package:codefix/recovery.dart';
import 'package:codefix/activation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:crypto/crypto.dart';
import 'package:shake/shake.dart';
import 'dart:convert';

  bool isLoading = false;
class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

class _LoginPageState extends State<LoginPage> {
 bool checkValue = false;

  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
     getSessionStatus(context);
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

    final email = TextFormField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
       style: new TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: TextStyle(fontSize: 15.0, color: Colors.grey),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );

    final password = TextFormField(
      controller: _password,
      autofocus: false,
      //initialValue: 'some password',
      obscureText: true,
       style: new TextStyle(color: Colors.white),
      decoration: InputDecoration(
      
        hintText: 'Password',
        hintStyle: TextStyle(fontSize: 15.0, color: Colors.grey),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: isLoading ? CircularProgressIndicator() :RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          setState(() {
           isLoading = true;
          });

          login();

        },
        padding: EdgeInsets.all(12),
        color: Colors.grey[800],
        child: Text('Log In', style: TextStyle(color: Colors.white)),
        
      ),
    );

  

      final createAccountLabel = FlatButton(
      child: Text(
        'No account? Create acccount',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {navigateToRegistration(context);},
    );
    
    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {navigateToRecovery(context);},
    );

   
 return WillPopScope(
      onWillPop: () async {
    MoveToBackground.moveTaskToBack();
         return false;
      },
    child:Scaffold(
      backgroundColor: Colors.white,
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
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
            createAccountLabel,
            forgotLabel
          ],
        ),
      ),
      ]
     ),
    ));
  }



void login()
{
  int count=0;

try
{
  if(_email.text=="" || _password.text=="")
  {
      setState(() {
           isLoading = false;
          });
    toast("Enter all required fields");
  }
  else{
     
     var bytes = utf8.encode(_password.text); // data being hashed
     var password = sha1.convert(bytes); 

   db.collection('student').snapshots().listen((data) =>data.documents.forEach((doc) {
    count++;
  
    if(doc.data['email']==_email.text && doc.data['password']==password.toString() && doc.data['status']=="active")
    {
       sessionCreate(doc.data['email'],doc.data['firstName'],doc.data['lastName'],doc.data['gender'],doc.data['creditType'],doc.data['wins']);
      success=1;
      _email.text="";
      _password.text="";
      setState(() {
           isLoading = false;
          });
      navigateToHomePage(context);
      
    }
    
     if(doc.data['email']==_email.text && doc.data['password']==password.toString() && doc.data['status']!="active")
     {
        setState(() {
           isLoading = false;
          });

       toast("Account not activated !");
        _email.text="";
       _password.text="";
       sessionCreate(doc.data['email'],doc.data['firstName'],doc.data['lastName'],doc.data['gender'],doc.data['creditType'],doc.data['wins']);
       activationSession(doc.data['email']);
       navigateToActivation(context);
     }

      if(count==data.documents.length && success==0)
        {
          setState(() {
           isLoading = false;
          });
         toast("Credentials not found");
        }
     
  
    }
  )
 );   
 
}

} 
 catch (e) 
 {

    toast("Something went wrong.Try again");
  }
  
}


}

  final db = Firestore.instance;

  var error=0;
  var statusError=0;
  int success=0;

 Future sessionCreate(String email,String firstName,String lastName,String gender,String creditType,String wins) async {
         final prefs = await SharedPreferences.getInstance();
        
          prefs.setString("email",email);
          prefs.setString("firstName",firstName);
          prefs.setString("lastName",lastName);
          prefs.setString("gender",gender);
          prefs.setString("creditType",creditType);
          prefs.setString("wins",wins);
      }
  

Future navigateToHomePage(context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
}

Future navigateToRegistration(context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
}

Future navigateToRecovery(context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => Recovery()));
}

Future navigateToActivation(context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => Activation()));
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



void deleteData() {
  try {
     db.collection('books').document('1').delete();
  } catch (e) {
    print(e.toString());
  }
}


     Future activationSession(String email) async {
         final prefs = await SharedPreferences.getInstance();
        
          prefs.setString("activation_email",email);

      }


      Future getSessionStatus(BuildContext context) async {
        final prefs = await SharedPreferences.getInstance();
        String active=prefs.getString("email");

        if(active!=null)
        {
          navigateToHomePage(context);
        }
        
      }


