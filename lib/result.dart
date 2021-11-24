part of tremor_tracking;

final String resultsTable = 'results';

class ResultFields {
  static final List<String> values = [id, dateTime, frequency, magnitude, pointColor];
  static final String id = '_id';
  static final String dateTime = 'dateTime';
  static final String frequency = 'frequency';
  static final String magnitude = 'magnitude';
  static final String pointColor = 'pointColor';
}

class Result {
  // id
  final int? id;

  /// Holds x value of the datapoint: DateTime
  final dynamic dateTime;

  /// Holds y value of the datapoint: Frequency
  final num frequency;

  /// Holds size of the datapoint: Magnitude
  final num magnitude;

  /// Holds point color of the datapoint: User Input
  final int pointColor;

  const Result({
    this.id,
    required this.dateTime,
    required this.frequency,
    required this.magnitude,
    required this.pointColor,
  });

  Result copy({
    int? id,
    dynamic dateTime,
    num? frequency,
    num? magnitude,
    int? pointColor,
  }) =>
      Result(
        id: id ?? this.id,
        dateTime: dateTime ?? this.dateTime,
        frequency: frequency ?? this.frequency,
        magnitude: magnitude ?? this.magnitude,
        pointColor: pointColor ?? this.pointColor,
      );

  static Result fromJson(Map<String, Object?> json) => Result(
        id: json[ResultFields.id] as int?,
        dateTime: DateTime.parse(json[ResultFields.dateTime] as String),
        frequency: json[ResultFields.frequency] as num,
        magnitude: json[ResultFields.magnitude] as num,
        pointColor: json[ResultFields.pointColor] as int, //HexColor(json[ResultFields.pointColor] as String),
      );

  Map<String, Object?> toJson() => {
        ResultFields.id: id,
        ResultFields.dateTime: dateTime.toString(),
        ResultFields.frequency: frequency,
        ResultFields.magnitude: magnitude,
        ResultFields.pointColor: pointColor, //.toString(),
      };
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
