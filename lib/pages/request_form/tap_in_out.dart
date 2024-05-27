// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:enta_mobile/args/general.dart';
import 'package:enta_mobile/models/general.dart';
import 'package:enta_mobile/models/office.dart';
import 'package:enta_mobile/pages/login.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:enta_mobile/root.dart';
import 'package:enta_mobile/utils/data.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:group_button/group_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/response_api.dart';
import '../../utils/functions.dart';
// import '../../utils/strings.dart';
import '../../utils/url.dart';

class TapInOutPage extends StatefulWidget {
  static const routeName = '/tap-in-out';
  final String? url;
  final String? title;
  final String? type;
  const TapInOutPage({Key? key, required this.type, this.title, this.url})
      : super(key: key);

  @override
  State<TapInOutPage> createState() => _TapInOutPageState();
}

class _TapInOutPageState extends State<TapInOutPage> {
  late DeviceState deviceState;
  Completer<GoogleMapController> mapController = Completer();
  final TextEditingController noteText = TextEditingController();
  final TextEditingController clockingTypeText = TextEditingController();
  Location location = Location();
  final formKey = GlobalKey<FormState>();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  GeneralModel? selectedClockingType;
  File? _imageFile;
  double? height, width;
  bool isLoading = false;
  bool isLoadingMap = false;
  bool isMapReady = false;
  bool getLocation = false;
  double opacitySubmit = 0.5;
  List<OfficeModel> nearestOffice = [];
  String infoJeff = "jefri";
  MarkerId markerId = const MarkerId("my_position_marker");
  String? _imageBase64;
  // String  _latitude, _longitude;
  // double latitude, longitude;
  var _planText, _secretKey, _parameters, responseAPI;
  late SharedPreferences prefs;
  final typeController = GroupButtonController();
  bool isCallAPI = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      typeController.selectIndex(0);
      selectedClockingType = UIData.clockingType[0];
      prefs = await SharedPreferences.getInstance();
      // location.onLocationChanged.listen((LocationData currentLocation) {
      //   getLocation = true;
      //   _longitude = currentLocation.longitude.toString();
      //   _latitude = currentLocation.latitude.toString();
      //   latitude = currentLocation.latitude;
      //   longitude = currentLocation.longitude;
      //   if (!isCallAPI) {
      generateMarker();
      //   }
      // });
    });
  }

  @override
  void dispose() {
    isMapReady = false;
    super.dispose();
  }

  void generateMarker() {
    if (isMapReady) {
      Marker marker = Marker(
        markerId: markerId,
        position: LatLng(
          deviceState.myLat!,
          deviceState.myLong!,
        ),
        infoWindow: const InfoWindow(title: "My Position", snippet: '*'),
        onTap: () {
          log("Marker Id => $markerId");
        },
      );

      goToNewPosition(
        newPosition: CameraPosition(
            target: LatLng(deviceState.myLat!, deviceState.myLong!), zoom: 16),
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
        maxHeight: height! * 0.4,
        maxWidth: width! * 0.4);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      confirmSubmit();
    }
  }

  Future<void> showListClockingType() async {
    FocusScope.of(context).requestFocus(FocusNode());
    await showMaterialModalBottomSheet(
      context: context,
      expand: false,
      enableDrag: false,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height! * 0.3),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "List Type".toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context)
                            .primaryTextTheme
                            .subtitle1!
                            .fontSize,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    )
                  ],
                ),
              ),
              const Divider(
                height: 0,
              ),
              Expanded(
                child: ListView.separated(
                    padding: const EdgeInsets.all(0),
                    itemCount: UIData.clockingType.length,
                    separatorBuilder: (BuildContext context, int i) {
                      return const Divider(
                        height: 0,
                      );
                    },
                    itemBuilder: (BuildContext context, int i) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                        onTap: () {
                          setState(() {
                            selectedClockingType = UIData.clockingType[i];
                            clockingTypeText.text = selectedClockingType!.label!;
                          });
                          Navigator.pop(context);
                        },
                        title: Text(
                          UIData.clockingType[i].label!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: selectedClockingType == null ||
                                selectedClockingType!.id !=
                                    UIData.clockingType[i].id
                            ? const SizedBox(
                                height: 5,
                              )
                            : const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> confirmSubmit() async {
    if (_imageFile != null) {
      var result = await showMaterialModalBottomSheet(
        context: context,
        builder: (context) => Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: buildNote(),
          ),
        ),
      );
      if (result == null || result == '') {
        log("Tidak Ada Result");
      } else {
        await callAPI();
      }
    } else {
      // UIFunction.showToastMessage(
      //     context: context,
      //     isError: true,
      //     position: 'TOP',
      //     title: 'Information',
      //     message: UIString.photoRequired);
      await _onTakePicture(ImageSource.camera);
    }
  }

  Future<void> callAPI() async {
    Uri uriTapInOut;
    if (prefs.getBool("secure")!) {
      uriTapInOut = Uri.https(
          prefs.getString("host")!, prefs.getString("prefix")! + widget.url!);
    } else {
      uriTapInOut = Uri.http(
          prefs.getString("host")!, prefs.getString("prefix")! + widget.url!);
    }
    String? clockingTypeText = '';
    if (widget.url == UIUrl.tapIn) {
      clockingTypeText = selectedClockingType!.code;
    } else {
      clockingTypeText = '';
    }
    _planText = "";
    _imageBase64 = await (UIFunction.encodeImageBase64(_imageFile!) as FutureOr<String?>);
    _planText = prefs.getString("username")! +
        deviceState.myLong.toString() +
        deviceState.myLat.toString() +
        _imageBase64! +
        noteText.text +
        clockingTypeText! +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId! +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId!;
    _secretKey = UIFunction.encodeSha1(_planText);
    _parameters = json.encode([
      prefs.getString("username"),
      deviceState.myLong.toString(),
      deviceState.myLat.toString(),
      _imageBase64,
      noteText.text,
      clockingTypeText,
      deviceState.myAuth!.companyCode,
      deviceState.deviceId,
      _secretKey
    ]);
    UIFunction.showDialogLoadingBlank(context: context);
    isCallAPI = true;
    setState(() {});
    ResponseAPI result = await UIFunction.callAPIDIO(
      method: 'POST',
      url: uriTapInOut.toString(),
      formData: _parameters,
    );
    Map<String, dynamic> result2 = <String, dynamic>{};
    result2["code"] = result.code;
    if (result.success) {
      result2["msg"] = result.data[1];
      if (result.data[0] == 'S') {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.popUntil(context, ModalRoute.withName(MainPage.routeName));
          UIFunction.showToastMessage(
              context: context,
              isError: false,
              position: 'TOP',
              title: 'Information',
              message: result.data[1]);
        });
      } else {
        isCallAPI = false;
        setState(() {});
        Navigator.pop(context);
        UIFunction.showToastMessage(
            context: context,
            isError: true,
            position: 'TOP',
            title: 'Information',
            message: result.data[1]);
      }
    } else {
      isCallAPI = false;
      setState(() {});
      Navigator.pop(context);
      if (result.code == 401) {
        UIFunction.unsetPreferences();
        Navigator.popUntil(context, ModalRoute.withName(MainPage.routeName));
        Navigator.pushReplacementNamed(
          context,
          LoginPage.routeName,
          arguments: GeneralArgs(
            showAlert: true,
            alertText: 'Session is expired',
          ),
        );
      }
      UIFunction.showToastMessage(
          context: context,
          isError: true,
          position: 'TOP',
          title: 'Information',
          message: result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceState = Provider.of<DeviceState>(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    if (deviceState.myLat != null) {
      log("Generate");
      generateMarker();
    }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
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
            LocationData locationData;
            locationData = await location.getLocation();
            log("get new location");
            setState(() {
              getLocation = true;
              deviceState.setMyLocation(
                latitude: locationData.latitude,
                longitude: locationData.longitude,
              );
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
              minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
              markers: Set<Marker>.of(markers.values),
              zoomGesturesEnabled: false,
              scrollGesturesEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              myLocationButtonEnabled: false,
              initialCameraPosition: const CameraPosition(
                  zoom: 16.0,
                  target: LatLng(-6.371302922081892, 107.2787540731551)),
              onMapCreated: (GoogleMapController controller) {
                mapController.complete(controller);
                isMapReady = true;
                setState(() {});
              },
            ),
            buildPhoto(),
          ],
        ),
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
        padding: EdgeInsets.only(top: width! * 0.05, left: width! * 0.05),
        child: Container(
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              image: DecorationImage(image: FileImage(_imageFile!))),
          height: width! * 0.28,
          width: width! * 0.2,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Visibility(
                  visible: widget.url == UIUrl.tapIn ? true : false,
                  child: GroupButton(
                    controller: typeController,
                    isRadio: true,
                    onSelected: (dynamic text, index, isSelected) {
                      selectedClockingType = deviceState.workFromStatusList[index];
                      setState(() {});
                    },
                    buttons: deviceState.workFromStatusLabels,
                  ),
                ),
                Text(
                  "Note",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        Theme.of(context).primaryTextTheme.caption!.fontSize,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: TextFormField(
                    maxLines: 4,
                    minLines: 2,
                    controller: noteText,
                    validator: (value) {
                      return null;
                    },
                    maxLength: 255,
                    decoration: const InputDecoration(
                      hintText: "Note (optional)",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () async {
                      Location location = Location();
                      bool isOn = await location.serviceEnabled();
                      if (!isOn) {
                        bool isturnedon = await location.requestService();
                        if (!isturnedon) {
                          UIFunction.showToastMessage(
                              context: context,
                              isError: true,
                              position: 'TOP',
                              message: 'please activate your gps');
                        }
                      } else {
                        if (formKey.currentState!.validate()) {
                          LocationData locationData;
                          locationData = await location.getLocation();
                          log("get new location");
                          setState(() {
                            getLocation = true;
                            deviceState.setMyLocation(
                              latitude: locationData.latitude,
                              longitude: locationData.longitude,
                            );
                          });
                          generateMarker();
                          if (selectedClockingType!.code == 'WFO' &&
                              widget.url == UIUrl.tapIn) {
                            if (deviceState.officeList!.isEmpty) {
                              Navigator.pop(context, true);
                            } else {
                              nearestOffice.clear();
                              for (var e in deviceState.officeList!) {
                                double distance = UIFunction.calculateDistance(
                                    lat1: e.latitude!,
                                    lat2: deviceState.myLat!,
                                    lon1: e.longitude!,
                                    lon2: deviceState.myLong!);
                                log("Distance My Location (${deviceState.myLat} - ${deviceState.myLong}) to ${e.name} (${e.latitude} - ${e.longitude}) is $distance KM");
                                if (distance <= 1) {
                                  nearestOffice.add(e);
                                }
                              }
                              if (nearestOffice.isEmpty) {
                                UIFunction.showToastMessage(
                                    context: context,
                                    isError: true,
                                    position: 'TOP',
                                    title: 'Oooopps',
                                    message: 'You are too far from the office');
                              } else {
                                Navigator.pop(context, true);
                              }
                            }
                          } else {
                            Navigator.pop(context, true);
                          }
                        }
                      }
                    },
                    child: const Text("Confirm"),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
