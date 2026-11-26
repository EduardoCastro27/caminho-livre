# Caminho Livre

MVP colaborativo para registrar e consultar obstáculos de acessibilidade urbana.

## Ambiente local

- Flutter 3.47.6 e Dart 3.13.5
- Android SDK em `D:\Desenvolvimento\ferramentas\android-sdk`
- JDK 21 em `D:\Desenvolvimento\ferramentas\java\jdk-21.0.12.1+1`

## Serviços externos

O projeto Firebase já está configurado como `caminho-livre-mvp-20261120`.

1. Authentication usa somente e-mail/senha. "Continuar como visitante" abre o app sem sessão: as regras liberam leitura apenas de ocorrências e trechos aprovados, e qualquer contribuição exige conta.
2. O Cloud Firestore já está criado em `southamerica-east1` e as regras estão publicadas em `firestore.rules`.
3. O Firebase Storage não é utilizado para evitar dependência do plano Blaze. Fotos são capturadas apenas localmente e não são enviadas.
4. O mapa usa `flutter_map` com tiles do OpenStreetMap e não exige chave de API.

`android/local.properties` não deve ser enviado ao Git.

## Portal de administração

É um entrypoint separado, apontando para o mesmo projeto Firebase:

```powershell
flutter run -t lib/admin_main.dart -d chrome
```

O acesso é liberado pela custom claim `admin: true` no token do usuário. Enquanto a claim não for distribuída, a conta `edwardcastro2014@gmail.com` mantém acesso pela regra de compatibilidade em `firestore.rules`.

## Comandos

```powershell
cd D:\Desenvolvimento\projetos\caminho_livre
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Estrutura

- `lib/main.dart` — app do cidadão (mapa, feed, perfil e registros).
- `lib/admin_main.dart` — portal de moderação de ocorrências e trechos.
- `lib/data/queries.dart` — consultas Firestore compartilhadas entre as telas.
- `firestore.rules` e `firestore.indexes.json` — segurança e índices.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
