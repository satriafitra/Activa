String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour >= 6 && hour < 12) return 'Good morning!';
  if (hour >= 12 && hour < 15) return 'Good day!';
  if (hour >= 15 && hour < 18) return 'Good afternoon!';
  return 'Good evening!';
}

String getTimeBasedBannerImage() {
  final hour = DateTime.now().hour;
  if (hour >= 6 && hour < 12) return 'assets/images/morning.png';
  if (hour >= 12 && hour < 15) return 'assets/images/day.png';
  if (hour >= 15 && hour < 18) return 'assets/images/afternoon.png';
  return 'assets/images/evening.png';
}

String getDayName(int weekday) {
  switch (weekday) {
    case 1: return 'Senin';
    case 2: return 'Selasa';
    case 3: return 'Rabu';
    case 4: return 'Kamis';
    case 5: return 'Jumat';
    case 6: return 'Sabtu';
    case 7: return 'Minggu';
    default: return '';
  }
}
