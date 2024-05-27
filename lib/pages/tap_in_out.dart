// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../models/response_api.dart';
import '../utils/functions.dart';
import '../utils/strings.dart';

class TapInOutPage extends StatefulWidget {
  static const routeName = '/tap-in-out';
  final String? url;
  final String? title;
  const TapInOutPage({Key? key, this.title, this.url}) : super(key: key);

  @override
  State<TapInOutPage> createState() => _TapInOutPageState();
}

class _TapInOutPageState extends State<TapInOutPage> {
  late DeviceState deviceState;
  Completer<GoogleMapController> mapController = Completer();
  final TextEditingController _noteText = TextEditingController();
  Location location = Location();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  File? _imageFile;
  double? heightScreen, widthScreen;
  bool isLoading = false;
  bool isLoadingMap = false;
  bool isMapReady = false;
  bool getLocation = false;
  double opacitySubmit = 0.5;
  String infoJeff = "jefri";
  MarkerId markerId = const MarkerId("my_position_marker");
  String? _imageBase64, _latitude, _longitude;
  double? latitude, longitude;
  var _planText, _secretKey, _parameters, responseAPI;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      location.onLocationChanged.listen((LocationData currentLocation) {
        getLocation = true;
        _longitude = currentLocation.longitude.toString();
        _latitude = currentLocation.latitude.toString();
        latitude = currentLocation.latitude;
        longitude = currentLocation.longitude;
        // log("$latitude & $longitude");
        generateMarker();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void generateMarker() {
    if (isMapReady && getLocation) {
      Marker marker = Marker(
        markerId: markerId,
        position: LatLng(
          latitude!,
          longitude!,
        ),
        infoWindow: const InfoWindow(title: "My Position", snippet: '*'),
        onTap: () {
          log("Marker Id => $markerId");
        },
      );

      goToNewPosition(
        newPosition: CameraPosition(
          target: LatLng(latitude!, longitude!),
          zoom: 17,
        ),
      );
      setState(() {
        markers[markerId] = marker;
      });
    }
  }

  Future<void> goToNewPosition({required CameraPosition newPosition}) async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
  }

  Future<void> _onTakePicture(ImageSource source) async {
    var image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 50,
        maxHeight: heightScreen! * 0.4,
        maxWidth: widthScreen! * 0.4);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      confirmSubmit();
    }
  }

  Future<void> confirmSubmit() async {
    if (_imageFile != null) {
      var result = await showMaterialModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: buildNote(),
        ),
      );
      if (result == null || result == '') {
        log("Tidak Ada Result");
      } else {
        await callAPI();
      }
    } else {
      Flushbar(
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: const Icon(
          Icons.info_outline_rounded,
          color: Colors.white,
        ),
        title: 'Information',
        message: UIString.photoRequired,
      ).show(context);
    }
  }

  Future<void> callAPI() async {
    _planText = "";
    _imageBase64 = await (UIFunction.encodeImageBase64(_imageFile!) as FutureOr<String?>);
    _planText = deviceState.myAuth!.username! +
        _longitude! +
        _latitude! +
        _imageBase64! +
        _noteText.text +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId! +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId!;
    _secretKey = UIFunction.encodeSha1(_planText);
    _parameters = json.encode([
      deviceState.myAuth!.username,
      _longitude,
      _latitude,
      _imageBase64,
      _noteText.text,
      deviceState.myAuth!.companyCode,
      deviceState.deviceId,
      _secretKey
    ]);
    UIFunction.showDialogLoadingBlank(context: context);
    ResponseAPI result = await UIFunction.callAPIDIO(
      method: 'POST',
      url: deviceState.myAuth!.host! + widget.url!,
      formData: _parameters,
    );
    Map<String, dynamic> result2 = <String, dynamic>{};
    result2["code"] = result.code;
    Navigator.pop(context);
    if (result.success) {
      log(result.data[0]);
      log(result.data[1]);
      result2["msg"] = result.data[1];
      if (result.data[0] == 'S') {
        Navigator.pop(context, result2);
      } else {
        Flushbar(
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
          duration: const Duration(seconds: 3),
          icon: const Icon(
            Icons.info_outline_rounded,
            color: Colors.white,
          ),
          title: 'Information',
          message: result.data[1],
        ).show(context);
      }
    } else {
      if (result.code == 401) {
        Navigator.pop(context, result2);
      }
      Flushbar(
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: const Icon(
          Icons.info_outline_rounded,
          color: Colors.white,
        ),
        title: 'Information',
        message: result.message,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceState = Provider.of<DeviceState>(context);
    widthScreen = MediaQuery.of(context).size.width;
    heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title!,
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await _onTakePicture(ImageSource.camera);
            },
            icon: const Icon(FontAwesomeIcons.camera),
          )
        ],
      ),
      bottomNavigationBar: buildBottom(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          LocationData _locationData;
          _locationData = await location.getLocation();
          log("get new location");
          setState(() {
            getLocation = true;
            _longitude = _locationData.longitude.toString();
            _latitude = _locationData.latitude.toString();
            latitude = _locationData.latitude;
            longitude = _locationData.longitude;
          });
          generateMarker();
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.my_location,
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            markers: Set<Marker>.of(markers.values),
            zoomGesturesEnabled: false,
            scrollGesturesEnabled: false,
            tiltGesturesEnabled: false,
            rotateGesturesEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            myLocationButtonEnabled: false,
            initialCameraPosition: const CameraPosition(
                zoom: 14.0, target: LatLng(-6.2848027, 106.6631437)),
            onMapCreated: (GoogleMapController controller) {
              mapController.complete(controller);
              isMapReady = true;
              setState(() {});
            },
          ),
          buildPhoto(),
        ],
      ),
    );
  }

  Widget buildBottom() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () async {
              await confirmSubmit();
            },
            child: Text(
              "Submit".toUpperCase(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPhoto() {
    if (_imageFile != null) {
      return Padding(
        padding:
            EdgeInsets.only(top: widthScreen! * 0.05, left: widthScreen! * 0.05),
        child: Container(
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              image: DecorationImage(image: FileImage(_imageFile!))),
          height: widthScreen! * 0.28,
          width: widthScreen! * 0.2,
        ),
      );
    } else {
      return const Center();
    }
  }

  Widget buildNote() {
    return CustomScrollView(
      shrinkWrap: true,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              )
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            key: const Key("Note Widget"),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.rectangle,
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextFormField(
                        autofocus: false,
                        keyboardAppearance: Brightness.light,
                        textAlign: TextAlign.left,
                        maxLines: 6,
                        maxLength: 255,
                        controller: _noteText,
                        decoration: const InputDecoration(
                          filled: true,
                          counterText: "",
                          contentPadding: EdgeInsets.all(10),
                          fillColor: Colors.transparent,
                          hintText: "Note (optional)",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text("Confirm"),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
