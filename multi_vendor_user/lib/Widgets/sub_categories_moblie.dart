import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../Model/sub_categories_model.dart';
import '../Pages/products_by_subcategories.dart';

class SubCategoriesWidgetMoblie extends StatefulWidget {
  final String category;
  const SubCategoriesWidgetMoblie({Key? key, required this.category})
      : super(key: key);

  @override
  State<SubCategoriesWidgetMoblie> createState() =>
      _SubCategoriesWidgetMoblieState();
}

class _SubCategoriesWidgetMoblieState extends State<SubCategoriesWidgetMoblie> {
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
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    enabled: true,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.only(right: 20, left: 8),
                        child: SizedBox(
                          height: 80,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 60,
                                width: 60,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: 40.0,
                                height: 8.0,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      itemCount: 10,
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: ((context, index) {
                  SubCategoriesModel subCategoriesModel = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: SizedBox(
                      height: 80,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: ((context) => ProductsBySubCategories(
                                    collection: subCategoriesModel.name,
                                  ))));
                        },
                        child: Column(
                          children: [
                            Center(
                              child: ClipOval(
                                child: Image.network(
                                  subCategoriesModel.image,
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              subCategoriesModel.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }));
          } else {
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    enabled: true,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.only(right: 20, left: 8),
                        child: SizedBox(
                          height: 80,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 60,
                                width: 60,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: 40.0,
                                height: 8.0,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      itemCount: 10,
                    ),
                  ),
                ),
              ],
            );
          }
        });
  }
}
