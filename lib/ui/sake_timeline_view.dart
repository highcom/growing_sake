import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:growing_sake/model/uid_docid_args.dart';
import 'package:growing_sake/component/sake_radar_chart_thumb.dart';
import 'package:growing_sake/component/sake_line_chart_thumb.dart';
import 'package:flutter_svg/flutter_svg.dart';

///
/// 日本酒のタイムラインでの一覧表示
/// 全てのユーザーの直近の投稿についてタイムラインで表示する
///
class SakeTimelineViewWidget extends StatelessWidget {
  final Color color;
  final String title;
  // 五味用のレーダーチャート
  final _sakeRadarChartThumb = SakeRadarChartThumb(fiveFlavorList: const {});
  // 香グラフ用のラインチャート
  final _sakeLineChartThumb = SakeLineChartThumb(elapsedList: const [0, 1, 2], levelList: const [10, 5, 3]);

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
          stream: FirebaseFirestore.instance.collection('Timeline').snapshots(),
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
                  childAspectRatio: 2.3),
              itemCount: snapshot.data!.docs.length,
              padding: const EdgeInsets.all(5.0),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/sake_detail', arguments: UidDocIdArgs('Timeline', snapshot.data!.docs[index].id));
                      },
                      child: Row(
                        children: <Widget>[
                          Image.asset(assetsImage, height: 200, fit: BoxFit.cover,),
                          Flexible(child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(children: <Widget>[
                                  SvgPicture.asset('images/sakura.svg', height: 36, width: 36,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                ],),
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ///
                                      /// 五味のレーダーチャート設定
                                      ///
                                      Container(
                                        constraints: const BoxConstraints(maxWidth: 100),
                                        alignment: Alignment.center,
                                        child: _sakeRadarChartThumb,
                                      ),
                                      ///
                                      /// 香りグラフのラインチャート設定
                                      ///
                                      Container(
                                        constraints: const BoxConstraints(maxWidth: 100),
                                        alignment: Alignment.center,
                                        child: _sakeLineChartThumb,
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
