import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin_web/Models/vendors.dart';
import 'drawer.dart';

class Search extends StatefulWidget {
  final String? collectionName;

  const Search({
    Key? key,
    this.collectionName,
  }) : super(key: key);
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _searchController = TextEditingController();
  ListView? _listView;
  Future<QuerySnapshot>? openedMarket;

  Future<QuerySnapshot> _buildStreamOpenedMarket() {
    return FirebaseFirestore.instance.collection(widget.collectionName!).get();
  }

  DocumentReference? userRef;
  String fullname = 'Olivette Admin';
  String profilePic =
      'https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png';
  String email = 'admin123@gmail.com';
  @override
  void initState() {
    super.initState();
    openedMarket = _buildStreamOpenedMarket();
  }

  String displayName = '';

  getList(int itemList) {
    if (displayName == '') {
      return 0;
    } else {
      return itemList;
    }
  }

  _buildListItem(BuildContext context, VendorsSnapshot vendors, int i) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        height: 200,
        width: MediaQuery.of(context).size.width / 1.6,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  vendors.photoUrl == null || vendors.photoUrl == ''
                      ? SizedBox(
                          height: 150,
                          width: MediaQuery.of(context).size.width / 5,
                        )
                      : Image.network(
                          vendors.photoUrl!,
                          fit: BoxFit.fill,
                          height: 150,
                          width: MediaQuery.of(context).size.width / 5,
                        ),
                  const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        vendors.displayName!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width >= 1100
                                ? 23
                                : 14),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.width >= 1100 ? 10 : 3,
                      ),
                      Text(
                        vendors.email!,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width >= 1100
                                ? 14
                                : 8),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.width >= 1100 ? 10 : 3,
                      ),
                      Text(vendors.address!,
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width >= 1100
                                      ? 14
                                      : 8)),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.width >= 1100 ? 10 : 3,
                      ),
                      Row(
                        children: [
                          Text('Total ratings:',
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width >= 1100
                                          ? 14
                                          : 8)),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(vendors.totalrating.toString(),
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width >= 1100
                                          ? 14
                                          : 8)),
                        ],
                      ),
                      MediaQuery.of(context).size.width >= 1100
                          ? Container()
                          : Column(
                              children: [
                                const SizedBox(height: 20),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width >= 1100
                                          ? 20
                                          : 10,
                                ),
                                ElevatedButton(
                                    onPressed: () {},
                                    child: const Text('View Profile'))
                              ],
                            ),
                    ],
                  ),
                  MediaQuery.of(context).size.width >= 1100
                      ? const VerticalDivider(
                          color: Colors.grey,
                          thickness: 1,
                        )
                      : Container(),
                  MediaQuery.of(context).size.width >= 1100
                      ? Center(
                          child: ElevatedButton(
                              onPressed: () {},
                              child: const Text('View Profile')),
                        )
                      : Container()
                ],
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        elevation: 5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: IconButton(
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pushNamed('/notifications');
                },
                icon: const Icon(Icons.notifications_outlined)),
          ),
        ],
      ),
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (MediaQuery.of(context).size.width >= 1100)
              const Expanded(
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: Card(
                elevation: 12,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      actions: const [],
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.white12,
                      expandedHeight: 150,
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        centerTitle: true,
                        background: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const SizedBox(
                                            height: 60,
                                            child: Icon(Icons.close))),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: SizedBox(
                                  height: 50,
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          displayName = value.toLowerCase();
                                        });
                                      },
                                      controller: _searchController,
                                      autofocus: true,
                                      style:
                                          const TextStyle(color: Colors.grey),
                                      decoration: InputDecoration(
                                        focusColor: Colors.grey,
                                        hintText: 'search for markets',
                                        hintStyle:
                                            const TextStyle(color: Colors.grey),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          size: 30,
                                          color: Colors.blue.shade800,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white10,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.grey, width: 1.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: Colors.grey, width: 1.0),
                                        ),
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverFillRemaining(
                        child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Search Results',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        FutureBuilder<QuerySnapshot>(
                            future: openedMarket,
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                List<VendorsSnapshot> itemList = [];
                                var allopenedMarkets = snapshot.data.docs;
                                for (var i = 0;
                                    i < allopenedMarkets.length;
                                    i++) {
                                  var documentSnapshot = allopenedMarkets[i];
                                  VendorsSnapshot item =
                                      VendorsSnapshot.fromSnapshot(
                                          documentSnapshot);
                                  if (item.displayName!
                                      .toLowerCase()
                                      .contains(displayName)) {
                                    itemList.add(item);
                                  }
                                }
                                _listView = ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: getList(itemList.length),
                                  itemBuilder: (context, i) =>
                                      _buildListItem(context, itemList[i], i),
                                );
                                return _listView!;
                              } else {
                                return Column(
                                  children: const [
                                    Text('Loading please wait...'),
                                  ],
                                );
                              }
                            })
                      ],
                    ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
