part of tremor_tracking;

class ResultsPage extends StatefulWidget {
  ResultsPage();
  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  List<Result> results = [];
  List<Result> rightResults = [];
  List<Result> leftResults = [];
  bool isLoading = false;

  @override
  void dispose() {
    ResultsDatabase.instance.close();
    super.dispose();
  }

  Future refreshResults() async {
    setState(() => isLoading = true);
    this.results = await ResultsDatabase.instance.readAllResults();
    this.rightResults = await ResultsDatabase.instance.readAllRightResults();
    this.leftResults = await ResultsDatabase.instance.readAllLeftResults();
    print(this.results);
    setState(() => isLoading = false);
  }

  //late Future<Result> futureResults;

  // double getMagnitude(List<double> data) {
  //   print(data[0]);
  //   return sqrt((pow(data[0], 2) + (pow(data[1], 2) + (pow(data[2], 2)))));
  // }

  // void printResults() {
  //   // widget.values.forEach((time, measurement) {
  //   //   double magnitude = getMagnitude(measurement);
  //   //   _str += 'time\t| measurement\t| magnitude\n';
  //   //   _str += '$time\t| $measurement\t| $magnitude\n';
  //   // });
  //   widget.values.forEach((value) {
  //     // print(value[0]);
  //     _str += ' \ttime\t| \tx\t| \ty\t| \tz\t| \ttotal\n';
  //     _str += '$value';
  //   });

  //   //print(_str);
  // }

  // PREPROCESSING
  // Data should be a uniform sampling – there should be an equal amount of time between each data timepoint.
  // Use an interpolation to get uniform data.

//   void preprocessing() {
//     // Create DF
//     widget.df.show();

//     // Get the median time interval
//     Array intervals = Array.empty();

//     for (int i = 1; i < widget.df.length; i++) {
//       intervals.add(widget.df.colRecords('time')[i] - widget.df.colRecords('time')[i - 1]);
//     }
//     double interval = median(intervals);
//     print("interval");
//     print(interval);

// // Generate uniform time interval

//     List<double> newTimes = [];
//     for (double i = widget.df.colRecords('time')[0];
//         i < widget.df.colRecords('time')[widget.df.colRecords('time').length - 1];
//         i + interval) {
//       print('I:');
//       i = i + interval;
//       print(i);
//       newTimes.add(i);
//     }
//     print("length");
//     print(newTimes.length);
// // widget.df.addRecords(records)

// //     var value = lerpDouble(10, 20, 0.5);

// // Interpolate using the values of the magnitude and the new time interval

// // FFT
//   }

  // double interpolate (DataFrame df, DateTime x){

  //   return df.colRecords('total')[i] + (x - df.colRecords('time')[i]) * ((d[1][1] - d[0][1])/(d[1][0] - d[0][0]))

  //   def interpolation(d, x):
  //   output = d[0][1] + (x - d[0][0]) * ((d[1][1] - d[0][1])/(d[1][0] - d[0][0]))

  //   return output

  // }
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(
        textAlignment: ChartAlignment.center,
        enable: true,
        canShowMarker: false,
        header: '',
        format: 'Time : point.x\nFrequency : point.y\nMagnitude : point.size');

    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.x,
      enablePanning: true,
    );
    super.initState();
    refreshResults();
  }

  List<BubbleSeries<Result, DateTime>> _getPointColorBubbleSeries() {
    return <BubbleSeries<Result, DateTime>>[
      BubbleSeries<Result, DateTime>(
        dataSource: results,
        opacity: 0.8,
        xValueMapper: (Result result, _) => result.dateTime as DateTime,
        yValueMapper: (Result result, _) => result.frequency,

        /// It helps to render a bubble series as various colors,
        /// which is given by user from data soruce.
        pointColorMapper: (Result result, _) => Color(result.pointColor),
        sizeValueMapper: (Result result, _) => result.magnitude,
      )
    ];
  }

  List<BubbleSeries<Result, DateTime>> _getRightHandSeries() {
    return <BubbleSeries<Result, DateTime>>[
      BubbleSeries<Result, DateTime>(
        dataSource: rightResults,
        opacity: 0.8,
        xValueMapper: (Result result, _) => result.dateTime as DateTime,
        yValueMapper: (Result result, _) => result.frequency,

        /// It helps to render a bubble series as various colors,
        /// which is given by user from data soruce.
        pointColorMapper: (Result result, _) => Color(result.pointColor),
        sizeValueMapper: (Result result, _) => result.magnitude,
      )
    ];
  }

  List<BubbleSeries<Result, DateTime>> _getLeftHandSeries() {
    return <BubbleSeries<Result, DateTime>>[
      BubbleSeries<Result, DateTime>(
        dataSource: leftResults,
        opacity: 0.8,
        xValueMapper: (Result result, _) => result.dateTime as DateTime,
        yValueMapper: (Result result, _) => result.frequency,

        /// It helps to render a bubble series as various colors,
        /// which is given by user from data soruce.
        pointColorMapper: (Result result, _) => Color(result.pointColor),
        sizeValueMapper: (Result result, _) => result.magnitude,
      )
    ];
  }

  List<ChartSeries> _getScoreSeries() {
    return <ChartSeries>[
      LineSeries<Result, DateTime>(
        dataSource: results,
        xValueMapper: (Result result, _) => result.dateTime as DateTime,
        yValueMapper: (Result result, _) => result.frequency * result.magnitude,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        child: SfCartesianChart(
                          title: ChartTitle(text: 'Measurments timeline'),
                          plotAreaBorderWidth: 0,
                          primaryXAxis: DateTimeAxis(
                            intervalType: DateTimeIntervalType.auto,
                            //desiredIntervals: 2,
                            minorTicksPerInterval: 2,
                            //dateFormat: DateFormat.Md(),
                          ),
                          primaryYAxis: NumericAxis(
                              numberFormat: NumberFormat.compact(),
                              title: AxisTitle(text: 'Frequency'),
                              axisLine: const AxisLine(width: 0),
                              minimum: 0,
                              maximum: 5,
                              rangePadding: ChartRangePadding.additional,
                              majorTickLines: const MajorTickLines(size: 0)),
                          series: _getPointColorBubbleSeries(),
                          tooltipBehavior: _tooltipBehavior,
                          zoomPanBehavior: _zoomPanBehavior,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(children: [
                          Icon(Icons.circle, color: Color(0xFF9C27B0), size: 12.0),
                          Text('  Left hand'),
                        ]),
                        Row(children: [
                          Icon(Icons.circle, color: Color(0xFF2196F3), size: 12.0),
                          Text('  Right hand'),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        child: SfCartesianChart(
                          title: ChartTitle(text: 'Right hand'),
                          plotAreaBorderWidth: 0,
                          primaryXAxis: DateTimeAxis(intervalType: DateTimeIntervalType.hours),
                          primaryYAxis: NumericAxis(
                              numberFormat: NumberFormat.compact(),
                              title: AxisTitle(text: 'Frequency'),
                              axisLine: const AxisLine(width: 0),
                              minimum: 0,
                              maximum: 5,
                              rangePadding: ChartRangePadding.additional,
                              majorTickLines: const MajorTickLines(size: 0)),
                          series: _getRightHandSeries(),
                          tooltipBehavior: _tooltipBehavior,
                          zoomPanBehavior: _zoomPanBehavior,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        child: SfCartesianChart(
                          title: ChartTitle(text: 'Left hand'),
                          plotAreaBorderWidth: 0,
                          primaryXAxis: DateTimeAxis(intervalType: DateTimeIntervalType.hours),
                          primaryYAxis: NumericAxis(
                              numberFormat: NumberFormat.compact(),
                              title: AxisTitle(text: 'Frequency'),
                              axisLine: const AxisLine(width: 0),
                              minimum: 0,
                              maximum: 5,
                              rangePadding: ChartRangePadding.additional,
                              majorTickLines: const MajorTickLines(size: 0)),
                          series: _getLeftHandSeries(),
                          tooltipBehavior: _tooltipBehavior,
                          zoomPanBehavior: _zoomPanBehavior,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        child: SfCartesianChart(
                          title: ChartTitle(text: 'Tremor score'),
                          plotAreaBorderWidth: 0,
                          primaryXAxis: DateTimeAxis(intervalType: DateTimeIntervalType.hours),
                          primaryYAxis: NumericAxis(
                              numberFormat: NumberFormat.compact(),
                              title: AxisTitle(text: 'Score'),
                              axisLine: const AxisLine(width: 0),
                              rangePadding: ChartRangePadding.additional,
                              majorTickLines: const MajorTickLines(size: 0)),
                          series: _getScoreSeries(),
                          tooltipBehavior: _tooltipBehavior,
                          zoomPanBehavior: _zoomPanBehavior,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScoreResult {
  ScoreResult(this.dateTime, this.score);
  final DateTime dateTime;
  final double score;
}
