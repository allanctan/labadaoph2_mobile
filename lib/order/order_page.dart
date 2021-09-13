import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/order/widgets/customer_card.dart';
import 'package:labadaph2_mobile/order/widgets/payment_card.dart';
import 'package:labadaph2_mobile/order/widgets/photo_gallery_card.dart';
import 'package:labadaph2_mobile/order/widgets/process_card.dart';
import 'package:labadaph2_mobile/order/widgets/schedule_card.dart';
import 'package:provider/provider.dart';

import 'order_model.dart';

class OrderPage extends StatelessWidget {
  static const String routeName = '/order';

  final Map<String, dynamic> orderData;

  OrderPage(this.orderData);

  Widget _buildForm(BuildContext context) {
    OrderModel sOrder = OrderModel(this.orderData);

    return ListView(
      children: [
        CustomerCard(
          sOrder,
          expanded: sOrder.data['status'] == 'new_',
        ),
        (sOrder.data['status'] == 'new_')
            ? ScheduleCard(
                order: sOrder,
                pickupMode: "Pickup",
              )
            : Container(width: 0, height: 0),
        (sOrder.data['status'] == 'for_pickup')
            ? PhotoGalleryCard(
                pickupMode: "Pickup",
              )
            : Container(width: 0, height: 0),
        (sOrder.data['status'] == 'in_process')
            ? ProcessCard(sOrder)
            : Container(width: 0, height: 0),
        (sOrder.data['status'] == 'for_payment')
            ? PaymentCard(order: sOrder)
            : Container(width: 0, height: 0),
        (sOrder.data['status'] == 'paid')
            ? ScheduleCard(
                order: sOrder,
                pickupMode: "Delivery",
              )
            : Container(width: 0, height: 0),
        (sOrder.data['status'] == 'for_delivery')
            ? PhotoGalleryCard(
                pickupMode: "Delivery",
              )
            : Container(width: 0, height: 0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(orderData['firstname'] + ' ' + orderData['lastname']),
        ),
        actions: <Widget>[
          SizedBox(width: 50),
        ],
      ),
      body: ChangeNotifierProvider<OrderModel>(
          create: (context) => OrderModel(orderData),
          builder: (context, widget) {
            return _buildForm(context);
          }),
    );
  }
}
