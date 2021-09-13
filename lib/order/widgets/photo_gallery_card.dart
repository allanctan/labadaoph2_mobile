import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/loading.dart';
import 'package:labadaph2_mobile/common/photo_upload_gallery.dart';
import 'package:labadaph2_mobile/globals.dart' as globals;
import 'package:provider/provider.dart';

import '../order_model.dart';

class PhotoGalleryCard extends StatefulWidget {
  final String pickupMode;

  PhotoGalleryCard({required this.pickupMode});
  @override
  State<StatefulWidget> createState() => new _PhotoGalleryCardState(pickupMode);
}

class _PhotoGalleryCardState extends State<PhotoGalleryCard> {
  final _formKey = GlobalKey<FormState>();
  final String pickupMode;
  Map<String, String> imageUrls = {};

  bool _isLoading = false;
  _PhotoGalleryCardState(this.pickupMode);

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
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Consumer<OrderModel>(
                  builder: (context, order, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Take Photos for $pickupMode:",
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .apply(color: Theme.of(context).accentColor)),
                      SizedBox(height: 8),
                      PhotoUploadGallery(
                        prefix:
                            globals.tenantRef + '/' + order.getCustomerName(),
                        takePhotoOnInit: true,
                        onUpload: (value) => imageUrls = value,
                      ),
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
                              // make sure photos are uploaded
                              setState(() {
                                _isLoading = true;
                              });
                              bool complete = true;
                              imageUrls.forEach((key, value) =>
                                  (value.isEmpty) ? complete = false : null);

                              if (!complete) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        'Photo has not yet been uploaded. Please wait.')));
                                setState(() {
                                  _isLoading = false;
                                });
                              } else {
                                if (this.pickupMode == 'Pickup')
                                  order.pickupPhoto(imageUrls);
                                else
                                  order.deliveryPhoto(imageUrls);
                                setState(() {
                                  _isLoading = false;
                                });
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          child: Text("Proceed"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
