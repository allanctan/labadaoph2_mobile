import 'package:calendar_time/calendar_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/loading.dart';

import '../order_model.dart';
import '../order_service.dart';

class HistoryCard extends StatelessWidget {
  final OrderModel order;
  OrdersService _service = OrdersService();

  HistoryCard({required this.order});

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("History:",
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .apply(color: Theme.of(context).accentColor)),
            FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: _service.getActivity(docId: order.data['docId']),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  if (snapshot.data!.docs.length == 0) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('No activities recorded.',
                              style: Theme.of(context).textTheme.headline6,
                              textAlign: TextAlign.center),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: snapshot.data!.docs.map((record) {
                        return ListTile(
                            title: Text(record['activity']),
                            subtitle: Text(CalendarTime(
                                    DateTime.fromMicrosecondsSinceEpoch(record
                                        .get("updatedAt")
                                        .microsecondsSinceEpoch))
                                .toHuman));
                      }).toList(),
                    );
                  }
                }
                return LoadingPanel(true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
