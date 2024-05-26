import 'package:flutter/material.dart';
import 'package:object_detector/app/app_router.dart';
import 'package:object_detector/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
  }

  late final List<MapObject> mapObjects = [
    const CircleMapObject(
        fillColor: Colors.red,
        strokeColor: Colors.red,
        mapId: MapObjectId("circle"),
        circle: Circle(
            center: Point(latitude: 48.712917, longitude: 44.526974),
            radius: 30)),
    startPlacemark,
    //stopByPlacemark,
    //endPlacemark
  ];
  final PlacemarkMapObject startPlacemark = const PlacemarkMapObject(
    mapId: MapObjectId('start_placemark'),
    point: Point(latitude: 48.712917, longitude: 44.526974),
  );

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
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                child: YandexMap(
              nightModeEnabled: true,
              mapObjects: mapObjects,
              onMapCreated: (YandexMapController yandexMapController) async {
                final geometry = Geometry.fromBoundingBox(BoundingBox(
                    northEast: startPlacemark.point,
                    southWest: startPlacemark.point));

                await yandexMapController
                    .moveCamera(CameraUpdate.newGeometry(geometry));
                await yandexMapController.moveCamera(CameraUpdate.zoomOut());
              },
            )),
          ]),
    );
  }
}
