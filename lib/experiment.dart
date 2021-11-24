part of tremor_tracking;

class Experiment extends StatefulWidget {
  @override
  _ExperimentState createState() => _ExperimentState();
}

class _ExperimentState extends State<Experiment> {
  @override
  Widget build(BuildContext context) {
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: '6pKqv_JKKYo',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: true,
      ),
    );

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
          Text("Tutorial text")
        ],
      ),
    );
  }
}
