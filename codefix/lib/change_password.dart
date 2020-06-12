import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codefix/login_page.dart';
import 'package:codefix/edit_account.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ChangePassword extends StatefulWidget {
 
  @override
  _ChangePassword createState() => new _ChangePassword();
   static String tag = 'change_password';
}

final db = Firestore.instance;
String userEmail;
final _formKeyChange = GlobalKey<FormState>();


TextEditingController _email = TextEditingController();
TextEditingController _newPassword = TextEditingController();
TextEditingController _oldPassword = TextEditingController();


class _ChangePassword extends State<ChangePassword> {

  bool _isHidePassword1 = true;
  bool _isHidePassword2=true;

  void _togglePasswordVisibility() {
    setState(() {
      _isHidePassword1 = !_isHidePassword1;
    });
  }

   void _togglePasswordVisibility2() {
    setState(() {
      _isHidePassword2 = !_isHidePassword2;
    });
  }

  @override
  void initState() {
    super.initState();
     getSession(context);
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


final oldPassword = TextFormField(
      autofocus: false,
      validator:validatePassword,
      controller:_oldPassword,
      //initialValue: 'some password',
       obscureText: _isHidePassword1,
       style: new TextStyle(color: Colors.white),
      decoration: InputDecoration(
      
        hintText: 'Old Password',
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
        suffixIcon: GestureDetector(
          onTap: () {
            _togglePasswordVisibility();
          },
          child: Icon(
            _isHidePassword1 ? Icons.visibility_off : Icons.visibility,
            color: _isHidePassword1 ? Colors.grey : Colors.blue,
          ),
        ),
        isDense: true,
      ),
    );

final newPassword = TextFormField(
       validator:validatePassword,
      autofocus: false,
      controller:_newPassword,
      //initialValue: 'some password',
       obscureText: _isHidePassword2,
       style: new TextStyle(color: Colors.white),
      decoration: InputDecoration(
      
        hintText: 'New Password',
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
        suffixIcon: GestureDetector(
          onTap: () {
            _togglePasswordVisibility2();
          },
          child: Icon(
            _isHidePassword2 ? Icons.visibility_off : Icons.visibility,
            color: _isHidePassword2 ? Colors.grey : Colors.blue,
          ),
        ),
        isDense: true,
      ),
    );
       

    final updateButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () async {

           if (_formKeyChange.currentState.validate()) {
              var count=0;
              var success=0;        

              try
              {
                if(_oldPassword.text=="" || _newPassword.text=="")
                {
                  toast("Enter all required fields");
                }
                else{
                  
                  var bytes = utf8.encode(_oldPassword.text); // data being hashed
                  var password = sha1.convert(bytes); 

                db.collection('student').snapshots().listen((data) =>data.documents.forEach((doc) {
                  count++;
                  if(doc.data['email']==userEmail && doc.data['password']==password.toString())
                  {

                    success=1;
                     var bytes2 = utf8.encode(_newPassword.text); // data being hashed
                     var password2 = sha1.convert(bytes2); 
                     _newPassword.text=password2.toString();

                    db.collection('student').document(userEmail).updateData({'password': _newPassword.text});
                    _newPassword.text="";
                    _oldPassword.text="";
                    toast("Password updated !!");
                    
                  }
                

                  if(doc.data['password']!=password.toString() && count==data.documents.length && success!=1)
                  {
                      toast("Old password not found");
                      
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
               
        },
        padding: EdgeInsets.all(12),
        color: Colors.grey[800],
        child: Text('Change password', style: TextStyle(color: Colors.white)),
        
      ),
    );


    
   
final mainForm= Form(
      key: _formKeyChange,
       child: ListView(
          shrinkWrap: true,

          children: <Widget>[
            oldPassword,
            SizedBox(height: 13.0),
            newPassword,
            SizedBox(height: 24.0),
            updateButton,
          ],
        ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      
          appBar: new AppBar(
             backgroundColor: Colors.black,
             automaticallyImplyLeading: true,
        //`true` if you want Flutter to automatically add Back Button when needed,
        //or `false` if you want to force your own back button every where
        title: Text('Change Password'),
        leading: IconButton(icon:Icon(Icons.arrow_back),
          onPressed:() => Navigator.pop(context,true),
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
             mainForm
          ],
        ),
      ),
      ]
     ),
    );
  }
}



Future getSession(BuildContext context) async {
      try{
        final prefs = await SharedPreferences.getInstance();

        if(prefs.getString("email")==null)
        {
          Navigator.of(context).pushNamed(LoginPage.tag);   
        }
        else
        {
           userEmail=prefs.getString("email");
          
        }
      } 
      catch(e)  
      {

      } 
   }


Future navigateToEditScreen(context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => Edit()));
   //Navigator.popAndPushNamed(context,'/edit');
}



void toast(String message)
{
  Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
    );
}


String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty) {
      return 'Please enter an email';
    } 
    else {
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }
}

  String validatePassword(String value) {
    Pattern pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regex = new RegExp(pattern);
    print(value);
    if (value.isEmpty) {
      return 'Please enter a password';
    } else {
      if (!regex.hasMatch(value))
        return 'Enter valid password!\nmust contain at least 8 characters with:\nupper case(s),lower case(s) and digit(s)';
      else
        return null;
    }
  }




