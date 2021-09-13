import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:labadaph2_mobile/order/order_model.dart';
import 'package:labadaph2_mobile/order/widgets/customer_card.dart';
import 'package:maps_launcher/maps_launcher.dart';

class MapPage extends StatefulWidget {
  static const String routeName = '/map';

  final Map<String, dynamic> orderData;

  MapPage(this.orderData);

  @override
  State<MapPage> createState() => MapPageState(this.orderData);
}

class MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  late OrderModel order;

  MapPageState(orderData) {
    this.order = OrderModel(orderData);
  }

  Widget _buildForm(BuildContext context) {
    List<Marker> _markers = <Marker>[];
    LatLng? location;
    if (order.data['lat'] != null && order.data['long'] != null) {
      location = LatLng(
        double.parse(order.data['lat']),
        double.parse(order.data['long']),
      );
      _markers.add(Marker(
          markerId: MarkerId(order.getCustomerName()),
          position: location,
          infoWindow: InfoWindow(title: order.data['labada_pin_address'])));
    }
    return ListView(
      children: [
        CustomerCard(order),
        Card(
          margin: EdgeInsets.all(12),
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(10),
            child: location == null
                ? Text("Location not found or not properly pinned.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline4)
                : GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: location,
                      zoom: 14.4746,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    markers: Set<Marker>.of(_markers),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () {
                if (location == null)
                  MapsLauncher.launchQuery(order.data['labada_pin_address']);
                else
                  MapsLauncher.launchCoordinates(location.latitude,
                      location.longitude, order.getCustomerName());
              },
              child: Text("Find in Google Maps")),
        )
        // ScheduleCard(
        //   order: order,
        //   pickupMode: "Pickup",
        // )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(order.getCustomerName()),
        ),
        actions: <Widget>[
          SizedBox(width: 50),
        ],
      ),
      body: _buildForm(context),
    );
  }
}
