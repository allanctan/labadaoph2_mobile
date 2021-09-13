import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/globals.dart' as globals;

class TimeDropdown extends StatelessWidget {
  TimeDropdown(
      {required this.onChanged, required this.value, this.isRequired = true});
  final ValueChanged<String?>? onChanged;
  final bool isRequired;
  final String value;

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .doc('stores/' + globals.tenantRef)
          .collection('timeslots')
          .orderBy('order')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(
            child: const CupertinoActivityIndicator(),
          );
        String initialTime = this.value;
        if (this.value == "am") {
          initialTime = snapshot.data!.docs.first['slot'];
          onChanged!(initialTime);
        } else if (this.value == "pm") {
          initialTime = snapshot.data!.docs
              .elementAt((snapshot.data!.size / 2).floor())['slot'];
          onChanged!(initialTime);
        }
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            icon: Icon(Icons.schedule),
            labelText: "Time",
            hintText: "Select One",
          ),
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.black, fontSize: 16),
          onChanged: onChanged,
          value: initialTime,
          items: snapshot.data!.docs.map((DocumentSnapshot document) {
            return new DropdownMenuItem<String>(
              value: document.get('slot'),
              child: Text(document.get('slot')),
            );
          }).toList(),
          validator: (value) {
            if (value == null) {
              return "Please choose a time.";
            }
            return null;
          },
        );
      },
    );
  }
}
