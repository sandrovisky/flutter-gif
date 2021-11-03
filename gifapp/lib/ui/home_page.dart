import 'package:flutter/material.dart';

import 'package:gifapp/ui/gif_page.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:share/share.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _search = "";
  int _offSet = 0;

  Future<Map> _getGifs() async {
    String trendingURL =
        "https://api.giphy.com/v1/gifs/trending?api_key=qk3y6ApIWjD1CGbNrIoc2I2uM01XGwd6&limit=19&rating=g";
    String searchURL =
        "https://api.giphy.com/v1/gifs/search?api_key=qk3y6ApIWjD1CGbNrIoc2I2uM01XGwd6&q=$_search&limit=19&offset=$_offSet&rating=g&lang=en";

    http.Response response; //

    if (_search.isEmpty) {
      response = await http.get(Uri.parse(trendingURL));
    } else {
      response = await http.get(Uri.parse(searchURL));
    }

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          const Text(
            "Made by Sandrovisky",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: TextField(
                decoration: const InputDecoration(
                  suffixIcon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  border: OutlineInputBorder(),
                  labelText: "Search",
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
                onSubmitted: (text) {
                  setState(() {
                    _search = text;
                  });
                }),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return _createGifTable(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (index < snapshot.data["data"].length || _search.isEmpty) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                height: 300,
                fit: BoxFit.cover,
								placeholder: kTransparentImage, 
								image: snapshot.data["data"][index]["images"]["fixed_height"]["url"]
							),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data["data"][index])));
              },
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]
                    ["fixed_height"]["url"]);
              },
            );
          } else {
            return GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70,
                  ),
                  Text(
                    "Carregar mais...",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _offSet += 19;
                });
              },
            );
          }
        });
  }
}
