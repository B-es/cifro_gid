import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
// ignore: library_prefixes
import 'dart:ui' as UI;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detector/app/app_resources.dart';
import 'package:object_detector/app/app_router.dart';
import 'package:object_detector/app/base/base_stateful.dart';
import 'package:object_detector/main.dart';
import 'package:object_detector/services/navigation_service.dart';
import 'package:object_detector/services/tensorflow_service.dart';
import 'package:object_detector/view_models/home_view_model.dart';
import 'package:object_detector/widgets/aperture/aperture_widget.dart';
import 'package:object_detector/widgets/confidence_widget.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class DetectorScreen extends StatefulWidget {
  const DetectorScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DetectorScreenState();
  }
}

class _DetectorScreenState extends BaseStateful<DetectorScreen, HomeViewModel>
    with WidgetsBindingObserver {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;

  late StreamController<Map> apertureController;

  late ScreenshotController screenshotController;

  @override
  bool get wantKeepAlive => true;

  @override
  void afterFirstBuild(BuildContext context) {
    super.afterFirstBuild(context);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void initState() {
    super.initState();
    loadModel(viewModel.state.type);
    initCamera();

    apertureController = StreamController<Map>.broadcast();
    screenshotController = ScreenshotController();
  }

  void initCamera() {
    _cameraController = CameraController(
        cameras[viewModel.state.cameraIndex], ResolutionPreset.high);
    _initializeControllerFuture = _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      //_cameraController.setFlashMode(FlashMode.off);

      /// TODO: Run Model
      setState(() {});
      _cameraController.startImageStream((image) async {
        if (!mounted) {
          return;
        }
        await viewModel.runModel(image);
      });
    });
  }

  void loadModel(ModelType type) async {
    await viewModel.loadModel(type);
  }

  Future<void> runModel(CameraImage image) async {
    if (mounted) {
      await viewModel.runModel(image);
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    viewModel.close();
    apertureController.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    /// TODO: Check Camera
    if (!_cameraController.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cameraController.stopImageStream();
    } else {
      initCamera();
    }
  }

  @override
  Widget buildPageWidget(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: false,
        appBar: buildAppBarWidget(context),
        body: buildBodyWidget(context),
        floatingActionButton: buildFloatingActionButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }

  Widget buildFloatingActionButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            onPressed: handleCaptureClick,
            tooltip: "Capture",
            backgroundColor: Colors.black,
            child: const Icon(
              Icons.cut_outlined,
              color: Colors.white,
            ),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: handleSwitchCameraClick,
            tooltip: "Switch Camera",
            backgroundColor: Colors.black,
            child: Icon(
              viewModel.state.isBackCamera()
                  ? Icons.camera_front
                  : Icons.camera_rear,
              color: Colors.white,
            ),
          ),
          FloatingActionButton(
            onPressed: () =>
                (Provider.of<NavigationService>(context, listen: false)
                    .pushNamedAndRemoveUntil(AppRoute.menuScreen)),
            backgroundColor: Colors.black,
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> handleSwitchCameraClick() async {
    apertureController.sink.add({});
    await viewModel.switchCamera();
    initCamera();
    return true;
  }

  handleSwitchSource(ModelType item) async {
    _cameraController.stopImageStream().then((value) {
      viewModel.updateTypeTfLite(item);
      Provider.of<NavigationService>(context, listen: false)
          .pushReplacementNamed(AppRoute.detectorScreen,
              args: {'isWithoutAnimation': true});
    });
  }

  Future<bool> handleCaptureClick() async {
    screenshotController.capture().then((value) async {
      if (value != null) {
        final cameraImage = await _cameraController.takePicture();
        await renderedAndSaveImage(value, cameraImage);
      }
    });
    return true;
  }

  Future<bool> renderedAndSaveImage(Uint8List draw, XFile camera) async {
    UI.Image cameraImage =
        await decodeImageFromList(await camera.readAsBytes());

    UI.Codec codec = await UI.instantiateImageCodec(draw);
    var detectionImage = (await codec.getNextFrame()).image;

    var cameraRatio = cameraImage.height / cameraImage.width;
    var previewRatio = detectionImage.height / detectionImage.width;

    double scaleWidth, scaleHeight;
    if (cameraRatio > previewRatio) {
      scaleWidth = cameraImage.width.toDouble();
      scaleHeight = cameraImage.width * previewRatio;
    } else {
      scaleWidth = cameraImage.height.toDouble() / previewRatio;
      scaleHeight = cameraImage.height.toDouble();
    }
    var difW = (scaleWidth - cameraImage.width) / 2;
    var difH = (scaleHeight - cameraImage.height) / 2;

    final recorder = UI.PictureRecorder();
    final canvas = Canvas(
        recorder,
        Rect.fromPoints(
            const Offset(0.0, 0.0),
            Offset(
                cameraImage.width.toDouble(), cameraImage.height.toDouble())));

    canvas.drawImage(cameraImage, Offset.zero, Paint());

    codec = await UI.instantiateImageCodec(draw,
        targetWidth: scaleWidth.toInt(), targetHeight: scaleHeight.toInt());
    detectionImage = (await codec.getNextFrame()).image;

    canvas.drawImage(detectionImage, Offset(difW.abs(), difH.abs()), Paint());

    canvas.save();
    canvas.restore();

    final picture = recorder.endRecording();

    var img = await picture.toImage(scaleWidth.toInt(), scaleHeight.toInt());

    final pngBytes = await img.toByteData(format: UI.ImageByteFormat.png);

    final result2 = await ImageGallerySaver.saveImage(
        Uint8List.view(pngBytes!.buffer),
        quality: 100,
        name: 'realtime_object_detection_${DateTime.now()}');
    print(result2);
    return true;
  }

  @override
  AppBar buildAppBarWidget(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      centerTitle: true,
      actions: [
        PopupMenuButton<ModelType>(
            onSelected: (item) => handleSwitchSource(item),
            itemBuilder: (context) => [
                  PopupMenuItem(
                      enabled: !viewModel.state.isYolo(),
                      value: ModelType.YOLO,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.api,
                              color: !viewModel.state.isYolo()
                                  ? AppColors.black
                                  : AppColors.grey),
                          Text(' YOLO',
                              style: AppTextStyles.regularTextStyle(
                                  color: !viewModel.state.isYolo()
                                      ? AppColors.black
                                      : AppColors.grey)),
                        ],
                      )),
                  PopupMenuItem(
                      enabled: !viewModel.state.isSSDMobileNet(),
                      value: ModelType.SSDMobileNet,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.api,
                              color: !viewModel.state.isSSDMobileNet()
                                  ? AppColors.black
                                  : AppColors.grey),
                          Text(' SSD MobileNet',
                              style: AppTextStyles.regularTextStyle(
                                  color: !viewModel.state.isSSDMobileNet()
                                      ? AppColors.black
                                      : AppColors.grey)),
                        ],
                      )),
                  PopupMenuItem(
                      enabled: !viewModel.state.isMobileNet(),
                      value: ModelType.MobileNet,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.api,
                              color: !viewModel.state.isMobileNet()
                                  ? AppColors.black
                                  : AppColors.grey),
                          Text(' MobileNet',
                              style: AppTextStyles.regularTextStyle(
                                  color: !viewModel.state.isMobileNet()
                                      ? AppColors.black
                                      : AppColors.grey)),
                        ],
                      )),
                  PopupMenuItem(
                      enabled: !viewModel.state.isPoseNet(),
                      value: ModelType.PoseNet,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.api,
                              color: !viewModel.state.isPoseNet()
                                  ? AppColors.black
                                  : AppColors.grey),
                          Text(' PoseNet',
                              style: AppTextStyles.regularTextStyle(
                                  color: !viewModel.state.isPoseNet()
                                      ? AppColors.black
                                      : AppColors.grey)),
                        ],
                      )),
                ]),
      ],
      title: const Text(
        AppStrings.title,
        style: TextStyle(fontFamily: 'Caveat', fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget buildBodyWidget(BuildContext context) {
    double heightAppBar = AppBar().preferredSize.height;

    bool isInitialized = _cameraController.value.isInitialized;

    final Size screen = MediaQuery.of(context).size;
    final double screenHeight = max(screen.height, screen.width);
    final double screenWidth = min(screen.height, screen.width);

    final Size previewSize = isInitialized
        ? _cameraController.value.previewSize!
        : const Size(100, 100);
    final double previewHeight = max(previewSize.height, previewSize.width);
    final double previewWidth = min(previewSize.height, previewSize.width);

    final double screenRatio = screenHeight / screenWidth;
    final double previewRatio = previewHeight / previewWidth;
    final maxHeight =
        screenRatio > previewRatio ? screenHeight : screenWidth * previewRatio;
    final maxWidth =
        screenRatio > previewRatio ? screenHeight / previewRatio : screenWidth;

    return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        color: Colors.grey.shade900,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Screenshot(
                  controller: screenshotController,
                  child: Stack(
                    children: <Widget>[
                      OverflowBox(
                        maxHeight: maxHeight,
                        maxWidth: maxWidth,
                        child: FutureBuilder<void>(
                            future: _initializeControllerFuture,
                            builder: (_, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return CameraPreview(_cameraController);
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator(
                                        color: AppColors.blue));
                              }
                            }),
                      ),
                      Consumer<HomeViewModel>(builder: (_, homeViewModel, __) {
                        return ConfidenceWidget(
                          heightAppBar: heightAppBar,
                          entities: homeViewModel.state.recognitions,
                          previewHeight: max(homeViewModel.state.heightImage,
                              homeViewModel.state.widthImage),
                          previewWidth: min(homeViewModel.state.heightImage,
                              homeViewModel.state.widthImage),
                          screenWidth: MediaQuery.of(context).size.width,
                          screenHeight: MediaQuery.of(context).size.height,
                          type: homeViewModel.state.type,
                        );
                      }),
                      OverflowBox(
                        maxHeight: maxHeight,
                        maxWidth: maxWidth,
                        child: ApertureWidget(
                          apertureController: apertureController,
                        ),
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.red, width: 2)
                      //   ),
                      // )
                    ],
                  ))),
        ));
  }
}
