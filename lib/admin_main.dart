import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

const administratorEmail = 'edwardcastro2014@gmail.com';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AdminPortalApp());
}

class AdminPortalApp extends StatelessWidget {
  const AdminPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caminho Livre — Administração',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF123B5D),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFFD8E1E6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFF16A6A1), width: 2),
          ),
        ),
      ),
      home: const AdminGate(),
    );
  }
}

class AdminGate extends StatelessWidget {
  const AdminGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) return const AdminLoginScreen();

        return FutureBuilder<IdTokenResult>(
          future: user.getIdTokenResult(true),
          builder: (context, claimSnapshot) {
            if (!claimSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final isAdmin = user.email?.toLowerCase() == administratorEmail;
            return isAdmin
                ? const AdminDashboardScreen()
                : const AdminAccessDeniedScreen();
          },
        );
      },
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_loginError(error.code))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.admin_panel_settings_rounded, size: 52),
                  const SizedBox(height: 16),
                  Text(
                    'Caminho Livre',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Portal de administração',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail administrativo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _loading ? null : _login,
                    child: Text(_loading ? 'Entrando...' : 'Entrar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminAccessDeniedScreen extends StatelessWidget {
  const AdminAccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 56),
                const SizedBox(height: 16),
                Text(
                  'Acesso reservado',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sua conta está cadastrada, mas ainda não possui a permissão de administrador.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text('Sair'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final occurrences = FirebaseFirestore.instance
        .collection('occurrences')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caminho Livre — Administração'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: occurrences,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Não foi possível carregar os dados.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final pending = docs
              .where((doc) => doc.data()['status'] == 'pendente')
              .toList();
          final confirmed = docs
              .where((doc) => doc.data()['status'] == 'confirmada')
              .length;
          final resolved = docs
              .where((doc) => doc.data()['status'] == 'resolvida')
              .length;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth > 720 ? 4 : 2;
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.4,
                        children: [
                          _MetricCard(
                            label: 'Total',
                            value: '${docs.length}',
                            icon: Icons.layers_outlined,
                          ),
                          _MetricCard(
                            label: 'Pendentes',
                            value: '${pending.length}',
                            icon: Icons.pending_actions_rounded,
                          ),
                          _MetricCard(
                            label: 'Confirmadas',
                            value: '$confirmed',
                            icon: Icons.verified_outlined,
                          ),
                          _MetricCard(
                            label: 'Resolvidas',
                            value: '$resolved',
                            icon: Icons.check_circle_outline,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Fila de análise',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  if (pending.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Nenhuma ocorrência pendente.'),
                      ),
                    )
                  else
                    for (final doc in pending)
                      _AdminDashboardCard(doc: doc, allDocs: docs),
                  const SizedBox(height: 28),
                  Text(
                    'Trechos de percurso para análise',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('segments')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, segmentSnapshot) {
                      if (segmentSnapshot.hasError) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Não foi possível carregar os trechos.',
                            ),
                          ),
                        );
                      }
                      if (!segmentSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final segments = segmentSnapshot.data!.docs
                          .where((doc) => doc.data()['status'] == 'pendente')
                          .toList();
                      if (segments.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Nenhum trecho pendente.'),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (final segment in segments)
                            _AdminSegmentCard(doc: segment),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AdminSegmentCard extends StatelessWidget {
  const _AdminSegmentCard({required this.doc});

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  Future<void> _setStatus(
    BuildContext context,
    String status, {
    String? severity,
  }) async {
    try {
      final update = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (severity != null) update['severity'] = severity;
      await doc.reference.update(update);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível atualizar o trecho.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final pointCount = (data['points'] as List<dynamic>?)?.length ?? 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.route_rounded),
        title: const Text('Trecho registrado pelo usuário'),
        subtitle: Text(
          '$pointCount pontos GPS • ${data['description'] as String? ?? 'Sem descrição'}',
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            FilledButton.tonal(
              onPressed: () =>
                  _setStatus(context, 'confirmada', severity: 'acessivel'),
              child: const Text('Acessível'),
            ),
            FilledButton.tonal(
              onPressed: () =>
                  _setStatus(context, 'confirmada', severity: 'atencao'),
              child: const Text('Atenção'),
            ),
            FilledButton.tonal(
              onPressed: () =>
                  _setStatus(context, 'confirmada', severity: 'bloqueado'),
              child: const Text('Bloqueado'),
            ),
            OutlinedButton(
              onPressed: () => _setStatus(context, 'resolvida'),
              child: const Text('Resolver'),
            ),
            OutlinedButton(
              onPressed: () => _setStatus(context, 'rejeitada'),
              child: const Text('Rejeitar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDashboardCard extends StatelessWidget {
  const _AdminDashboardCard({required this.doc, required this.allDocs});

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs;

  int get similarCount {
    final data = doc.data();
    final category = data['category'];
    final lat = (data['latitude'] as num?)?.toDouble();
    final lng = (data['longitude'] as num?)?.toDouble();
    if (category is! String || lat == null || lng == null) return 1;
    return allDocs.where((other) {
      if (other.id == doc.id) return true;
      final otherData = other.data();
      if (otherData['category'] != category) return false;
      final otherLat = (otherData['latitude'] as num?)?.toDouble();
      final otherLng = (otherData['longitude'] as num?)?.toDouble();
      if (otherLat == null || otherLng == null) return false;
      final latDistance = (otherLat - lat) * 111000;
      final lngDistance = (otherLng - lng) * 111000;
      return (latDistance * latDistance + lngDistance * lngDistance) <= 900;
    }).length;
  }

  Future<void> _setStatus(BuildContext context, String status) async {
    try {
      await doc.reference.update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão administrativa não reconhecida.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final recurring = similarCount >= 3;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(data['category'] as String? ?? 'Ocorrência'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['description'] as String? ?? 'Sem descrição'),
            const SizedBox(height: 4),
            Text(
              recurring
                  ? 'Limiar atingido: $similarCount registros em até 30 m'
                  : '$similarCount registro(s) semelhante(s) em até 30 m',
              style: TextStyle(
                color: recurring
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: recurring ? FontWeight.w700 : null,
              ),
            ),
            const SizedBox(height: 4),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: doc.reference.collection('feedback').snapshots(),
              builder: (context, snapshot) {
                final feedback = snapshot.data?.docs ?? [];
                final confirmations = feedback
                    .where((item) => item.data()['type'] == 'confirmar')
                    .length;
                final contests = feedback
                    .where((item) => item.data()['type'] == 'contestar')
                    .length;
                return Text(
                  'Confirmações: $confirmations  •  Contestações: $contests',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            FilledButton.tonal(
              onPressed: () => _setStatus(context, 'confirmada'),
              child: const Text('Aprovar'),
            ),
            OutlinedButton(
              onPressed: () => _setStatus(context, 'resolvida'),
              child: const Text('Resolver'),
            ),
            OutlinedButton(
              onPressed: () => _setStatus(context, 'rejeitada'),
              child: const Text('Rejeitar'),
            ),
          ],
        ),
      ),
    );
  }
}

String _loginError(String code) {
  if (code == 'invalid-credential' || code == 'wrong-password') {
    return 'E-mail ou senha inválidos.';
  }
  return 'Não foi possível entrar com esta conta.';
}
