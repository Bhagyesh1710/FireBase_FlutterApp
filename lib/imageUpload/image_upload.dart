import 'dart:io';

import 'package:flutter/material.dart';

// image picker for picking the image
// firbase storage for uploading image
// and cloud firestore for saving the image url for upload image to our application

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ImageUpload extends StatefulWidget {

  //we need the user id to create a image folder for a particular user
  String? userId;

  ImageUpload({Key? key,this.userId}) : super(key:key);

  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {

  // some initialization code

  File? _image;
  final imagePicker = ImagePicker();
  String? downloadURL;

  //image picker
  Future imagePickerMethod() async{
    //Picking the file
    final pick = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if(pick !=null){
        _image = File(pick.path);
      }
      else{
        //Showing SnackBar
        showSnackBar('No File Selected', Duration(microseconds: 400));
      }
    });
  }


  //Uploading the image,then getting the download url and then
  //adding that download url to our cloudfirestore

  Future uploadImage() async{

    final postID = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseFirestore firebaseFirestore =FirebaseFirestore.instance;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${widget.userId}/images")
        .child("post_$postID");


    await ref.putFile(_image!);
    downloadURL = await ref.getDownloadURL();
    //print(downloadURL);

    //Uploading to CloudFireStore

    await firebaseFirestore.collection("users")
        .doc(widget.userId)
        .collection("images")
        .add({'downloadURL': downloadURL})
        .whenComplete(() =>showSnackBar(
            "Image Uploaded Successfully:",
            Duration(seconds: 2)),);
  }

//SnackBar For Showing Errors

  showSnackBar(String snackText,Duration d){
    final snackBar = SnackBar(content: Text(snackText),duration: d,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload'),
        elevation: 0.0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),

          //For Rounded Rectangular Clip

          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              height: 550,
              width: double.infinity,
              child: Column(
                children: [
                  Text('Upload Image'),
                  SizedBox(
                    height: 10,
                  ),

                  Expanded(
                      flex:4,
                      child: Container(
                        width: 350.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.red)
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: _image == null
                                  ? const Center(child: Text('No Image Selected'),)
                                      :Image.file(_image!),
                              ),
                              ElevatedButton(onPressed: (){
                                imagePickerMethod();
                              }, child: Text('Select Image'),),
                              ElevatedButton(onPressed: (){

                                //Upload only when the image has some values
                                if(_image != null) {
                                  uploadImage();
                                }else{
                                  showSnackBar("Select Image First", Duration(milliseconds: 400));
                                }

                              }, child: Text('Upload Image'),),
                            ],
                          ),
                        ),

                  ),),

                ],
              ),
            ),
          ),

        ),
      ),
    );
  }
}
