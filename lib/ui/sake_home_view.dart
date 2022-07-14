import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:growing_sake/main.dart';
import 'package:growing_sake/model/uid_docid_args.dart';
import 'package:growing_sake/util/firebase_storage_access.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

///
/// 日本酒一覧表示画面
/// Firestoreから自分が登録した日本酒を取得して一覧で表示する
///
class SakeHomeViewWidget extends HookConsumerWidget {
  final Color color;
  final String title;
  int prevUpdateCount = 0;

  SakeHomeViewWidget({Key? key, required this.color, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final String uid = ref.watch(uidProvider);
    // 新規作成や詳細画面で更新があった場合を監視するために更新カウンタを確認する
    final int updateCount = ref.watch(updateDetailProvider);
    if (prevUpdateCount != updateCount) {
      prevUpdateCount = updateCount;
    }
    return Scaffold(
      body: uid == "" ? const Center(child: Text("メニューからログインして下さい")) : StreamBuilder(
        stream: FirebaseFirestore.instance.collection(uid).orderBy('createAt', descending: true).snapshots(),
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
                crossAxisSpacing: 5.0, // 縦
                mainAxisSpacing: 5.0, // 横
                childAspectRatio: 0.75),
            itemCount: snapshot.data!.docs.length,
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            itemBuilder: (BuildContext context, int index) {
              // タップされた日本酒に対する詳細画面への遷移処理を定義
              return Container(
                child: GestureDetector(
                  onTap: () {
                    // タップされた場合は詳細画面に遷移する
                    Navigator.of(context).pushNamed('/sake_detail_reference', arguments: UidDocIdArgs(uid, snapshot.data!.docs[index].id, true));
                  },
                  onLongPress: () {
                    // 長押しされた場合は削除ダイアログを表示する
                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text(snapshot.data!.docs[index]['title']),
                          content: Text("削除しますか？"),
                          actions: <Widget>[
                            // ボタン領域
                            FlatButton(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            FlatButton(
                              child: Text("OK"),
                              onPressed: () async {
                                FirebaseStorageAccess.deleteFile(uid + '/' + snapshot.data!.docs[index].id + '_1.JPG');
                                await snapshot.data!.docs[index].reference.delete();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Column(
                    children: <Widget>[
                      FutureBuilder<String?>(
                        future: FirebaseStorageAccess.downloadFile(uid + '/' + snapshot.data!.docs[index].id + '_1.JPG'),
                        builder: (context, imageSnapshot) => imageSnapshot.hasData ? InkWell(
                          child: Image.network(
                            imageSnapshot.data as String,
                            fit: BoxFit.cover,
                          ),
                        ) : Image.asset('images/ic_sake.png', fit: BoxFit.cover,),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Row(
                          children: [
                            Image.asset('images/sakura.png', height: 24, width: 24,),
                            Flexible(child: Text(
                                snapshot.data!.docs[index]['title'],
                                style: const TextStyle(fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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
