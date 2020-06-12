import 'package:flutter/material.dart';
import 'package:codefix/activation.dart';
import 'package:codefix/login_page.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';


class Register extends StatefulWidget {
 
  @override
  _Register createState() => new _Register();
   static String tag = 'register';
}

final db = Firestore.instance;
final _formKeyRegister = GlobalKey<FormState>();

String _genderSelected = "";
String _creditSelected = "";
TextEditingController _email = TextEditingController();
TextEditingController _firstName = TextEditingController();
TextEditingController _lastName = TextEditingController();
TextEditingController _password = TextEditingController();
bool isLoading = false;

class _Register extends State<Register> {
    final List<String> _genderTypes = ["Male","Female"]; 
    final List<String> _creditTypes = ["Digicel","Flow"];


  bool _isHidePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _isHidePassword = !_isHidePassword;
    });
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


    

     final firstName = TextFormField(
       validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a first name';
              }
              return null;
            },
       controller: _firstName,
      autofocus: false,
      //initialValue: 'alucard@gmail.com',
       style: new TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'First name',
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


      final lastName= TextFormField(
        validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a last name';
              }
              return null;
            },
        controller: _lastName,
        autofocus: false,
        //initialValue: 'alucard@gmail.com',
        style: new TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Last name',
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

      

    final email = TextFormField(
      validator:validateEmail,
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

    final password = TextFormField(
       validator:validatePassword,
      autofocus: false,
      controller:_password,
      //initialValue: 'some password',
       obscureText: _isHidePassword,
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
        suffixIcon: GestureDetector(
          onTap: () {
            _togglePasswordVisibility();
          },
          child: Icon(
            _isHidePassword ? Icons.visibility_off : Icons.visibility,
            color: _isHidePassword ? Colors.grey : Colors.blue,
          ),
        ),
        isDense: true,
      ),
    );


        final gender= CustomDropdown(items: _genderTypes,hintText: "Select gender",count:1);
        final credit= CustomDropdown(items: _creditTypes,hintText: "Select credit type",count:2);
       

    final registerButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: isLoading ? CircularProgressIndicator() :RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () async {
         if (_formKeyRegister.currentState.validate()) {
           setState(() {
           isLoading = true;
          });

          var bytes = utf8.encode(_password.text); // data being hashed
          var digest = sha1.convert(bytes);
          String userEmail=_email.text;
          String pinNumber=randomPin();
          String resetKey=randomPin();

              final snapShot = await Firestore.instance.collection('student').document(_email.text).get();

                if (snapShot == null || !snapShot.exists) {

                   await db.collection('student').document(_email.text).setData({
                    'email': _email.text,
                    'firstName':_firstName.text,
                    'lastName':_lastName.text,
                    'gender':_genderSelected,
                    'password':digest.toString(),
                    'creditType':_creditSelected,
                    'wins':"0",
                    'pin':pinNumber,
                    'resetKey':resetKey,
                    'status':"not active"
                  });

                  sendPin(userEmail,pinNumber); 
                  activationSession(_email.text);
                  emptyFields();

                   setState(() {
                  isLoading = false;
                  }); 

                
                 Navigator.push(context, MaterialPageRoute(builder: (context) => Activation())); 

                  toast("Account created !!!");
                }
                 else{
                  setState(() {
                  isLoading = false;
                  }); 
                   toast("Account already exists");
                  }   
              }
               
               
              },
        padding: EdgeInsets.all(12),
        color: Colors.grey[800],
        child: Text('Register', style: TextStyle(color: Colors.white)),
        
      ),
    );


    
   
final mainForm= Form(
      key: _formKeyRegister,
       child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 30.0),
            email,
            SizedBox(height: 13.0),
            password,
            SizedBox(height: 13.0),
            firstName,
            SizedBox(height: 13.0),
            lastName,
            SizedBox(height: 13.0),
            gender,
            SizedBox(height: 13.0),
            credit,
            SizedBox(height: 24.0),
            registerButton,
          /*  SizedBox(height: 24.0),
            checkButton, */
           
          ],
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
             mainForm
          ],
        ),
      ),
      ]
     ),
    );
  }
}

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  String first;
  int count;
  final String hintText;
 
  CustomDropdown({Key key, @required this.items, @required this.hintText,@required this.count}) : super(key: key);
  @override
  _CustomDropdownState createState() => _CustomDropdownState();
  
}

class _CustomDropdownState extends State<CustomDropdown> {
  //String selectedItem;
  @override
  Widget build(BuildContext context) {
    //selectedItem = widget.items[0];
     return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.0),
            border: Border.all(color: Colors.grey)),
        child: new Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.grey[800],
          ),
          child: DropdownButton(
   
              items: 
              widget.items
                  .map((value) {
                    return DropdownMenuItem(
                        child: Text(value,
                            style: new TextStyle(color: Colors.white)),
                        value: value,
                      );})
                  .toList(),
              onChanged: ( value) {
                //once dropdown changes, update the state of currentValue
                setState(() {
                  widget.first = value;
                 
                  if (widget.count==1) {
                    _genderSelected=widget.first;
                  } 
                  if (widget.count==2) {
                    _creditSelected=widget.first;
                  } 

                });
              },
              hint: Text(widget.hintText,
                  style: TextStyle(
                    color: Colors.grey,
                  )),

              //this wont make dropdown expanded and fill the horizontal space
              isExpanded: false,
              //make default value of dropdown the first value of list
              value: widget.first,
            ),
        ),
        
     );
      
  }
      
}


Future navigateToActivation(context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => Activation()));

}

Future navigateToLogin(context) async {
   Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
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


void emptyFields()
{
   _firstName.text="";
   _lastName.text="";
   _email.text="";
   _password.text="";
}

String randomPin(){
  var rndnumber="";
  var rnd= new Random();
  for (var i = 0; i < 4; i++) {
  rndnumber = rndnumber + rnd.nextInt(9).toString();
  }
    return rndnumber;
}


Future activationSession(String email) async {

         final prefs = await SharedPreferences.getInstance();
        
          prefs.setString("activation_email",email);

      }


bool validEmail=false;
String validateEmail(String value) {

String members; 
int count=0;

    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
   
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty){
      return 'Please enter a valid email registered at NCU';
    } 
    else {
            db.collection('validEmails').snapshots().listen((data) async =>data.documents.forEach((doc) { 
              count++;
              if(count==1)
                {
                  members=doc.data['membersList'].toString().replaceAll(" ","");
                  if(!members.contains(value))
                    {
                      toast("Email not related to NCU CIS department");
                      _email.text=" ";
                      validEmail=false;
                    }  
                }
              }
            )
          );  
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
      return 'Please enter password';
    } else {
      if (!regex.hasMatch(value))
        return 'Enter valid password!\nmust contain at least 8 characters with:\nupper case(s),lower case(s) and digit(s)';
      else
        return null;
    }
  }



sendPin(String recipientEmail,String pin) async {
  String username = 'codefixapp@gmail.com';
  String password = 'codefix2019';

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, 'Gary Roberts(Founder of CodeFix)')
    ..recipients.add(recipientEmail)
    ..subject = 'Verify your CodeFix account. Thanks for joining us 😀'
    ..text = 'Activation pin for CodeFix:'
    ..html = "<h1>Acitivate now !!!</h1>\n<p>Activation pin for CodeFix: "+pin+"</p><br><br><p>Gary Roberts(Founder of CodeFix)</p>";

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
 
  var connection = PersistentConnection(smtpServer);

  //await connection.send(message);

  await connection.close();
  
}
