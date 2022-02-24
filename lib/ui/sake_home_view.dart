import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

///
/// 日本酒一覧表示画面
/// Firestoreから自分が登録した日本酒を取得して一覧で表示する
///
class SakeHomeViewWidget extends StatelessWidget {
  final Color color;
  final String title;

  const SakeHomeViewWidget({Key? key, required this.color, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var assetsImage = "images/ic_sake.png";
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Brands').snapshots(),
        builder: (BuildContext context,
          // データ取得中は処理中のプログレスを表示
          AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          ///
          /// Firestoreから取得したデータをGグリッド表示で並べる
          ///
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0, // 縦
                mainAxisSpacing: 10.0, // 横
                childAspectRatio: 0.7),
            itemCount: snapshot.data!.docs.length,
            padding: const EdgeInsets.all(5.0),
            itemBuilder: (BuildContext context, int index) {
              // タップされた日本酒に対する詳細画面への遷移処理を定義
              return Container(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/sake_detail', arguments: snapshot.data!.docs[index].id);
                  },
                  child: Column(
                    children: <Widget>[
                      Image.asset(assetsImage, fit: BoxFit.cover,),
                      Container(
                        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Text(
                          snapshot.data!.docs[index]['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,),
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
