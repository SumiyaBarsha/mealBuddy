import 'package:shared_preferences/shared_preferences.dart';
bool isAdmin=false;
String mealtype= 'breakfast',eatenBreakfast='Recommended 255 - 383 kcal',eatenLunch='Recommended 383 - 510 kcal',eatenDinner='Recommended 383 - 510 kcal';
double kcalLeftValue = 0.0, kcalTotalValue = 0.0, kcalEatenValue = 0.0, eatenFat=0.0 , eatenCarbs=0.0 , eatenProtein=0.0 , totalProtein=0.0;
int filledGlasses = 0;

class PreferencesService {
  late final SharedPreferences prefs;

  PreferencesService._internal();

  static final PreferencesService _instance = PreferencesService._internal();

  factory PreferencesService() {
    return _instance;
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }
  Future<void> saveData({
    required String mealType,
    required String eatenBreakfast,
    required String eatenLunch,
    required String eatenDinner,
    required double kcalLeftValue,
    required double kcalEatenValue,
    required double eatenFat,
    required double eatenCarbs,
    required double eatenProtein,
    required int filledGlasses,
    required bool isAdmin,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('mealType', mealType);
    await prefs.setString('eatenBreakfast', eatenBreakfast);
    await prefs.setString('eatenLunch', eatenLunch);
    await prefs.setString('eatenDinner', eatenDinner);
    await prefs.setDouble('kcalLeftValue', kcalLeftValue);
    await prefs.setDouble('kcalEatenValue', kcalEatenValue);
    await prefs.setDouble('eatenFat', eatenFat);
    await prefs.setDouble('eatenCarbs', eatenCarbs);
    await prefs.setDouble('eatenProtein', eatenProtein);
    await prefs.setInt('filledGlasses', filledGlasses);
    await prefs.setBool('isAdmin', isAdmin);
  }

  Future<Map<String, dynamic>> loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return {
      'mealType': prefs.getString('mealType') ?? 'breakfast',
      'eatenBreakfast': prefs.getString('eatenBreakfast') ?? 'Recommended 255 - 383 kcal',
      'eatenLunch': prefs.getString('eatenLunch') ?? 'Recommended 383 - 510 kcal',
      'eatenDinner': prefs.getString('eatenDinner') ?? 'Recommended 383 - 510 kcal',
      'kcalLeftValue': prefs.getDouble('kcalLeftValue') ?? 0.0,
      'kcalEatenValue': prefs.getDouble('kcalEatenValue') ?? 0.0,
      'eatenFat': prefs.getDouble('eatenFat') ?? 0.0,
      'eatenCarbs': prefs.getDouble('eatenCarbs') ?? 0.0,
      'eatenProtein': prefs.getDouble('eatenProtein') ?? 0.0,
      'filledGlasses':prefs.getInt('filledGlasses') ?? 0,
      'isAdmin':prefs.getBool('isAdmin') ?? false,
    };
  }
  void saveAllData() async {
    PreferencesService prefsService = PreferencesService();
    await prefsService.init();

    await prefsService.saveData(
      mealType: 'breakfast',
      eatenBreakfast: 'Recommended 255 - 383 kcal',
      eatenLunch: 'Recommended 255 - 383 kcal',
      eatenDinner: 'Recommended 255 - 383 kcal',
      kcalLeftValue: 0.0,
      kcalEatenValue: 0.0,
      eatenFat: 0.0,
      eatenCarbs: 0.0,
      eatenProtein: 0.0,
      filledGlasses: 0,
      isAdmin: false,
    );
  }


// Call saveAllData() whenever you need to save these data points.

}
bool hasDataBeenClearedToday = false;

Future<void> clearDailyData() async {
  DateTime now = DateTime.now();

  // Check if it's after midnight and if data hasn't been cleared yet
  if ((now.hour == 0 || !hasDataBeenClearedToday) && now.minute < 15) {  // 15 minutes range to ensure the task runs after midnight
    final prefs = await SharedPreferences.getInstance();

    // Reset your variables and save them
    await prefs.setString('mealType', 'breakfast');
    await prefs.setString('eatenBreakfast', 'Recommended 255 - 383 kcal');
    await prefs.setString('eatenLunch', 'Recommended 383 - 510 kcal');
    await prefs.setString('eatenDinner', 'Recommended 383 - 510 kcal');
    await prefs.setDouble('kcalLeftValue', 0.0);
    await prefs.setDouble('kcalEatenValue', 0.0);
    await prefs.setDouble('eatenFat', 0.0);
    await prefs.setDouble('eatenCarbs', 0.0);
    await prefs.setDouble('eatenProtein', 0.0);
    await prefs.setInt('filledGlasses', 0);
    await prefs.setBool('isAdmin', false);

    hasDataBeenClearedToday = true;  // Mark that the data has been cleared for the day
  } else if (now.hour > 0) {
    hasDataBeenClearedToday = false;  // Reset the flag after midnight
  }
}
