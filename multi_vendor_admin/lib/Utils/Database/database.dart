import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:admin_web/Models/slider.dart';
import 'package:admin_web/Models/user.dart';

class SliderImage1 with ChangeNotifier {
  // collection reference Slider
  final CollectionReference slider =
      FirebaseFirestore.instance.collection('Slider');

  // Add Slider
  Future<void> addSlider(SliderImage sliderImage, String id) async {
    notifyListeners();
    await slider.doc(id).set(sliderImage.toMap());
  }

  // Fetch Slider

  Future<List<SliderImage>> getSlider() {
    return slider.get().then((snapshot) => snapshot.docs
        .map((doc) => SliderImage.fromMap(doc.data(), doc.id))
        .toList());
  }
}

class PaymentClass {
  final CollectionReference paymentSystem =
      FirebaseFirestore.instance.collection('Payment System');

  final CollectionReference paymentDetail =
      FirebaseFirestore.instance.collection('Payment System Details');

  Future<void> updateStripe(String publishableKey, String secretKey) async {
    await paymentDetail
        .doc('Stripe')
        .set({'Publishable key': publishableKey, 'Secret Key': secretKey});
  }

  Future<void> updatePaystack(String publicKey, String backendUrl) async {
    await paymentDetail
        .doc('Paystack')
        .set({'Public key': publicKey, 'banckendUrl': backendUrl});
  }

  Future<void> updateFlutterwave(String publicKey, String encryptionKey) async {
    await paymentDetail
        .doc('Flutterwave')
        .set({'Public key': publicKey, 'Encryption Key': encryptionKey});
  }

  Future<void> enableStripe(bool enableStripe) async {
    await paymentSystem.doc('Stripe').set({'Stripe': enableStripe});
  }

  Future<void> enableCashondelivery(bool enableCashondelivery) async {
    await paymentSystem
        .doc('Cash on delivery')
        .set({'Cash on delivery': enableCashondelivery});
  }

  Future<void> enableFlutterwave(bool enableFlutterwave) async {
    await paymentSystem
        .doc('Flutterwave')
        .set({'Flutterwave': enableFlutterwave});
  }

  Future<void> enablePaystack(bool enablePaystack) async {
    await paymentSystem.doc('Paystack').set({'Paystack': enablePaystack});
  }
}

class Clients {
  //Get Client Details

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference vendors =
      FirebaseFirestore.instance.collection('vendors');

  final CollectionReference deliveryBoy =
      FirebaseFirestore.instance.collection('delivery boy');
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('Orders');

  Future<List<UserModel>> getAllUsers() {
    return users.get().then((snapshot) =>
        snapshot.docs.map((e) => UserModel.fromMap(e.data(), e.id)).toList());
  }

  Future<List<UserModel>> getAllApprovedVendors() {
    return vendors.where('Approval', isEqualTo: true).get().then((snapshot) =>
        snapshot.docs.map((e) => UserModel.fromMap(e.data(), e.id)).toList());
  }

  Future<List<UserModel>> getAllUnApprovedVendors() {
    return vendors.where('Approval', isEqualTo: false).get().then((snapshot) =>
        snapshot.docs.map((e) => UserModel.fromMap(e.data(), e.id)).toList());
  }

  Future<List<UserModel>> getAllApprovedDeliveryBoy() {
    return deliveryBoy.where('Approval', isEqualTo: true).get().then(
        (snapshot) => snapshot.docs
            .map((e) => UserModel.fromMap(e.data(), e.id))
            .toList());
  }

  Future<List<UserModel>> getAllUnApprovedDeliveryBoy() {
    return deliveryBoy.where('Approval', isEqualTo: false).get().then(
        (snapshot) => snapshot.docs
            .map((e) => UserModel.fromMap(e.data(), e.id))
            .toList());
  }

  Future<List<UserModel>> deliveryBoyNumberOfOrders(String deliveryBoyId) {
    return FirebaseFirestore.instance
        .collection('Orders')
        .where('deliveryBoyId', isEqualTo: deliveryBoyId)
        .get()
        .then((snapshot) => snapshot.docs
            .map((e) => UserModel.fromMap(e.data(), e.id))
            .toList());
  }

  Future<List<UserModel>> vendorNumberOfOrders(String deliveryBoyId) {
    return FirebaseFirestore.instance
        .collection('Orders')
        .where('vendorsID', isEqualTo: deliveryBoyId)
        .get()
        .then((snapshot) => snapshot.docs
            .map((e) => UserModel.fromMap(e.data(), e.id))
            .toList());
  }

  Future<List<UserModel>> userNumberOfOrders(String deliveryBoyId) {
    return FirebaseFirestore.instance
        .collection('Orders')
        .where('userID', isEqualTo: deliveryBoyId)
        .get()
        .then((snapshot) => snapshot.docs
            .map((e) => UserModel.fromMap(e.data(), e.id))
            .toList());
  }
}
