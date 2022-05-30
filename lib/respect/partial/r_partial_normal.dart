import 'package:game/respect/partial/r_partial.dart';

class RPartialNormal with RPartialData {
  String pic;
  String type;
  RPartialNormal({
    required this.pic,
    required this.type,
  });

  factory RPartialNormal.fromJson(Map<String, dynamic> json) {
    return RPartialNormal(
      pic: json['pic'],
      type: json['type']
    );
  }

  @override
  void supplement(Map<String, dynamic> json) {
    if (json["pic"] == null) {
      json["pic"] = pic;
    }
    if (json["type"] == null) {
      json["type"] = type;
    }
  }
}
