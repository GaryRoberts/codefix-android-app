import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:codefix/login_page.dart';
import 'package:codefix/champion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';


class Challenge extends StatefulWidget {
  @override
  _Challenge createState() => new _Challenge();
  static String tag = 'challenge';
}

final db = Firestore.instance;
String challengeId;
String snippetWrong;
String snippetType;
String snippetCorrect;
String challengeName;
String winnableStatus;
String heading="";
var _snippetController;



class _Challenge extends State<Challenge>
    with SingleTickerProviderStateMixin {
  SharedPreferences sharedPreferences;


 @override
  void initState() {
    super.initState();
     Future.delayed(Duration.zero, () async {
       await getSession(context);
    });
    getChallenge(context);
 
   
  }


  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    var other = 2;
    return Scaffold(
         resizeToAvoidBottomInset:false,
          appBar: new AppBar(
             automaticallyImplyLeading: true,
        title: Text('Challenge'),
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

            Container(
               
                child: Column(
                  children: <Widget>[
          
                    Text(
                     heading,
                      style: TextStyle(fontSize: 17.0,color: Colors.white),
                      textAlign: TextAlign.center,
                     ),

                     Text(
                     "Fix the issues in the snippet below then submit\n",
                      style: TextStyle(fontSize: 17.0,color: Colors.white),
                      textAlign: TextAlign.center,
                     ),
            
                     TextField(
                        autofocus:true,
                        controller: _snippetController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 17,
                      ),

                  Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () {
                       
                      submitCode(_snippetController.text,email,creditType);  
                    },
                    padding: EdgeInsets.all(12),
                    color: Colors.green,
                    child: Text('Submit Code', style: TextStyle(color: Colors.white)),
                    
                  ),
                ),


                  ],
                ),
   
                ),
                ]
             ), 

          );

  } 

  String email,firstName,lastName,gender,creditType,wins;

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
            firstName=prefs.getString("firstName");
            lastName=prefs.getString("lastName");
            gender=prefs.getString("gender");
            creditType=prefs.getString("creditType");
            wins=prefs.getString("wins");
           });
    
        }
        
      }
  


Future submitCode(String code,String email,String creditType)async
{
    bool error=false;
    int totalWins;
    int count=0;

 db.collection('submission').snapshots().listen((data) =>data.documents.forEach((doc)async{
     if(doc.data['id']==challengeId && doc.data['email']==email)
        {
           setState(() {
            error=true;
          });

           Navigator.of(context).pop();
        }
    
    } 
    )
  );  


 if(!error)
  {
  
   if(_snippetController.text.replaceAll(" ","").replaceAll("\n","").toString()==snippetCorrect.replaceAll(" ",""))
    {
       
         if(winnableStatus=="true")
         {
             String digits;
             String creditId;

             db.collection('credit').snapshots().listen((data) async =>data.documents.forEach((doc) { 
                if(doc.data['cardStatus']=="available" && doc.data['cardType']==creditType)
                {
                    count++;
                    if(count==1)
                    {
                      digits=doc.data['cardDigits'];
                      creditId=doc.data['creditId'];
                    }
                  }
                }
                )
              ); 

             
            
           await db.collection('challenge').document(challengeId).updateData({'winnableStatus':"false"});
           await db.collection('credit').document(creditId).updateData({'cardStatus':"unavailable"});

            totalWins=int.parse(wins)+5;
           await db.collection('student').document(email).updateData({'wins':totalWins.toString()});

           await db.collection('prizesDeployed').document(email+"(chall"+challengeId+")").setData({
                  'email': email,
                  'creditType':creditType,
                  'cardDigits':digits,
                  'value':"100"
              }); 
              
          // _winnerMessage(context,"Congrats !!!"+email,"You are the mega winner for this challenge. You got 5 points and a 100 dollars credit.");
         
           db.collection('submission').document(email+"(sub"+challengeId+")").setData({
                  'email': email,
                  'id':challengeId,
                  'snippetReceived':_snippetController.text
              }); 

             setState(() {
                  error=false;
                });
               
            Navigator.push(context, MaterialPageRoute(builder: (context) => Congrats())); 

               
         }
         else{
            totalWins=int.parse(wins)+3;
           await db.collection('student').document(email).updateData({'wins':totalWins.toString()});
           _winnerMessage(context,"Congrats !!!"+firstName,"You are not the mega winner who got the credit. But you got 3 points. Next time work faster. Keep it up !!");
         }
        
           
    }
    else{
      toast("Mission failed.You left some issue(s) !!!.\n Thanks for trying");
       await db.collection('submission').document(email+"(sub"+challengeId+")").setData({
                  'email': email,
                  'id':challengeId,
                  'snippetReceived':_snippetController.text
              });
          Navigator.of(context).pop();
        
      }    
    }
    
  }

}



void main() {
   runApp(new Challenge());
 
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


void _winnerMessage(BuildContext context,String header,String message) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(header),
          content: new Text(message),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
}




Future getChallenge(BuildContext context) async {

  try{



      final prefs = await SharedPreferences.getInstance();
       challengeId=prefs.getString("challengeId");

        db.collection('challenge').snapshots().listen((data) =>data.documents.forEach((doc) {
  
        if(doc.data['id']==challengeId)
        {
          if(doc.data['status']=="active")
          {
            String code=doc.data['snippetWrong'];
            snippetWrong=code.replaceAll("---","\n");
             _snippetController = new TextEditingController(text:snippetWrong);
            snippetCorrect=doc.data['snippetCorrect'];
            snippetType=doc.data['type'];
            challengeName=doc.data['name'];
            winnableStatus=doc.data['winnableStatus'];
            heading="\n"+challengeName+"       "+"Type: "+snippetType+"\n";
           
          }
          else{
            toast("This challenge has ended");
            Navigator.of(context).pop();
          }
          
        }

    } 
    )
  );
}
  catch(e)
  {
     toast("Something went wrong.Try again");
  }
}
