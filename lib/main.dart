import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:ntmobile_notification/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<String> multiImei = await ImeiPlugin.getImeiMulti(
      shouldShowRequestPermissionRationale:
          false); //for double-triple SIM phones

  multiImei.forEach((element) => print(element));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}
