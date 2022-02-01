import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/imageUpload/image_upload.dart';
import 'package:flutter_auth/imageUpload/show_images.dart';
import 'package:flutter_auth/model/user_model.dart';
import 'package:flutter_auth/screens/login_screen.dart';
import 'package:flutter_auth/screens/push_notification.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
    .collection("users")
    .doc(user!.uid)
    .get()
    .then((value){
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 150,
              child: Image.asset('asset/solulab.jpg',fit: BoxFit.contain,),
              ),
              Text('Welcome Back',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Text('Name: ${loggedInUser.firstName} ${loggedInUser.secondName}',style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,

              ),),
              SizedBox(height: 10,),
              Text('Email Id: ${loggedInUser.email}',style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,

              ),),
              SizedBox(height: 10,),
              Text('User Id: ${loggedInUser.uid}',style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,

              ),),

              SizedBox(height: 15,),

              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageUpload(userId: this.loggedInUser.uid,),),);
              }, child: Text('Upload Images')
              ),

              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ShowUpload(userID: this.loggedInUser.uid,),),);
              }, child: Text('Show Images')),

              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>PushNote(),),);
              }, child: Text('Push Notification')),

            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async{
    await _auth.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen(),),);
  }
  _appBar(){
    //getting the size of AppBar
    //we will get the height

    final appBarHeight = AppBar().preferredSize.height;
    return PreferredSize(
        child: AppBar(title: Text('Profile'),
        actions: [
          IconButton(onPressed: (){
            logout(context);
          }, icon: Icon(Icons.logout),),
        ],
        ),
        preferredSize: Size.fromHeight(appBarHeight),
    );
  }
}
