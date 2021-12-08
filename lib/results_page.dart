part of tremor_tracking;

class ResultsPage extends StatefulWidget {
  ResultsPage();
  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  List<Result> results = [];
  List<Result> _results = [];
  List<Result> rightResults = [];
  List<Result> leftResults = [];
  bool isLoading = false;

  late ResultsDataSource resultsDataSource;

  @override
  void dispose() {
    ResultsDatabase.instance.close();
    super.dispose();
  }

  Future refreshResults() async {
    setState(() => isLoading = true);
    this.results = await ResultsDatabase.instance.readAllResults();
    _results = results;
    this.rightResults = await ResultsDatabase.instance.readAllRightResults();
    this.leftResults = await ResultsDatabase.instance.readAllLeftResults();
    setState(() => isLoading = false);
  }

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
    resultsDataSource = ResultsDataSource(resultList: _results);
  }

  List<BubbleSeries<Result, DateTime>> _getPointColorBubbleSeries() {
    return <BubbleSeries<Result, DateTime>>[
      BubbleSeries<Result, DateTime>(
        dataSource: results,
        opacity: 0.8,
        xValueMapper: (Result result, _) => result.dateTime as DateTime,
        yValueMapper: (Result result, _) => result.frequency,
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
        pointColorMapper: (Result result, _) => Color(result.pointColor),
        sizeValueMapper: (Result result, _) => result.magnitude,
      )
    ];
  }

  List<ChartSeries> _getScoreSeries() {
    return <ChartSeries>[
      LineSeries<Result, DateTime>(
        dataSource: leftResults,
        isVisible: true,
        width: 2,
        xValueMapper: (Result result, _) => result.dateTime as DateTime,
        yValueMapper: (Result result, _) => result.frequency * result.magnitude,
        markerSettings: MarkerSettings(isVisible: true),
        color: Color(0xFF2196F3),
      ),
      LineSeries<Result, DateTime>(
        dataSource: rightResults,
        isVisible: true,
        width: 2,
        xValueMapper: (Result result, _) => result.dateTime as DateTime,
        yValueMapper: (Result result, _) => result.frequency * result.magnitude,
        markerSettings: MarkerSettings(isVisible: true),
        color: Color(0xFF9C27B0),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 20, bottom: 5),
            child: Row(
              children: [
                Image(image: AssetImage("assets/images/logo.png"), height: 60),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
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
                                title: ChartTitle(
                                    text: 'Measurements timeline'.toUpperCase(),
                                    textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'MuseoSans',
                                        letterSpacing: 2,
                                        color: Color(0xff463f57))),
                                plotAreaBorderWidth: 0,
                                primaryXAxis: DateTimeAxis(
                                  intervalType: DateTimeIntervalType.auto,
                                  rangePadding: ChartRangePadding.additional,
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
                                title: ChartTitle(
                                    text: 'Right hand'.toUpperCase(),
                                    textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'MuseoSans',
                                        letterSpacing: 2,
                                        color: Color(0xff463f57))),
                                plotAreaBorderWidth: 0,
                                primaryXAxis: DateTimeAxis(
                                    intervalType: DateTimeIntervalType.hours,
                                    rangePadding: ChartRangePadding.additional),
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
                                title: ChartTitle(
                                    text: 'Left hand'.toUpperCase(),
                                    textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'MuseoSans',
                                        letterSpacing: 2,
                                        color: Color(0xff463f57))),
                                plotAreaBorderWidth: 0,
                                primaryXAxis: DateTimeAxis(
                                    intervalType: DateTimeIntervalType.hours,
                                    rangePadding: ChartRangePadding.additional),
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
                                title: ChartTitle(
                                    text: 'Tremor score'.toUpperCase(),
                                    textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'MuseoSans',
                                        letterSpacing: 2,
                                        color: Color(0xff463f57))),
                                plotAreaBorderWidth: 0.7,
                                primaryXAxis: DateTimeAxis(
                                    intervalType: DateTimeIntervalType.auto,
                                    rangePadding: ChartRangePadding.additional),
                                primaryYAxis: NumericAxis(
                                    numberFormat: NumberFormat.compact(),
                                    title: AxisTitle(text: 'Score'),
                                    axisLine: const AxisLine(width: 1),
                                    rangePadding: ChartRangePadding.normal,
                                    majorTickLines: const MajorTickLines(size: 0)),
                                series: _getScoreSeries(),
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
                  // DATA GRID

                  // Card(
                  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  //   elevation: 10,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(10.0),
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Center(
                  //           child: SfDataGrid(
                  //             source: resultsDataSource,
                  //             columns: [
                  //               GridColumn(
                  //                   columnName: 'Time',
                  //                   label: Container(
                  //                       padding: EdgeInsets.symmetric(horizontal: 16.0),
                  //                       alignment: Alignment.centerRight,
                  //                       child: Text(
                  //                         'Time',
                  //                         overflow: TextOverflow.ellipsis,
                  //                       ))),
                  //               GridColumn(
                  //                   columnName: 'Frequency',
                  //                   label: Container(
                  //                       padding: EdgeInsets.symmetric(horizontal: 16.0),
                  //                       alignment: Alignment.centerLeft,
                  //                       child: Text(
                  //                         'Frequency',
                  //                         overflow: TextOverflow.ellipsis,
                  //                       ))),
                  //               GridColumn(
                  //                   columnName: 'Magnitude',
                  //                   label: Container(
                  //                       padding: EdgeInsets.symmetric(horizontal: 16.0),
                  //                       alignment: Alignment.centerLeft,
                  //                       child: Text(
                  //                         'Magnitude',
                  //                         overflow: TextOverflow.ellipsis,
                  //                       ))),
                  //               GridColumn(
                  //                   columnName: 'Hand',
                  //                   label: Container(
                  //                       padding: EdgeInsets.symmetric(horizontal: 16.0),
                  //                       alignment: Alignment.centerLeft,
                  //                       child: Text(
                  //                         'Hand',
                  //                         overflow: TextOverflow.ellipsis,
                  //                       ))),
                  //             ],
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreResult {
  ScoreResult(this.dateTime, this.score);
  final DateTime dateTime;
  final double score;
}

class ResultsDataSource extends DataGridSource {
  ResultsDataSource({required List<Result> resultList}) {
    print(resultList);
    dataGridRows = resultList
        .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
              DataGridCell<dynamic>(columnName: 'Time', value: dataGridRow.dateTime),
              DataGridCell<num>(columnName: 'Frequency', value: dataGridRow.frequency),
              DataGridCell<num>(columnName: 'Magnitude', value: dataGridRow.magnitude),
              DataGridCell<String>(
                  columnName: 'Hand', value: dataGridRow.pointColor == 0xFF2196F3 ? 'Right' : 'Left'),
            ]))
        .toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
          ));
    }).toList());
  }
}
