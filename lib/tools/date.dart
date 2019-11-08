int thisWeek(DateTime semesterStartDate) {
return getWhichWeek(semesterStartDate, DateTime.now());
}
 getWhichWeek(DateTime semesterStartDate,DateTime oneDayInTheSemester){
  if(oneDayInTheSemester.isBefore(semesterStartDate)){
    throw ArgumentError(
        'oneDayInTheSemester must be after semesterStartDate '
            'the oneDayInTheSemester: $oneDayInTheSemester' " isn't after "
            'semesterStartDate: $semesterStartDate'
    );
  }else{
    return inWeeks(oneDayInTheSemester.difference(getMondayDate(semesterStartDate)))+1;
  }
}
 int inWeeks(Duration dur) {

return dur.inDays~/7;
}

 DateTime getMondayDate(DateTime oneDayOfTheWeek){
return oneDayOfTheWeek.subtract(Duration(days: oneDayOfTheWeek.weekday-1));
}


DateTime getSemesterStartDate() => DateTime(2019,8,26);