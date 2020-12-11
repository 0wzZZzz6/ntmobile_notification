import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sms_maintained/sms.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _title = '';
  String _destinationNumber = '';
  String _body = '';
  bool status = false;
  bool isTokenRegistered = false;
  String myToken;
  GlobalKey scaffoldKey = GlobalKey();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  SmsSender sender = SmsSender();

  _register() {
    _firebaseMessaging.getToken().then((token) async {
      print(token);
      print('register token');
      setState(() {
        myToken = token;
      });

      try {
        String url =
            'http://www.devversions.com/ntmobile-api/store/notification/token';
        var body = {'token': token};
        var response = await http.post(url, body: body);

        if (response.statusCode == 200) {
          setState(() {
            isTokenRegistered = true;
          });
        } else {
          print('error....');
        }
      } on Exception catch (_) {
        print('never reached');
      }

      // Future.delayed(Duration(seconds: 3), () {
      //   setState(() {
      //     isTokenRegistered = true;
      //   });
      // });
    });
  }

  @override
  void initState() {
    super.initState();
    _register();
    getMessage();
  }

  Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      print("onBackground: $data");
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      print("onBackground: $notification");
    }

    sendMessage(message);

    print('hey im in background');

    // Or do other work.
  }

  void getMessage() {
    _firebaseMessaging.configure(
      onBackgroundMessage: myBackgroundHandler,
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        sendMessage(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        sendMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        sendMessage(message);
      },
    );
  }

  void sendMessage(Map<String, dynamic> notificationData) {
    String destinationNumber = notificationData["data"]["destinationNumber"];
    String textBody = notificationData["data"]["body"];

    SmsMessage message = SmsMessage(destinationNumber, textBody);

    setState(() {
      _title = notificationData["data"]["title"];
      _destinationNumber = notificationData["data"]["destinationNumber"];
      _body = notificationData["data"]["body"];
      status = false;
    });

    message.onStateChanged.listen((state) {
      if (state == SmsMessageState.Sent) {
        print("SMS is sent!");
        setState(() => status = true);
      } else if (state == SmsMessageState.Delivered) {
        print("SMS is delivered!");
        setState(() => status = true);
      }
    });

    sender.sendSms(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: isTokenRegistered ? _mainBody() : _registeringToken(),
    );
  }

  Widget _registeringToken() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text('registering token'),
        ],
      ),
    );
  }

  Widget _mainBody() {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Title: $_title",
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),
            Text(
              "destinationNumber: $_destinationNumber",
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),
            Text(
              "Body: $_body",
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),
            Text(
              "Token registered?: $isTokenRegistered",
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),
            Text(
              "Sent? : $status",
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(new ClipboardData(text: myToken));

                Get.snackbar("test", "token copied to clipboard");
              },
              child: Text(
                "token: $myToken",
                style: TextStyle(
                  fontSize: 18,
                  height: 2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            OutlineButton(
              child: Text("Copy token"),
              onPressed: () {
                Clipboard.setData(new ClipboardData(text: myToken));

                Get.snackbar("test", "token copied to clipboard");
              },
            ),
          ]),
    );
  }
}

Future<dynamic> myBackgroundHandler(Map<String, dynamic> message) {
  return _HomeState().myBackgroundMessageHandler(message);
}
