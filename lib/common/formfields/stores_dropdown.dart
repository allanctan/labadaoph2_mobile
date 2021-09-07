import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StoresDropdown extends StatelessWidget {
  final dropdownState = GlobalKey<FormFieldState>();
  final ValueChanged<String?> onChanged;

  StoresDropdown({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('stores').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(
                child: const CupertinoActivityIndicator(),
              );
            return new DropdownButtonFormField<String>(
              key: dropdownState,
              decoration: InputDecoration(
                icon: Icon(Icons.storefront),
                labelText: "Store",
                hintText: "Select One",
              ),
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
              onChanged: onChanged,
              items: [
                    DropdownMenuItem<String>(
                        value: '', child: Text('Select One'))
                  ] +
                  (snapshot.data!.docs.map((DocumentSnapshot document) {
                    return new DropdownMenuItem<String>(
                      value: document.id + ':' + document.get('name'),
                      child: Text(
                        document.get('name'),
                      ),
                    );
                  }).toList()),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please select a store.";
                }
                return null;
              },
            );
          },
        ),
      ],
    );
  }
}
