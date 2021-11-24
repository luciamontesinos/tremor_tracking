part of tremor_tracking;

class Album {
  final int userId;
  final int id;
  final String title;

  Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}


// var data = await getData('http://10.0.2.2:5000/);
// var decodedData = jsonDecode(data);
// print(decodedData['query']);