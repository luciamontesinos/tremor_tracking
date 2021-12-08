library tremor_tracking;

import 'dart:async';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:df/df.dart';
import 'package:scidart/numdart.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

part 'results_page.dart';
part 'result.dart';
part 'db.dart';
part 'steps.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff463f57),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                        image: AssetImage("assets/images/logo.png"),
                        width: MediaQuery.of(context).size.width * 0.8),
                  ],
                ),
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xff463f57),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                            context, MaterialPageRoute(builder: (context) => MeasurementSteps())),
                        child: Text("New measurement".toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'MuseoSans',
                              letterSpacing: 1.5,
                            )),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xff463f57),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsPage())),
                        child: Text(
                          "View Results".toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'MuseoSans',
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
