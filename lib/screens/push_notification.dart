import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/model/pushnotification_model.dart';
import 'package:flutter_auth/notification_badge.dart';
import 'package:overlay_support/overlay_support.dart';
class PushNote extends StatefulWidget {
  @override
  _PushNoteState createState() => _PushNoteState();
}

class _PushNoteState extends State<PushNote> {
  //initialize some values

  late final FirebaseMessaging _messaging;
  late int _totalNotificationCounter;

  //Push Notification Model

  PushNotification? _notificationInfo;


  //Register Notification

  void registerNotification() async{
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    //three types of state in notification
    //not determinded(null) , grant(true) and decline(false)

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print("User Granted the permission");

      //Main Message
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        //Saving particular message to PshNotification Model when we created

        PushNotification notification = PushNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );

        setState(() {
          _totalNotificationCounter ++;
          _notificationInfo = notification;
        });

        if(notification != null){
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: 
              NotificationBadge(totalNotification: _totalNotificationCounter),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.cyan.shade700,
            duration: Duration(seconds: 2)
          );
        }
      });
    }
    else{
      print('Permission Declined By User');

    }
  }

  //check the initial message that we receive
  checkForInitialMessage() async{
    await Firebase.initializeApp();
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null){
      PushNotification notification = PushNotification(
        title: initialMessage.notification!.title,
        body: initialMessage.notification!.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );
      setState(() {
        _totalNotificationCounter ++;
        _notificationInfo = notification;
      });
    }
  }

  @override
  void initState() {
    //when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage messages) {

      PushNotification notification = PushNotification(
        title: messages.notification!.title,
        body: messages.notification!.body,
        dataTitle: messages.data['title'],
        dataBody: messages.data['body'],
      );
      setState(() {
        _totalNotificationCounter ++;
        _notificationInfo = notification;
      });
    });

    //normal Notification
    registerNotification();

    //When app is in terminated state
    checkForInitialMessage();

    // TODO: implement initState
    _totalNotificationCounter = 0;
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Push Notification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Flutter Push Notification',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),),

            SizedBox(height: 12,),

            //Showing a notification  badge which will
            //count the total notification that we recieve

            NotificationBadge(totalNotification: _totalNotificationCounter),
            SizedBox(height: 30,),

            //if notificationInfo is not null

            _notificationInfo != null ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('TITLE: ${_notificationInfo!.dataTitle ?? _notificationInfo!.title}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),),
                SizedBox(height: 9.0,),
                Text('BODY: ${_notificationInfo!.dataBody ?? _notificationInfo!.body}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),),

              ],
            )
                :Container()
          ],
        ),
      ),
    );
  }
}
