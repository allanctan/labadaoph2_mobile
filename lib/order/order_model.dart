import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/order/order_service.dart';

class OrderModel extends ChangeNotifier {
  Map<String, dynamic> data;
  bool notifyCustomer = true;
  String? scheduleDate;
  String? scheduleTime;
  int grandTotal = 0;
  OrdersService orderService = OrdersService();

  OrderModel(this.data);

  getCustomerName() {
    return data['firstname'] + ' ' + data['lastname'];
  }

  doSchedulePickup() {
    orderService.updateOrder({
      'pickupDate': scheduleDate,
      'pickupTime': scheduleTime,
      'status': 'for_pickup',
    }, data['docId']);
    orderService.addActivity(
        docId: data['docId'],
        activity: "Pickup scheduled: $scheduleDate $scheduleTime");
    Map<String, dynamic> tmpOrder = data;
    tmpOrder.addAll({
      'pickupDate': scheduleDate,
      'pickupTime': scheduleTime,
    });
    if (notifyCustomer) {
      orderService.sendEmail("for_pickup", tmpOrder);
      orderService.sendSMS("for_pickup", tmpOrder);
    }
  }

  doScheduleDelivery() {
    orderService.updateOrder({
      'deliveryDate': scheduleDate,
      'deliveryTime': scheduleTime,
      'status': 'for_delivery',
    }, data['docId']);
    orderService.addActivity(
        docId: data['docId'],
        activity: "Delivery scheduled: $scheduleDate $scheduleTime");
    Map<String, dynamic> tmpOrder = data;
    tmpOrder.addAll({
      'deliveryDate': scheduleDate,
      'deliveryTime': scheduleTime,
    });
    if (notifyCustomer) {
      orderService.sendEmail("for_delivery", tmpOrder);
      orderService.sendSMS("for_delivery", tmpOrder);
    }
  }

  pickupPhoto(Map<String, String> imageUrls) {
    List<String> urls = [];
    imageUrls.forEach((key, value) => urls.add(value));
    orderService.updateOrder({
      'imageUrls': urls,
      'status': 'in_process',
    }, data['docId']);
    orderService.addActivity(
        docId: data['docId'],
        activity:
            "Pickup done. " + imageUrls.length.toString() + " photo taken. ");
    Map<String, dynamic> tmpOrder = data;
    tmpOrder.addAll({
      'imageUrls': urls,
    });

    if (notifyCustomer) {
      orderService.sendEmail("in_process", tmpOrder);
      orderService.sendSMS("in_process", tmpOrder);
    }
  }

  updateProcessing(QuerySnapshot<Map<String, dynamic>> offerings,
      String customCharge, String customAmount) async {
    Map<String, String> updates = {};
    List orderItems = [];
    offerings.docs.forEach((offering) {
      String key = "d" + offering.data()['order'];
      updates[key] = data[key];
      int qty = int.tryParse(data[key] ?? "0") ?? 0;
      if (qty > 0) {
        num amount = qty * offering.data()['price'];
        var orderItem = {
          'qty': qty,
          'description': offering.data()['name'],
          'amount': amount
        };
        orderItems.add(orderItem);
      }
    });
    if (customAmount != "0") {
      orderItems.add(
          {'qty': "1", 'description': customCharge, 'amount': customAmount});
    }
    updates["customCharge"] = customCharge;
    updates["customAmount"] = customAmount;
    updates["grandTotal"] = grandTotal.toString();
    updates["status"] = "for_payment";
    orderService.updateOrder(updates, data['docId']);
    orderService.addActivity(
        docId: data['docId'], activity: "Now processing... ");
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await orderService.getPaymentDetails(data['modes_of_payment']);
    String paymentDetails = snapshot.docs.first.data()['description'];
    Map<String, dynamic> tmpOrder = data;
    tmpOrder.addAll({
      'orderItems': orderItems,
      'grandTotal': grandTotal.toString(),
      'payment_details': paymentDetails
    });
    if (notifyCustomer) {
      orderService.sendEmail("for_payment", tmpOrder);
    }
  }

  markAsPaid(String mode) {
    orderService.updateOrder({
      'paid_via': mode,
      'status': 'paid',
    }, data['docId']);
    orderService.addActivity(docId: data['docId'], activity: "Paid via $mode");
  }

  deliveryPhoto(Map<String, String> imageUrls) {
    List<String> urls = [];
    imageUrls.forEach((key, value) => urls.add(value));
    orderService.updateOrder({
      'deliverImageUrls': urls,
      'status': 'done',
    }, data['docId']);
    orderService.addActivity(
        docId: data['docId'],
        activity: "Laundry delivered! " +
            imageUrls.length.toString() +
            " photo taken. ");
  }

  delivered() {
    orderService.updateOrder({
      'status': 'done',
    }, data['docId']);
    orderService.addActivity(
        docId: data['docId'], activity: "Laundry delivered! ");
  }
}
