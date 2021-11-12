import 'package:flutter/material.dart';

class SakeGridViewWidget extends StatelessWidget {
  final Color color;
  final String title;

  const SakeGridViewWidget({Key? key, required this.color, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Grid List',
      home: Scaffold(
        body: GridView.count(
          padding: const EdgeInsets.all(4.0),
          crossAxisCount: 3,
          crossAxisSpacing: 10.0, // 縦
          mainAxisSpacing: 10.0, // 横
          childAspectRatio: 0.7, // 高さ
          shrinkWrap: true,
          children: List.generate(100, (index) {

            var assetsImage = "images/ic_sake.png";

            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(5.0, 5.0),
                    blurRadius: 10.0,
                  )
                ],
              ),
              child:Column(
                  children: <Widget>[
                    Image.asset(assetsImage, fit: BoxFit.cover,),
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      child: Text(
                        'Meeage $index',
                      ),
                    ),
                  ]
              ),
            );
          }),
        ),
      ),
    );
  }
}
