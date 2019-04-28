class Course {
  String name,classRoom,teacher;
  int weekday,startLesson,endLesson;
  String weeks;
  int startWeek,endWeek;
  Course({this.name, this.classRoom, this.teacher, this.startWeek,
    this.endWeek, this.weekday, this.startLesson, this.endLesson,this.weeks}){
    if ((startWeek==null||endWeek==null)&&weeks!=null) {
      startWeek=weeks.indexOf('1');
      endWeek=weeks.indexOf('1');
    }

  }
  //教师姓名不对,姓名应该是下一个课程的
  static List<Course> creatList(String htmlString){
    List<Course> courses=List();
    int index =htmlString.indexOf('activity = new TaskActivity');//设置每个课程的代码分别以activity = new TaskActivity开头,
    htmlString=htmlString.substring(index);                              //去除第一个课程代码前面的无用部分

    htmlString.split('</script>')[0]//去除脚本后的部分
        .split('activity = new TaskActivity').sublist(1)//生成列表并跳过(为空字符串的)首元素
        .map((s)=>s.split('var actTeachers')[0])//再次去除无用的后半部分
        .where((s)=>!s.contains('停课'))//停课则跳过
    .forEach((s){//遍历
      var data =s.split(';');

      var couresData=data[0].split(',').sublist(5).map((s)=>s.replaceAll('"', '')).toList(); //整理字符串生成的部分数据如例,并去除双引号:["科研设计与论文撰写(B005007-2.01)","1839" "本部C401", "01111111111111110000000000000000000000000000000000000"]
      assert(couresData.length==9||couresData.length==10);
      if (couresData.length==10) {//如果上课地点中出现了逗号,调整一下
        couresData[2]=couresData[2]+couresData[3];
        couresData.removeAt(3);
      }

      Course c=Course(name: couresData[0],classRoom: couresData[2],weeks: couresData[3]);
      data.sublist(1).map((s)=>s.trim()).where((s)=>s.startsWith('index')).forEach((s){//data.sublist(1)主要包含教师名及上课时间
        c.weekday=int.parse(s[7])+1;//星期几
        int lesson=int.parse(s[19])+1;//第几节

        if (c.startLesson!=null) {
          if (c.startLesson>lesson)c.startLesson=lesson;
        }else {
          c.startLesson=lesson;
        }

        if (c.endLesson!=null) {
          if (c.endLesson<lesson)c.endLesson=lesson;
        }else {
          c.endLesson=lesson;
        }

      });
      if(data[data.length-2].trim().startsWith('var teachers')) {
        c.teacher=data[data.length-2].split(',')[1].split(':')[1];
      }
      assert(c.startWeek>0);
      courses.add(c);
    });
    return courses;;
  }
  @override
  String toString() {
    var shortName=name.contains('(')?name.split('(')[0]:name;
    return '$shortName\n$classRoom';
  }

}