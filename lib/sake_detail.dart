import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class SakeDetailWidget extends StatelessWidget {
  SakeDetailWidget({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sake Detail'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('香りグラフ'),
            SizedBox(
              height: 250,
              child: charts.TimeSeriesChart(
                _createAromaData(aromaList),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final aromaList = <AromaData>[
    AromaData(DateTime(2020, 10, 2), 50),
    AromaData(DateTime(2020, 10, 3), 53),
    AromaData(DateTime(2020, 10, 4), 40)
  ];

  List<charts.Series<AromaData, DateTime>> _createAromaData(
      List<AromaData> aromaList) {
    return [
      charts.Series<AromaData, DateTime>(
        id: 'Muscles',
        data: aromaList,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (AromaData aromaData, _) => aromaData.date,
        measureFn: (AromaData aromaData, _) => aromaData.level,
      )
    ];
  }
}

class AromaData {
  final DateTime date;
  final double level;

  AromaData(this.date, this.level);
}
