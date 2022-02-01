import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShowUpload extends StatefulWidget {

  //Getting the UserId
  String? userID;

  ShowUpload({Key? key,this.userID}) : super(key:key);
  @override
  _ShowUploadState createState() => _ShowUploadState();
}

class _ShowUploadState extends State<ShowUpload> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Show Images'),
        elevation: 0.0,

      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").doc(widget.userID).collection("images").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData){
            return (const Center(child: Text('No Image Uploaded'),));

          }
          else{
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context,int index){
                    String url = snapshot.data!.docs[index]['downloadURL'];
                    return Image.network(url,
                    height: 300,
                    fit: BoxFit.cover,);
              }),
            );
          }
        },
      ),
    );
  }
}
