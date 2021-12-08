part of tremor_tracking;

class MeasurementSteps extends StatefulWidget {
  @override
  _MeasurementSteps createState() => _MeasurementSteps();
}

class _MeasurementSteps extends State<MeasurementSteps> {
  int _currentStep = 0;
  late String hand;
  String message = "Processing...";
  bool experimentSent = false;

  int dotCount = 3;
  List<int> steps = [0, 1, 2];
  late DataFrame df = DataFrame();

  late VideoPlayerController _videoPlayerController;
  late VideoPlayerController _loadingPlayerController;
  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.asset('assets/videos/tutorial1.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.setLooping(true);
        _videoPlayerController.play();
      });
    _loadingPlayerController = VideoPlayerController.asset('assets/videos/loading.mp4')
      ..initialize().then((_) {
        setState(() {});
        _loadingPlayerController.setPlaybackSpeed(0.5);
        _loadingPlayerController.play();
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
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
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: steps.asMap().entries.map(
                    (step) {
                      var index = step.value;
                      return Container(
                        width: 7.0,
                        height: 7.0,
                        margin: EdgeInsets.symmetric(horizontal: 6.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index <= _currentStep
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).primaryColor.withOpacity(0.5)),
                      );
                    },
                  ).toList(),
                ),
                SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getContent(context),
                    SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "The experiment is about to start".toUpperCase(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'MuseoSans',
                  letterSpacing: 1.5,
                  color: Color(0xff463f57)),
            ),
            SizedBox(height: 10),
            Text(
              "Please hold the phone with one hand and avoid sudden movements",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'MuseoSans',
                  color: Color(0xff463f57)),
            ),
            SizedBox(height: 10),
            Container(
              child: _videoPlayerController.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController))
                  : SizedBox.shrink(),
            ),
            SizedBox(height: 20),
            Text(
              "Select hand to start".toUpperCase(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'MuseoSans',
                  letterSpacing: 1.5,
                  color: Color(0xff463f57)),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image(image: AssetImage("assets/images/left1.png"), height: 110),
                      onTap: () {
                        setState(() {
                          hand = 'left';
                          _currentStep++;
                        });
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image(image: AssetImage("assets/images/right1.png"), height: 110),
                      onTap: () {
                        setState(() {
                          hand = 'right';
                          _currentStep++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ]),
        );
      case 1:
        _loadingPlayerController.play();
        startExperiment();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Experiment in progress".toUpperCase(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'MuseoSans',
                  letterSpacing: 1.5,
                  color: Color(0xff463f57)),
            ),
            Text(
              "Please avoid sudden movements",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'MuseoSans',
                  color: Color(0xff463f57)),
            ),
            SizedBox(height: 10),
            _loadingPlayerController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _loadingPlayerController.value.aspectRatio,
                    child: VideoPlayer(_loadingPlayerController))
                : SizedBox.shrink(),
            SizedBox(height: 10),
          ],
        );
      case 2:
        if (!experimentSent)
          stopExperiment().then((value) => {
                setState(() {
                  message = value;
                  experimentSent = true;
                }),
                Timer(Duration(seconds: 3), () {
                  Navigator.of(context).pop();
                }),
              });
        return (Text(message.toUpperCase(),
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'MuseoSans',
                letterSpacing: 1.5,
                color: Color(0xff463f57))));
      default:
        return SizedBox.shrink();
    }
  }

  void startExperiment() {
    df = DataFrame();
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
        double total = sqrt((pow(event.x, 2) + (pow(event.y, 2) + (pow(event.z, 2)))));
        df.addRow(
            <String, Object>{'time': timestamp, 'x': event.x, 'y': event.y, 'z': event.z, 'total': total});
      },
    );
    Timer(Duration(seconds: 3), () {
      setState(() {
        _currentStep++;
      });
    });
  }

  Future<String> stopExperiment() async {
    String message;
    print("Experiment stoped");
    var response = await sendResults(df);
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);
      saveResult(response, hand);
      message = "The experiment has been saved";
    } else {
      message = "An error has ocurred, the experiment was not saved";
    }
    return message;
  }

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

  Future saveResult(var response, String hand) async {
    Map<String, dynamic> json = parseResponse(response.body);

    int color = hand == 'right' ? 0xFF2196F3 : 0xFF9C27B0;

    String date = json['timestamp'].replaceAll(",", "").replaceAll('/', '-');
    String month = date.split('-')[0];
    String day = date.split('-')[1];
    String year = date.split('-')[2].split(' ')[0];
    String time = date.split(' ')[1];
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
}
