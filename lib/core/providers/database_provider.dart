import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase.instance);
