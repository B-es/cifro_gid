import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:object_detector/app/app_router.dart';
import 'package:object_detector/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter/services.dart';

class AugmentedRealityScreen extends StatefulWidget {
  const AugmentedRealityScreen({super.key});

  @override
  State<AugmentedRealityScreen> createState() => _AugmentedRealityScreenState();
}

class _AugmentedRealityScreenState extends State<AugmentedRealityScreen>
    with SingleTickerProviderStateMixin {
  late ArCoreController arCoreController;
  late Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => (Provider.of<NavigationService>(context, listen: false)
            .pushNamedAndRemoveUntil(AppRoute.menuScreen)),
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
      ),
      body: ArCoreView(
        onArCoreViewCreated: onArCoreViewCreated,
      ),
    );
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }

  void onArCoreViewCreated(ArCoreController controller) {
    try {
      arCoreController = controller;
      displayBackground();
    } catch (e) {
      print(e);
    }
  }

  Future<Uint8List> getImageBytes(String imageName) async {
    final ByteData data = await rootBundle.load('assets/images/$imageName');
    return data.buffer.asUint8List();
  }

  void displayBackground() async {
    imageBytes = await getImageBytes("image.jpg");

    final background = ArCoreNode(
      image: ArCoreImage(bytes: imageBytes, height: 1000, width: 1000),
      position: vector.Vector3(1, 0, 0),
    );

    arCoreController.addArCoreNode(background);
  }
}
