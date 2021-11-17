import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:growing_sake/sake_detail.dart';

class SakeGridViewWidget extends StatelessWidget {
  final Color color;
  final String title;

  const SakeGridViewWidget({Key? key, required this.color, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var assetsImage = "images/ic_sake.png";
    return MaterialApp(
      title: 'Grid List',
      routes: <String, WidgetBuilder> {
        '/sake_detail': (BuildContext context) => SakeDetailWidget()
      },
      home: Scaffold(
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
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0, // 縦
                  mainAxisSpacing: 10.0, // 横
                  childAspectRatio: 0.7),
              itemCount: snapshot.data!.docs.length,
              padding: const EdgeInsets.all(5.0),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/sake_detail');
                    },
                    child: Column(
                      children: <Widget>[
                        Image.asset(assetsImage, fit: BoxFit.cover,),
                        Container(
                          margin: const EdgeInsets.all(10.0),
                          child: Text(snapshot.data!.docs[index]['title']),
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
      ),
    );
  }
}
