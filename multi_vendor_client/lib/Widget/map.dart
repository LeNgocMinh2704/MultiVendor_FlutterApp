// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:vendor/Model/constant.dart';

class MapScreen extends StatefulWidget {
  final num userLat;
  final num userLong;
  final num marketLat;
  final num marketLong;
  final String address;
  final num zoom;
  const MapScreen(
      {Key? key,
      required this.userLat,
      required this.zoom,
      required this.address,
      required this.userLong,
      required this.marketLong,
      required this.marketLat})
      : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  // double originLatitude = 6.5212402, originLongitude = 3.3679965;
  // double destLatitude = 6.849660, destLongitude = 3.648190;
  // double originLatitude = 5.5289, originLongitude = 7.4930;
  // double destLatitude = 5.5418, destLongitude = 7.5017;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = googleApiKey;

  @override
  void initState() {
    super.initState();

    /// origin marker
    _addMarker(LatLng(widget.userLat.toDouble(), widget.userLong.toDouble()),
        "origin", BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(
        LatLng(widget.marketLat.toDouble(), widget.marketLong.toDouble()),
        "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));
    _getPolyline();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.userLat);
    return SafeArea(
      child: Scaffold(
          body: GoogleMap(
        initialCameraPosition: CameraPosition(
            target:
                LatLng(widget.userLat.toDouble(), widget.userLong.toDouble()),
            zoom: widget.zoom.toDouble()),
        myLocationEnabled: true,
        tiltGesturesEnabled: true,
        compassEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        onMapCreated: _onMapCreated,
        markers: Set<Marker>.of(markers.values),
        polylines: Set<Polyline>.of(polylines.values),
      )),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(widget.userLat.toDouble(), widget.userLong.toDouble()),
        PointLatLng(widget.marketLat.toDouble(), widget.marketLong.toDouble()),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: widget.address)]);
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    _addPolyLine();
  }
}
