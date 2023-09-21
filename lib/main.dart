import 'package:bazaarhelper_final/share_preferences_helper.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/bazaar_helper.dart';
List<CameraDescription>? cameras;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  cameras=await availableCameras();
  await SharedPreferences.getInstance(); // Initialize SharedPreferences
  await Firebase.initializeApp();
  runApp(BazaarHelper());
}
