import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin_web/Models/cashout.dart';
import 'package:admin_web/Models/history.dart';

class CompletedPayoutData extends StatefulWidget {
  const CompletedPayoutData({Key? key}) : super(key: key);

  @override
  State<CompletedPayoutData> createState() => _CompletedPayoutDataState();
}

class _CompletedPayoutDataState extends State<CompletedPayoutData> {
  bool isLoaded = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  final bool _sortAscending = true;

  String deliveryBoyID = '';

  String currencyName = '';
  String currencyCode = '';
  String currencySymbol = '';
  String getcurrencyName = '';
  String getcurrencyCode = '';
  String getcurrencySymbol = '';

  getCurrencyDetails() {
    FirebaseFirestore.instance
        .collection('Currency Settings')
        .doc('Currency Settings')
        .get()
        .then((value) {
      setState(() {
        getcurrencyName = value['Currency name'];
        getcurrencyCode = value['Currency code'];
        getcurrencySymbol = value['Currency symbol'];
      });
    });
  }

  @override
  void initState() {
    getCurrencyDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<CashOutModel> deliveryBoy;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('Cash out')
              .where('paid', isEqualTo: true)
              .get(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            deliveryBoy = snapshot.data!.docs
                .map((e) => CashOutModel.fromMap(e.data(), e.id))
                .toList();
            var deliveryBoyData =
                DeliveryBoyDataSource(deliveryBoy, getcurrencySymbol, context);
            return ListView(
              shrinkWrap: true,
              children: [
                PaginatedDataTable(
                    showCheckboxColumn: false,
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Payout request'),
                      ],
                    ),
                    rowsPerPage: _rowsPerPage,
                    onRowsPerPageChanged: (int? value) {
                      setState(() {
                        _rowsPerPage = value!;
                      });
                    },
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text('Time'),
                      ),
                      DataColumn(
                        label: Text('User status'),
                      ),
                      DataColumn(
                        label: Text('User name'),
                      ),
                      DataColumn(
                        label: Text('Amount'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('Vendor bank details'),
                        numeric: true,
                      ),
                    ],
                    source: deliveryBoyData),
              ],
            );
          }),
    );
  }
}

int numberOfdelivery = 0;

List<int> deliveryBoyAmount = [];

class DeliveryBoyDataSource extends DataTableSource {
  final BuildContext context;
  final List<CashOutModel> deliveryBoy;
  final String getcurrencySymbol;
  DeliveryBoyDataSource(this.deliveryBoy, this.getcurrencySymbol, this.context);

  final int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= deliveryBoy.length) return null;
    final CashOutModel result = deliveryBoy[index];
    return DataRow.byIndex(index: index, cells: <DataCell>[
      DataCell(Text(result.timeCreated)),
      DataCell(Text(result.status)),
      DataCell(Text(result.vendorsName)),
      DataCell(Text('$getcurrencySymbol${result.amount}')),
      DataCell(ElevatedButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(10),
          backgroundColor: MaterialStateProperty.all<Color>(
            Colors.blue.shade800,
          ),
        ),
        child: const Text('Bank detail', style: TextStyle(color: Colors.white)),
        onPressed: () {
          showDialog(
              context: context,
              builder: (builder) {
                return AlertDialog(
                    content: Bankdetail(
                  cashOutModel: result,
                ));
              });
        },
      )),
    ]);
  }

  @override
  int get rowCount => deliveryBoy.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class Bankdetail extends StatefulWidget {
  final CashOutModel cashOutModel;

  const Bankdetail({Key? key, required this.cashOutModel}) : super(key: key);
  @override
  State<Bankdetail> createState() => _BankdetailState();
}

class _BankdetailState extends State<Bankdetail> {
  String accountName = '';
  String accountNumber = '';
  String bankName = '';

  getUserStatus() {
    if (widget.cashOutModel.status == 'Vendor') {
      return 'vendors';
    } else {
      return 'drivers';
    }
  }

  updateHistory(HistoryModel historyModel) {
    FirebaseFirestore.instance
        .collection(getUserStatus())
        .doc(widget.cashOutModel.vendorID)
        .collection('History')
        .add(historyModel.toMap());
  }

  String currencySymbol = '';
  String getcurrencyName = '';
  String getcurrencyCode = '';
  String getcurrencySymbol = '';

  getCurrencyDetails() {
    FirebaseFirestore.instance
        .collection('Currency Settings')
        .doc('Currency Settings')
        .get()
        .then((value) {
      setState(() {
        getcurrencyName = value['Currency name'];
        getcurrencyCode = value['Currency code'];
        getcurrencySymbol = value['Currency symbol'];
      });
    });
  }

  @override
  void initState() {
    getCurrencyDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Account name'),
          Text(widget.cashOutModel.accountName),
          const SizedBox(height: 20),
          const Text('Account number'),
          Text(widget.cashOutModel.accountNumber.toString()),
          const SizedBox(height: 20),
          const Text('Bank name'),
          Text(widget.cashOutModel.bankName),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(10),
              backgroundColor: MaterialStateProperty.all<Color>(
                Colors.blue.shade800,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Back'),
          )
        ],
      ),
    );
  }
}
