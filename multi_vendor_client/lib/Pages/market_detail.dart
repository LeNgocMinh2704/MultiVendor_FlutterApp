import 'package:carousel_pro_nullsafety/carousel_pro_nullsafety.dart';
import 'package:flutter/material.dart';
import 'package:vendor/Model/market.dart';
import 'package:vendor/Widget/add_products.dart';
import 'package:vendor/Widget/edit_market.dart';
import 'package:vendor/Widget/market_overview.dart';
import 'package:vendor/Widget/products_list.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Widget/add_flash_sales.dart';
import '../Widget/flash_sales_list.dart';

class MarketDetail extends StatefulWidget {
  final MarketModel marketModel;
  final String vendorID;
  const MarketDetail(
      {Key? key, required this.marketModel, required this.vendorID})
      : super(key: key);

  @override
  State<MarketDetail> createState() => _MarketDetailState();
}

class _MarketDetailState extends State<MarketDetail>
    with TickerProviderStateMixin {
  TabController? controller;
  ScrollController scrollController = ScrollController();
  double offset = 0.0;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller!.addListener(_switchTabIndex);
    scrollController.addListener(() {
      setState(() {
        offset = scrollController.offset;
      });
    });
  }

  void _switchTabIndex() {
    //print(controller!.index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: controller!.index == 1
          ? FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddProducts(
                          marketCategory: widget.marketModel.category,
                          marketID: widget.marketModel.uid,
                          vendorID: widget.vendorID,
                          marketName: widget.marketModel.marketName,
                        )));
              },
              child: const Icon(Icons.add))
          : controller!.index == 2
              ? FloatingActionButton(
                  backgroundColor: Colors.orange,
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (builder) {
                      return AddFlashSales(
                        marketCategory: widget.marketModel.category,
                        marketID: widget.marketModel.uid,
                        vendorID: widget.vendorID,
                        marketName: widget.marketModel.marketName,
                      );
                    }));
                  },
                  child: const Center(
                    child: Icon(Icons.add),
                  ))
              : const SizedBox(),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              centerTitle: true,
              title: (offset == 0)
                  ? Container()
                  : Text(widget.marketModel.marketName,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )),
              pinned: false,
         //     backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.pin,
                  background: Column(
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.bottomEnd,
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height / 2.2,
                              width: double.infinity,
                              child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(40.0),
                                      bottomLeft: Radius.circular(40.0)),
                                ),
                                child: Carousel(
                                  animationDuration: const Duration(seconds: 2),
                                  showIndicator: false,
                                  images: [
                                    widget.marketModel.image1 == ''
                                        ? Image.network(
                                            'https://cdn.iconscout.com/icon/free/png-256/gallery-187-902099.png',
                                            fit: BoxFit.cover)
                                        : Image.network(
                                            widget.marketModel.image1),
                                    widget.marketModel.image2 == ''
                                        ? Image.network(
                                            'https://cdn.iconscout.com/icon/free/png-256/gallery-187-902099.png',
                                            fit: BoxFit.cover)
                                        : Image.network(
                                            widget.marketModel.image2),
                                    widget.marketModel.image3 == ''
                                        ? Image.network(
                                            'https://cdn.iconscout.com/icon/free/png-256/gallery-187-902099.png',
                                            fit: BoxFit.cover)
                                        : Image.network(
                                            widget.marketModel.image3),
                                  ],
                                ),
                              )),
                          Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Text(widget.marketModel.marketName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.orange)),
                              ))
                        ],
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => EditMarket(
                                          marketModel: widget.marketModel,
                                        )));
                              },
                              child: const Text('Edit Market').tr()),
                        ),
                      )
                    ],
                  )),
              expandedHeight: MediaQuery.of(context).size.height / 1.7,
              bottom: TabBar(
                isScrollable: true,
                // indicatorColor: Theme.of(context).primaryColor,
                // labelColor: Theme.of(context).primaryColor,
                tabs: [
                  Tab(text: 'MARKET OVERVIEW'.tr()),
                  Tab(text: 'PRODUCTS'.tr()),
                  Tab(text: 'FLASH PRODUCTS'.tr())
                ],
                controller: controller,
              ),
            )
          ];
        },
        body: TabBarView(controller: controller, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MarketOverview(marketModel: widget.marketModel),
          ),
          ProductList(marketID: widget.marketModel.uid!),
          FlashSalesList(marketID: widget.marketModel.uid!),
        ]),
      ),
    );
  }
}
