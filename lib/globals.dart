import 'package:shared_preferences/shared_preferences.dart';
bool isAdmin= false;
String mealtype= 'breakfast',eatenBreakfast='Recommended 255 - 383 kcal';
double kcalLeftValue = 0.0, kcalTotalValue = 0.0, kcalEatenValue = 0.0, eatenFat=0.0 , eatenCarbs=0.0 , eatenProtein=0.0 , totalProtein=0.0;

class PreferencesService {
  Future<void> saveData({
    required bool isAdmin,
    required String mealType,
    required String eatenBreakfast,
    required double kcalLeftValue,
    required double kcalTotalValue,
    required double kcalEatenValue,
    required double eatenFat,
    required double eatenCarbs,
    required double eatenProtein,
    required double totalProtein,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isAdmin', isAdmin);
    await prefs.setString('mealType', mealType);
    await prefs.setString('eatenBreakfast', eatenBreakfast);
    await prefs.setDouble('kcalLeftValue', kcalLeftValue);
    await prefs.setDouble('kcalTotalValue', kcalTotalValue);
    await prefs.setDouble('kcalEatenValue', kcalEatenValue);
    await prefs.setDouble('eatenFat', eatenFat);
    await prefs.setDouble('eatenCarbs', eatenCarbs);
    await prefs.setDouble('eatenProtein', eatenProtein);
    await prefs.setDouble('totalProtein', totalProtein);
  }

  Future<Map<String, dynamic>> loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return {
      'isAdmin': prefs.getBool('isAdmin') ?? false,
      'mealType': prefs.getString('mealType') ?? 'breakfast',
      'eatenBreakfast': prefs.getString('eatenBreakfast') ?? 'Recommended 255 - 383 kcal',
      'kcalLeftValue': prefs.getDouble('kcalLeftValue') ?? 0.0,
      'kcalTotalValue': prefs.getDouble('kcalTotalValue') ?? 0.0,
      'kcalEatenValue': prefs.getDouble('kcalEatenValue') ?? 0.0,
      'eatenFat': prefs.getDouble('eatenFat') ?? 0.0,
      'eatenCarbs': prefs.getDouble('eatenCarbs') ?? 0.0,
      'eatenProtein': prefs.getDouble('eatenProtein') ?? 0.0,
      'totalProtein': prefs.getDouble('totalProtein') ?? 0.0,
    };
  }
}