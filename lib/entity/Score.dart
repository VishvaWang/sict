class Score {
  String name,dailyPerformance,finalExam,finalGrade;

  Score.name({this.name, this.dailyPerformance, this.finalExam, this.finalGrade});

  @override
  String toString() {
    return 'name: $name, dailyPerformance: $dailyPerformance, finalExam: $finalExam, finalGrade: $finalGrade}';
  }
}