import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:growing_sake/app_theme_color.dart';
import 'package:growing_sake/sake_line_chart.dart';
import 'package:growing_sake/sake_radar_chart.dart';
import 'package:growing_sake/candidate_list.dart';

class SakeDetailWidget extends StatefulWidget {
  const SakeDetailWidget({Key? key}) : super(key: key);

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

  String args = '';

  bool showPicker = false;
  late AnimationController _controller;
  IconData _iconData = Icons.add;
  String _specific = '';
  String _polishing = '';
  String _material = '';
  String _capacity = '';
  String _purchase = '';
  String _temperature = '';
  String _drinking = '';

  // TODO:他の入力項目も定義する
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subTitleController = TextEditingController();
  final TextEditingController _breweryController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  int selectedDataSetIndex = -1;

  @override
  void initState() {
    setFilters();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    super.initState();
  }

  setFilters() {
    setState(() {
      _specific = specificList[0];
      _drinking = drinkingList[3];
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

  Future<DocumentSnapshot> getBrandData() async {
    Future<DocumentSnapshot> future = FirebaseFirestore.instance.collection('BrandList').doc(args).get();
    DocumentSnapshot snapshot = await future;
    _titleController.text = snapshot.get('title');
    _subTitleController.text = snapshot.get('subtitle');
    // TODO:一覧と合わないデータが入るとエラーになるので一旦コメントアウト
    // _brewery = snapshot.get('brewery');
    // _area = snapshot.get('area');
    _specific = snapshot.get('specific');
    _polishing = snapshot.get('polishingRate').toString();
    _material = snapshot.get('rawMaterial');
    _capacity = snapshot.get('capacity').toString();
    // _purchase = snapshot.get('purchase');
    _temperature = snapshot.get('storageTemperature').toString();
    // _drinking = snapshot.get('howToDrink');
    return future;
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      args = ModalRoute.of(context)!.settings.arguments as String;
    } else {
      args = '9s7xq5AmBX6jXKRRICK8';
    }
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
                  await FirebaseFirestore.instance.collection('BrandList')
                      .doc()
                      .set({
                    'title': _titleController.text,
                    'subtitle': _subTitleController.text,
                    'brewery': _breweryController.text,
                    'area': _areaController.text,
                    'specific': _specific,
                    'polishingRate': _polishing,
                    'rawMaterial': _material,
                    'capacity': _capacity,
                    'purchase': _purchase,
                    'storageTemperture': _temperature,
                    'howToDrink': _drinking,
                  });
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
                  child: TextField(
                    controller: _titleController,
                    enabled: true,
                    maxLines: 1,
                    onTap: () {
                      final FocusScopeNode currentScope = FocusScope.of(context);
                      if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                        FocusManager.instance.primaryFocus!.unfocus();
                      } else {
                        List<String> params = ['銘柄名', _titleController.text];
                        Navigator.of(context).pushNamed("/candidate_list", arguments: params).then((value) {
                          if (value != null) {
                            Map<String, String> result = value as Map<String, String>;
                            if (result['brand'] != null) {
                              _titleController.text = result['brand'] as String;
                              _breweryController.text = result['brewery'] as String;
                              _areaController.text = result['area'] as String;
                            }
                          }
                        });
                      }
                    },
                    decoration: TextFieldDecoration('銘柄名'),
                  ),
                ),
                Container(
                  height: 45,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    enabled: true,
                    maxLines: 1,
                    onChanged: (value) {
                      _subTitleController.text = value;
                    },
                    decoration: TextFieldDecoration('サブ銘柄名'),
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
                        child: SakeRadarChart(title: _titleController.text),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: TextField(
                          enabled: true,
                          maxLines: 1,
                          controller: _breweryController,
                          onChanged: (value) {
                            _breweryController.text = value;
                          },
                          decoration: TextFieldDecoration('酒舗'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: TextField(
                          enabled: true,
                          maxLines: 1,
                          controller: _areaController,
                          onChanged: (value) {
                            _areaController.text = value;
                          },
                          decoration: TextFieldDecoration('地域'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: DropdownButtonFormField<String>(
                          decoration: TextFieldDecoration('特定名称'),
                          value: _specific,
                          onChanged: (v) {
                            setState(() {
                              _specific = v!;
                            });
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
                        child: TextField(
                          enabled: true,
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter
                              .digitsOnly
                          ],
                          onChanged: (value) {
                            setState(() {
                              _polishing = value;
                            });
                          },
                          decoration: TextFieldWithSuffixDecoration(
                              '精米歩合', '％'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: TextField(
                          enabled: true,
                          maxLines: 1,
                          onChanged: (value) {
                            setState(() {
                              _material = value;
                            });
                          },
                          decoration: TextFieldDecoration('原材料'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: TextField(
                          enabled: true,
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter
                              .digitsOnly
                          ],
                          onChanged: (value) {
                            setState(() {
                              _capacity = value;
                            });
                          },
                          decoration: TextFieldWithSuffixDecoration(
                              '内容量', 'ml'),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    enabled: true,
                    maxLines: 1,
                    onChanged: (value) {
                      setState(() {
                        _purchase = value;
                      });
                    },
                    decoration: TextFieldDecoration('購入日'),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    enabled: true,
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      setState(() {
                        _temperature = value;
                      });
                    },
                    decoration: TextFieldWithSuffixDecoration('保管温度', '度'),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: DropdownButtonFormField<String>(
                    decoration: TextFieldDecoration('飲み方'),
                    value: _drinking,
                    onChanged: (v) {
                      setState(() {
                        _drinking = v!;
                      });
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
