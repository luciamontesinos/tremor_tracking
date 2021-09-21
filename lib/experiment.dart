part of tremor_tracking;

class Experiment extends StatefulWidget {
  @override
  _ExperimentState createState() => _ExperimentState();
}

class _ExperimentState extends State<Experiment> {
  Map<String, List<double>> _values = {};

  void startExperiment() {
    print("Starting experiment");
    userAccelerometerEvents.listen(
      (UserAccelerometerEvent event) {
        String timestamp = DateTime.now().toString();
        _values[timestamp] = <double>[event.x, event.y, event.z];
      },
    );
  }

  void stopExperiment() {
    print("Experiment stoped");
    String _str = 'MEASUREMENTS \t| #\n';

    _values.forEach((time, measurement) {
      double magnitude = getMagnitude(measurement);
      _str += '$time\t| $measurement\t| $magnitude\n';
    });

    print(_str);
  }

  double getMagnitude(List<double> data) {
    print(data[0]);
    return sqrt((pow(data[0], 2) + (pow(data[1], 2) + (pow(data[2], 2)))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => startExperiment(),
            child: Text("Start experiment"),
          ),
          ElevatedButton(
            onPressed: () => stopExperiment(),
            child: Text("Stop experiment"),
          ),
        ],
      ),
    );
  }
}
