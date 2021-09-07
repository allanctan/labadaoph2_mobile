import 'package:calendar_time/calendar_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/dialog.dart';
import 'package:labadaph2_mobile/common/loading.dart';
import 'package:labadaph2_mobile/navigation/app_drawer.dart';
import 'package:labadaph2_mobile/order/widgets/circle_button.dart';

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

  Widget _buildAction(DocumentSnapshot orderData) {
    switch (orderData.get("status")) {
      case "new_":
        return CircleButton(
          icon: Icons.calendar_today,
          onPressed: () {},
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
          child: Text('Orders'),
        ),
        actions: [SizedBox(width: 50)],
      ),
      drawer: AppDrawer(),
      body: StreamBuilder<QuerySnapshot>(
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
                    height: 125,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Icon(
                    Icons.shopping_basket,
                    size: 100,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'You have no orders.',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              );
            } else {
              return ListView.separated(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot orderData = snapshot.data!.docs[index];
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
                      onTap: () {},
                      //   => Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => TaxPage(
                      //       snapshot: taxData,
                      //       isNew: false,
                      //     ),
                      //   ),
                      // ),
                      title: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                orderData.get("firstname") +
                                    " " +
                                    orderData.get("lastname"),
                                style: Theme.of(context).textTheme.headline5),
                            Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                  child: Icon(
                                    Icons.pin_drop,
                                    color: Theme.of(context).accentColor,
                                    size: 30,
                                  ),
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
                                DateTime.fromMicrosecondsSinceEpoch(orderData
                                    .get("createdAt")
                                    .microsecondsSinceEpoch))
                            .toHuman),
                      ),
                      trailing: _buildAction(orderData),
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
