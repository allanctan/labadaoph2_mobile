import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:labadaph2_mobile/globals.dart' as globals;

class OrdersService {
  static DocumentReference<Map<String, dynamic>> _dbRef =
      FirebaseFirestore.instance.doc("stores/" + globals.tenantRef);

  static Map<String, dynamic>? notification;

  Future<void> updateOrder(Map<String, dynamic> order, String docId) {
    return _dbRef.collection('orders').doc(docId).update(order);
  }

  Future<void> addActivity({required String docId, required String activity}) {
    return _dbRef
        .collection('orders')
        .doc(docId)
        .collection("activity")
        .add({'updatedAt': DateTime.now(), 'activity': activity});
  }

  Future<void> archiveOrder(String docID) {
    return _dbRef
        .collection('orders')
        .doc(docID)
        .update({"status": "archived"});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getOrdersStream(String status) {
    print("Retrieving orders with status:$status");
    return _dbRef
        .collection('orders')
        .where("status", isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getOfferings() {
    print("Retrieving offerings");
    return _dbRef.collection('offerings').orderBy('order').get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getModesofPayment() {
    print("Retrieving modes of payment");
    return _dbRef.collection('modes_of_payment').orderBy('order').get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPaymentDetails(String mode) {
    print("Retrieving modes of payment :" + mode);
    return _dbRef
        .collection('modes_of_payment')
        .where('name', isEqualTo: mode)
        .get();
  }

  Future<void> sendEmail(String template, Map<String, dynamic> order) async {
    DocumentSnapshot<Map<String, dynamic>> notif =
        await _dbRef.collection('notifications').doc(template).get();
    String bcc = "support@labada.ph," + order["store_email"];
    if (notif.exists) if (notif.data()?['email']?.isNotEmpty ?? false)
      bcc = bcc + "," + notif.data()!['email']!;
    FirebaseFirestore.instance.collection("mail").add({
      "bcc": bcc,
      "template": {"data": order, "name": template},
      "to": order["email"]
    });
  }

  String buildSMSMessage(String template, Map<String, dynamic> order) {
    if (template == "for_pickup")
      return "Hi " +
          order['firstname'] +
          ", Your laundry pickup is scheduled " +
          order['pickupDate'] +
          ", " +
          order['pickupTime'] +
          ". Thank you. " +
          order['store_name'];
    else if (template == "for_delivery")
      return "Hi " +
          order['firstname'] +
          ", Your laundry is ready. Delivery is scheduled " +
          order['pickupDate'] +
          ", " +
          order['pickupTime'] +
          ". Thank you. " +
          order['store_name'];
    else if (template == "in_process")
      return "Hi " +
          order['firstname'] +
          ", Your laundry is received. Please check " +
          order['order_page_url'] +
          " for your reference. Thank you. " +
          order['store_name'];
    return "";
  }

  Future<void> sendSMS(String template, Map<String, dynamic> order) async {
    DocumentSnapshot<Map<String, dynamic>> store = await _dbRef.get();
    String apiKey = "";
    String senderName = "";
    if (store.exists) {
      apiKey = store.data()?['semaphore_apikey'] ?? "";
      senderName = store.data()?['semaphore_name'] ?? "";
      String longUrl = (store.data()?['order_page_url'] ?? "") +
          "?sid=" +
          store.id +
          "&oid=" +
          (order['docId'] ?? "");
      var url = Uri.parse('https://api-ssl.bitly.com/v4/shorten');

      http.Response response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader:
              '429f9f71034ba3601d11153742ae7a08725c2df2',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: jsonEncode(
          {
            "long_url": longUrl,
            "domain": "bit.ly",
            "group_guid": "Bla189FHnz7"
          },
        ),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode < 300) {
        order.putIfAbsent(
            'order_page_url', () => jsonDecode(response.body)['link']);
      } else {
        print('Not sending SMS due to bitly link.');
      }
    }

    if (apiKey.isNotEmpty) {
      DocumentSnapshot<Map<String, dynamic>> notif =
          await _dbRef.collection('notifications').doc(template).get();
      var url = Uri.parse('https://api.semaphore.co/api/v4/messages');
      String numbers = order["mobileno"];
      if (notif.exists) if (notif.data()?['mobile']?.isNotEmpty ?? false)
        numbers = numbers + "," + notif.data()!['mobile']!;
      String message = buildSMSMessage(template, order);
      var response = await http.post(url, body: {
        'apikey': apiKey,
        'sendername': senderName,
        'number': numbers,
        'message': message
      });
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}
