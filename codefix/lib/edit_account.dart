import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codefix/login_page.dart';
import 'package:codefix/change_password.dart';

class Edit extends StatefulWidget {
 
  @override
  _Edit createState() => new _Edit();
   static String tag = 'edit_account';
}

final db = Firestore.instance;
final _formKeyEdit = GlobalKey<FormState>();

var _genderSelected="Select gender"; 
var _creditSelected="Select credit type";
TextEditingController _firstName = TextEditingController();
TextEditingController _lastName = TextEditingController();
bool isLoading = false;

class _Edit extends State<Edit> {
    final List<String> _genderTypes = ["Male","Female"]; //The list of values on the dropdown
    final List<String> _creditTypes = ["Digicel","Flow"];

  @override
  void initState() {
    super.initState();
     Future.delayed(Duration.zero, () async {
    await getSession(context);
    });
    
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    

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

    

    final gender= CustomDropdown(items: _genderTypes,hintText: _genderSelected,count:1);
    final credit= CustomDropdown(items: _creditTypes,hintText: _creditSelected,count:2);
       

    final editButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
     child: isLoading ? CircularProgressIndicator() :RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () async {
            if (_formKeyEdit.currentState.validate()) {
                  setState(() {
              isLoading = true;
              });
          try{
              final snapShot = await Firestore.instance.collection('student').document(email).get();

                if (snapShot.exists) {

                  await db.collection('student').document(email).updateData({'firstName': _firstName.text,'lastName':_lastName.text,'gender':_genderSelected,'creditType':_creditSelected});
                   sessionUpdate(_firstName.text,_lastName.text,_genderSelected,_creditSelected);
                  
                 setState(() {
                      isLoading = false;
                      });

                  toast("Account Updated !!!");      
                }
                else{ 
                     setState(() {
                      isLoading = false;
                      });
                  toast("Account does not exist");
                }
          }
          catch(e)
          {
               setState(() {
              isLoading = false;
              });
            toast("Something went wront.Try again");
          }
            }   
         },
        padding: EdgeInsets.all(12),
        color: Colors.grey[800],
        child: Text('Update', style: TextStyle(color: Colors.white)),
        
      ),
    );


final changePassword=Container(
        child:FloatingActionButton.extended(
              backgroundColor: Colors.white,
              elevation: 2.0,
              icon: Icon(Icons.lock),
              label: Text("Change Password"),
              onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePassword()));}
        ));
   
final mainForm= Form(
      key: _formKeyEdit,
       child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          children: <Widget>[
            firstName,
            SizedBox(height: 11.0),
            lastName,
            SizedBox(height: 11.0),
            gender,
            SizedBox(height: 11.0),
            credit,
            SizedBox(height: 22.0),
            editButton,
             
          ],
        ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      
          appBar: new AppBar(
             backgroundColor: Colors.black,
             automaticallyImplyLeading: true,
        title: Text('Update Account'),
        leading: IconButton(icon:Icon(Icons.arrow_back),
          onPressed:() => Navigator.popAndPushNamed(context,'/homepage'),
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
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          children: <Widget>[
            changePassword,
             SizedBox(height: 90.0),
             mainForm
             
          ],
        ),
      ),
      ]
     ),
    );
  }

  String email;

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
              _firstName.text=prefs.getString("firstName");
              _lastName.text=prefs.getString("lastName");
              _genderSelected=prefs.getString("gender");
              _creditSelected=prefs.getString("creditType");
           });
    
        }
        
      }


   Future sessionUpdate(String firstName,String lastName,String gender,String creditType) async {
         final prefs = await SharedPreferences.getInstance();
        
          prefs.setString("firstName",firstName);
          prefs.setString("lastName",lastName);
          prefs.setString("gender",gender);
          prefs.setString("creditType",creditType);

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
            
              //map each value from the lIst to our dropdownMenuItem widget
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
                //once dropdown changes, update the state of out currentValue
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
                    color: Colors.white,
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




