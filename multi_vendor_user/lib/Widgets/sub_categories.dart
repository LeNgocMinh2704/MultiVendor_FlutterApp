import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../Model/sub_categories_model.dart';
import '../Pages/products_by_subcategories.dart';

class SubCategoriesWidget extends StatefulWidget {
  final String category;
  const SubCategoriesWidget({Key? key, required this.category})
      : super(key: key);

  @override
  State<SubCategoriesWidget> createState() => _SubCategoriesWidgetState();
}

class _SubCategoriesWidgetState extends State<SubCategoriesWidget> {
  Future<List<SubCategoriesModel>> getSubCollections() {
    return FirebaseFirestore.instance
        .collection('Sub Categories')
        .where('category', isEqualTo: widget.category)
        .get()
        .then((event) {
      return event.docs
          .map((e) => SubCategoriesModel.fromMap(e.data(), e.id))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SubCategoriesModel>>(
        future: getSubCollections(),
        builder: (context, snapshot) {
          if (snapshot.data?.isEmpty ?? true) {
            return Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      enabled: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 48.0,
                                height: 48.0,
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: double.infinity,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.0),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.0),
                                    ),
                                    Container(
                                      width: 40.0,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        itemCount: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            return ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(
                      thickness: 1,
                      color: Colors.grey,
                      indent: 10,
                      endIndent: 10,
                    ),
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: ((context, index) {
                  SubCategoriesModel subCategoriesModel = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: SizedBox(
                      height: 50,
                      child: Center(
                        child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: ((context) =>
                                      ProductsBySubCategories(
                                        collection: subCategoriesModel.name,
                                      ))));
                            },
                            leading: Image.network(
                              subCategoriesModel.image,
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              subCategoriesModel.name,
                              style: const TextStyle(fontSize: 15),
                            )),
                      ),
                    ),
                  );
                }));
          } else {
            return Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      enabled: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 48.0,
                                height: 48.0,
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: double.infinity,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.0),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.0),
                                    ),
                                    Container(
                                      width: 40.0,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        itemCount: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
