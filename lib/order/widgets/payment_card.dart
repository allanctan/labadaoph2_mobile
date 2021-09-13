import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/loading.dart';

import '../order_model.dart';
import '../order_service.dart';

class PaymentCard extends StatelessWidget {
  final OrderModel order;
  OrdersService _service = OrdersService();

  PaymentCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(12),
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: _service.getModesofPayment(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              if (snapshot.data!.docs.length == 0) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 125,
                      width: MediaQuery.of(context).size.width,
                    ),
                    Text('No Modes of Payment Available.',
                        style: Theme.of(context)
                            .textTheme
                            .headline3!
                            .apply(color: Colors.red),
                        textAlign: TextAlign.center),
                  ],
                );
              } else {
                return Column(
                  children: <Widget>[
                        Text("Order is paid using:",
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .apply(color: Theme.of(context).accentColor)),
                        SizedBox(height: 12),
                      ] +
                      snapshot.data!.docs.map((mode) {
                        return ElevatedButton(
                          child: Text(mode['name']),
                          onPressed: () {
                            order.markAsPaid(mode['name']);
                            Navigator.of(context).pop();
                          },
                        );
                      }).toList(),
                );
              }
            }
            return LoadingPanel(true);
          },
        ),
      ),
    );
  }
}
