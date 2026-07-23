import 'package:cloud_firestore/cloud_firestore.dart';

import '../../sos/models/emergency_contact.dart';
import '../../sos/models/emergency_event.dart';
import 'firebase_service.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore =
      FirebaseService.instance.firestore;

  static const String usersCollection = 'users';
  static const String contactsCollection = 'emergency_contacts';
  static const String emergenciesCollection = 'emergency_history';

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _firestore.collection(usersCollection).doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(
      String uid,
      ) async {
    return await _firestore
        .collection(usersCollection)
        .doc(uid)
        .get();
  }

  Future<void> updateUser({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(usersCollection)
        .doc(uid)
        .update(data);
  }

  Future<void> deleteUser(
      String uid,
      ) async {
    await _firestore
        .collection(usersCollection)
        .doc(uid)
        .delete();
  }

  Future<void> addEmergencyContact({
    required String uid,
    required EmergencyContact contact,
  }) async {
    await _firestore
        .collection(usersCollection)
        .doc(uid)
        .collection(contactsCollection)
        .doc(contact.id)
        .set(contact.toMap());
  }

  Future<List<EmergencyContact>> getEmergencyContacts(
      String uid,
      ) async {
    final snapshot = await _firestore
        .collection(usersCollection)
        .doc(uid)
        .collection(contactsCollection)
        .get();

    return snapshot.docs
        .map(
          (doc) => EmergencyContact.fromMap(doc.data()),
    )
        .toList();
  }

  Future<void> updateEmergencyContact({
    required String uid,
    required EmergencyContact contact,
  }) async {
    await _firestore
        .collection(usersCollection)
        .doc(uid)
        .collection(contactsCollection)
        .doc(contact.id)
        .update(contact.toMap());
  }

  Future<void> deleteEmergencyContact({
    required String uid,
    required String contactId,
  }) async {
    await _firestore
        .collection(usersCollection)
        .doc(uid)
        .collection(contactsCollection)
        .doc(contactId)
        .delete();
  }

  Future<void> saveEmergencyEvent({
    required String uid,
    required EmergencyEvent event,
  }) async {
    await _firestore
        .collection(usersCollection)
        .doc(uid)
        .collection(emergenciesCollection)
        .doc(event.id)
        .set(event.toMap());
  }

  Future<List<EmergencyEvent>> getEmergencyHistory(
      String uid,
      ) async {
    final snapshot = await _firestore
        .collection(usersCollection)
        .doc(uid)
        .collection(emergenciesCollection)
        .orderBy('triggeredAt', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => EmergencyEvent.fromMap(doc.data()),
    )
        .toList();
  }

  Future<void> deleteEmergencyEvent({
    required String uid,
    required String eventId,
  }) async {
    await _firestore
        .collection(usersCollection)
        .doc(uid)
        .collection(emergenciesCollection)
        .doc(eventId)
        .delete();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(
      String uid,
      ) {
    return _firestore
        .collection(usersCollection)
        .doc(uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> contactsStream(
      String uid,
      ) {
    return _firestore
        .collection(usersCollection)
        .doc(uid)
        .collection(contactsCollection)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> emergencyHistoryStream(
      String uid,
      ) {
    return _firestore
        .collection(usersCollection)
        .doc(uid)
        .collection(emergenciesCollection)
        .orderBy('triggeredAt', descending: true)
        .snapshots();
  }
}