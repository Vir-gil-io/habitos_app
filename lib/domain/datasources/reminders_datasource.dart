import 'package:habitos_app/domain/entities/reminder.dart';

abstract class RemindersDatasource {
  Future<List<Reminder>> getAll();
  Future<List<Reminder>> getByDate(DateTime date);
  Future<Reminder>       create(Reminder reminder);
  Future<void>           delete(String id);
}