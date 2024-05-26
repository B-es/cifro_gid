import 'package:flutter/material.dart';
import 'package:object_detector/screens/augmented_reality_screen.dart';
import 'package:object_detector/screens/detector_screen.dart';
import 'package:object_detector/screens/map_screen.dart';
import 'package:object_detector/screens/menu_screen.dart';
import 'package:object_detector/screens/splash_screen.dart';
import 'package:object_detector/services/tensorflow_service.dart';
import 'package:object_detector/view_models/home_view_model.dart';
import 'package:provider/provider.dart';

class AppRoute {
  static const splashScreen = '/splashScreen';
  static const detectorScreen = '/detectorScreen';
  static const mapScreen = '/mapScreen';
  static const menuScreen = '/menuScreen';
  static const arScreen = '/arScreen';

  static final AppRoute _instance = AppRoute._private();
  factory AppRoute() {
    return _instance;
  }
  AppRoute._private();

  static AppRoute get instance => _instance;

  static Widget createProvider<P extends ChangeNotifier>(
    P Function(BuildContext context) provider,
    Widget child,
  ) {
    return ChangeNotifierProvider<P>(
      create: provider,
      builder: (_, __) {
        return child;
      },
    );
  }

  Route<Object>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return AppPageRoute(builder: (_) => const SplashScreen());
      case detectorScreen:
        Duration? duration;
        if (settings.arguments != null) {
          final args = settings.arguments as Map<String, dynamic>;
          if ((args['isWithoutAnimation'] as bool)) {
            duration = Duration.zero;
          }
        }
        return AppPageRoute(
            appTransitionDuration: duration,
            appSettings: settings,
            builder: (_) => ChangeNotifierProvider(
                create: (context) => HomeViewModel(context,
                    Provider.of<TensorFlowService>(context, listen: false)),
                builder: (_, __) => const DetectorScreen()));
      case menuScreen:
        return AppPageRoute(
            appSettings: settings, builder: (_) => const MenuScreen());
      case mapScreen:
        return AppPageRoute(
            appSettings: settings, builder: (_) => const MapScreen());
      case arScreen:
        return AppPageRoute(
            appSettings: settings,
            builder: (_) => const AugmentedRealityScreen());
      default:
        return null;
    }
  }
}

class AppPageRoute extends MaterialPageRoute<Object> {
  Duration? appTransitionDuration;

  RouteSettings? appSettings;

  AppPageRoute(
      {required super.builder, this.appSettings, this.appTransitionDuration});

  @override
  Duration get transitionDuration =>
      appTransitionDuration ?? super.transitionDuration;

  @override
  RouteSettings get settings => appSettings ?? super.settings;
}
