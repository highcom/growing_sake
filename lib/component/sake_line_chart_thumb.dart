import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

///
/// 香りグラフ用ラインチャート
/// [elapsedList] x軸の値となる経過日数
/// [levelList] y軸の値となる香りレベル
///
class SakeLineChartThumb extends StatefulWidget {
  final List<double> elapsedList;
  final List<double> levelList;
  final List<FlSpot> aromaDataList = [];

  SakeLineChartThumb({Key? key, required this.elapsedList, required this.levelList}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SakeLineChartThumbState();
}

class _SakeLineChartThumbState extends State<SakeLineChartThumb> with SingleTickerProviderStateMixin {
  // 折れ線用のグラデーションカラー
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  // 香りデータ入力エリア表示・非表示設定
  bool showPicker = false;
  late AnimationController _controller;

  // 開始日
  double _startDate = 0;
  // 終了日
  double _endDate = 0;

  @override
  void initState() {
    Intl.defaultLocale = 'ja_JP';
    initializeDateFormatting();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // コンストラクタで渡されたパラメータをグラフデータリストに追加していく
    setState(() {
      for (int i = 0; i < widget.elapsedList.length && i < widget.levelList.length; i++) {
        FlSpot data = FlSpot(widget.elapsedList[i], widget.levelList[i]);
        widget.aromaDataList.add(data);
      }
      if (widget.elapsedList.isNotEmpty && widget.levelList.isNotEmpty) {
        widget.aromaDataList.sort((left, right) => left.x.compareTo(right.x));
        _startDate = widget.aromaDataList.first.x;
        _endDate = widget.aromaDataList.last.x;
      }
    });

    super.initState();
  }

  ///
  /// ラインチャートデータ作成処理メイン
  ///
  LineChartData mainData() {
    return LineChartData(
      ///
      /// x軸y軸メモリ表示設定
      ///
      titlesData: FlTitlesData(
        show: false,
      ),
      ///
      /// 香りデータのラインチャート表示設定
      ///
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: _startDate,
      maxX: _endDate,
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: widget.aromaDataList,
          isCurved: true,
          colors: gradientColors,
          barWidth: 3,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
            gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 2.5,
          child: Container(
            child: LineChart(mainData()),
          ),
        ),
      ],
    );
  }
}
