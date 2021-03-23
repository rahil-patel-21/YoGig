import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yogigg_users_app/models/gigg_model.dart';
import 'package:yogigg_users_app/ui/custom_shapes/custom_app_bar.dart';
import 'package:yogigg_users_app/utils/router_constants.dart';

import 'package:yogigg_users_app/utils/time_helper.dart';

class GiggSearchScreen extends StatefulWidget {
  @override
  _GiggSearchScreenState createState() => _GiggSearchScreenState();
}

class _GiggSearchScreenState extends State<GiggSearchScreen> {
  double toolBarCurveRadius = 83;
  TextEditingController searchEditingController = TextEditingController();
  List<GiggModel> giggs = List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        brightness: Brightness.light,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  
                  height: 145,
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.only(left: 83, right: 32),
                  height: 80,
                  child: Row(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {},
                        itemCount: 0,
                        scrollDirection: Axis.horizontal,
                      ),
                      SizedBox(
                        width: 40,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(8),
                          color: Color(0xFF0185D0),

                          onPressed: () {
                            print('tap');
                            Navigator.of(context)
                                .pushNamed(SearchFiltersScreenRoute);
                          },
                          // decoration: BoxDecoration(
                          //   color: Color(0xFF0185D0),
                          //   borderRadius: BorderRadius.circular(6),
                          // ),
                          child: SvgPicture.asset(
                            'assets/svg/filters_icon.svg',
                            height: 18,
                            width: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                        color: Color(0xFF0185D0),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 1),
                              blurRadius: 14,
                              color: Color(0xFF19282F))
                        ]),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              giggs[index].giggName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                            Text(
                              'Posted ${timeAgoSinceDate(giggs[index].postedAt)}',
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 7),
                          child: Text(
                            giggs[index].description,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        )
                      ],
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  );
                }, childCount: giggs.length),
              )
            ],
          ),
          buildAppBar(context),
        ],
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    // return CustomPaint(
    //   size: Size(MediaQuery.of(context).size.width, 225),
    //   painter: CustomToolBar(
    //       LinearGradient(
    //           colors: [Color(0xFFFF464F), Color(0xFF512989)]),
    //       83.0),
    // );
    return Container(
       
        child: Stack(
    children: [
      Container(
        
        height: 83,
        width: 83,
      ),
      IgnorePointer(
                    child: CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 225),
          painter: CustomToolBar(
              LinearGradient(colors: [Color(0xFFFF464F), Color(0xFF512989)]),
              83.0),
          child: Container(
            height: 225,
            color: Colors.transparent,
          
          ),
        ),
        
      ),
      Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 23, left: 42),
                    child: Text(
                      'Gigg Search',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  buildSearchBar()
                ],
              ),
            )
    ],
        ),
      );
  }

  Container buildSearchBar() {
    return Container(
      height: 56,
      margin: EdgeInsets.only(left: 36, right: 31, top: 14),
      child: Stack(
        children: [
          Center(
            child: Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(right: 5),
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Container(
                width: 300,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: TextField(
                  maxLines: 1,
                  controller: searchEditingController,
                  style: TextStyle(fontSize: 22.0),
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
            ),
          ),
          Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: () {
                  if (searchEditingController.text.isNotEmpty) {
                    search(searchEditingController.text);
                  }
                },
                child: Container(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      'assets/svg/search_icon.svg',
                    ),
                  ),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0185D0), Color(0xFF512989)])),
                ),
              ))
        ],
      ),
    );
  }

  search(String query) async {
    String url =
        'https://e2fa73da9853446e8d0c7f31c54938e1.ent-search.us-central1.gcp.cloud.es.io';
    String searchApiKey = 'search-va7i3b6xtibjkgn1t4d5exxb';
    Dio dio = Dio(BaseOptions(
      baseUrl: url,
    ));
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $searchApiKey",
    };
    final data = {"query": query};
    try {
      Response response = await dio.post(
          '/api/as/v1/engines/giggs-search/search',
          options: Options(headers: headers),
          data: data);

      print(response.data['results'][0]);
      giggs.clear();
      for (var item in response.data['results']) {
        GiggModel giggModel = GiggModel.fromSearchResponse(item);
        giggs.add(giggModel);
      }

      setState(() {});
    } catch (e) {
      print(e);
    }
  }
}
