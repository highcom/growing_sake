import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:growing_sake/util/firebase_storage_access.dart';
import 'package:flutter/rendering.dart';
import 'package:growing_sake/model/uid_docid_args.dart';
import 'package:growing_sake/component/sake_radar_chart_thumb.dart';
import 'package:growing_sake/component/sake_line_chart_thumb.dart';

///
/// 日本酒のタイムラインでの一覧表示
/// 全てのユーザーの直近の投稿についてタイムラインで表示する
///
class SakeTimelineViewWidget extends StatelessWidget {
  final Color color;
  final String title;
  // 五味用のレーダーチャート
  SakeRadarChartThumb _sakeRadarChartThumb = SakeRadarChartThumb(fiveFlavorList: const {});
  // 香グラフ用のラインチャート
  SakeLineChartThumb _sakeLineChartThumb = SakeLineChartThumb(elapsedList: const [0, 1], levelList: const [0, 0]);

  SakeTimelineViewWidget({Key? key, required this.color, required this.title}) : super(key: key);

  ///
  /// スナップショットから引数で指定された項目の内容を設定する
  ///
  String getSnapshotValue(QueryDocumentSnapshot snapshot, String name) {
    try {
      String? value = snapshot[name];
      if (value != null && value != "") {
        return value;
      } else {
        return 'ー';
      }
    } catch(e) {
      print('snapshot exception' + e.toString());
      return 'ー';
    }
  }

  @override
  Widget build(BuildContext context) {

    var assetsImage = "images/ic_sake.png";
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Timeline').orderBy('createAt', descending: true).snapshots(),
          builder: (BuildContext context,
            ///
            /// データ取得中は処理中のプログレスを表示
            ///
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
                  crossAxisCount: 1,
                  crossAxisSpacing: 5.0, // 縦
                  mainAxisSpacing: 5.0, // 横
                  childAspectRatio: 2.2),
              itemCount: snapshot.data!.docs.length,
              padding: const EdgeInsets.all(5.0),
              itemBuilder: (BuildContext context, int index) {
                // 五味データがある場合にはデータを設定する
                if (snapshot.data!.docs[index].get('fiveFlavorList') != null) {
                  _sakeRadarChartThumb = SakeRadarChartThumb(fiveFlavorList: snapshot.data!.docs[index].get('fiveFlavorList').cast<String, int>() as Map<String, int>);
                }
                // 香りデータがある場合にはデータを設定する
                if (snapshot.data!.docs[index].get('aromaElapsedList') != null && snapshot.data!.docs[index].get('aromaLevelList') != null) {
                  _sakeLineChartThumb = SakeLineChartThumb(
                      elapsedList: snapshot.data!.docs[index].get('aromaElapsedList').cast<double>() as List<double>,
                      levelList: snapshot.data!.docs[index].get('aromaLevelList').cast<double>() as List<double>);
                }

                return Container(
                  child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/sake_detail_reference', arguments: UidDocIdArgs('Timeline', snapshot.data!.docs[index].id, false));
                      },
                      child: Row(
                        children: <Widget>[
                          FutureBuilder<String?>(
                            future: FirebaseStorageAccess.downloadFile(snapshot.data!.docs[index].get('uid') + '/' + snapshot.data!.docs[index].get('orgDocId') + '.JPG'),
                            builder: (context, imageSnapshot) => imageSnapshot.hasData ? InkWell(
                              child: Image.network(
                                imageSnapshot.data as String,
                                fit: BoxFit.cover,
                              ),
                            ) : Image.asset(assetsImage, fit: BoxFit.cover,),
                          ),
                          Flexible(child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                        child: Text(getSnapshotValue(snapshot.data!.docs[index], 'title'),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 26,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                      Image.asset('images/sakura.png', height: 36, width: 36,),
                                  ],),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: Text(getSnapshotValue(snapshot.data!.docs[index], 'subtitle'),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                ],),
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ///
                                      /// 五味のレーダーチャート設定
                                      ///
                                      Expanded(child: Container(
                                          padding: const EdgeInsets.fromLTRB(2.0, 0, 0, 0),
                                          alignment: Alignment.center,
                                          child: _sakeRadarChartThumb,
                                        ),
                                      ),
                                      ///
                                      /// 香りグラフのラインチャート設定
                                      ///
                                      Expanded(child: Container(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 2.0, 0),
                                        alignment: Alignment.center,
                                          child: _sakeLineChartThumb,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ),
                        ],
                      )),
                  decoration: BoxDecoration(
                    color: color,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(1.0, 1.0),
                        blurRadius: 1.0,
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
