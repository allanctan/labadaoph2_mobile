import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:labadaph2_mobile/globals.dart' as globals;
import 'package:path/path.dart';

class UsersService {
  final _dbRef = FirebaseFirestore.instance;
  static String _keyword = "";

  Future<String> getUserTenantRef(String userRef) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _dbRef.doc(userRef).get();
    if (snapshot.data()!.isEmpty) return "";
    return snapshot.get('tenantId');
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getTenant() async {
    if (globals.tenantRef.isEmpty)
      return null;
    else
      return await _dbRef.doc(globals.tenantRef).get();
  }

  Future<Map<String, dynamic>?> getUser(String userRef) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _dbRef.doc(userRef).get();
      if (snapshot.data()!.isEmpty) return null;
      return snapshot.data();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> addUser(Map<String, dynamic> user) async {
    Map<String, dynamic> empty = {};
    DocumentReference newRef = await _dbRef.collection('User').add(empty);

    user.addAll({
      'createDate': DateTime.now(),
      'docId': newRef.id,
    });

    return newRef.set(user);
  }

  Future<void> editUser(Map<String, dynamic> user, String docID) {
    return _dbRef.collection('User').doc(docID).update(user);
  }

  Future<String> uploadImage(String name, String docId, File image) async {
    String pathName = '/profile/' +
        docId +
        '/' +
        name +
        '_' +
        basename(image.path).replaceAll("[\\W]|_", "");
    try {
      await FirebaseStorage.instance.ref(pathName).putFile(image);
      return await FirebaseStorage.instance.ref(pathName).getDownloadURL();
    } on FirebaseException catch (e) {
      print(e);
      return "";
    }
  }

  Future<String> uploadPhoto(String docId, File image) async {
    if (image != null) {
      String imageUrl = await this.uploadImage('', docId, image);
      _dbRef.collection('User').doc(docId).update({
        'profilePic': imageUrl,
      });
      return imageUrl;
    }
    return '';
  }

  Future<void> deleteUser(String docID) {
    return _dbRef.collection('User').doc(docID).delete();
  }

  Stream<QuerySnapshot> getUsers() {
    return _dbRef.collection('User').orderBy('firstName').snapshots();
  }

  var streamTransformer =
      StreamTransformer<QuerySnapshot, List<DocumentSnapshot>>.fromHandlers(
    handleData: (QuerySnapshot data, EventSink sink) {
      List<DocumentSnapshot> f = [];
      for (var e in data.docs) {
        String masterList = e.get('firstName') +
            ' ' +
            e.get('lastName') +
            ' ' +
            (e.get('email') != null ? e.get('email') : '') +
            ' ' +
            (e.get('mobile') != null
                ? e.get('mobile').replaceFirst('+639', '09')
                : '');
        List<String> words = masterList.toLowerCase().split(" ");
        if (_keyword.length == 0)
          f.add(e);
        else
          for (final word in words) {
            if (word.contains(_keyword)) {
              f.add(e);
              break;
            }
          }
      }
      sink.add(f);
    },
    handleError: (error, stacktrace, sink) {
      sink.addError('Something went wrong: $error');
    },
    handleDone: (sink) {
      print('transformer: done');
      sink.close();
    },
  );

  Stream<List<DocumentSnapshot>> searchUsers(
      {String role = 'All Roles', String keyword = ''}) {
    _keyword = keyword.toLowerCase();
    Stream<QuerySnapshot> results;

    if (role == 'All Roles') {
      results = _dbRef
          .collection('User')
          .where('tenantId', isEqualTo: globals.tenantRef)
          .orderBy('firstName')
          .snapshots();
    } else {
      results = _dbRef
          .collection('User')
          .orderBy('firstName')
          .where('tenantId', isEqualTo: globals.tenantRef)
          .where('userType', isEqualTo: role)
          .snapshots();
    }
    return results.transform(streamTransformer);
  }
}
