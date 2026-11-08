import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/main.dart';

void main() {
  testWidgets('TaskFlow app smoke test', (WidgetTester tester) async {
    // Строим наше приложение
    await tester.pumpWidget(const TaskFlowApp());

    // Проверяем, что главный экран загрузился и отображает вкладку статистики
    expect(find.text('Статистика'), findsOneWidget);
  });
}