import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/loading.dart';
import 'package:labadaph2_mobile/order/widgets/date_dropdown.dart';
import 'package:labadaph2_mobile/order/widgets/time_dropdown.dart';

import '../order_model.dart';

class ScheduleCard extends StatefulWidget {
  final OrderModel order;
  final String pickupMode;

  ScheduleCard({required this.order, required this.pickupMode});

  @override
  _ScheduleCardState createState() =>
      _ScheduleCardState(order: order, pickupMode: pickupMode);
}

class _ScheduleCardState extends State<ScheduleCard> {
  final _formKey = GlobalKey<FormState>();
  final OrderModel order;
  final String pickupMode;

  bool isLoading = false;

  _ScheduleCardState({required this.order, required this.pickupMode}) {
    if (DateTime.now().hour < 12) {
      // schedule pickup today
      order.scheduleDate = "Today";
      order.scheduleTime = "pm";
    } else {
      order.scheduleDate = "Tomorrow";
      order.scheduleTime = "am";
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingPanel(true)
        : Card(
            margin: EdgeInsets.all(12),
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Schedule for $pickupMode:",
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .apply(color: Theme.of(context).accentColor)),
                    DateDropdown(
                        value: order.scheduleDate!,
                        onChanged: (value) {
                          order.scheduleDate = value;
                        }),
                    TimeDropdown(
                        value: order.scheduleTime!,
                        onChanged: (value) {
                          order.scheduleTime = value;
                        }),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: order.notifyCustomer,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (value) {
                        setState(() {
                          order.notifyCustomer = value ?? false;
                        });
                      },
                      title: Text("Notify Customer?"),
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            setState(() {
                              isLoading = false;
                            });
                            if (pickupMode == "Pickup") {
                              order.doSchedulePickup();
                              setState(() {
                                isLoading = true;
                              });
                              Navigator.of(context).pop();
                            } else {
                              order.doScheduleDelivery();
                              setState(() {
                                isLoading = true;
                              });
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        child: Text("Schedule $pickupMode"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
