import 'dart:math';

import 'package:calendar_time/calendar_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/dialog.dart';
import 'package:labadaph2_mobile/common/extensions/cap_extension.dart';
import 'package:labadaph2_mobile/common/loading.dart';
import 'package:labadaph2_mobile/map/map_page.dart';
import 'package:labadaph2_mobile/navigation/app_drawer.dart';
import 'package:labadaph2_mobile/order/widgets/circle_button.dart';

import 'order_model.dart';
import 'order_page.dart';
import 'order_service.dart';

class OrdersPage extends StatefulWidget {
  static const String routeName = '/orders';

  @override
  _OrdersPageState createState() => _OrdersPageState();
  final String status;
  OrdersPage({this.status = "new_"});
}

class _OrdersPageState extends State<OrdersPage> {
  OrdersService _service = new OrdersService();
  final _formKey = GlobalKey<FormState>();

  static const Map<String, IconData> statusIcons = {
    'new_': Icons.calendar_today,
    'for_pickup': Icons.photo_camera_outlined,
    'in_process': Icons.local_laundry_service_outlined,
    'for_payment': Icons.payment,
    'paid': Icons.calendar_today,
    'for_delivery': Icons.check_box_outlined,
  };

  var positiveRemarks = [
    "Good job!",
    "All is good here.",
    "Just chill and relax.",
    "Nicely done."
  ];
  final _random = new Random();

  String getStatusDisplay() {
    String t1 = widget.status.replaceAll("_", " ").trim();
    return t1.capitalizeFirstofEach;
  }

  Widget _buildAction(Map<String, dynamic> data) {
    switch (data["status"]) {
      case "new_":
      case "for_pickup":
      case "in_process":
      case "for_payment":
      case "paid":
        return CircleButton(
          icon: statusIcons[data["status"]] ?? Icons.device_unknown,
          onPressed: () {
            Navigator.pushNamed(
              context,
              OrderPage.routeName,
              arguments: data,
            );
          },
        );
      case "for_delivery":
        return CircleButton(
          icon: statusIcons[data["status"]] ?? Icons.device_unknown,
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Confirm Delivery'),
              content: const Text(
                  'Please confirm order has been delivered to client.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      OrderPage.routeName,
                      arguments: data,
                    );
                  },
                  child: const Text('Take Photo'),
                ),
                ElevatedButton(
                  onPressed: () {
                    OrderModel order = OrderModel(data);
                    order.delivered();
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
        );
    }
    return Container(width: 0, height: 0);
  }

  _OrdersPageState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Orders - ' + getStatusDisplay()),
        ),
        actions: [SizedBox(width: 50)],
      ),
      drawer: AppDrawer(),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.getOrdersStream(widget.status),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.hasData &&
              snapshot.data != null) {
            if (snapshot.data!.docs.length == 0) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                  ),
                  (widget.status == 'new_')
                      ? Icon(
                          Icons.hourglass_empty,
                          size: 80,
                          color: Colors.grey,
                        )
                      : Icon(
                          Icons.library_add_check,
                          size: 80,
                          color: Colors.green,
                        ),
                  SizedBox(
                    height: 25,
                    width: MediaQuery.of(context).size.width,
                  ),
                  (widget.status == 'new_')
                      ? Text("It's quiet today.",
                          style: Theme.of(context)
                              .textTheme
                              .headline3!
                              .apply(color: Colors.green),
                          textAlign: TextAlign.center)
                      : Text(
                          positiveRemarks[
                              _random.nextInt(positiveRemarks.length)],
                          style: Theme.of(context)
                              .textTheme
                              .headline3!
                              .apply(color: Colors.green),
                          textAlign: TextAlign.center),
                  SizedBox(
                    height: 12,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Text('No Pending Orders.\n You can check next steps.',
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center),
                ],
              );
            } else {
              return ListView.separated(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot<Map<String, dynamic>> orderData =
                      snapshot.data!.docs[index];
                  return Dismissible(
                    key: Key(orderData.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          Text(
                            "Archive Record?",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .apply(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    onDismissed: (direction) {
                      _service.archiveOrder(orderData.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Order from " +
                              orderData.get("firstname") +
                              " " +
                              orderData.get("lastname") +
                              " is archived.")));
                    },
                    confirmDismiss: (DismissDirection direction) async {
                      return DialogHelper.confirmDelete(
                          context,
                          _formKey,
                          orderData.get("firstname") +
                              " " +
                              orderData.get("lastname"));
                    },
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order No : ' +
                                (orderData.data()?["order_no"] ?? "")),
                            Text(
                                orderData.get("firstname") +
                                    " " +
                                    orderData.get("lastname"),
                                style: Theme.of(context).textTheme.headline5),
                            Row(
                              children: [
                                GestureDetector(
                                  child: SizedBox(
                                    width: 30,
                                    child: Icon(
                                      Icons.pin_drop,
                                      color: Theme.of(context).accentColor,
                                      size: 30,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        MapPage.routeName,
                                        arguments: orderData.data()!);
                                  },
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        orderData.get('labada_pin_address'))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Text(CalendarTime(
                                DateTime.fromMicrosecondsSinceEpoch(
                                    orderData
                                        .get("createdAt")
                                        .microsecondsSinceEpoch))
                            .toHuman),
                      ),
                      trailing: _buildAction(orderData.data()!),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => Divider(
                  height: 20,
                  thickness: 5,
                  color: Colors.black38,
                ),
                itemCount: snapshot.data?.docs.length ?? 0,
              );
            }
          }
          return LoadingPanel(true);
        },
      ),
    );
  }
}
