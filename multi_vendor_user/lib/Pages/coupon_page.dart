import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_vendor_user/Model/coupon.dart';

class CouponPage extends StatefulWidget {
  const CouponPage({Key? key}) : super(key: key);

  @override
  State<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  Stream<List<CouponModel>> getCoupons() {
    return FirebaseFirestore.instance
        .collection('Coupons')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CouponModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          titleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
          backgroundColor: Theme.of(context).colorScheme.background,
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'Coupons',
          ).tr()),
      body: StreamBuilder<List<CouponModel>>(
          stream: getCoupons(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: SpinKitCircle(color: Colors.orange),
              );
            } else {
              return snapshot.data?.isEmpty ?? true
                  ? Center(child: Image.asset('assets/image/coupon.jpg'))
                  : ListView.builder(
                      itemCount: snapshot.data!.length,
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext buildContext, int index) {
                        CouponModel couponModel = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CouponCard(
                            height: 300,
                            curvePosition: 180,
                            curveRadius: 30,
                            borderRadius: 10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple,
                                  Colors.purple.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            firstChild: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  couponModel.title!,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${couponModel.percentage}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'OFF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            secondChild: Container(
                              width: double.maxFinite,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.white),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 42),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                  ),
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(
                                    const EdgeInsets.symmetric(horizontal: 80),
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  FlutterClipboard.copy(couponModel.coupon)
                                      .then((value) {
                                    Fluttertoast.showToast(
                                        msg: "Coupon Code Copied".tr(),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.TOP,
                                        timeInSecForIosWeb: 1,

                                        fontSize: 14.0);
                                  });
                                },
                                child: const Text(
                                  'Copy Coupon Code',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
            }
          }),
    );
  }
}
