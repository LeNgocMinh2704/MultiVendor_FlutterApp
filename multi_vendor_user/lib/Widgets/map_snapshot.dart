// import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SnapshotBody extends StatefulWidget {
  final num lat;
  final num long;
  const SnapshotBody({Key? key, required this.lat, required this.long})
      : super(key: key);

  @override
  SnapshotBodyState createState() => SnapshotBodyState();
}

class SnapshotBodyState extends State<SnapshotBody> {
  GoogleMapController? mapController;
  // Uint8List? _imageBytes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 180,
            child: GoogleMap(
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                  target: LatLng(widget.lat.toDouble(), widget.long.toDouble()),
                  zoom: 11.0),
            ),
          ),
          // TextButton(
          //   child: const Text('Take a snapshot'),
          //   onPressed: () async {
          //     final Uint8List? imageBytes =
          //         await _mapController?.takeSnapshot();
          //     setState(() {
          //       _imageBytes = imageBytes;
          //     });
          //   },
          // ),
          // Container(
          //   decoration: BoxDecoration(color: Colors.blueGrey[50]),
          //   height: 180,
          //   width: double.infinity,
          //   child: _imageBytes != null ? Image.memory(_imageBytes!) : null,
          // ),
        ],
      ),
    );
  }

  // ignore: use_setters_to_change_properties
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}
