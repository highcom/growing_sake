import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:growing_sake/main.dart';
import 'package:growing_sake/model/uid_docid_args.dart';
import 'package:growing_sake/util/app_theme_color.dart';
import 'package:growing_sake/util/firebase_storage_access.dart';
import 'package:growing_sake/component/sake_line_chart.dart';
import 'package:growing_sake/component/sake_radar_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

///
/// 日本酒に対する詳細内容の表示
///
class SakeDetailEditWidget extends StatefulHookConsumerWidget {
  final arguments;
  const SakeDetailEditWidget({Key? key, required this.arguments}) : super(key: key);

  @override
  ConsumerState<SakeDetailEditWidget> createState() => _SakeDetailEditState();
}

// 基本
//  銘柄名
//  サブ銘柄名
//  画像
// 詳細
//  酒舗
//  産地
//  特定名称
//  精米歩合
//  原材料
//  内容量
//  五味
// 育て方
//  保管温度
//  飲み方
//  香りグラフ
class _SakeDetailEditState extends ConsumerState<SakeDetailEditWidget> with SingleTickerProviderStateMixin {
  // 特定名称リスト
  List<String> specificList = [
    '名称',
    '吟醸酒',
    '大吟醸酒',
    '純米酒',
    '純米吟醸酒',
    '純米大吟醸酒',
    '特別純米酒',
    '本醸造酒',
    '特別本醸造酒',
  ];

  // 飲み方リスト
  List<String> drinkingList = [
    '雪冷え(5℃)',
    '花冷え(10℃)',
    '涼冷え(15℃)',
    '冷や(20℃)',
    '日向燗(30℃)',
    '人肌燗(35℃)',
    'ぬる燗(40℃)',
    '上燗(45℃)',
    '熱燗(50℃)',
    '飛び切り燗(55℃)',
  ];

  // タイムラインMAX登録数
  final int timeline_max = 100;

  // FirebaseStorageへのアップロードタスクオブジェクト
  firebase_storage.UploadTask? uploadTask;

  // ユーザーID
  late String uid;
  // ユーザー画像
  late String userImage;
  // 日本酒のドキュメントID
  String? docId;
  // 初回データ取得か？
  bool firstTime = false;

  // 選択画像ファイルオブジェクト
  File? encodeFile1;
  File? encodeFile2;

  // 詳細内容の表示非表示設定
  bool showPicker = false;
  late AnimationController _controller;
  // 詳細表示状態に応じたアイコン
  IconData _iconData = Icons.add;

  // 香グラフ用のラインチャート
  late SakeLineChart _sakeLineChart;
  // 五味グラフ用のレーダーチャート
  late SakeRadarChart _sakeRadarChart;

  // データ作成日時
  late Timestamp _createAt;
  // 日本酒の詳細内容に対する各種項目
  late DateTime _purchaseDateTime;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _subtitle = TextEditingController();
  final TextEditingController _brewery = TextEditingController();
  final TextEditingController _area = TextEditingController();
  final TextEditingController _specific = TextEditingController();
  final TextEditingController _polishing = TextEditingController();
  final TextEditingController _material = TextEditingController();
  final TextEditingController _capacity = TextEditingController();
  final TextEditingController _purchase = TextEditingController();
  final TextEditingController _temperature = TextEditingController();
  final TextEditingController _drinking = TextEditingController();

  @override
  void initState() {
    userImage = FirebaseAuth.instance.currentUser?.photoURL ?? "";
    final UidDocIdArgs uidDocIdArgs = widget.arguments as UidDocIdArgs;
    uid = uidDocIdArgs.uid;
    docId = uidDocIdArgs.docId;
    firstTime = true;
    setFilters();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    Intl.defaultLocale = 'ja_JP';
    initializeDateFormatting();
    super.initState();
  }

  setFilters() {
    setState(() {
      _specific.text = specificList[0];
      _drinking.text = drinkingList[3];
    });
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

  ///
  /// 日本酒画像設定
  ///
  Widget _setSakeImage(String num) {
    File? encodeFile;
    if (num == "_1") {
      encodeFile = encodeFile1;
    } else {
      encodeFile = encodeFile2;
    }
    return SizedBox(
      width: 300,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => _storageUpload(num),
          child: FutureBuilder<String?>(
            future: FirebaseStorageAccess.downloadFile('UserData/' + uid + '/' + docId! + num + '.JPG'),
            builder: (context, imageSnapshot) => (encodeFile == null && imageSnapshot.hasData) ?
            // FirebaseStorageに画像があれば表示
            InkWell(
              child: Image.network(
                imageSnapshot.data as String,
                fit: BoxFit.cover,
              ),
            ) : encodeFile != null ?
            // 選択された画像があれば表示
            Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: _imageDeleteButton(num),
                ),
                Image.file(encodeFile)
              ],
              // 選択画像が無ければアイコン画像を表示
            ) : Image.asset('images/ic_sake_frame.png', fit: BoxFit.cover,),
          ),
        ),
      ),
    );
  }

  ///
  /// 選択画像を詳細画面に反映させる処理
  /// ImagePickerで指定された画像を詳細画面に反映する
  ///
  Future<void> _storageUpload(String num) async {
    final xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xfile == null) return;
    final file = File(xfile.path);
    final bytes = await file.readAsBytes();
    img.Image src = img.decodeImage(bytes)!;
    img.Image croppedImage = img.copyResizeCropSquare(src, 512);
    final encFile = await File(file.path).writeAsBytes(img.encodeJpg(croppedImage));
    setState(() {
      if (num == "_1") {
        encodeFile1 = encFile;
      } else {
        encodeFile2 = encFile;
      }
    });
  }

  ///
  /// テキストエリアの入力に対する表示反映
  /// 引数で設定された文字列をテキストエリアに反映してカーソル位置を末尾に設定する
  ///
  void setControllerValue(TextEditingController controller, String? value) {
    if (value != null) {
      controller.text = value;
    } else {
      controller.text = "";
    }
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
  }

  ///
  /// 日本酒情報の取得処理
  /// ドキュメントIDに対応する日本酒のデータをFirestoreから取得してテキストエリアに反映する
  ///
  Future<DocumentSnapshot> getBrandData() async {
    Future<DocumentSnapshot> future;
    // ドキュメントIDがあれば対応する情報を取得し、新規作成の場合はデフォルトパラメータの情報を取得する
    if (uid == 'Base') {
      future = FirebaseFirestore.instance.collection(uid).doc(docId).get();
    } else {
      future = FirebaseFirestore.instance.collection('HomeData').doc('UserList').collection(uid).doc(docId).get();
    }
    // スナップショットから各種パラメータを取得
    DocumentSnapshot snapshot = await future;
    if (firstTime == true) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      // 既に作成されているデータの編集の場合には新規作成時の日付とする
      if (data.containsKey('createAt')) {
        _createAt = data['createAt'];
      } else {
        _createAt = Timestamp.fromDate(DateTime.now());
      }
      _title.text = data['title'] as String;
      _subtitle.text = data['subtitle'] as String;
      _brewery.text = data['brewery'] as String;
      _area.text = data['area'] as String;
      _specific.text = data['specific'] as String;
      _polishing.text = data['polishing'].toString();
      _material.text = data['material'] as String;
      _capacity.text = data['capacity'].toString();
      if (data.containsKey('purchase')) {
        _purchaseDateTime = data['purchase'].toDate();
      } else {
        _purchaseDateTime = DateTime.now();
      }
      _purchase.text = (DateFormat.yMMMEd()).format(_purchaseDateTime);
      _temperature.text = data['temperature'].toString();
      _drinking.text = data['drinking'] as String;

      // 香りデータがある場合にはデータを設定する
      if (data.containsKey('aromaList')) {
        List<String> _aromaList = data['aromaList'].cast<String>() as List<String>;
        List<double> _elapsedList = [];
        List<double> _levelList = [];
        for (var aroma in _aromaList) {
          List<String> _coord = aroma.split(',');
          _elapsedList.add(double.parse(_coord[0]));
          _levelList.add(double.parse(_coord[1]));
        }
        _sakeLineChart = SakeLineChart(elapsedList: _elapsedList, levelList: _levelList);
      } else {
        _sakeLineChart = SakeLineChart(elapsedList: const [], levelList: const []);
      }

      // 五味データがある場合にはデータを設定する
      if (data.containsKey('fiveFlavorList')) {
        _sakeRadarChart = SakeRadarChart(title: _title.text, fiveFlavorList: data['fiveFlavorList'].cast<String, int>() as Map<String, int>);
      } else {
        _sakeRadarChart = SakeRadarChart(title: _title.text, fiveFlavorList: const {});
      }

      firstTime = false;
    }
    return future;
  }

  ///
  /// テキストフィールドに対するフォーカス設定処理
  /// タップされたテキストフィールドに対してカーソルが当たるようにフォーカスを設定する
  ///
  void setFocusScope(BuildContext context) {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  ///
  /// 日付選択処理
  /// カレンダーを表示して選択された日付を購入日エリアに設定する
  ///
  Future<void> selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      locale: const Locale('ja'),
    );
    if (selected != null) {
      setState(() {
        _purchaseDateTime = selected;
        _purchase.text = (DateFormat.yMMMEd()).format(_purchaseDateTime);
      });
    }
  }

  ///
  /// 選択画像削除ボタン
  /// FirebaseStorageにアップロードする前の選択画像を削除する
  ///
  Widget _imageDeleteButton(String num) {
    return RaisedButton(
      child: const Icon(Icons.cancel_outlined),
      color: Colors.white,
      shape: const CircleBorder(
        side: BorderSide(
          color: Colors.white,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      onPressed: () {
        setState(() {
          if (num == "_1") {
            encodeFile1 = null;
          } else {
            encodeFile2 = null;
          }
        });
      },
    );
  }

  ///
  /// 編集画面終了
  ///
  void finish(BuildContext context) {
    // データが更新されたことを通知するために値を更新
    ref.read(updateDetailProvider.notifier).state++;
    // 編集画面を終了する
    Navigator.of(context).pop();
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
                icon: const Icon(Icons.check),
                onPressed: () async {
                  DocumentReference docRef;
                  DocumentReference timelineDocRef;
                  String wuid;
                  // 新規作成の場合は、自分のUIDにドキュメントを保存するようにuidを取得する
                  if (uid == 'Base') {
                    wuid = ref.watch(uidProvider);
                  } else {
                    wuid = uid;
                  }
                  // docIdがあれば上書き更新する
                  if (docId!.compareTo('defaultDoc') != 0) {
                    // docRef = FirebaseFirestore.instance.collection(wuid).doc(docId);
                    docRef = FirebaseFirestore.instance.collection('HomeData').doc('UserList').collection(wuid).doc(docId);
                  } else {
                    docRef = FirebaseFirestore.instance.collection('HomeData').doc('UserList').collection(wuid).doc();
                  }

                  var _fiveFlavorList = <String, int>{
                    'sweetness': _sakeRadarChart.fiveFlavorParameter.sweetness.param,
                    'sourness': _sakeRadarChart.fiveFlavorParameter.sourness.param,
                    'pungent': _sakeRadarChart.fiveFlavorParameter.pungent.param,
                    'bitterness': _sakeRadarChart.fiveFlavorParameter.bitterness.param,
                    'astringent': _sakeRadarChart.fiveFlavorParameter.astringent.param,
                  };

                  List<String> _aromaList = [];
                  for (var aroma in _sakeLineChart.aromaDataList) {
                    _aromaList.add(aroma.x.toString() + ',' + aroma.y.toString());
                  }

                  ///
                  /// 各入力項目の内容をFirestoreに反映する
                  ///
                  await docRef.set({
                        'createAt': _createAt,
                        'title': _title.text,
                        'subtitle': _subtitle.text,
                        'brewery': _brewery.text,
                        'area': _area.text,
                        'specific': _specific.text,
                        'polishing': _polishing.text,
                        'material': _material.text,
                        'capacity': _capacity.text,
                        'purchase': _purchaseDateTime,
                        'temperature': _temperature.text,
                        'drinking': _drinking.text,
                        'fiveFlavorList': _fiveFlavorList,
                        'aromaList': FieldValue.arrayUnion(_aromaList),
                  });

                  ///
                  /// タイムラインに既にtimeline_maxレコード以上ある場合には、古い方からtimeline_maxレコード未満まで削除する
                  ///
                  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Timeline').orderBy('createAt', descending: true).get();
                  int count = 1;
                  for (var doc in snapshot.docs) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    // 既存データの更新の場合には古いデータを削除する
                    if (data['uid'] == wuid && data['orgDocId'] == docRef.id) {
                      doc.reference.delete();
                    } else if (count >= timeline_max) {
                      doc.reference.delete();
                    }
                    count++;
                  }

                  ///
                  /// 登録したdocIdをFirestoreのTimelineにも反映する
                  ///
                  timelineDocRef = FirebaseFirestore.instance.collection('Timeline').doc();
                  Timestamp createAtTimestamp = Timestamp.fromDate(DateTime.now());
                  await timelineDocRef.set({
                    'uid': wuid,
                    'orgDocId': docRef.id,
                    'userImage': userImage,
                    'createAt': createAtTimestamp,
                    'title': _title.text,
                    'subtitle': _subtitle.text,
                    'brewery': _brewery.text,
                    'area': _area.text,
                    'specific': _specific.text,
                    'polishing': _polishing.text,
                    'material': _material.text,
                    'capacity': _capacity.text,
                    'purchase': _purchaseDateTime,
                    'temperature': _temperature.text,
                    'drinking': _drinking.text,
                    'fiveFlavorList': _fiveFlavorList,
                    'aromaList': FieldValue.arrayUnion(_aromaList),
                  });

                  // 選択された画像ファイルをFirebaseStorageへアップロードする
                  if (encodeFile1 != null) {
                    // 1枚目があればアップロード
                    firebase_storage.UploadTask? uploadTask = await FirebaseStorageAccess.uploadFile('UserData/' + wuid, docRef.id + '_1', XFile(encodeFile1!.path));
                    uploadTask!.whenComplete(() async {
                      // 2枚目があればアップロード
                      if (encodeFile2 != null) {
                        firebase_storage.UploadTask? uploadTask = await FirebaseStorageAccess.uploadFile('UserData/' + wuid, docRef.id + '_2', XFile(encodeFile2!.path));
                        uploadTask!.whenComplete(() {
                          finish(context);
                        });
                      } else {
                        finish(context);
                      }
                    });
                  } else if (encodeFile2 != null) {
                    // 2枚目のみの場合はここでアップロード
                    firebase_storage.UploadTask? uploadTask = await FirebaseStorageAccess.uploadFile('UserData/' + wuid, docRef.id + '_2', XFile(encodeFile2!.path));
                    uploadTask!.whenComplete(() {
                      finish(context);
                    });
                  } else {
                    finish(context);
                  }
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
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: GestureDetector(
                    onTap: () => setFocusScope(context),
                    child: TextField(
                      controller: _title,
                      enabled: true,
                      maxLines: 1,
                      onTap: () {
                        List<String> params = ['銘柄名', _title.text];
                        Navigator.of(context).pushNamed("/candidate_list", arguments: params).then((value) {
                          if (value != null) {
                            Map<String, String> result = value as Map<String, String>;
                            _title.text = result['brand'] as String;
                            if (result['brewery'] != '') {
                              _brewery.text = result['brewery'] as String;
                            }
                            if (result['area'] != '') {
                              _area.text = result['area'] as String;
                            }
                          }
                          FocusManager.instance.primaryFocus!.unfocus();
                        });
                      },
                      decoration: const TextFieldDecoration('銘柄名'),
                    ),
                  ),
                ),
                //
                // サブ銘柄名テキストフィールド設定
                //
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: GestureDetector(
                    onTap: () => setFocusScope(context),
                    child: TextField(
                      controller: _subtitle,
                      enabled: true,
                      maxLines: 1,
                      decoration: const TextFieldDecoration('サブ銘柄名'),
                    ),
                  ),
                ),
                ///
                /// 日本酒の写真設定
                ///
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // 1枚目
                      _setSakeImage("_1"),
                      // 2枚目
                      _setSakeImage("_2"),
                    ],
                  ),
                ),
                ///
                /// 詳細項目の表示・非表示をするためのボタン設定
                ///
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  alignment: Alignment.centerLeft,
                  child: ButtonTheme(
                    child: OutlinedButton.icon(
                      icon: Icon(_iconData,
                        color: AppThemeColor.baseColor,
                      ),
                      label: const Text('詳細表示',
                        style: TextStyle(color: AppThemeColor.baseColor),
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
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                        child: _sakeRadarChart,
                      ),
                      ///
                      /// 酒舗テキストフィールド設定
                      ///
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: GestureDetector(
                          onTap: () => setFocusScope(context),
                          child: TextField(
                            controller: _brewery,
                            enabled: true,
                            maxLines: 1,
                            decoration: const TextFieldDecoration('酒舗'),
                          ),
                        ),
                      ),
                      ///
                      /// 地域テキストフィールド設定
                      ///
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: GestureDetector(
                          onTap: () => setFocusScope(context),
                          child: TextField(
                            controller: _area,
                            enabled: true,
                            maxLines: 1,
                            decoration: const TextFieldDecoration('地域'),
                          ),
                        ),
                      ),
                      ///
                      /// 特定名称テキストフィールド設定
                      /// 特定名称リストから選択する
                      ///
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: DropdownButtonFormField<String>(
                          decoration: const TextFieldDecoration('特定名称'),
                          value: _specific.text,
                          onChanged: (value) {
                            setControllerValue(_specific, value);
                          },
                          items: specificList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      ///
                      /// 精米歩合テキストフィールド設定
                      /// 数値のみの入力に制限する
                      ///
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: GestureDetector(
                          onTap: () => setFocusScope(context),
                          child: TextField(
                            controller: _polishing,
                            enabled: true,
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter
                                .digitsOnly
                            ],
                            decoration: const TextFieldWithSuffixDecoration(
                                '精米歩合', '％'),
                          ),
                        ),
                      ),
                      ///
                      /// 原材料テキストフィールド設定
                      ///
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: GestureDetector(
                          onTap: () => setFocusScope(context),
                          child: TextField(
                            controller: _material,
                            enabled: true,
                            maxLines: 1,
                            decoration: const TextFieldDecoration('原材料'),
                          ),
                        ),
                      ),
                      ///
                      /// 内容量テキストフィールド設定
                      /// 数値のみの入力に制限する
                      ///
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: GestureDetector(
                          onTap: () => setFocusScope(context),
                          child: TextField(
                            controller: _capacity,
                            enabled: true,
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter
                                .digitsOnly
                            ],
                            decoration: const TextFieldWithSuffixDecoration(
                                '内容量', 'ml'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ///
                /// 購入日テキストフィールド設定
                /// タップしてカレンダーから日付を選択する
                ///
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: GestureDetector(
                    onTap: () => setFocusScope(context),
                    child: TextField(
                      controller: _purchase,
                      enabled: true,
                      readOnly: true,
                      maxLines: 1,
                      onTap: () => selectDate(context),
                      decoration: const TextFieldDecoration('購入日'),
                    ),
                  ),
                ),
                ///
                /// 保管温度テキストフィールド設定
                /// 数値のみの入力に制限する
                ///
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: GestureDetector(
                    onTap: () => setFocusScope(context),
                    child: TextField(
                      controller: _temperature,
                      enabled: true,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const TextFieldWithSuffixDecoration('保管温度', '度'),
                    ),
                  ),
                ),
                ///
                /// 飲み方テキストフィールド設定
                ///
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: DropdownButtonFormField<String>(
                    decoration: const TextFieldDecoration('飲み方'),
                    value: _drinking.text,
                    onChanged: (value) {
                      setControllerValue(_drinking, value);
                    },
                    items: drinkingList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
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
      },
    );
  }
}

///
/// テキストフィールドのデコレーション設定
/// 詳細画面でのテキストフィールドのデコレーション設定を設定する
///
class TextFieldDecoration extends InputDecoration {
  const TextFieldDecoration(String text) : super(
    labelText: text,
    hintText: '未記入',
    hintStyle: const TextStyle(color: Color(0xFFC0C0C0)),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    filled: true,
    border: const UnderlineInputBorder(),
  );
}

///
/// サフィックス付きテキストフィールドのデコレーション設定
/// 単位などをサフィックスで付けるようなテキストフィールドのデコレーションを設定する
///
class TextFieldWithSuffixDecoration extends InputDecoration {
  const TextFieldWithSuffixDecoration(String text, String suffix) : super(
    labelText: text,
    hintText: '未記入',
    hintStyle: const TextStyle(color: Color(0xFFC0C0C0)),
    suffixText: suffix,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    filled: true,
    border: const UnderlineInputBorder(),
  );
}
