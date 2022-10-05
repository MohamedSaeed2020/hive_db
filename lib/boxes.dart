import 'package:hive/hive.dart';
import 'package:hive_db/models/transaction.dart';

class StoredBoxes {
  static Box<Transaction> getTransactions() {
    return Hive.box<Transaction>('transactions');
  }
}
