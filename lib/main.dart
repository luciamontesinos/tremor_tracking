library tremor_tracking;

import 'dart:async';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:df/df.dart';
import 'package:scidart/numdart.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

part 'experiment.dart';
part 'results_page.dart';
part 'result.dart';
part 'db.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  // Map<String, List<double>> _values = {};
  Map<String, dynamic> row = {};
  List rows = [];
  late DataFrame df = DataFrame();

  Future saveResult(var response, String hand) async {
    Map<String, dynamic> json = parseResponse(response.body);

    int color = hand == 'right' ? 0xFF2196F3 : 0xFF9C27B0;

    String date = json['timestamp'].replaceAll(",", "").replaceAll('/', '-');
    String month = date.split('-')[0];
    String day = date.split('-')[1];
    String year = date.split('-')[2].split(' ')[0];
    String time = date.split(' ')[1];
    //print(Colors.blue.);
    final result = Result(
        frequency: json['frequency'],
        magnitude: json['magnitude'],
        dateTime: DateTime.parse("$year-$month-$day $time"),
        pointColor: color);
    await ResultsDatabase.instance.create(result);
  }

  Map<String, dynamic> parseResponse(String response) {
    return jsonDecode(response);
  }

  @override
  Widget build(BuildContext context) {
    /// Stop experiment and send data to sever

    void stopExperiment(String hand) async {
      print("Experiment stoped");
      var response = await sendResults(df);
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(response.body);
        saveResult(response, hand);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The experiment has been saved")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("An error has ocurred, the experiment was not saved")));
      }

      Navigator.pop(context);
    }

    /// Tutorial video config
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: '6pKqv_JKKYo',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: true,
      ),
    );

    /// Dialog to start the experiment
    final AlertDialog experimentDialog = AlertDialog(
      title: Text("Experiment in progress...\nPlease avoid sudden movements"),
      contentPadding: EdgeInsets.all(10),
      insetPadding: EdgeInsets.all(10),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          LoadingIndicator(
            indicatorType: Indicator.ballScaleMultiple,
            colors: _kDefaultRainbowColors,
            strokeWidth: 2,
          ),
          SizedBox(height: 10),
          Text("Please select the hand:"),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () => stopExperiment('left'),
              child: Text("Left"),
            ),
            ElevatedButton(
              onPressed: () => stopExperiment('right'),
              child: Text("Right"),
            ),
          ],
        ),
      ],
    );

    /// Dialog to see a tutorial video
    final AlertDialog tutorialDialog = AlertDialog(
      title: Text("Tutorial"),
      contentPadding: EdgeInsets.all(10),
      insetPadding: EdgeInsets.all(10),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: false,
              controlsTimeOut: Duration(milliseconds: 1),
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Skip"),
        ),
      ],
    );

    void startExperiment() {
      df = DataFrame();
      showDialog<void>(context: context, builder: (context) => experimentDialog, barrierDismissible: false);
      print("Starting experiment");
      df.setColumns([
        DataFrameColumn(name: 'time', type: DateTime),
        DataFrameColumn(name: 'x', type: double),
        DataFrameColumn(name: 'y', type: double),
        DataFrameColumn(name: 'z', type: double),
        DataFrameColumn(name: 'total', type: double),
      ]);

      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          double timestamp = DateTime.now().toUtc().millisecondsSinceEpoch / 1000;
          // _values[timestamp] = <double>[event.x, event.y, event.z];
          double total = sqrt((pow(event.x, 2) + (pow(event.y, 2) + (pow(event.z, 2)))));
          // row = {'time': timestamp, 'x': event.x, 'y': event.y, 'z': event.z, 'total': total};
          // rows.add(row);
          df.addRow(
              <String, Object>{'time': timestamp, 'x': event.x, 'y': event.y, 'z': event.z, 'total': total});
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ButtonBar(
            buttonPadding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            buttonAlignedDropdown: true,
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => startExperiment(),
                child: Text("Start experiment"),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsPage())),
                child: Text("Results"),
              ),
              ElevatedButton(
                onPressed: () => showDialog<void>(
                    context: context, builder: (context) => tutorialDialog, barrierDismissible: false),
                //Navigator.push(context, MaterialPageRoute(builder: (context) => Experiment())),
                child: Text("Tutorial"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  /// Experiment in progress indicator colors
  static List<Color> _kDefaultRainbowColors = const [
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  /// Send results to server
  Future<http.Response> sendResults(DataFrame df) async {
    var response = await http.post(
      Uri.parse('https://luciamontesinos.pythonanywhere.com/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'time': df.colRecords('time'),
        'x': df.colRecords('x'),
        'y': df.colRecords('y'),
        'z': df.colRecords('z'),
        'total': df.colRecords('total')
      }),
    );
    return response;
  }
}
