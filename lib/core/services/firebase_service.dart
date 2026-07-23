import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    try {
      await _requestNotificationPermission();
      await _initializeMessaging();
    } catch (e, stackTrace) {
      debugPrint('Firebase initialization error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _requestNotificationPermission() async {
    try {
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e) {
      debugPrint('Notification permission error: $e');
    }
  }

  Future<void> _initializeMessaging() async {
    try {
      final token = await messaging.getToken();

      debugPrint('Firebase Messaging Token: $token');

      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('Foreground Notification');
        debugPrint(message.notification?.title);
        debugPrint(message.notification?.body);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('Notification Opened');
      });
    } catch (e) {
      debugPrint('Messaging initialization error: $e');
    }
  }

  User? get currentUser => auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  Future<void> signOut() async {
    await auth.signOut();
  }
}