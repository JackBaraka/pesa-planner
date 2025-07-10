import 'package:hive/hive.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.openBox('expenses');
    await Hive.openBox('budgets');
  }

  static Box getExpenseBox() {
    return Hive.box('expenses');
  }
}
