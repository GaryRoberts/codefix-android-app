import 'package:flutter/material.dart';
import 'package:codefix/message.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Recovery extends StatefulWidget {
 
  @override
  _Recovery createState() => new _Recovery();
   static String tag = 'Recovery';
}

final db = Firestore.instance;

TextEditingController _email = TextEditingController();


class _Recovery extends State<Recovery> {


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
      keyboardType: TextInputType.emailAddress,
      controller: _email,
      autofocus: false,
      //initialValue: 'alucard@gmail.com',
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

   

    final resetButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () async { 
              try{
                if(_email.text!="")
                {

                   final snapShot = await Firestore.instance.collection('student').document(_email.text).get();

                        if (snapShot.exists)
                        {   
                           sendRecovery(_email.text);
                        }
                        else
                        {
                           toast("Account not found.Try again");
                        }
                }
                else{
                    toast("Email field cannot be empty !!!");
                }
              }
              catch(e)
              {
                
              }
                            
              },
        padding: EdgeInsets.all(12),
        color: Colors.grey[800],
        child: Text('Recover Account', style: TextStyle(color: Colors.white)),
        
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
             backgroundColor: Colors.black,
             automaticallyImplyLeading: true,

        title: Text('Back'),
        leading: IconButton(icon:Icon(Icons.arrow_back),
          onPressed:() => Navigator.of(context).pop(),
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

      Center( 
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 30.0),
            email,
            SizedBox(height: 24.0),
            resetButton,
          ],
        ),
      ),
      ]
     ),
    );
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

