

class Task {
  Task(
      {this.id,
      this.title,
      this.note,
      this.isCompleted,
      this.date,
      this.startTime,
      this.endTime,
      this.color,
      this.remind,
      this.repeat});
  int? id;
  String? title;
  String? note;
  int? isCompleted;
  String? date;
  String? startTime;
  String? endTime;
  int? color;
  int? remind;
  String? repeat;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "note": note,
      "date": date,
      "startTime": startTime,
      "endTime": endTime,
      "remind": remind,
      "repeat": repeat,
      "color": color,
      "isCompleted": isCompleted,
    };
  }

  Task.fromJson(Map<String, dynamic> jason) {
    id = jason["id"];
    title = jason["title"];
    note = jason["note"];
    isCompleted = jason["isCompleted"];
    date = jason["date"];
    startTime = jason["startTime"];
    endTime = jason["endTime"];
    color = jason["color"];
    remind = jason["remind"];
    repeat = jason["repeat"];
  }
}
