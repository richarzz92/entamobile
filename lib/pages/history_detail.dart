import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:enta_mobile/components/loading.dart';
import 'package:enta_mobile/models/history.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:enta_mobile/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class HistoryDetailPage extends StatefulWidget {
  static const routeName = '/history/detail';
  final HistoryModel? data;
  const HistoryDetailPage({Key? key, this.data}) : super(key: key);

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  var snapController = SnappingSheetController();
  final ScrollController scrollController = ScrollController();
  Completer<GoogleMapController> mapController = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId markerId = const MarkerId("my_position_marker");
  late DeviceState deviceState;
  double? widthScreen, heightScreen;

  @override
  void initState() {
    super.initState();
    log("image url");
    Future.delayed(Duration.zero, () {
      log(deviceState.myAuth!.host! + widget.data!.imageUrl!);
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widthScreen = MediaQuery.of(context).size.width;
    heightScreen = MediaQuery.of(context).size.height;
    deviceState = Provider.of<DeviceState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail"),
      ),
      body: SnappingSheet(
        lockOverflowDrag: true,
        controller: snapController,
        grabbingHeight: 90,
        snappingPositions: const [
          SnappingPosition.factor(
            positionFactor: 0.0,
            snappingCurve: Curves.elasticOut,
            snappingDuration: Duration(milliseconds: 750),
            grabbingContentOffset: GrabbingContentOffset.top,
          ),
          SnappingPosition.factor(
            snappingCurve: Curves.bounceOut,
            snappingDuration: Duration(milliseconds: 750),
            positionFactor: 0.3,
          ),
          SnappingPosition.factor(
            snappingCurve: Curves.bounceOut,
            snappingDuration: Duration(milliseconds: 750),
            positionFactor: 0.5,
          ),
        ],
        grabbing: buildGrabbing(),
        sheetBelow: SnappingSheetContent(
          draggable: true,
          childScrollController: scrollController,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                buildSheetBelow(),
              ],
            ),
          ),
        ),
        child: GoogleMap(
          markers: Set<Marker>.of(markers.values),
          zoomGesturesEnabled: false,
          scrollGesturesEnabled: false,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          initialCameraPosition: CameraPosition(
            target: LatLng(double.parse(widget.data!.latitude!),
                double.parse(widget.data!.longitude!)),
            zoom: 17,
          ),
          onMapCreated: (GoogleMapController controller) {
            mapController.complete(controller);
            Marker marker = Marker(
              markerId: markerId,
              position: LatLng(
                double.parse(widget.data!.latitude!),
                double.parse(widget.data!.longitude!),
              ),
              infoWindow: const InfoWindow(title: "My Position", snippet: '*'),
              onTap: () {
                log("Marker Id => $markerId");
              },
            );
            markers[markerId] = marker;
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget buildGrabbing() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              blurRadius: 5.0,
              color: Theme.of(context).dividerColor.withAlpha(30),
              offset: const Offset(0, -1))
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300]),
                ),
              ),
            ],
          ),
          ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: widget.data!.type == 'in'
                  ? Theme.of(context).primaryColor
                  : widget.data!.type == 'out'
                      ? Colors.redAccent
                      : Colors.orangeAccent,
              child: Center(
                child: Icon(
                  widget.data!.type == 'in'
                      ? FontAwesomeIcons.arrowUp
                      : widget.data!.type == 'out'
                          ? FontAwesomeIcons.arrowDown
                          : FontAwesomeIcons.question,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ),
            title: Text(
              widget.data!.date!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  widget.data!.time!,
                  style: TextStyle(
                      fontSize: Theme.of(context)
                          .primaryTextTheme
                          .subtitle2!
                          .fontSize),
                ),
                Text(
                  widget.data!.status!,
                  style: TextStyle(
                      fontSize: Theme.of(context)
                          .primaryTextTheme
                          .subtitle2!
                          .fontSize),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSheetBelow() {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Remarks : ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(widget.data!.note!),
            Center(
              child: CachedNetworkImage(
                imageUrl: "${deviceState.myAuth!.host}${widget.data!.imageUrl}",
                fit: BoxFit.cover,
                placeholder: (context, url) => const LoadingWidget(),
                errorWidget: (context, url, error) {
                  log("error => ${deviceState.myAuth!.host}${widget.data!.imageUrl}");
                  return SvgPicture.asset(
                    UIImage.noPhoto,
                    height: heightScreen! * 0.25,
                  );
                },
              ),
            ),
          ],
        ));
  }
}
