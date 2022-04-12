import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const artColor = Color(0xff63e7e5);
const baseColor = Color(0x44afafaf);

///
/// 五味グラフ用レーダーチャート
/// [title] グラフタイトル
/// [fiveFlavorList] 五味データ
///
class SakeRadarChartThumb extends StatefulWidget {
  final Map<String, int> fiveFlavorList;
  final FiveFlavorParameter fiveFlavorParameter = FiveFlavorParameter();

  SakeRadarChartThumb({Key? key, required this.fiveFlavorList}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SakeRadarChartThumbState();
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

class _SakeRadarChartThumbState extends State<SakeRadarChartThumb> {

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
        title: '五味',
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ///
        /// レーダーチャート本体
        ///
        AspectRatio(
          aspectRatio: 1.0,
          child: RadarChart(
            RadarChartData(
              dataSets: showingDataSets(
                  selectedDataSetIndex),
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: const BorderSide(
                  color: Colors.transparent),
              titlePositionPercentageOffset: 0.1,
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
      ],
    );
  }
}
