class User {

  String name,major,classeAndGrade,account,faculty,entranceTime,graduationTime;

  User({this.name, this.major, this.classeAndGrade, this.account,
      this.faculty, this.entranceTime, this.graduationTime});

  @override
  String toString() {
    return   '''
$name
$major
$classeAndGrade
$account
$faculty
$entranceTime - $graduationTime
''';
  }

}