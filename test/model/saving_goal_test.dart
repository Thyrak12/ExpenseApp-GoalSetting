import 'package:flutter_test/flutter_test.dart';
import 'package:saving_app/model/model.dart';

void main() {
  group('SavingGoal date tests', () {
    test('Goal with endDate in the past should have daysLeft = 0', () {
      final goal = SavingGoal(
        title: 'Test Goal',
        targetAmount: 100.0,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 6), // Yesterday (Jan 6)
        isCompleted: false,
      );

      print('Today: ${DateTime.now()}');
      print('End Date: ${goal.endDate}');
      print('Days Left: ${goal.daysLeft}');
      print('Is Completed: ${goal.isCompleted}');

      expect(goal.daysLeft, equals(0));
    });

    test('Goal with endDate today should have daysLeft = 1', () {
      final now = DateTime.now();
      final goal = SavingGoal(
        title: 'Test Goal',
        targetAmount: 100.0,
        startDate: DateTime(now.year, now.month, now.day - 5),
        endDate: DateTime(now.year, now.month, now.day), // Today
        isCompleted: false,
      );

      print('Today: $now');
      print('End Date: ${goal.endDate}');
      print('Days Left: ${goal.daysLeft}');

      expect(goal.daysLeft, equals(1));
    });

    test('Goal with endDate tomorrow should have daysLeft = 1', () {
      final now = DateTime.now();
      final goal = SavingGoal(
        title: 'Test Goal',
        targetAmount: 100.0,
        startDate: DateTime(now.year, now.month, now.day - 5),
        endDate: DateTime(now.year, now.month, now.day + 1), // Tomorrow
        isCompleted: false,
      );

      print('Today: $now');
      print('End Date: ${goal.endDate}');
      print('Days Left: ${goal.daysLeft}');

      // Tomorrow at 00:00 - today = 1 day difference, +1 = 1 day left (including tomorrow)
      expect(goal.daysLeft, equals(1));
    });

    test('isCompleted flag is false by default', () {
      final goal = SavingGoal(
        title: 'Test Goal',
        targetAmount: 100.0,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 6),
      );

      expect(goal.isCompleted, isFalse);
    });

    test('copyWith can set isCompleted to true', () {
      final goal = SavingGoal(
        title: 'Test Goal',
        targetAmount: 100.0,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 6),
        isCompleted: false,
      );

      final completedGoal = goal.copyWith(isCompleted: true);

      expect(goal.isCompleted, isFalse);
      expect(completedGoal.isCompleted, isTrue);
    });

    test('Goal ended (daysLeft = 0) but isCompleted still false until marked', () {
      final goal = SavingGoal(
        title: 'Test Goal',
        targetAmount: 100.0,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 6), // Past date
        isCompleted: false,
      );

      print('Days Left: ${goal.daysLeft}');
      print('Is Completed: ${goal.isCompleted}');

      // Goal has ended (daysLeft = 0) but isCompleted is still false
      // This is the current behavior - isCompleted must be set manually
      expect(goal.daysLeft, equals(0));
      expect(goal.isCompleted, isFalse);
    });

    test('Check if goal should be auto-completed when date passes', () {
      final goal = SavingGoal(
        title: 'Test Goal',
        targetAmount: 100.0,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 6),
        isCompleted: false,
      );

      // Helper to check if goal has ended based on date
      bool hasEnded(SavingGoal g) {
        final now = DateTime.now();
        final endOfDay = DateTime(g.endDate.year, g.endDate.month, g.endDate.day, 23, 59, 59);
        return now.isAfter(endOfDay);
      }

      print('Has Ended: ${hasEnded(goal)}');
      print('Is Completed Flag: ${goal.isCompleted}');

      // The goal HAS ended (date passed) but isCompleted flag is still false
      expect(hasEnded(goal), isTrue);
      expect(goal.isCompleted, isFalse);
    });
  });

  group('Current JSON data test', () {
    test('Test with actual JSON data', () {
      // This simulates your current saving_goal.json
      final json = {
        "id": "e4c49373-1818-43bc-ad7d-fecfc2b093da",
        "title": "Buffet",
        "targetAmount": 10.0,
        "startDate": "2026-01-01T20:52:30.951202",
        "endDate": "2026-01-06T00:00:00.000",
        "isCompleted": false
      };

      final goal = SavingGoal.fromJson(json);

      print('=== Current Goal from JSON ===');
      print('Title: ${goal.title}');
      print('Start Date: ${goal.startDate}');
      print('End Date: ${goal.endDate}');
      print('Today: ${DateTime.now()}');
      print('Days Left: ${goal.daysLeft}');
      print('Is Completed (flag): ${goal.isCompleted}');
      print('Is Ended (auto-detect): ${goal.isEnded}');
      print('');

      expect(goal.daysLeft, equals(0)); // End date Jan 6, today Jan 7
      expect(goal.isEnded, isTrue); // Date has passed - AUTO DETECTED!
      expect(goal.isCompleted, isFalse); // Flag is still false
    });
  });

  group('isEnded auto-detection tests', () {
    test('Goal with past endDate should have isEnded = true', () {
      final goal = SavingGoal(
        title: 'Test Goal',
        targetAmount: 100.0,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 6), // Yesterday
        isCompleted: false,
      );

      print('End Date: ${goal.endDate}');
      print('Is Ended: ${goal.isEnded}');

      expect(goal.isEnded, isTrue);
    });

    test('Goal with future endDate should have isEnded = false', () {
      final now = DateTime.now();
      final goal = SavingGoal(
        title: 'Test Goal',
        targetAmount: 100.0,
        startDate: now,
        endDate: DateTime(now.year, now.month, now.day + 5), // 5 days from now
        isCompleted: false,
      );

      print('End Date: ${goal.endDate}');
      print('Is Ended: ${goal.isEnded}');

      expect(goal.isEnded, isFalse);
    });

    test('Goal with today as endDate should have isEnded = false', () {
      final now = DateTime.now();
      final goal = SavingGoal(
        title: 'Test Goal',
        targetAmount: 100.0,
        startDate: DateTime(now.year, now.month, now.day - 5),
        endDate: DateTime(now.year, now.month, now.day), // Today
        isCompleted: false,
      );

      print('Today: $now');
      print('End Date: ${goal.endDate}');
      print('Is Ended: ${goal.isEnded}');

      // Today is still ongoing, so isEnded should be false
      expect(goal.isEnded, isFalse);
    });
  });
}
