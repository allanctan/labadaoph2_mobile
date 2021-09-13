import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import '../order_model.dart';

class CustomerCard extends StatefulWidget {
  final OrderModel order;
  final bool expanded;

  CustomerCard(this.order, {this.expanded = false});

  @override
  _CustomerCardState createState() => _CustomerCardState(order, expanded);
}

class _CustomerCardState extends State<CustomerCard> {
  final OrderModel order;
  bool expanded;

  _CustomerCardState(this.order, this.expanded);

  String _buildCustomerDetails() {
    return "Name: " +
        order.data['firstname'] +
        " " +
        order.data['lastname'] +
        "\n" +
        "Phone: " +
        order.data['mobileno'] +
        "\n" +
        "Email: " +
        order.data['email'] +
        "\n" +
        "Address: " +
        order.data['labada_pin_address'] +
        " (" +
        order.data['location_details'] +
        ")";
  }

  @override
  Widget build(BuildContext context) {
    String address = order.data['labada_pin_address'];
    if (order.data['location_details'].isNotEmpty)
      address = address + "\n" + order.data['location_details'];
    print('render CustomerCard');
    return Card(
      margin: EdgeInsets.all(12),
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      Clipboard.setData(
                              new ClipboardData(text: _buildCustomerDetails()))
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied to Clipboard.')),
                        );
                      });
                    },
                    child: Text("Copy Details")),
                TextButton(onPressed: () => {}, child: Text("Call")),
                TextButton(onPressed: () => {}, child: Text("SMS")),
                TextButton(onPressed: () => {}, child: Text("Email"))
              ],
            ),
            Divider(
              thickness: 2,
              height: 2,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.person,
                    color: Colors.black54,
                  ),
                ),
                Text(order.data['firstname'] + " " + order.data["lastname"],
                    style: Theme.of(context).textTheme.headline4),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      expanded = !expanded;
                    });
                  },
                  icon: Icon(expanded?Icons.arrow_drop_up:Icons.arrow_drop_down),
                ),
              ],
            ),
            Visibility(
              visible: expanded,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.home,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 8),
                    Expanded(child: Text(address)),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: expanded,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 8),
                    Text(order.data['mobileno']),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: expanded,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 8),
                    Text(order.data['email']),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: expanded,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.shopping_cart,
                      color: Colors.black54,
                    ),
                  ),
                  Expanded(child: Html(data: order.data['order_details'])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
