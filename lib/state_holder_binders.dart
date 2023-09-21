

import 'package:get/get.dart';

import 'state_holder_controller.dart';

class StateHolderBinders extends Bindings{
  @override
  void dependencies(){
    Get.put(MainBottomNavController());
  }
}