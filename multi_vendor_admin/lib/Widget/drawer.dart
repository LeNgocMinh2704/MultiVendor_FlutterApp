import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hovering/hovering.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  DocumentReference? userRef;
  String fullname = 'Olivete Admin';
  bool profileExpansionTile = false;
  bool userExpansionTile = false;
  bool payoutExpansionTile = false;
  bool courierExpansionTile = false;
  bool categoryExpansionTile = false;
  String routeName = 'home';
  String expansionTileName = '';

  String profilePic =
      'https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png'
          .tr();

  @override
  void initState() {
    getFirebaseDetails();
    super.initState();
  }

  getSelectedRoute() {
    SharedPreferences.getInstance().then((prefs) {
      var route = prefs.getString('route-name');
      setState(() {
        routeName = route!;
      });
    });
  }

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

  @override
  Widget build(BuildContext context) {
    getSelectedRoute();
    return Drawer(
      elevation: 5,
      child: Container(
        color: Colors.blue.shade800,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Divider(
                color: Colors.grey[100],
                thickness: 1,
              ),
              CircleAvatar(
                radius: 40.0,
                backgroundImage: NetworkImage(adminImage),
                backgroundColor: Colors.transparent,
              ),
              HoverAnimatedContainer(
                hoverColor: Colors.blue,
                child: ExpansionTile(
                  collapsedIconColor: Colors.white,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  initiallyExpanded: true,
                  onExpansionChanged: (value) {
                    //print(value);
                    setState(() {
                      profileExpansionTile = !profileExpansionTile;
                    });
                  },
                  title: Text(
                    fullname,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    adminUsername,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  children: <Widget>[
                    HoverAnimatedContainer(
                      hoverColor: Colors.grey,
                      child: Container(
                        color: routeName == 'profile' ? Colors.grey : null,
                        child: ListTile(
                            onTap: () async {
                              Modular.to.navigate(
                                '/profile',
                              );
                              setState(() {
                                profileExpansionTile = true;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString('route-name', 'profile');
                            },
                            title: const Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ).tr(),
                            leading: const Icon(
                              Icons.people,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    HoverAnimatedContainer(
                      hoverColor: Colors.grey,
                      child: Container(
                        color: routeName == 'coupon' ? Colors.grey : null,
                        child: ListTile(
                            onTap: () async {
                              Modular.to.navigate('/coupon');
                              setState(() {
                                profileExpansionTile = true;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString('route-name', 'coupon');
                            },
                            title: const Text(
                              'Coupon',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ).tr(),
                            leading: const Icon(Icons.card_giftcard,
                                color: Colors.white)),
                      ),
                    ),
                    HoverAnimatedContainer(
                      hoverColor: Colors.grey,
                      child: Container(
                        color: routeName == 'app-settings' ? Colors.grey : null,
                        child: ListTile(
                            onTap: () async {
                              Modular.to.navigate(
                                '/settings',
                              );
                              setState(() {
                                profileExpansionTile = true;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString('route-name', 'app-settings');
                            },
                            title: const Text(
                              'App Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ).tr(),
                            leading: const Icon(Icons.settings,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey[100],
                thickness: 1,
              ),
              HoverAnimatedContainer(
                hoverColor: Colors.grey,
                child: Container(
                  color: routeName == 'home' ? Colors.grey : null,
                  child: ListTile(
                    onTap: () async {
                      Modular.to.navigate(
                        '/home',
                      );

                      var prefs = await SharedPreferences.getInstance();
                      prefs.setString('route-name', 'home');
                    },
                    title: const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ).tr(),
                    leading: const Icon(Icons.dashboard, color: Colors.white),
                  ),
                ),
              ),
              HoverAnimatedContainer(
                hoverColor: Colors.blue,
                child: ExpansionTile(
                  collapsedIconColor: Colors.white,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  initiallyExpanded: categoryExpansionTile,
                  onExpansionChanged: (value) {
                    //print(value);
                    setState(() {
                      categoryExpansionTile = !categoryExpansionTile;
                    });
                  },
                  title: const Text(
                    'Categories settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ).tr(),
                  leading: const Icon(Icons.category, color: Colors.white),
                  children: <Widget>[
                    HoverAnimatedContainer(
                      hoverColor: Colors.grey,
                      child: Container(
                        color: routeName == 'categories' ? Colors.grey : null,
                        child: ListTile(
                            onTap: () async {
                              Modular.to.navigate(
                                '/categories',
                              );
                              setState(() {
                                categoryExpansionTile = true;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString('route-name', 'categories');
                            },
                            title: const Text(
                              'Categories',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ).tr(),
                            leading: const Icon(Icons.category,
                                color: Colors.white)),
                      ),
                    ),
                    HoverAnimatedContainer(
                      hoverColor: Colors.grey,
                      child: Container(
                        color:
                            routeName == 'sub-categories' ? Colors.grey : null,
                        child: ListTile(
                            onTap: () async {
                              Modular.to.navigate(
                                '/sub-categories',
                              );
                              setState(() {
                                categoryExpansionTile = true;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString('route-name', 'sub-categories');
                            },
                            title: const Text(
                              'Sub categories',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ).tr(),
                            leading: const Icon(Icons.category,
                                color: Colors.white)),
                      ),
                    ),
                    // HoverAnimatedContainer(
                    //   hoverColor: Colors.grey,
                    //   child: Container(
                    //     color: routeName == "sub-categories-collections"
                    //         ? Colors.grey
                    //         : null,
                    //     child: ListTile(
                    //         onTap: () async {
                    //           Modular.to.navigate(
                    //             '/sub-categories-collections',
                    //           );
                    //           setState(() {
                    //             categoryExpansionTile = true;
                    //           });
                    //           var prefs = await SharedPreferences.getInstance();
                    //           prefs.setString(
                    //               'route-name', 'sub-categories-collections');
                    //         },
                    //         title: const Text(
                    //           'Sub categories collections',
                    //           style:
                    //               TextStyle(fontSize: 14, color: Colors.white),
                    //         ).tr(),
                    //         leading: const Icon(Icons.category, color: Colors.white)),
                    //   ),
                    // ),
                    // HoverAnimatedContainer(
                    //   hoverColor: Colors.grey,
                    //   child: Container(
                    //     color: routeName == 'brands' ? Colors.grey : null,
                    //     child: ListTile(
                    //         onTap: () async {
                    //           Modular.to.navigate(
                    //             '/brands',
                    //           );
                    //           setState(() {
                    //             categoryExpansionTile = true;
                    //           });
                    //           var prefs = await SharedPreferences.getInstance();
                    //           prefs.setString('route-name', 'brands');
                    //         },
                    //         title: const Text(
                    //           'Brands',
                    //           style:
                    //               TextStyle(fontSize: 14, color: Colors.white),
                    //         ).tr(),
                    //         leading: const Icon(Icons.branding_watermark,
                    //             color: Colors.white)),
                    //   ),
                    // ),
                  ],
                ),
              ),
              HoverAnimatedContainer(
                hoverColor: Colors.grey,
                child: Container(
                  color: routeName == 'orders' ? Colors.grey : null,
                  child: ListTile(
                    onTap: () async {
                      Modular.to.navigate(
                        '/orders',
                      );
                      var prefs = await SharedPreferences.getInstance();
                      prefs.setString('route-name', 'orders');
                    },
                    title: const Text(
                      'Orders',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ).tr(),
                    leading: const Icon(Icons.list, color: Colors.white),
                  ),
                ),
              ),
              HoverAnimatedContainer(
                hoverColor: Colors.grey,
                child: Container(
                  color: routeName == 'markets' ? Colors.grey : null,
                  child: ListTile(
                      onTap: () async {
                        Modular.to.navigate(
                          '/markets',
                        );

                        var prefs = await SharedPreferences.getInstance();
                        prefs.setString('route-name', 'markets');
                      },
                      title: const Text(
                        'Markets',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ).tr(),
                      leading:
                          const Icon(Icons.local_mall, color: Colors.white)),
                ),
              ),
              // HoverAnimatedContainer(
              //   hoverColor: Colors.grey,
              //   child: Container(
              //     color: routeName == 'cities' ? Colors.grey : null,
              //     child: ListTile(
              //         onTap: () async {
              //           Modular.to.navigate(
              //             '/cities',
              //           );

              //           var prefs = await SharedPreferences.getInstance();
              //           prefs.setString('route-name', 'cities');
              //         },
              //         title: const Text(
              //           'Cities',
              //           style: TextStyle(fontSize: 14, color: Colors.white),
              //         ).tr(),
              //         leading:
              //             const Icon(Icons.location_city, color: Colors.white)),
              //   ),
              // ),
              HoverAnimatedContainer(
                hoverColor: Colors.blue,
                child: ExpansionTile(
                  collapsedIconColor: Colors.white,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  initiallyExpanded: userExpansionTile,
                  onExpansionChanged: (value) {
                    setState(() {
                      userExpansionTile = !userExpansionTile;
                    });
                  },
                  title: const Text(
                    'Users settings',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ).tr(),
                  leading: const Icon(Icons.person),
                  children: <Widget>[
                    HoverAnimatedContainer(
                      hoverColor: Colors.grey,
                      child: Container(
                        color: routeName == 'users' ? Colors.grey : null,
                        child: ListTile(
                            onTap: () async {
                              Modular.to.navigate(
                                '/users',
                              );
                              setState(() {
                                userExpansionTile = true;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString('route-name', 'users');
                            },
                            title: const Text(
                              'Users',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ).tr(),
                            leading:
                                const Icon(Icons.person, color: Colors.white)),
                      ),
                    ),
                    HoverAnimatedContainer(
                      hoverColor: Colors.grey,
                      child: Container(
                        color: routeName == 'approved-vendors'
                            ? Colors.grey
                            : null,
                        child: ListTile(
                            onTap: () async {
                              Modular.to.navigate(
                                '/vendors',
                              );
                              setState(() {
                                userExpansionTile = true;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString('route-name', 'approved-vendors');
                            },
                            title: const Text(
                              'Vendors',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ).tr(),
                            leading:
                                const Icon(Icons.person, color: Colors.white)),
                      ),
                    ),
                    HoverAnimatedContainer(
                      hoverColor: Colors.grey,
                      child: Container(
                        color:
                            routeName == 'delivery-boys' ? Colors.grey : null,
                        child: ListTile(
                            onTap: () async {
                              Modular.to.navigate(
                                '/delivery-boys',
                              );
                              setState(() {
                                userExpansionTile = true;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString('route-name', 'delivery-boys');
                            },
                            title: const Text(
                              'Delivery boys',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ).tr(),
                            leading: const Icon(Icons.delivery_dining,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              HoverAnimatedContainer(
                hoverColor: Colors.grey,
                child: Container(
                  color: routeName == 'feeds' ? Colors.grey : null,
                  child: ListTile(
                    onTap: () async {
                      Modular.to.navigate(
                        '/feeds',
                      );

                      var prefs = await SharedPreferences.getInstance();
                      prefs.setString('route-name', 'feeds');
                    },
                    title: const Text(
                      'Feeds',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ).tr(),
                    leading: const Icon(Icons.feed, color: Colors.white),
                  ),
                ),
              ),
              HoverAnimatedContainer(
                hoverColor: Colors.blue,
                child: ExpansionTile(
                  collapsedIconColor: Colors.white,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  initiallyExpanded: payoutExpansionTile,
                  onExpansionChanged: (value) {
                    setState(() {
                      payoutExpansionTile = !payoutExpansionTile;
                    });
                  },
                  title: const Text(
                    'Pay outs',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ).tr(),
                  leading:
                      const Icon(Icons.monetization_on, color: Colors.white),
                  children: <Widget>[
                    HoverAnimatedContainer(
                      hoverColor: Colors.grey,
                      child: Container(
                        color: routeName == 'completed-payouts'
                            ? Colors.grey
                            : null,
                        child: ListTile(
                            onTap: () async {
                              Modular.to.navigate(
                                '/completed-payouts',
                              );
                              setState(() {
                                userExpansionTile = true;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString(
                                  'route-name', 'completed-payouts');
                            },
                            title: const Text(
                              'Completed pay outs',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ).tr(),
                            leading:
                                const Icon(Icons.done, color: Colors.white)),
                      ),
                    ),
                    HoverAnimatedContainer(
                      hoverColor: Colors.grey,
                      child: Container(
                        color:
                            routeName == 'payout-requests' ? Colors.grey : null,
                        child: ListTile(
                            onTap: () async {
                              Modular.to.navigate(
                                '/payout-requests',
                              );
                              setState(() {
                                userExpansionTile = true;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString('route-name', 'payout-requests');
                            },
                            title: const Text(
                              'Pay out requests',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ).tr(),
                            leading: const Icon(Icons.request_page,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              HoverAnimatedContainer(
                hoverColor: Colors.blue,
                child: ExpansionTile(
                  collapsedIconColor: Colors.white,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  initiallyExpanded: courierExpansionTile,
                  onExpansionChanged: (value) {
                    setState(() {
                      courierExpansionTile = !courierExpansionTile;
                    });
                  },
                  title: const Text(
                    'Courier settings',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ).tr(),
                  leading:
                      const Icon(Icons.delivery_dining, color: Colors.white),
                  children: <Widget>[
                    HoverAnimatedContainer(
                      hoverColor: Colors.grey,
                      child: Container(
                        color: routeName == 'courier-settings'
                            ? Colors.grey
                            : null,
                        child: ListTile(
                            onTap: () async {
                              Modular.to.navigate(
                                '/courier-settings',
                              );
                              setState(() {
                                userExpansionTile = true;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString('route-name', 'courier-settings');
                            },
                            title: const Text(
                              'Courier Settings',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ).tr(),
                            leading: const Icon(Icons.settings,
                                color: Colors.white)),
                      ),
                    ),
                    HoverAnimatedContainer(
                      hoverColor: Colors.grey,
                      child: Container(
                        color: routeName == 'completed-deliveries'
                            ? Colors.grey
                            : null,
                        child: ListTile(
                            onTap: () async {
                              Modular.to.navigate(
                                '/completed-deliveries',
                              );
                              setState(() {
                                userExpansionTile = true;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString(
                                  'route-name', 'completed-deliveries');
                            },
                            title: const Text(
                              'Completed deliveries',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ).tr(),
                            leading:
                                const Icon(Icons.done, color: Colors.white)),
                      ),
                    ),
                    HoverAnimatedContainer(
                      hoverColor: Colors.grey,
                      child: Container(
                        color:
                            routeName == 'new-deliveries' ? Colors.grey : null,
                        child: ListTile(
                            onTap: () async {
                              Modular.to.navigate(
                                '/new-deliveries',
                              );
                              setState(() {
                                userExpansionTile = true;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString('route-name', 'new-deliveries');
                            },
                            title: const Text(
                              'New deliveries',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ).tr(),
                            leading: const Icon(Icons.delivery_dining,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              HoverAnimatedContainer(
                hoverColor: Colors.grey,
                child: Container(
                  color: routeName == 'notifications' ? Colors.grey : null,
                  child: ListTile(
                    onTap: () async {
                      Modular.to.navigate(
                        '/notifications',
                      );
                      setState(() {
                        userExpansionTile = true;
                      });
                      var prefs = await SharedPreferences.getInstance();
                      prefs.setString('route-name', 'notifications');
                    },
                    title: const Text(
                      'Notifications',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ).tr(),
                    leading:
                        const Icon(Icons.notifications, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
