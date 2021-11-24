import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:growing_sake/brand.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert' show json;
@JsonSerializable()

class CandidateListWidget extends StatelessWidget {
  const CandidateListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CandidateList(),
    );
  }
}

class CandidateList extends StatefulWidget {
  const CandidateList({Key? key}) : super(key: key);

  @override
  State<CandidateList> createState() => _CandidateListState();
}
class _CandidateListState extends State<CandidateList> {
  String _name = '';

  Future<List<Brand>> fetchBrands() async {
    final response = await http.get(Uri.parse('https://muro.sakenowa.com/sakenowa-data/api/brands'));
    if (response.statusCode == 200) {
      List<Brand> brands = [];
      Map<String, dynamic> decodeJson = json.decode(response.body);
      List<dynamic> brandList = decodeJson['brands'];
      brandList.forEach((element) {
        brands.add(Brand.fromJson(element));
      });
      return brands;
    } else {
      throw Exception('Failed to load brand');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sake Detail'),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: TextField(
              enabled: true,
              maxLines: 1,
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
              decoration: InputDecoration(
                labelText: '名称',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                filled: true,
                fillColor: Colors.blue.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),

              ),
            ),
          ),
          Flexible(child:
            FutureBuilder<List<Brand>> (
              future: fetchBrands(),
              builder: (BuildContext context, AsyncSnapshot<List<Brand>> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return _candidateItem(snapshot.data![index].name);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _candidateItem(String title) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey))
      ),
      child:ListTile(
        title: Text(
          title,
          style: const TextStyle(
              color:Colors.black,
              fontSize: 18.0
          ),
        ),
        onTap: () {
          print("onTap called.");
        }, // タップ
      ),
    );
  }
}
