# Caminho Livre

MVP colaborativo para registrar e consultar obstáculos de acessibilidade urbana.

## Ambiente local

- Flutter 3.47.6 e Dart 3.13.5
- Android SDK em `D:\Desenvolvimento\ferramentas\android-sdk`
- JDK 21 em `D:\Desenvolvimento\ferramentas\java\jdk-21.0.12.1+1`

## Serviços externos

O projeto Firebase já está configurado como `caminho-livre-mvp-20261120`.

1. Ative Authentication > Sign-in method > Anonymous.
2. O Cloud Firestore já está criado em `southamerica-east1` e as regras estão publicadas.
3. O Firebase Storage não é utilizado para evitar dependência do plano Blaze. Fotos são capturadas apenas localmente e não são enviadas.
4. O mapa atual é uma prévia demonstrável. Para usar Google Maps real no Android, habilite a Maps SDK e inclua uma chave em `android/local.properties`:

   ```properties
   MAPS_API_KEY=sua_chave_aqui
   ```

`android/local.properties` não deve ser enviado ao Git.

## Comandos

```powershell
cd D:\Desenvolvimento\projetos\caminho_livre
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
