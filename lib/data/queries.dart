import 'package:cloud_firestore/cloud_firestore.dart';

/// Consultas Firestore compartilhadas pela interface.
///
/// `Query.snapshots()` devolve um stream broadcast: manter uma única instância
/// por consulta faz com que telas e widgets diferentes escutem o mesmo
/// listener, em vez de abrir uma leitura independente para cada um.
///
/// Acesse apenas depois de `Firebase.initializeApp` (os widgets já validam
/// `Firebase.apps.isEmpty` antes de usar).
class AppQueries {
  AppQueries._();

  static final AppQueries instance = AppQueries._();

  /// Limite do feed de ocorrências e dos marcadores do mapa.
  static const int occurrencesLimit = 100;

  /// Limite de trechos carregados para desenho e listagem.
  static const int segmentsLimit = 100;

  /// Ocorrências publicadas (confirmadas ou resolvidas), mais recentes antes.
  late final Stream<QuerySnapshot<Map<String, dynamic>>> approvedOccurrences =
      _db
          .collection('occurrences')
          .where('status', whereIn: ['confirmada', 'resolvida'])
          .orderBy('createdAt', descending: true)
          .limit(occurrencesLimit)
          .snapshots();

  /// Trechos publicados. A consulta não ordena por data para não exigir um
  /// índice composto em `segments`; a lista ordena em memória quando precisa.
  late final Stream<QuerySnapshot<Map<String, dynamic>>> approvedSegments = _db
      .collection('segments')
      .where('status', whereIn: ['confirmada', 'resolvida'])
      .limit(segmentsLimit)
      .snapshots();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
}
