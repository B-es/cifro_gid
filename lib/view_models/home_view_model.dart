import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detector/app/base/base_view_model.dart';
import '/models/recognition.dart';
import 'package:object_detector/services/tensorflow_service.dart';
import 'package:object_detector/view_states/home_view_state.dart';

class HomeViewModel extends BaseViewModel<HomeViewState> {
  bool _isLoadModel = false;
  bool _isDetecting = false;

  late TensorFlowService _tensorFlowService;

  HomeViewModel(BuildContext context, this._tensorFlowService)
      : super(context, HomeViewState(_tensorFlowService.type));

  Future switchCamera() async {
    state.cameraIndex = state.cameraIndex == 0 ? 1 : 0;
    notifyListeners();
  }

  Future<void> loadModel(ModelType type) async {
    state.type = type;
    //if (type != this._tensorFlowService.type) {
    await _tensorFlowService.loadModel(type);
    //}
    _isLoadModel = true;
  }

  Future<void> runModel(CameraImage cameraImage) async {
    if (_isLoadModel && mounted) {
      if (!_isDetecting && mounted) {
        _isDetecting = true;
        int startTime = DateTime.now().millisecondsSinceEpoch;
        var recognitions =
            await _tensorFlowService.runModelOnFrame(cameraImage);
        int endTime = DateTime.now().millisecondsSinceEpoch;
        print('Time detection: ${endTime - startTime}');
        if (recognitions != null && mounted) {
          state.recognitions = List<Recognition>.from(
              recognitions.map((model) => Recognition.fromJson(model)));
          state.widthImage = cameraImage.width;
          state.heightImage = cameraImage.height;
          notifyListeners();
        }
        _isDetecting = false;
      }
    } else {
      print(
          'Please run `loadModel(type)` before running `runModel(cameraImage)`');
    }
  }

  Future<void> close() async {
    await _tensorFlowService.close();
  }

  void updateTypeTfLite(ModelType item) {
    _tensorFlowService.type = item;
  }
}
