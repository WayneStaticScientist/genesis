class GenesisDate {
  static String formatMonthAndDay(DateTime dateTime) {
    return "${getMonthName(dateTime.month)} ${dateTime.day}";
  }

  static String formatNormalDate(DateTime dateTime) {
    return "${getWeekDayName(dateTime)} ${dateTime.day} ${getMonthName(dateTime.month)} ${dateTime.year}";
  }

  static String formatNormalDateN(DateTime? dateTime) {
    if (dateTime == null) return "";
    return "${getWeekDayName(dateTime)} ${dateTime.day} ${getMonthName(dateTime.month)} ${dateTime.year}";
  }

  static String getInformalDate(DateTime dateTime) {
    return "${getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  static String getInformalShortDate(DateTime dateTime) {
    return "${getShortMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}";
  }

  static String getDays(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    if (difference.inSeconds < 60) {
      return "${difference.inSeconds} s";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hrs";
    }
    return "${difference.inDays} day(s)";
  }

  static String getLastSeen(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inSeconds < 60) {
      return "${difference.inSeconds} s";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hrs";
    } else if (difference.inDays < 2) {
      return "${difference.inDays} day(s)";
    }
    return "${getShortMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}";
  }

  static int getDaysDifference(DateTime to) {
    final from = DateTime.now();
    return to.difference(from).inDays;
  }

  static String getWeekDayName(DateTime dateTime) {
    switch (dateTime.weekday) {
      case DateTime.monday:
        return "Monday";
      case DateTime.tuesday:
        return "Tuesday";
      case DateTime.wednesday:
        return "Wednesday";
      case DateTime.thursday:
        return "Thursday";
      case DateTime.friday:
        return "Friday";
      case DateTime.saturday:
        return "Saturday";
      case DateTime.sunday:
        return "Sunday";
      default:
        return "";
    }
  }

  static String getMonthName(int month) {
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "";
    }
  }

  static String getShortMonthName(int month) {
    switch (month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "Aug";
      case 9:
        return "Sept";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
      default:
        return "";
    }
  }

  static formatSortableDate(DateTime createdAt) {
    return "${createdAt.year}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')} ${getWeekDayName(createdAt)} ${createdAt.day} ${getShortMonthName(createdAt.month)}";
  }
}
