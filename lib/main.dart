import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'app/app_router.dart';
import 'services/navigation_service.dart';
import 'services/tensorflow_service.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MultiProvider(
    providers: <SingleChildWidget>[
      Provider<AppRoute>(create: (_) => AppRoute()),
      Provider<NavigationService>(create: (_) => NavigationService()),
      Provider<TensorFlowService>(create: (_) => TensorFlowService())
    ],
    child: const Application(),
  ));
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRoute appRoute = Provider.of<AppRoute>(context, listen: false);
    return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: () {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark(),
            onGenerateRoute: appRoute.generateRoute,
            initialRoute: AppRoute.splashScreen,
            navigatorKey: NavigationService.navigationKey,
            navigatorObservers: <NavigatorObserver>[
              NavigationService.routeObserver
            ],
          );
        });
  }
}
