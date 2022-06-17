import 'package:flutter/material.dart';
import 'package:growing_sake/model/uid_docid_args.dart';
import 'package:growing_sake/util/app_theme_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:growing_sake/util/firebase_storage_access.dart';
import 'package:growing_sake/component/sake_line_chart.dart';
import 'package:growing_sake/component/sake_radar_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

///
/// 日本酒に対する詳細内容の表示(参照のみ)
///
class SakeDetailReferenceWidget extends StatefulWidget {
  final arguments;
  const SakeDetailReferenceWidget({Key? key, required this.arguments}) : super(key: key);

  @override
  State<SakeDetailReferenceWidget> createState() => _SakeDetailReferenceWidgetState();
}

class _SakeDetailReferenceWidgetState extends State<SakeDetailReferenceWidget> with SingleTickerProviderStateMixin {
  // 初回データ取得か？
  bool firstTime = false;

  // 詳細内容の表示非表示設定
  bool showPicker = false;
  late AnimationController _controller;
  // 詳細表示状態に応じたアイコン
  IconData _iconData = Icons.add;

  // ユーザーID
  late String uid;
  // 日本酒のドキュメントID
  late String docId;

  // 香グラフ用のラインチャート
  late SakeLineChart _sakeLineChart;
  // 五味グラフ用のレーダーチャート
  late SakeRadarChart _sakeRadarChart;

  String  _title = "";
  String  _subtitle = "";
  String  _brewery = "";
  String  _area = "";
  String  _specific = "";
  String  _polishing = "";
  String  _material = "";
  String  _capacity = "";
  String  _purchase = "";
  String  _temperature = "";
  String  _drinking = "";

  @override
  void initState() {
    final UidDocIdArgs uidDocIdArgs = widget.arguments as UidDocIdArgs;
    uid = uidDocIdArgs.uid;
    docId = uidDocIdArgs.docId;
    firstTime = true;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    Intl.defaultLocale = 'ja_JP';
    initializeDateFormatting();
    super.initState();
  }

  ///
  /// 日本酒情報の取得処理
  /// ドキュメントIDに対応する日本酒のデータをFirestoreから取得してテキストエリアに反映する
  ///
  Future<DocumentSnapshot> getBrandData() async {
    Future<DocumentSnapshot> future;
    // ドキュメントIDがあれば対応する情報を取得し、新規作成の場合はデフォルトパラメータの情報を取得する
    future = FirebaseFirestore.instance.collection(uid).doc(docId).get();
    // スナップショットから各種パラメータを取得
    DocumentSnapshot snapshot = await future;
    if (firstTime == true) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      _title = data['title'] as String;
      _subtitle = data['subtitle'] as String;
      _brewery = data['brewery'] as String;
      _area = data['area'] as String;
      _specific = data['specific'] as String;
      _polishing = data['polishing'].toString();
      _material = data['material'] as String;
      _capacity = data['capacity'].toString();
      if (data['purchase'] != null) {
        _purchase = (DateFormat.yMMMEd()).format(data['purchase'].toDate());
      }
      _temperature = data['temperature'].toString();
      _drinking = data['drinking'] as String;
      if (data.containsKey('aromaElapsedList') && data.containsKey('aromaLevelList')) {
        _sakeLineChart = SakeLineChart(
            elapsedList: data['aromaElapsedList'].cast<double>() as List<double>,
            levelList: data['aromaLevelList'].cast<double>() as List<double>,
            editEnable: false);
      } else {
        _sakeLineChart = SakeLineChart(elapsedList: const [], levelList: const [], editEnable: false);
      }

      if (data.containsKey('fiveFlavorList')) {
        _sakeRadarChart = SakeRadarChart(title: _title, fiveFlavorList: data['fiveFlavorList'].cast<String, int>() as Map<String, int>, editEnable: false);
      } else {
        _sakeRadarChart = SakeRadarChart(title: _title, fiveFlavorList: const {}, editEnable: false);
      }

      firstTime = false;
    }
    return future;
  }

  ///
  /// 詳細内容の表示・非表示に対応するハンドリング
  ///
  void _handleVisible() {
    setState(() {
      showPicker = !showPicker;
      if (showPicker) {
        _controller.forward();
        _iconData = Icons.remove;
      } else {
        _controller.reverse();
        _iconData = Icons.add;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getBrandData(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        ///
        /// データ取得中は処理中のプログレスを表示
        ///
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('銘柄詳細'),
            automaticallyImplyLeading: true,
            actions: [
              ///
              /// 変更確定処理用のチェックボタン設定
              ///
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO:タイムラインから来る場合は不要
                  // TODO:ホームからの場合は最初から編集の方が良いか検討
                  // 編集画面に遷移する
                  Navigator.of(context).pushNamed('/sake_detail_edit', arguments: UidDocIdArgs(uid, docId));
                },
              ),
            ],
          ),
          ///
          /// 詳細項目入力領域に対する画面スクロール設定
          ///
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //
                // 銘柄名テキストフィールド設定
                // 銘柄名をタップされると日本酒名候補一覧画面に遷移して選択された銘柄名と地域を反映する
                //
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Text(_title,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Theme.of(context).primaryColor
                    ),
                  ),
                ),
                //
                // サブ銘柄名テキスト設定
                //
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Text(_subtitle,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                ///
                /// 日本酒の写真設定
                ///
                Container(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    child: FutureBuilder<String?>(
                      future: FirebaseStorageAccess.downloadFile(uid + '/' + docId + '.JPG'),
                      builder: (context, imageSnapshot) => imageSnapshot.hasData ?
                      // FirebaseStorageに画像があれば表示
                      InkWell(
                        child: Image.network(
                          imageSnapshot.data as String,
                          fit: BoxFit.cover,
                        ),
                      // 選択画像が無ければアイコン画像を表示
                      ) : Image.asset('images/ic_sake.png', fit: BoxFit.cover,),
                    ),
                  ),
                ),
                ///
                /// 詳細項目の表示・非表示をするためのボタン設定
                ///
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  alignment: Alignment.centerLeft,
                  child: ButtonTheme(
                    child: OutlineButton.icon(
                      color: AppThemeColor.baseColor,
                      icon: Icon(_iconData,
                        color: AppThemeColor.baseColor,
                      ),
                      label: const Text('詳細表示',
                        style: TextStyle(color: AppThemeColor.baseColor),
                      ),
                      shape: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppThemeColor.baseColor),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      onPressed: _handleVisible,
                    ),
                  ),
                ),
                ///
                /// 詳細項目の表示・非表示に合わせてコンテナサイズを変更する
                /// 非表示の場合には高さを0に設定する事で非表示状態にする
                ///
                SizeTransition(
                  sizeFactor: _controller,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _sakeRadarChart,
                      ),
                      ///
                      /// 酒舗テキスト設定
                      ///
                      titleContentContainer('酒舗', _brewery),
                      ///
                      /// 地域テキスト設定
                      ///
                      titleContentContainer('地域', _area),
                      ///
                      /// 特定名称テキスト設定
                      ///
                      titleContentContainer('特定名称', _specific),
                      ///
                      /// 精米歩合テキスト設定
                      ///
                      titleContentContainer('精米歩合(%)', _polishing),
                      ///
                      /// 原材料テキスト設定
                      ///
                      titleContentContainer('原材料', _material),
                      ///
                      /// 内容量テキスト設定
                      ///
                      titleContentContainer('内容量(ml)', _capacity),
                    ],
                  ),
                ),
                ///
                /// 購入日テキスト設定
                ///
                titleContentContainer('購入日', _purchase),
                ///
                /// 保管温度テキスト設定
                ///
                titleContentContainer('保管温度(℃)', _temperature),
                ///
                /// 飲み方テキスト設定
                ///
                titleContentContainer('飲み方', _drinking),
                ///
                /// 香りグラフのラインチャート設定
                ///
                Container(
                  padding: const EdgeInsets.all(8),
                  child: _sakeLineChart,
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget titleContentContainer(String title, String content) {
    return Container(
      color: const Color(0xfff0f0f0),
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(content,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}