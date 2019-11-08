import 'package:sict/tools/date.dart' as date;
import 'package:test/test.dart';
import 'package:sict/tools/Sict.dart';

main(){
  date_test();
  test('', ()=>expect(date.thisWeek(DateTime.now()),1));

}
date_test(){
  test('', ()=>
      expect(date.getSemesterStartDate(), DateTime(2019,6,10))
  );

  group('',(){
    test('', ()=>expect(date.getMondayDate(DateTime(2019,6,9)),DateTime(2019,6,3)));
    test('', ()=>expect(date.getMondayDate(DateTime(2019,6,3)),DateTime(2019,6,3)));
    test('', ()=>expect(date.getMondayDate(DateTime(2019,6,5)),DateTime(2019,6,3)));
  });

  test('', ()=>expect(date.inWeeks(DateTime(2019,6,3).difference(DateTime(2019,6,3))),0));
  test('', ()=>expect(date.inWeeks(DateTime(2019,6,9).difference(DateTime(2019,6,3))),0));
  test('', ()=>expect(date.inWeeks(DateTime(2019,6,10).difference(DateTime(2019,6,3))),1));

  test('', ()=>expect(date.getWhichWeek(DateTime(2019,6,3),(DateTime(2019,6,3))),1));
  test('', ()=>expect(date.getWhichWeek(DateTime(2019,6,3),(DateTime(2019,6,9))),1));
  test('', ()=>expect(date.getWhichWeek(DateTime(2019,6,3),(DateTime(2019,6,10))),2));
  test('', ()=>expect(date.getWhichWeek(DateTime(2019,6,3),(DateTime(2019,6,16))),2));
  test('', ()=>expect(date.getWhichWeek(DateTime(2019,6,9),(DateTime(2019,6,9))),1));
  test('', ()=>expect(date.getWhichWeek(DateTime(2019,6,9),(DateTime(2019,6,10))),2));
  test('', ()=>expect(date.getWhichWeek(DateTime(2019,6,9),(DateTime(2019,6,16))),2));

  test('', ()=>expect(()=>date.getWhichWeek(DateTime(2019,6,9),(DateTime(2019,6,1))),
      allOf(throwsArgumentError,messageIs(
          'oneDayInTheSemester must be after semesterStartDate '
              'the oneDayInTheSemester: ${DateTime(2019,6,1)}' " isn't after "
              'semesterStartDate: ${DateTime(2019,6,9)}'
      ))
  ));


  test('', ()=>expect(date.thisWeek(DateTime.now()),1));
}
class messageIs extends Matcher{
  String message;
  @override
  Description describe(Description description) {
    // TODO: implement describe
    return null;
  }

  @override
  bool matches(item, Map matchState) {
    try{
      item();
    }catch (e){
      return e.message==message;
    }
    return false;
  }

  messageIs(this.message);

}