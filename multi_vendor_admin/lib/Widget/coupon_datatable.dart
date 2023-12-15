import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:admin_web/Models/coupon.dart';
import 'package:random_string/random_string.dart';

class CouponData extends StatefulWidget {
  const CouponData({Key? key}) : super(key: key);

  @override
  State<CouponData> createState() => _CouponDataState();
}

class _CouponDataState extends State<CouponData> {
  bool isLoaded = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  final bool _sortAscending = true;

  Stream<QuerySnapshot>? yourStream;
  @override
  void initState() {
    yourStream = FirebaseFirestore.instance.collection('Coupons').snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<CouponModel> vendor;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<QuerySnapshot>(
          stream: yourStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            vendor = snapshot.data!.docs
                .map((e) => CouponModel.fromMap(e.data(), e.id))
                .toList();
            var vendorData = VendorDataSource(vendor, context);
            if (snapshot.hasData) {
              return ListView(
                shrinkWrap: true,
                children: [
                  PaginatedDataTable(
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Coupons'),
                        ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const AlertDialog(
                                      title: Text('Generate Coupon'),
                                      content: SizedBox(
                                        height: 500,
                                        width: 400,
                                        child: GenerateCoupon(),
                                      ),
                                    );
                                  });
                            },
                            child: const Text('Create A Coupon'))
                      ],
                    ),
                    rowsPerPage: _rowsPerPage,
                    onRowsPerPageChanged: (int? value) {
                      setState(() {
                        _rowsPerPage = value!;
                      });
                    },
                    source: vendorData,
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text('Index'),
                      ),
                      DataColumn(
                        label: Text('Title'),
                      ),
                      DataColumn(
                        label: Text('Coupon'),
                      ),
                      DataColumn(
                        label: Text('Time Created'),
                      ),
                      DataColumn(
                        label: Text('Percentage %'),
                      ),
                      DataColumn(
                        label: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Container();
            }
          }),
    );
  }
}

int numberOfdelivery = 0;

List<int> categoriesAmount = [];

class VendorDataSource extends DataTableSource {
  final List<CouponModel> vendor;
  VendorDataSource(this.vendor, this.context);
  final BuildContext context;
  final int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= vendor.length) return null;
    final CouponModel result = vendor[index];
    return DataRow.byIndex(index: index, cells: <DataCell>[
      DataCell(Text('${index + 1}')),
      DataCell(Text(result.title)),
      DataCell(Text(result.coupon)),
      DataCell(Text('${result.timeCreated}')),
      DataCell(Text('${result.percentage}%')),
      DataCell(InkWell(
          onTap: () {
            FirebaseFirestore.instance
                .collection('Coupons')
                .doc(result.uid)
                .delete();
          },
          child: const Text('Delete Coupon'))),
    ]);
  }

  @override
  int get rowCount => vendor.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class GenerateCoupon extends StatefulWidget {
  const GenerateCoupon({Key? key}) : super(key: key);

  @override
  State<GenerateCoupon> createState() => _GenerateCouponState();
}

class _GenerateCouponState extends State<GenerateCoupon> {
  String coupon = '';
  num percentage = 0;
  String title = '';

  generateCoupon() {
    setState(() {
      coupon = randomAlphaNumeric(10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextFormField(
            //  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.name,
            onChanged: (v) {
              setState(() {
                title = v;
              });
            },
            decoration: const InputDecoration(hintText: 'Enter title'),
          ),
          const SizedBox(height: 20),
          TextFormField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            onChanged: (v) {
              setState(() {
                percentage = int.parse(v);
              });
            },
            decoration: const InputDecoration(hintText: 'Enter Percentage'),
          ),
          const SizedBox(height: 20),
          Text('Coupon Code: $coupon'),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                generateCoupon();
              },
              child: const Text('Generate Coupon')),
          const SizedBox(height: 40),
          ElevatedButton(
              onPressed: () {
                if (coupon == '' || percentage == 0 || title == '') {
                  Fluttertoast.showToast(
                      msg: "All fields are required",
                      backgroundColor: Colors.blue.shade800,
                      textColor: Colors.white);
                } else {
                  FirebaseFirestore.instance.collection('Coupons').add({
                    'title': title,
                    'percentage': percentage,
                    'coupon': coupon,
                    'timeCreated': DateFormat.yMMMMEEEEd()
                        .format(DateTime.now())
                        .toString(),
                  }).then((value) {
                    Modular.to.pop();
                    Fluttertoast.showToast(
                        msg: "Coupon Successfully Created",
                        backgroundColor: Colors.blue.shade800,
                        textColor: Colors.white);
                  });
                }
              },
              child: const Text('Upload Coupon'))
        ],
      ),
    );
  }
}
