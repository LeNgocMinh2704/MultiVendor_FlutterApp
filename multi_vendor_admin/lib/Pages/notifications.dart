import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin_web/Models/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widget/islogged_widget.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  DocumentReference? userRef;
  String fullname = 'Olivette Admin';
  String profilePic =
      'https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png';
  String email = 'admin123@gmail.com';

  @override
  void initState() {
    getFirebaseDetails();
    yourStream = FirebaseFirestore.instance
        .collection('Notifications')
        .get()
        .then((event) => event.docs
            .map((e) => NotificationsModel.fromMap(e.data(), e.id))
            .toList());
    super.initState();
  }

  Future<List<NotificationsModel>>? yourStream;

  String adminImage = '';
  String oldPassword = '';
  String adminUsername = '';
  getFirebaseDetails() {
    FirebaseFirestore.instance
        .collection('Admin')
        .doc('Admin')
        .get()
        .then((value) {
      setState(() {
        adminImage = value['ProfilePic'];
        oldPassword = value['password'];
        adminUsername = value['username'];
      });
    });
  }

  bool? loggedIn;

  getSelectedRoute() {
    SharedPreferences.getInstance().then((prefs) {
      var log = prefs.getBool('logged in');
      setState(() {
        loggedIn = log!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getSelectedRoute();
    return loggedIn == false || loggedIn == null
        ? const IsLoggedWidget()
        : Scaffold(
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(
                                      Icons.notifications,
                                      size: 30,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Notifications',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.start,
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ]),
                        ),
                        const SizedBox(height: 20),
                        FutureBuilder<List<NotificationsModel>>(
                            future: yourStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data!.isEmpty
                                    ? Center(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.notifications,
                                              color: Colors.grey,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  3,
                                            ),
                                            const SizedBox(height: 40),
                                            const Text("Notification is Empty",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, int index) {
                                          NotificationsModel
                                              notificationsModel =
                                              snapshot.data![index];
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              height: 100,
                                              child: Card(
                                                child: ListTile(
                                                  trailing: InkWell(
                                                      onTap: () {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Notifications')
                                                            .doc(
                                                                notificationsModel
                                                                    .uid)
                                                            .delete()
                                                            .then((value) {});
                                                      },
                                                      child: const Icon(
                                                          Icons.delete)),
                                                  title: notificationsModel
                                                              // ignore: unnecessary_null_comparison
                                                              .heading ==
                                                          null
                                                      ? const Text('')
                                                      : Text(
                                                          notificationsModel
                                                              .heading,
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors.blue
                                                                  .shade800)),
                                                  subtitle: notificationsModel
                                                              // ignore: unnecessary_null_comparison
                                                              .content ==
                                                          null
                                                      ? const Text('')
                                                      : SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              1.3,
                                                          child: Text(
                                                              notificationsModel
                                                                  .content,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                  leading: const Icon(
                                                    Icons.notifications,
                                                    size: 50,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                              } else {
                                return Container();
                              }
                            })
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
