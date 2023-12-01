import 'package:shared_preferences/shared_preferences.dart';
bool isAdmin= false;
String mealtype= 'breakfast',eatenBreakfast='Recommended 255 - 383 kcal';
double kcalLeftValue = 0.0, kcalTotalValue = 0.0, kcalEatenValue = 0.0, eatenFat=0.0 , eatenCarbs=0.0 , eatenProtein=0.0 , totalProtein=0.0;

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
    required double kcalLeftValue,
    required double kcalEatenValue,
    required double eatenFat,
    required double eatenCarbs,
    required double eatenProtein,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('mealType', mealType);
    await prefs.setString('eatenBreakfast', eatenBreakfast);
    await prefs.setDouble('kcalLeftValue', kcalLeftValue);
    await prefs.setDouble('kcalEatenValue', kcalEatenValue);
    await prefs.setDouble('eatenFat', eatenFat);
    await prefs.setDouble('eatenCarbs', eatenCarbs);
    await prefs.setDouble('eatenProtein', eatenProtein);
  }

  Future<Map<String, dynamic>> loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return {
      'mealType': prefs.getString('mealType') ?? 'breakfast',
      'eatenBreakfast': prefs.getString('eatenBreakfast') ?? 'Recommended 255 - 383 kcal',
      'kcalLeftValue': prefs.getDouble('kcalLeftValue') ?? 0.0,
      'kcalEatenValue': prefs.getDouble('kcalEatenValue') ?? 0.0,
      'eatenFat': prefs.getDouble('eatenFat') ?? 0.0,
      'eatenCarbs': prefs.getDouble('eatenCarbs') ?? 0.0,
      'eatenProtein': prefs.getDouble('eatenProtein') ?? 0.0,
    };
  }
  void saveAllData() async {
    PreferencesService prefsService = PreferencesService();
    await prefsService.init();

    await prefsService.saveData(
      mealType: 'breakfast',
      eatenBreakfast: 'Recommended 255 - 383 kcal',
      kcalLeftValue: 0.0,
      kcalEatenValue: 0.0,
      eatenFat: 0.0,
      eatenCarbs: 0.0,
      eatenProtein: 0.0,
    );
  }


// Call saveAllData() whenever you need to save these data points.

}