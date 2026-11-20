import 'package:flutter_test/flutter_test.dart';

import 'package:caminho_livre/main.dart';

void main() {
  testWidgets('shows the Caminho Livre start screen', (tester) async {
    await tester.pumpWidget(const CaminhoLivreApp());

    expect(find.text('Caminho Livre'), findsOneWidget);
    expect(find.text('Criar minha conta'), findsOneWidget);
    expect(find.text('Continuar como visitante'), findsOneWidget);
  });
}
