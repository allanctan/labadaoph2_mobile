import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/formfields/list_dropdown.dart';
import 'package:labadaph2_mobile/common/loading.dart';

import '../order_model.dart';
import '../order_service.dart';

class ProcessCard extends StatefulWidget {
  final OrderModel order;
  ProcessCard(this.order);

  @override
  _ProcessCardState createState() => _ProcessCardState(order);
}

class _ProcessCardState extends State<ProcessCard> {
  final _formKey = GlobalKey<FormState>();
  final OrdersService _service = OrdersService();
  final OrderModel order;

  bool _isLoading = false;
  _ProcessCardState(this.order) {
    order.grandTotal =
        int.tryParse(order.data['booking_total_amount'] ?? "0") ?? 0;
  }

  Future<QuerySnapshot<Map<String, dynamic>>>? offeringsFuture;
  QuerySnapshot<Map<String, dynamic>>? offerings;
  bool addCharge = false;

  TextEditingController chargeNameController = TextEditingController();
  TextEditingController chargeAmountController = TextEditingController();

  void computeTotal({String chargeAmount = "0"}) {
    int grandTotal = int.tryParse(chargeAmount) ?? 0;
    offerings?.docs.forEach((offering) {
      int price = offering.get("price");
      int qty = int.parse(order.data["d" + offering.get("order")] ?? "0");
      int total = price * qty;
      grandTotal = grandTotal + total;
    });
    order.grandTotal = grandTotal;
  }

  @override
  void initState() {
    super.initState();
    offeringsFuture = _service.getOfferings();
  }

  Widget _listOfferings() {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: _service.getOfferings(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            offerings = snapshot.data!;
            return ListView.separated(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot<Map<String, dynamic>> offering =
                    snapshot.data!.docs[index];
                int price = offering.get("price");
                int qty =
                    int.parse(order.data["d" + offering.get("order")] ?? "0");
                int total = price * qty;
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offering.get("name"),
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text("P " + offering.get("price").toString()),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 45,
                      child: ListDropdown(
                          value: order.data["d" + offering.get("order")] ?? "0",
                          list: [
                            "0",
                            "1",
                            "2",
                            "3",
                            "4",
                            "5",
                            "6",
                            "7",
                            "8",
                            "9",
                            "10"
                          ],
                          onChanged: (value) {
                            setState(() {
                              order.data["d" + offering.get("order")] = value;
                              computeTotal();
                            });
                          }),
                    ),
                    Container(
                      width: 80,
                      child: Text(
                        ((total != 0) ? ("P " + total.toString()) : '--'),
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                  ],
                );
              },
              itemCount: snapshot.data?.docs.length ?? 0,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 8);
              },
            );
          }
          return Text("Loading...");
        });
  }

  String? validateNumber(String value) {
    if (value == null || value.isEmpty) return null;
    final num = int.tryParse(value) ?? null;
    if (num == null) return "Invalid";
    return null;
  }

  Widget _buildAdjustment() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              maxLines: 1,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Custom Charge',
                hintText: 'Charge Name',
                contentPadding: EdgeInsets.zero,
              ),
              controller: chargeNameController,
              validator: (value) {
                if (chargeAmountController.text.isNotEmpty) {
                  if (value?.isEmpty ?? true)
                    return "Please describe adjustment amount.";
                }
                return null;
              },
            ),
          ),
          SizedBox(
            width: 60,
          ),
          Container(
            width: 80,
            child: TextFormField(
              keyboardType: TextInputType.phone,
              maxLines: 1,
              textAlign: TextAlign.end,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: Theme.of(context).textTheme.headline5,
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: 'Amount',
                errorText: validateNumber(chargeAmountController.text),
                contentPadding: EdgeInsets.zero,
              ),
              controller: chargeAmountController,
              validator: (value) {
                return validateNumber(value.toString());
              },
              onChanged: (value) {
                setState(() {
                  computeTotal(chargeAmount: value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingPanel(true)
        : Card(
            margin: EdgeInsets.all(12),
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Confirm Booking Details:",
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .apply(color: Theme.of(context).accentColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _listOfferings(),
                    ),
                    Visibility(visible: addCharge, child: _buildAdjustment()),
                    Visibility(
                        visible: !addCharge,
                        child: Container(
                          height: 36,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                addCharge = true;
                              });
                            },
                            child: Text(
                              "+ Add Charge",
                            ),
                          ),
                        )),
                    Padding(
                      // Grand Total
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text("Grand Total: ",
                                style: Theme.of(context).textTheme.headline5),
                          ),
                          Container(
                            width: 80,
                            color: Colors.amberAccent,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "P " + order.grandTotal.toString(),
                                textAlign: TextAlign.right,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .apply(
                                        decoration: TextDecoration.underline,
                                        decorationStyle:
                                            TextDecorationStyle.double),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // save the updates
                            setState(() {
                              _isLoading = true;
                            });
                            order.updateProcessing(
                                offerings!,
                                chargeNameController.text,
                                chargeAmountController.text);
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text("Confirm Booking"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
