import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:growing_sake/app_theme_color.dart';
import 'package:growing_sake/sake_line_chart.dart';
import 'package:growing_sake/sake_radar_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class SakeDetailWidget extends StatefulWidget {
  final arguments;
  const SakeDetailWidget({Key? key, required this.arguments}) : super(key: key);

  @override
  State<SakeDetailWidget> createState() => _SakeDetailState();
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
class _SakeDetailState extends State<SakeDetailWidget> with SingleTickerProviderStateMixin {
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

  String? docId;
  bool firstTime = false;

  bool showPicker = false;
  late AnimationController _controller;
  IconData _iconData = Icons.add;

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
    if (widget.arguments != null) {
      docId = widget.arguments as String;
    }
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

  void setControllerValue(TextEditingController controller, String? value) {
    if (value != null) {
      controller.text = value;
    } else {
      controller.text = "";
    }
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
  }

  Future<DocumentSnapshot> getBrandData() async {
    Future<DocumentSnapshot> future;
    if (docId != null) {
      future = FirebaseFirestore.instance.collection('Brands').doc(docId).get();
    } else {
      future = FirebaseFirestore.instance.collection('Base').doc('defaultDoc').get();
    }
    DocumentSnapshot snapshot = await future;
    if (firstTime == true) {
      _title.text = snapshot.get('title');
      _subtitle.text = snapshot.get('subtitle');
      _brewery.text = snapshot.get('brewery');
      _area.text = snapshot.get('area');
      _specific.text = snapshot.get('specific');
      _polishing.text = snapshot.get('polishing').toString();
      _material.text = snapshot.get('material');
      _capacity.text = snapshot.get('capacity').toString();
      if (docId != null) {
        _purchaseDateTime = snapshot.get('purchase').toDate();
      } else {
        _purchaseDateTime = DateTime.now();
      }
      _purchase.text = (DateFormat.yMMMEd()).format(_purchaseDateTime);
      _temperature.text = snapshot.get('temperature').toString();
      _drinking.text = snapshot.get('drinking');
      firstTime = false;
    }
    return future;
  }

  void setFocusScope(BuildContext context) {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (selected != null) {
      setState(() {
        _purchaseDateTime = selected;
        _purchase.text = (DateFormat.yMMMEd()).format(_purchaseDateTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getBrandData(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('Brands')
                      .doc()
                      .set({
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
                      });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
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
                      decoration: TextFieldDecoration('銘柄名'),
                    ),
                  ),
                ),
                Container(
                  height: 45,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: GestureDetector(
                    onTap: () => setFocusScope(context),
                    child: TextField(
                      controller: _subtitle,
                      enabled: true,
                      maxLines: 1,
                      decoration: TextFieldDecoration('サブ銘柄名'),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('images/ic_sake.png'),
                ),
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
                SizeTransition(
                  sizeFactor: _controller,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SakeRadarChart(title: _title.text),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: GestureDetector(
                          onTap: () => setFocusScope(context),
                          child: TextField(
                            controller: _brewery,
                            enabled: true,
                            maxLines: 1,
                            decoration: TextFieldDecoration('酒舗'),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: GestureDetector(
                          onTap: () => setFocusScope(context),
                          child: TextField(
                            controller: _area,
                            enabled: true,
                            maxLines: 1,
                            decoration: TextFieldDecoration('地域'),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: DropdownButtonFormField<String>(
                          decoration: TextFieldDecoration('特定名称'),
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
                            decoration: TextFieldWithSuffixDecoration(
                                '精米歩合', '％'),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: GestureDetector(
                          onTap: () => setFocusScope(context),
                          child: TextField(
                            controller: _material,
                            enabled: true,
                            maxLines: 1,
                            decoration: TextFieldDecoration('原材料'),
                          ),
                        ),
                      ),
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
                            decoration: TextFieldWithSuffixDecoration(
                                '内容量', 'ml'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                      decoration: TextFieldDecoration('購入日'),
                    ),
                  ),
                ),
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
                      decoration: TextFieldWithSuffixDecoration('保管温度', '度'),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: DropdownButtonFormField<String>(
                    decoration: TextFieldDecoration('飲み方'),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const SakeLineChart(),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class TextFieldDecoration extends InputDecoration {
  TextFieldDecoration(String text) : super(
    labelText: text,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    filled: true,
    fillColor: AppThemeColor.baseColor.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}

class TextFieldWithSuffixDecoration extends InputDecoration {
  TextFieldWithSuffixDecoration(String text, String suffix) : super(
    labelText: text,
    suffixText: suffix,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    filled: true,
    fillColor: AppThemeColor.baseColor.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}
