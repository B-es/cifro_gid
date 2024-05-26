import 'package:flutter/material.dart';
import 'package:object_detector/app/app_router.dart';
import 'package:object_detector/services/navigation_service.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Text title = const Text(
    "ЦифроГид",
    style: TextStyle(fontFamily: 'Caveat', fontWeight: FontWeight.bold),
    textScaler: TextScaler.linear(2.2),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 90.0,
          centerTitle: true,
          title: title,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Stack(
          children: [
            const Align(
              alignment: Alignment.bottomCenter,
              child: Image(
                image: AssetImage("assets/images/mainmenu.png"),
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
            Align(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () => (Provider.of<NavigationService>(context,
                              listen: false)
                          .pushNamedAndRemoveUntil(AppRoute.mapScreen)),
                      style: ElevatedButton.styleFrom(
                          elevation: 9, minimumSize: const Size(200, 60)),
                      child: const Text(
                        "Карта",
                        style: TextStyle(
                          fontFamily: 'Caveat',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textScaler: TextScaler.linear(1.5),
                      )),
                  const SizedBox(height: 50),
                  ElevatedButton(
                      onPressed: () => (Provider.of<NavigationService>(context,
                              listen: false)
                          .pushNamedAndRemoveUntil(AppRoute.detectorScreen)),
                      style: ElevatedButton.styleFrom(
                          elevation: 9, minimumSize: const Size(200, 60)),
                      child: const Text(
                        "Режим сканирования",
                        style: TextStyle(
                          fontFamily: 'Caveat',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textScaler: TextScaler.linear(1.5),
                      )),
                  const SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                      onPressed: () => (Provider.of<NavigationService>(context,
                              listen: false)
                          .pushNamedAndRemoveUntil(AppRoute.arScreen)),
                      style: ElevatedButton.styleFrom(
                          elevation: 9, minimumSize: const Size(200, 60)),
                      child: const Text(
                        "Дополненная реальность",
                        style: TextStyle(
                          fontFamily: 'Caveat',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textScaler: TextScaler.linear(1.5),
                      )),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ],
        )); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
