import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labadaph2_mobile/globals.dart' as globals;

class OrdersService {
  static DocumentReference _dbRef =
      FirebaseFirestore.instance.doc("stores/" + globals.tenantRef);

  Future<void> editOrder(Map<String, dynamic> tax, String docID) {
    return _dbRef.collection('orders').doc(docID).update(tax);
  }

  Future<void> archiveOrder(String docID) {
    return _dbRef
        .collection('orders')
        .doc(docID)
        .update({"status": "archived"});
  }

  Stream<QuerySnapshot> getOrdersStream(String status) {
    print("Retrieving orders with status:$status");
    return _dbRef
        .collection('orders')
        .where("status", isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }
}
