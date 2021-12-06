import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SakeTimelineViewWidget extends StatelessWidget {
  final Color color;
  final String title;

  const SakeTimelineViewWidget({Key? key, required this.color, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var assetsImage = "images/ic_sake.png";
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('BrandList').snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 10.0, // 縦
                  mainAxisSpacing: 10.0, // 横
                  childAspectRatio: 2.0),
              itemCount: snapshot.data!.docs.length,
              padding: const EdgeInsets.all(5.0),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/sake_detail', arguments: snapshot.data!.docs[index].id);
                      },
                      child: Row(
                        children: <Widget>[
                          Image.asset(assetsImage, height: 100, fit: BoxFit.cover,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.all(4.0),
                                child: const Text('銘柄名：'),
                              ),
                              Container(
                                margin: const EdgeInsets.all(4.0),
                                child: const Text('サブ銘柄名：'),
                              ),
                              Container(
                                margin: const EdgeInsets.all(4.0),
                                child: const Text('酒舗：'),
                              ),
                              Container(
                                margin: const EdgeInsets.all(4.0),
                                child: const Text('地域名：'),
                              ),
                              Container(
                                margin: const EdgeInsets.all(4.0),
                                child: const Text('特定名称：'),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.all(4.0),
                                child: Text(snapshot.data!.docs[index]['title']),
                              ),
                              Container(
                                margin: const EdgeInsets.all(4.0),
                                child: Text(snapshot.data!.docs[index]['subtitle']),
                              ),
                              Container(
                                margin: const EdgeInsets.all(4.0),
                                child: Text(snapshot.data!.docs[index]['brewery']),
                              ),
                              Container(
                                margin: const EdgeInsets.all(4.0),
                                child: Text(snapshot.data!.docs[index]['area']),
                              ),
                              Container(
                                margin: const EdgeInsets.all(4.0),
                                child: Text(snapshot.data!.docs[index]['specific']),
                              ),
                            ],
                          ),
                        ],
                      )),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(5.0, 5.0),
                        blurRadius: 10.0,
                      )
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
