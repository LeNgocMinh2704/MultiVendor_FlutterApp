import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReferralSystem extends StatefulWidget {
  const ReferralSystem({Key? key}) : super(key: key);

  @override
  State<ReferralSystem> createState() => _ReferralSystemState();
}

class _ReferralSystemState extends State<ReferralSystem> {
  final _formKey = GlobalKey<FormState>();
  num referralAmount = 0;
  bool enableReferral = false;
  bool status = false;

  getReferralDetails() {
    FirebaseFirestore.instance
        .collection('Referral System')
        .doc('Referral System')
        .snapshots()
        .listen((value) {
      setState(() {
        if (mounted) {
          referralAmount = value['Referral Amount'];
          enableReferral = value['Status'];
        }
      });
    });
  }

  updateReferralStatus(bool status, num amount) {
    FirebaseFirestore.instance
        .collection('Referral System')
        .doc('Referral System')
        .set({
      'Status': status,
      'Referral Amount': referralAmount,
    });
  }

  @override
  void initState() {
    getReferralDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Referral System',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        CheckboxListTile(
          title: const Text('Enable Referral System'),
          value: enableReferral,
          onChanged: (bool? value) {
            setState(() {
              enableReferral = !enableReferral;
              updateReferralStatus(enableReferral, referralAmount);
            });
          },
        ),
        Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                        flex: 1,
                        child: Text('Referral reward amount:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ))),
                    Flexible(
                        flex: 4,
                        child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                referralAmount = int.parse(value);
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              hintText: referralAmount.toString(),
                              focusColor: Colors.grey,
                              filled: true,
                              fillColor: Colors.white10,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.grey, width: 1.0),
                              ),
                            )))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(10),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.blue.shade800,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.reset();
                      updateReferralStatus(enableReferral, referralAmount);
                      Fluttertoast.showToast(
                          msg: "Update completed",
                          backgroundColor: Colors.blue.shade800,
                          textColor: Colors.white);
                    }
                  },
                  child: const Text('Update', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 2,
        ),
      ],
    );
  }
}
