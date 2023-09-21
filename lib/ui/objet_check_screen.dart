
import 'package:bazaarhelper_final/state_holder_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tflite/tflite.dart';

import '../main.dart';

class ObjectCheck extends StatefulWidget {
  const ObjectCheck({Key? key}) : super(key: key);

  @override
  State<ObjectCheck> createState() => _ObjectCheckState();
}

class _ObjectCheckState extends State<ObjectCheck> {
  bool isWorking = false;
  String result = '';
  CameraController? cameraController;
  CameraImage? cameraImage;

  initCamera() {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController?.startImageStream((imageFromStream) => {
          if (!isWorking)
            {
              isWorking = true,
              cameraImage = imageFromStream,
              runModelOnStreamFrame(),
            }
        });
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
    cameraController?.dispose();
  }

  runModelOnStreamFrame() async {
    var recognitions = await Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true);

    bool showSnackbar = false;

    result = '';
    recognitions!.forEach((response) {
      String label = response['label'];
      double confidence = response['confidence'] as double;

      result += label + ' ' + confidence.toStringAsFixed(2) + '\n\n';


    });

    setState(() {
      result;
    });

    isWorking = false;

    if (showSnackbar) {
      Get.snackbar(
        'Detected',
        'Check this!',
        snackPosition: SnackPosition.TOP, // Adjust the position as needed
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green, // Customize the background color
        colorText: Colors.white, // Customize the text color
      );    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.find<MainBottomNavController>().backToHome();
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.green,
            leading: IconButton(
              onPressed: () {
                Get.find<MainBottomNavController>().backToHome();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            title: Text(
              "Food Scan",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/screenbackgroun.png'),
                    fit: BoxFit.fill)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Text("Check Your Food Quality!",style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500
                  ),)),
                  Center(child: Text("Click Video Icon to start scanning!!",style: TextStyle(
                    fontSize: 16
                  ),)),
                  Stack(
                    children: [
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 100),
                          height: 220,
                          width: 320,
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            initCamera();
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 65.0),
                            height: 275,
                            width: 360,
                            child: cameraImage == null
                                ? Container(
                              height: 500,
                              width: 360,
                              child: Icon(
                                Icons.photo_camera_front,
                                size: 60.0,
                                color: Colors.pink,
                              ),
                            )
                                : AspectRatio(
                              aspectRatio:
                              cameraController!.value.aspectRatio,
                              child: CameraPreview(cameraController!),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 55),
                      child: SingleChildScrollView(
                        child: Text(
                          result,
                          style: TextStyle(
                              backgroundColor: Colors.black,
                              fontSize: 25.0,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}






///////////--------------------
// import 'package:bazaarhelper_final/state_holder_controller.dart';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:tflite/tflite.dart';
//
// import '../main.dart';
//
// class ObjectCheck extends StatefulWidget {
//   const ObjectCheck({super.key});
//
//   @override
//   State<ObjectCheck> createState() => _ObjectCheckState();
// }
//
// class _ObjectCheckState extends State<ObjectCheck> {
//   bool isWorking = false;
//   String result = '';
//   CameraController? cameraController;
//   CameraImage? cameraImage;
//
//   initCamera() {
//     cameraController = CameraController(cameras![0], ResolutionPreset.medium);
//     cameraController!.initialize().then((value) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {
//         cameraController?.startImageStream((imageFromStream) =>
//         {
//           if (!isWorking) {
//             isWorking = true,
//             cameraImage = imageFromStream,
//             runModelOnStreamFrame()
//           }
//         });
//       });
//     });
//   }
//
//   loadModel() async {
//     await Tflite.loadModel(
//         model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     loadModel();
//   }
//
//   @override
//   void dispose() async {
//     super.dispose();
//     await Tflite.close();
//     cameraController?.dispose();
//   }
//
//   runModelOnStreamFrame() async {
//     var recognitions = await Tflite.runModelOnFrame(
//         bytesList: cameraImage!.planes.map((plane) {
//           return plane.bytes;
//         }).toList(),
//         imageHeight: cameraImage!.height,
//         imageWidth: cameraImage!.width,
//         imageMean: 127.5,
//         imageStd: 127.5,
//         rotation: 90,
//         numResults: 2,
//         threshold: 0.1,
//         asynch: true
//     );
//     result = '';
//     recognitions!.forEach((response) {
//       result += response['label'] + ' ' +
//           (response['confidence'] as double).toStringAsFixed(2) + '\n\n';
//     });
//     setState(() {
//       result;
//     });
//     isWorking = false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Get.find<MainBottomNavController>().backToHome();
//         return false;
//       },
//       child: SafeArea(
//           child: Scaffold(
//             appBar: AppBar(
//               elevation: 0,
//               backgroundColor: Colors.green,
//               leading: IconButton(
//                 onPressed: () {
//                   Get.find<MainBottomNavController>().backToHome();
//                 },
//                 icon: const Icon(
//                   Icons.arrow_back,
//                   color: Colors.white,
//                 ),
//               ),
//               title: Text(
//                 "Food Scan",
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//             body:Container(
//               decoration: BoxDecoration(
//                   image: DecorationImage(
//                       image: AssetImage('assets/images/screenbackgroun.png'),fit: BoxFit.fill
//                   )
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Stack(
//                       children: [
//                         Center(
//                           child: Container(
//                             margin: EdgeInsets.only(top: 100),
//                             height: 220,
//                             width: 320,
//                           ),
//                         ),
//                         Center(
//                             child: TextButton(
//                               onPressed: () {
//                                 initCamera();
//                               },
//                               child: Container(
//                                   margin: EdgeInsets.only(top: 65.0),
//                                   height: 275,
//                                   width: 360,
//                                   child: cameraImage == null
//                                       ? Container(
//                                     height: 500,
//                                     width: 360,
//                                     child: Icon(
//                                       Icons.photo_camera_front,
//                                       size: 60.0,
//                                       color: Colors.pink,
//                                     ),
//                                   )
//                                       : AspectRatio(
//                                     aspectRatio: cameraController!.value.aspectRatio,
//                                     child: CameraPreview(cameraController!),
//                                   )),
//                             ))
//                       ],
//                     ),
//                     Center(
//                       child: Container(
//                         margin: EdgeInsets.only(top: 55),
//                         child: SingleChildScrollView(
//                           child: Text(
//                             result,
//                             style: TextStyle(
//                                 backgroundColor: Colors.black,
//                                 fontSize: 25.0,
//                                 color: Colors.white
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           )),
//     );
//   }
// }
