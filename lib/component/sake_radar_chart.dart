import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const artColor = Color(0xff63e7e5);
const baseColor = Color(0x44afafaf);

///
/// 五味グラフ用レーダーチャート
/// [title] グラフタイトル
/// [fiveFlavorList] 五味データ
///
class SakeRadarChart extends StatefulWidget {
  final String title;
  final Map<String, int> fiveFlavorList;
  final editEnable;
  final FiveFlavorParameter fiveFlavorParameter = FiveFlavorParameter();

  SakeRadarChart({Key? key, required this.title, required this.fiveFlavorList, this.editEnable = true}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SakeRadarChartState();
}

const gridColor = Color(0xff68739f);
const titleColor = Color(0xff8c95db);

///
/// プリミティブ型データ設定
///
class PrimitiveParameter {
  int param;
  PrimitiveParameter({required this.param});
}

///
/// 五味データ
///
class FiveFlavorParameter {
  final PrimitiveParameter sweetness = PrimitiveParameter(param: 3);
  final PrimitiveParameter sourness = PrimitiveParameter(param: 3);
  final PrimitiveParameter pungent = PrimitiveParameter(param: 3);
  final PrimitiveParameter bitterness = PrimitiveParameter(param: 3);
  final PrimitiveParameter astringent = PrimitiveParameter(param: 3);
}

///
/// レーダーチャート用RAWデータ
///
class RawDataSet {
  final String title;
  final Color color;
  final List<double> values;

  RawDataSet({
    required this.title,
    required this.color,
    required this.values,
  });
}

class _SakeRadarChartState extends State<SakeRadarChart> {

  // 選択データINDEX
  int selectedDataSetIndex = -1;

  @override
  void initState() {
    // 五味データの初期値を設定する
    setState(() {
      if (widget.fiveFlavorList.containsKey('sweetness')) {
        widget.fiveFlavorParameter.sweetness.param = widget.fiveFlavorList['sweetness']!;
      }
      if (widget.fiveFlavorList.containsKey('sourness')) {
        widget.fiveFlavorParameter.sourness.param = widget.fiveFlavorList['sourness']!;
      }
      if (widget.fiveFlavorList.containsKey('pungent')) {
        widget.fiveFlavorParameter.pungent.param = widget.fiveFlavorList['pungent']!;
      }
      if (widget.fiveFlavorList.containsKey('bitterness')) {
        widget.fiveFlavorParameter.bitterness.param = widget.fiveFlavorList['bitterness']!;
      }
      if (widget.fiveFlavorList.containsKey('astringent')) {
        widget.fiveFlavorParameter.astringent.param = widget.fiveFlavorList['astringent']!;
      }
    });
    super.initState();
  }

  ///
  /// レーダーチャート表示データ設定
  /// [selectedDataSetIndex] 選択データINDEX
  ///
  List<RadarDataSet> showingDataSets(int selectedDataSetIndex) {
    return rawDataSets().asMap().entries.map((entry) {
      var index = entry.key;
      var rawDataSet = entry.value;

      final isSelected = index == selectedDataSetIndex
          ? true
          : selectedDataSetIndex == -1
          ? true
          : false;

      return RadarDataSet(
        fillColor: isSelected
            ? rawDataSet.color.withOpacity(0.2)
            : rawDataSet.color.withOpacity(0.05),
        borderColor:
        isSelected ? rawDataSet.color : rawDataSet.color.withOpacity(0.25),
        entryRadius: isSelected ? 3 : 2,
        dataEntries:
        rawDataSet.values.map((e) => RadarEntry(value: e)).toList(),
        borderWidth: isSelected ? 2.3 : 2,
      );
    }).toList();
  }

  ///
  /// レーダーチャート用RAWデータ設定
  ///
  List<RawDataSet> rawDataSets() {
    return [
      RawDataSet(
        title: widget.title,
        color: artColor,
        values: [
          widget.fiveFlavorParameter.sweetness.param.toDouble(),
          widget.fiveFlavorParameter.sourness.param.toDouble(),
          widget.fiveFlavorParameter.pungent.param.toDouble(),
          widget.fiveFlavorParameter.bitterness.param.toDouble(),
          widget.fiveFlavorParameter.astringent.param.toDouble(),
        ],
      ),
      RawDataSet(
        title: '最大',
        color: baseColor,
        values: [
          5,
          5,
          5,
          5,
          5,
        ],
      ),
      RawDataSet(
        title: '最小',
        color: baseColor,
        values: [
          1,
          1,
          1,
          1,
          1,
        ],
      ),
    ];
  }

  ///
  /// 円形ボタンウィジェット
  /// [icon] ボタンに表示するアイコン
  /// [stateSetter] setStateするオブジェクト
  /// [parameter] 五味データ
  /// [value] 増減値
  ///
  Widget roundRaisedButton(IconData icon, StateSetter stateSetter, PrimitiveParameter parameter, int value) {
    return RaisedButton(
      child: Icon(icon),
      color: Colors.white,
      shape: const CircleBorder(
        side: BorderSide(
          color: Colors.black,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      onPressed: () {
        stateSetter(() {
          if ((value < 0 && parameter.param > 1) || (value > 0 && parameter.param < 5)) {
            parameter.param += value;
          }
        });
      },
    );
  }

  ///
  /// 五味データ入力ダイアログ
  ///
  Future<FiveFlavorParameter?> showInputDialog(BuildContext context, FiveFlavorParameter params) {
    FiveFlavorParameter _fiveFlavor = FiveFlavorParameter();
    _fiveFlavor = params;

    return showDialog<FiveFlavorParameter>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('五味データ入力'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Column(
                    children: [
                      Row(
                        children: [
                          const Text('甘味'),
                          roundRaisedButton(Icons.remove, setState, _fiveFlavor.sweetness, -1),
                          Text(_fiveFlavor.sweetness.param.toString()),
                          roundRaisedButton(Icons.add, setState, _fiveFlavor.sweetness, 1),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('酸味'),
                          roundRaisedButton(Icons.remove, setState, _fiveFlavor.sourness, -1),
                          Text(_fiveFlavor.sourness.param.toString()),
                          roundRaisedButton(Icons.add, setState, _fiveFlavor.sourness, 1),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('辛味'),
                          roundRaisedButton(Icons.remove, setState, _fiveFlavor.pungent, -1),
                          Text(_fiveFlavor.pungent.param.toString()),
                          roundRaisedButton(Icons.add, setState, _fiveFlavor.pungent, 1),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('苦味'),
                          roundRaisedButton(Icons.remove, setState, _fiveFlavor.bitterness, -1),
                          Text(_fiveFlavor.bitterness.param.toString()),
                          roundRaisedButton(Icons.add, setState, _fiveFlavor.bitterness, 1),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('渋味'),
                          roundRaisedButton(Icons.remove, setState, _fiveFlavor.astringent, -1),
                          Text(_fiveFlavor.astringent.param.toString()),
                          roundRaisedButton(Icons.add, setState, _fiveFlavor.astringent, 1),
                        ],
                      ),
                    ], // コンテンツ
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, _fiveFlavor),
                child: const Text('OK'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      decoration: const BoxDecoration(color: Color(0xfff0f0f0)),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ///
          /// レーダーチャート本体
          ///
          AspectRatio(
            aspectRatio: 1.3,
            child: RadarChart(
              RadarChartData(
                radarTouchData: RadarTouchData(
                    touchCallback: (FlTouchEvent event,
                        response) async {
                      if (!event.isInterestedForInteractions) {
                        setState(() {
                          selectedDataSetIndex = -1;
                        });
                        if (widget.editEnable && response != null) {
                          FiveFlavorParameter? returnParams = await showInputDialog(context, widget.fiveFlavorParameter);
                          setState(() {
                            if (returnParams != null) {
                              widget.fiveFlavorParameter.sweetness.param = returnParams.sweetness.param;
                              widget.fiveFlavorParameter.sourness.param = returnParams.sourness.param;
                              widget.fiveFlavorParameter.pungent.param = returnParams.pungent.param;
                              widget.fiveFlavorParameter.bitterness.param = returnParams.bitterness.param;
                              widget.fiveFlavorParameter.astringent.param = returnParams.astringent.param;
                            }
                          });
                        }
                        return;
                      }
                      setState(() {
                        selectedDataSetIndex =
                            response?.touchedSpot
                                ?.touchedDataSetIndex ?? -1;
                      });
                    }),
                dataSets: showingDataSets(
                    selectedDataSetIndex),
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: const BorderSide(
                    color: Colors.transparent),
                titlePositionPercentageOffset: 0.2,
                titleTextStyle:
                const TextStyle(
                    color: titleColor, fontSize: 14),
                getTitle: (index) {
                  switch (index) {
                    case 0:
                      return '甘味';
                    case 1:
                      return '酸味';
                    case 2:
                      return '辛味';
                    case 3:
                      return '苦味';
                    case 4:
                      return '渋味';
                    default:
                      return '';
                  }
                },
                tickCount: 1,
                ticksTextStyle:
                const TextStyle(color: Colors.transparent,
                    fontSize: 10),
                tickBorderData: const BorderSide(
                    color: Colors.transparent),
                gridBorderData: const BorderSide(
                    color: gridColor, width: 2),
              ),
              swapAnimationDuration: const Duration(
                  milliseconds: 400),
            ),
          ),
          ///
          /// グラフタイトル
          ///
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('五味グラフ'),
            ],
          ),
        ],
      ),
    );
  }
}