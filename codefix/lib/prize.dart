import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codefix/login_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Prize extends StatefulWidget {
  @override
  _Prize createState() => _Prize();
  static String tag = 'prize';
}



class _Prize extends State<Prize>
    with SingleTickerProviderStateMixin {
  
 @override
  void initState() {
    super.initState();

      Future.delayed(Duration.zero, () async {
    await getSession(context);
    });

  }

  @override
  Widget build(BuildContext context) {
     final db = Firestore.instance;
    Size size = MediaQuery.of(context).size;

      return Scaffold(
          appBar: new AppBar(
          automaticallyImplyLeading: true,
        title: Text('Prizes'),
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
          child: StreamBuilder<QuerySnapshot>(
              stream: db.collection('prizesDeployed').where('email',isEqualTo: email).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                   return Column(
                   children: snapshot.data.documents.map((doc) {    
                   return Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                     new ListTile(
                      leading: Icon(Icons.credit_card, size: 35, color: Colors.white),
                      title: Text(doc.data['value'],style: TextStyle(fontSize: 18,color: Colors.green)),
                      subtitle: Text(doc.data['creditType']),
                      trailing: new IconButton(
                      icon: new Icon(Icons.add_call),
                      highlightColor: Colors.pink,
                      iconSize:30.0,
                      color: Colors.white,
                       onPressed: () => launch("tel:" + Uri.encodeComponent(doc.data['cardDigits'].toString())),
                     ),

                  ),
                    
                  ],
                ),
              );

                    }).toList(),
                
                   );
                   
                   } 
                   else
                    {
                      return Container();
                    }
                    
                  })),
                ]
             ), 

          );

  }

String email="";
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
           });
    
        }
        
      }
}


void main() {
   runApp(new Prize());
 
}