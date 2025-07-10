import 'package:hive/hive.dart';

class DatabaseService {
  Future<void> syncLocalData() async {
    Hive.box('expenses');
    // Sync logic here
  }
}
