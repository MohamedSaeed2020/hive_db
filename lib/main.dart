import 'package:flutter/material.dart';
import 'package:hive_db/models/transaction.dart';
import 'package:hive_db/views/page/transaction_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  await Hive.openBox<Transaction>('transactions',
      compactionStrategy: (entries, deletedEntries) {
    return deletedEntries > 50;
  });
  //The compactionStrategy above will compact your box when 50 keys have been overridden or deleted.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hive Database',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const TransactionPage(),
    );
  }
}
