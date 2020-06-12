import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:deivao_drawer/deivao_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:codefix/prize.dart';
import 'package:codefix/help.dart';
import 'package:codefix/login_page.dart';
import 'package:codefix/edit_account.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codefix/challenge.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => new _HomePage();
  static String tag = 'home-page';
}

var scaffold;

String _active;

class _HomePage extends State<HomePage> with SingleTickerProviderStateMixin {


final drawerController = DeivaoDrawerController(); 

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
    await getSession(context);
    });
    _tabController = new TabController(
      length: 3,
      vsync: this,
      initialIndex: 0,
    )..addListener(() {
        setState(() {
          if(_tabController.index==1)
          {
            //_onButtonPressed(context,2);
          }
          
          });
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final db = Firestore.instance;
    Size size = MediaQuery.of(context).size;

     scaffold = new Scaffold(
      
          appBar: new AppBar(
            title: const Text('CodeFix'),
         
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: drawerController.toggle,
          ),
          
            bottom: new TabBar(controller: _tabController,isScrollable: true, tabs: [
              new Tab(text: '    Challenges     ', icon: new Icon(Icons.assignment)),
              new Tab(text: '       Ranking       ', icon: new Icon(Icons.star)),
              new Tab(text: '    Notices  ', icon: new Icon(Icons.notification_important)),
            ]),
          ),
          body: new TabBarView(controller: _tabController,
            
            children: [
              
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
            child: StreamBuilder<QuerySnapshot>(
                stream: db.collection('challenge').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                    children: snapshot.data.documents.map((doc) {    
                    return Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new ListTile(
                        leading: Icon(Icons.blur_on, size: 35, color: Colors.white),
                        title: Text(doc.data['name'],style: TextStyle(fontSize: 18)),
                        subtitle: Text(doc.data['type']),
                        trailing: new IconButton(
                        icon: new Icon(Icons.arrow_right),
                        highlightColor: Colors.pink,
                        iconSize:38.0,
                        color: Colors.white,
                        onPressed: ()async{
                          
                           int counter=0;
                           String challenge=doc.data['id'];
                           bool notFound=true;
               
                           db.collection('submission').snapshots().listen((data) =>data.documents.forEach((doc) async {
                             counter++;
                               if(doc.data['id']==challenge && doc.data['email']==email && counter==data.documents.length)
                                {
                                  notFound=false;
                                  _challengeAccess(context,"Sorry "+firstName,"You do not have access to this challenge anymore. A submission was already found for you.");
                                } 
                                else if(counter==data.documents.length && notFound){
                                    navigateToChallenge(context,challenge);
                                }
                            
                            } 
                            )
                          );  

                         
                          
                        },
                      ),

                    ),
                      
                    ],
                  ),
                );

                    }).toList(),
                
                   );} else {
                      return Container();
                }
                  })),
                ]
             ),
                
           


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
          child: StreamBuilder<QuerySnapshot>(
              stream: db.collection('student').orderBy('wins', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                   return Column(
                   children: snapshot.data.documents.map((doc) {    
                   return Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                     new ListTile(
                      leading: Icon(Icons.face, size: 30, color: Colors.white),
                      title: Text(doc.data['firstName']+" "+doc.data['lastName'],style: TextStyle(fontSize: 18)),
                      subtitle: Text("wins:"+doc.data['wins'].toString()),
                      trailing: new IconButton(
                      icon: new Icon(Icons.info),
                      highlightColor: Colors.pink,
                      iconSize:30.0,
                      color: Colors.white,
                      onPressed: (){_onButtonPressed(context,doc.data['firstName'],"Name: "+doc.data['firstName']+doc.data['lastName']+"\n\n"+"Email: "+doc.data['email']+"\n\n"+"Gender: "+doc.data['gender']+"\n\n""Points: "+doc.data['wins']);},
                     ),

                  ),
                    
                  ],
                ),
              );

                    }).toList(),
                
                   );} else {
                      return Container();
                }
                  })),
                ]
             ),

               


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
          child: StreamBuilder<QuerySnapshot>(
              stream: db.collection('notices').orderBy('noticeId', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                   return Column(
                   children: snapshot.data.documents.map((doc) {    
                   return Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                     new ListTile(
                      leading: Icon(Icons.message, size: 30, color: Colors.white),
                      title: Text(doc.data['subject'],style: TextStyle(fontSize: 18)),
                      subtitle: Text("date:"+doc.data['date'].toString()),
                      trailing: new IconButton(
                      icon: new Icon(Icons.arrow_right),
                      highlightColor: Colors.pink,
                      iconSize:30.0,
                      color: Colors.white,
                      onPressed: (){_noticePressed(context,doc.data['subject'],doc.data['info']+"\n\n"+"date: "+doc.data['date']);},
                     ),

                  ),
                    
                  ],
                ),
              );

                    }).toList(),
                
                   );} else {
                      return Container();
                }
                  })),
                ]
             )
               

            ],
          ),
          
       /*    floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              backgroundColor: Colors.white,
              elevation: 2.0,
              icon: Icon(Icons.monetization_on),
              label: Text("Prize"),
              onPressed: () {},
            )
            
          : FloatingActionButton.extended(
             backgroundColor: Colors.white,
             elevation: 2.0,
               icon: Icon(Icons.equalizer),
              label: Text("Stats"),
              onPressed: () {},
            ) */
            
            );
           
           
     
  var drawerNav=new DeivaoDrawer(
      controller: drawerController,
      child:scaffold,
      drawer: _buildDrawer(context),
      
    );         
             


    return WillPopScope(
      onWillPop: () async {
    MoveToBackground.moveTaskToBack();
         return false;
      },
    child:Scaffold(
      backgroundColor: Colors.white,
      body: drawerNav,
      ));     
    
  }

  ListView _buildDrawer(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(0),
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 50, bottom: 20),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
               CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 60.0,
                child: Image.asset('assets/images/profile_image.png'),
              ),
              SizedBox(height: 15),
              Text(
                firstName+" "+lastName,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
               child:Text(
                email,
                style: TextStyle(color: Colors.white),
              ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
               child:Text(
                "Gender:"+gender+"   Points:"+wins,
                style: TextStyle(color: Colors.white),
              ),
              ),
            ],
          ),
        ),
        ListTile(leading: Icon(Icons.account_box), title: Text("Edit Account"),onTap: () {navigateToEdit(context);}),
        ListTile(leading: Icon(Icons.monetization_on), title: Text("Prizes"),onTap: () {navigateToPrizes(context);}),
        ListTile(leading: Icon(Icons.help), title: Text("Help"),onTap: () {navigateToHelp(context);}),
        ListTile(leading: Icon(Icons.lock), title: Text("Log out"),onTap: () {navigateToLogout(context);}),
       //ListTile(title: Text("(c)Roberts' Technologies 2019")),
       
      ],
    );
  }

String email="user@gmail.com",firstName="John",lastName="Doe",gender="male",creditType="Digicel",wins="0";

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
}


List<Widget> list = <Widget>[


  new ListTile(
    title: new Text('Gary Roberts',
        style: new TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0)),
    subtitle: new Text('10 wins'),
    leading: new Icon(
      Icons.blur_on,
      color: Colors.deepPurple,
    ),
  ), 
 

];

void _onButtonPressed(BuildContext context,String userName,String info) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(userName),
          content: new Text(info),
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


void _noticePressed(BuildContext context,String subject,String info) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(subject),
          content: new Text(info),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
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


void _challengeAccess(BuildContext context,String header,String message) {

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




Future navigateToPrizes(context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => Prize()));
}

Future navigateToHelp(context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => Help()));
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

Future navigateToLogout(context) async {

    final prefs = await SharedPreferences.getInstance();
        
     prefs.setString("email",null);
     prefs.setString("firstName",null);
     prefs.setString("lastName",null);
     prefs.setString("gender",null);
     prefs.setString("creditType",null);
     prefs.setString("wins",null);

  Navigator.push(context, MaterialPageRoute(builder: (context) =>LoginPage()));
}

Future navigateToEdit(context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) =>Edit()));
}

Future navigateToChallenge(context,String id) async {
   final prefs = await SharedPreferences.getInstance();
   prefs.setString("challengeId",id);
   Navigator.push(context, MaterialPageRoute(builder: (context) =>Challenge()));
}


void main() {
   runApp(new HomePage());
 
}