import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'firebase_options.dart';

final highContrastNotifier = ValueNotifier<bool>(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CaminhoLivreApp());
}

class CaminhoLivreApp extends StatelessWidget {
  const CaminhoLivreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: highContrastNotifier,
      builder: (context, highContrast, _) {
        final colorScheme = ColorScheme.light(
          primary: highContrast
              ? const Color(0xFF002B45)
              : const Color(0xFF123B5D),
          onPrimary: Colors.white,
          secondary: highContrast
              ? const Color(0xFF006B68)
              : const Color(0xFF16A6A1),
          surface: highContrast
              ? const Color(0xFFFFFFFF)
              : const Color(0xFFF4F7F8),
          onSurface: const Color(0xFF122235),
          error: const Color(0xFFBA1A1A),
        );

        return MaterialApp(
          title: 'Caminho Livre',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: colorScheme,
            scaffoldBackgroundColor: colorScheme.surface,
            useMaterial3: true,
            fontFamily: 'Arial',
            cardTheme: CardThemeData(
              elevation: 0,
              color: Colors.white,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
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
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                side: BorderSide(color: Color(0xFFB8CBD3)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF4F7F8),
              foregroundColor: Color(0xFF122235),
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),
          home: const StartScreen(),
        );
      },
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Firebase.apps.isEmpty
        ? null
        : FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) return const HomeScreen();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  const _BrandMark(),
                  const SizedBox(height: 18),
                  Text(
                    'Caminho Livre',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Encontre caminhos mais acessíveis e ajude a melhorar a cidade.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const AuthScreen(initialRegistering: true),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                    ),
                    child: const Text('Criar minha conta'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const AuthScreen(initialRegistering: false),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                    ),
                    child: const Text('Entrar'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const HomeScreen(),
                      ),
                    ),
                    child: const Text('Continuar como visitante'),
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _selectedIndex = 0;

  static const _pages = <Widget>[
    MapScreen(),
    OccurrencesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.format_list_bulleted_outlined),
            selectedIcon: Icon(Icons.format_list_bulleted),
            label: 'Ocorrências',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  Future<void> _startLocationTracking() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _currentPosition = position);
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 20,
            ),
          ).listen((position) {
            if (mounted) setState(() => _currentPosition = position);
          });
    } catch (_) {
      // The map remains usable with the last known public position data.
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                children: [
                  const _BrandMark(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Caminho Livre',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    tooltip: 'Notificações',
                    onPressed: () => _showMessage(
                      context,
                      'Você ainda não possui notificações.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'A cidade, no seu caminho.',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Veja obstáculos informados pela comunidade antes de sair.',
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: const Color(0xFF4A5568)),
              ),
              const SizedBox(height: 20),
              MapPreview(currentPosition: _currentPosition),
              const SizedBox(height: 20),
              const _ApprovedSegmentsList(),
              const SizedBox(height: 20),
              const _InfoBanner(),
              const SizedBox(height: 20),
              Text(
                'Próximo de você',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ObstacleCard(obstacle: demoObstacles.first),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ReportObstacleScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Registrar obstáculo'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RouteRecordingScreen(),
                  ),
                ),
                icon: const Icon(Icons.route_rounded),
                label: const Text('Iniciar registro de trecho'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapPreview extends StatelessWidget {
  const MapPreview({super.key, this.currentPosition});

  final Position? currentPosition;

  @override
  Widget build(BuildContext context) {
    const belem = LatLng(-1.4558, -48.4902);
    const points = [
      LatLng(-1.4525, -48.4890),
      LatLng(-1.4580, -48.4950),
      LatLng(-1.4610, -48.4865),
    ];

    return Semantics(
      label: 'Mapa OpenStreetMap de Belém com três obstáculos registrados',
      child: AspectRatio(
        aspectRatio: 1.45,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: FlutterMap(
            options: const MapOptions(initialCenter: belem, initialZoom: 14),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'br.com.caminholivre.app',
              ),
              _ObstacleMarkers(
                fallbackPoints: points,
                currentPosition: currentPosition,
              ),
              const _ApprovedSegmentLines(),
              const Positioned(left: 16, bottom: 16, child: _SegmentLegend()),
              const Positioned(left: 16, top: 16, child: _LocationPill()),
              Positioned(
                right: 16,
                bottom: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'full-map',
                      tooltip: 'Abrir mapa em tela cheia',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const FullMapScreen(),
                        ),
                      ),
                      child: const Icon(Icons.fullscreen_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  final _mapController = MapController();
  final _tts = FlutterTts();
  Position? _position;
  var _hideBlocked = false;
  StreamSubscription<Position>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadMapPreference();
    _followLocation();
  }

  Future<void> _loadMapPreference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final avoidBlocked = snapshot.data()?['avoidBlocked'] as bool?;
      if (mounted && avoidBlocked != null) {
        setState(() => _hideBlocked = avoidBlocked);
      }
      final voiceGuidance = snapshot.data()?['voiceGuidance'] as bool? ?? false;
      if (mounted) {
        if (voiceGuidance) {
          await _tts.setLanguage('pt-BR');
          await _tts.speak(
            'Orientação por voz ativada. O mapa acompanhará seu deslocamento.',
          );
        }
      }
    } catch (_) {
      // Keep the default map filter when preferences are unavailable.
    }
  }

  Future<void> _followLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final current = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() => _position = current);
        _mapController.move(LatLng(current.latitude, current.longitude), 17);
      }
      _subscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen((position) {
            if (!mounted) return;
            setState(() => _position = position);
            _mapController.move(
              LatLng(position.latitude, position.longitude),
              17,
            );
          });
    } catch (_) {
      // The map remains usable without active location.
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const belem = LatLng(-1.4558, -48.4902);
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(initialCenter: belem, initialZoom: 15),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'br.com.caminholivre.app',
              ),
              _ApprovedSegmentLines(hideBlocked: _hideBlocked),
              _ObstacleMarkers(
                fallbackPoints: const [LatLng(-1.4525, -48.4890)],
                currentPosition: _position,
              ),
              if (_position != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_position!.latitude, _position!.longitude),
                      width: 22,
                      height: 22,
                      child: const Icon(
                        Icons.my_location,
                        color: Color(0xFF123B5D),
                        size: 22,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      tooltip: 'Voltar',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Text('Mapa de acessibilidade'),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      tooltip: 'Filtros do mapa',
                      onPressed: () =>
                          setState(() => _hideBlocked = !_hideBlocked),
                      icon: Icon(
                        _hideBlocked
                            ? Icons.filter_alt
                            : Icons.filter_alt_outlined,
                        color: _hideBlocked ? const Color(0xFF16A6A1) : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(left: 16, bottom: 24, child: _SegmentLegend()),
        ],
      ),
    );
  }
}

class RouteRecordingScreen extends StatefulWidget {
  const RouteRecordingScreen({super.key});

  @override
  State<RouteRecordingScreen> createState() => _RouteRecordingScreenState();
}

class _RouteRecordingScreenState extends State<RouteRecordingScreen> {
  final _descriptionController = TextEditingController();
  StreamSubscription<Position>? _subscription;
  final List<LatLng> _points = [];
  bool _recording = false;
  bool _saving = false;

  @override
  void dispose() {
    _subscription?.cancel();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      _message('Crie uma conta antes de registrar um trecho.');
      return;
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      _message('Ative o GPS para iniciar o registro.');
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _message('Permita o acesso à localização para registrar o trecho.');
      return;
    }
    final current = await Geolocator.getCurrentPosition();
    setState(() {
      _points
        ..clear()
        ..add(LatLng(current.latitude, current.longitude));
      _recording = true;
    });
    _subscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((position) {
          if (mounted) {
            setState(
              () => _points.add(LatLng(position.latitude, position.longitude)),
            );
          }
        });
  }

  Future<void> _finish() async {
    if (_points.length < 2) {
      _message('Caminhe alguns metros antes de finalizar o trecho.');
      return;
    }
    setState(() => _saving = true);
    await _subscription?.cancel();
    try {
      await FirebaseFirestore.instance.collection('segments').add({
        'points': _points
            .map((point) => GeoPoint(point.latitude, point.longitude))
            .toList(),
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'reporterId': FirebaseAuth.instance.currentUser!.uid,
        'status': 'pendente',
      });
      if (mounted) {
        _message('Trecho enviado para análise.');
        Navigator.of(context).pop();
      }
    } catch (_) {
      _message('Não foi possível enviar o trecho.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar trecho')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _recording
                ? 'Caminhe somente pelo trecho afetado. Finalize ao passar pelo fim do problema.'
                : 'Comece exatamente no início do trecho com dificuldade e finalize ao sair dele.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          if (_points.length >= 2)
            SizedBox(
              height: 280,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _points.last,
                    initialZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'br.com.caminholivre.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _points,
                          color: Colors.red,
                          strokeWidth: 6,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(
              height: 280,
              child: Center(
                child: Text('O trecho aparecerá aqui durante o registro.'),
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'O que dificulta a passagem?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : (_recording ? _finish : _start),
            icon: Icon(
              _recording ? Icons.stop_rounded : Icons.play_arrow_rounded,
            ),
            label: Text(_recording ? 'Finalizar e enviar' : 'Iniciar registro'),
          ),
        ],
      ),
    );
  }
}

class _ApprovedSegmentLines extends StatelessWidget {
  const _ApprovedSegmentLines({this.hideBlocked = false});

  final bool hideBlocked;

  Color _color(String? severity) {
    switch (severity) {
      case 'acessivel':
        return Colors.green;
      case 'atencao':
        return Colors.orange;
      case 'bloqueado':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) return const SizedBox.shrink();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('segments')
          .where('status', whereIn: ['confirmada', 'resolvida'])
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        final lines = <Polyline>[];
        for (final doc in snapshot.data?.docs ?? []) {
          final data = doc.data();
          if (hideBlocked && data['severity'] == 'bloqueado') continue;
          final rawPoints = data['points'] as List<dynamic>? ?? [];
          final points = rawPoints
              .whereType<GeoPoint>()
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
          if (points.length >= 2) {
            lines.add(
              Polyline(
                points: points,
                color: _color(data['severity'] as String?),
                strokeWidth: 7,
              ),
            );
          }
        }
        return PolylineLayer(polylines: lines);
      },
    );
  }
}

class _SegmentLegend extends StatelessWidget {
  const _SegmentLegend();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white.withValues(alpha: .94),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acessibilidade',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            _LegendRow(color: Colors.green, label: 'Acessível'),
            _LegendRow(color: Colors.orange, label: 'Atenção'),
            _LegendRow(color: Colors.red, label: 'Bloqueado'),
          ],
        ),
      ),
    );
  }
}

class _ApprovedSegmentsList extends StatelessWidget {
  const _ApprovedSegmentsList();

  String _label(String? severity) {
    switch (severity) {
      case 'acessivel':
        return 'Acessível';
      case 'atencao':
        return 'Atenção';
      case 'bloqueado':
        return 'Bloqueado';
      default:
        return 'Sem classificação';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) return const SizedBox.shrink();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('segments')
          .where('status', whereIn: ['confirmada', 'resolvida'])
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        final segments = snapshot.data?.docs ?? [];
        if (segments.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trechos mapeados',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            for (final segment in segments)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.route_rounded),
                  title: Text(_label(segment.data()['severity'] as String?)),
                  subtitle: Text(
                    segment.data()['description'] as String? ?? 'Sem descrição',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDetails(context, segment),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showDetails(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> segment,
  ) {
    final data = segment.data();
    final points =
        (data['points'] as List<dynamic>?)?.whereType<GeoPoint>().toList() ??
        [];
    var meters = 0.0;
    for (var index = 1; index < points.length; index++) {
      meters += Geolocator.distanceBetween(
        points[index - 1].latitude,
        points[index - 1].longitude,
        points[index].latitude,
        points[index].longitude,
      );
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _label(data['severity'] as String?),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(data['description'] as String? ?? 'Sem descrição'),
              const SizedBox(height: 8),
              Text('Extensão aproximada: ${meters.round()} m'),
              const SizedBox(height: 8),
              Text(
                data['status'] == 'resolvida'
                    ? 'Status: resolvido'
                    : 'Status: confirmado',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}

class _ObstacleMarkers extends StatelessWidget {
  const _ObstacleMarkers({
    required this.fallbackPoints,
    required this.currentPosition,
  });

  final List<LatLng> fallbackPoints;
  final Position? currentPosition;

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return _markerLayer(fallbackPoints);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('occurrences')
          .where('status', whereIn: ['confirmada', 'resolvida'])
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        final points =
            snapshot.data?.docs
                .map((doc) {
                  final data = doc.data();
                  final latitude = (data['latitude'] as num?)?.toDouble();
                  final longitude = (data['longitude'] as num?)?.toDouble();
                  if (latitude == null || longitude == null) return null;
                  return LatLng(latitude, longitude);
                })
                .whereType<LatLng>()
                .toList() ??
            const <LatLng>[];

        final nearbyPoints = currentPosition == null
            ? points
            : points
                  .where(
                    (point) =>
                        Geolocator.distanceBetween(
                          currentPosition!.latitude,
                          currentPosition!.longitude,
                          point.latitude,
                          point.longitude,
                        ) <=
                        1000,
                  )
                  .toList();

        return _markerLayer(
          nearbyPoints.isEmpty ? fallbackPoints : nearbyPoints,
        );
      },
    );
  }

  Widget _markerLayer(List<LatLng> points) {
    return MarkerLayer(
      markers: [
        for (final point in points)
          Marker(
            point: point,
            width: 44,
            height: 44,
            child: const _MapPin(
              color: Color(0xFFDC2626),
              icon: Icons.warning_amber_rounded,
            ),
          ),
      ],
    );
  }
}

class _LocationPill extends StatelessWidget {
  const _LocationPill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12)],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_rounded, color: Color(0xFF005F73), size: 18),
            SizedBox(width: 5),
            Text('Belém, PA'),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Color(0xFF005F73)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Os pontos no mapa são contribuições da comunidade e podem ser atualizados.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OccurrencesScreen extends StatefulWidget {
  const OccurrencesScreen({super.key});

  @override
  State<OccurrencesScreen> createState() => _OccurrencesScreenState();
}

class _OccurrencesScreenState extends State<OccurrencesScreen> {
  final _searchController = TextEditingController();
  var _category = 'Todas';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('occurrences')
                .where('status', whereIn: ['confirmada', 'resolvida'])
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              final occurrences =
                  snapshot.data?.docs.map(Obstacle.fromFirestore).toList() ??
                  const <Obstacle>[];
              final term = _searchController.text.trim().toLowerCase();
              final filtered = occurrences.where((obstacle) {
                final matchesText =
                    term.isEmpty ||
                    obstacle.title.toLowerCase().contains(term) ||
                    obstacle.place.toLowerCase().contains(term);
                final matchesCategory =
                    _category == 'Todas' ||
                    obstacle.title.toLowerCase().contains(
                      _category.toLowerCase(),
                    );
                return matchesText && matchesCategory;
              }).toList();

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Ocorrências',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Informações recentes enviadas por pessoas da região.',
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      labelText: 'Buscar por problema ou local',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final option in [
                          'Todas',
                          'Calçada',
                          'Rampa',
                          'Desnível',
                          'Obstáculo',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(option),
                              selected: _category == option,
                              onSelected: (_) =>
                                  setState(() => _category = option),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (snapshot.hasError)
                    const _FeedMessage(
                      icon: Icons.cloud_off_rounded,
                      title: 'Não foi possível carregar as ocorrências.',
                      message: 'Verifique sua conexão e tente novamente.',
                    )
                  else if (!snapshot.hasData)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (filtered.isEmpty)
                    const _FeedMessage(
                      icon: Icons.map_outlined,
                      title: 'Nenhuma ocorrência encontrada.',
                      message: 'Tente outro termo ou remova os filtros.',
                    )
                  else
                    for (final obstacle in filtered) ...[
                      ObstacleCard(obstacle: obstacle),
                      const SizedBox(height: 12),
                    ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeedMessage extends StatelessWidget {
  const _FeedMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 36, color: const Color(0xFF005F73)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ObstacleCard extends StatelessWidget {
  const ObstacleCard({super.key, required this.obstacle});

  final Obstacle obstacle;

  @override
  Widget build(BuildContext context) {
    final severityColor = obstacle.severity == Severity.high
        ? const Color(0xFFB91C1C)
        : const Color(0xFFB45309);

    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(obstacle.icon, color: severityColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    obstacle.title,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(obstacle.place),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _StatusChip(
                        label: obstacle.severity.label,
                        color: severityColor,
                      ),
                      _StatusChip(
                        label: obstacle.time,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                  if (obstacle.id != null) ...[
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('occurrences')
                          .doc(obstacle.id)
                          .collection('feedback')
                          .snapshots(),
                      builder: (context, snapshot) {
                        final docs = snapshot.data?.docs ?? [];
                        final confirmations = docs
                            .where((doc) => doc.data()['type'] == 'confirmar')
                            .length;
                        final contests = docs
                            .where((doc) => doc.data()['type'] == 'contestar')
                            .length;
                        return Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _sendFeedback(context, 'confirmar'),
                              icon: const Icon(Icons.check, size: 18),
                              label: Text('Confirmar ($confirmations)'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _sendFeedback(context, 'contestar'),
                              icon: const Icon(Icons.flag_outlined, size: 18),
                              label: Text('Contestar ($contests)'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendFeedback(BuildContext context, String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entre em uma conta para avaliar.')),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('occurrences')
          .doc(obstacle.id)
          .collection('feedback')
          .doc(user.uid)
          .set({'type': type, 'createdAt': FieldValue.serverTimestamp()});
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível registrar sua avaliação.'),
          ),
        );
      }
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(label, style: TextStyle(color: color, fontSize: 12)),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isRegistered = user != null && !user.isAnonymous;

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Seu perfil',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 24),
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFFCFFAFE),
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 38,
                      color: Color(0xFF005F73),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isRegistered
                        ? (user.displayName ?? 'Usuário')
                        : 'Visitante',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isRegistered
                        ? (user.email ?? 'Conta cadastrada')
                        : 'Crie uma conta para enviar ocorrências.',
                  ),
                  const SizedBox(height: 20),
                  if (!isRegistered)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AuthScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Entrar ou criar conta'),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const MobilityProfileScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.accessibility_new_rounded),
                          label: const Text('Meu perfil de mobilidade'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const AccessibilityPreferencesScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.tune_rounded),
                          label: const Text('Preferências de acessibilidade'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => FirebaseAuth.instance.signOut(),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Sair da conta'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MobilityProfileScreen extends StatefulWidget {
  const MobilityProfileScreen({super.key});

  @override
  State<MobilityProfileScreen> createState() => _MobilityProfileScreenState();
}

class AccessibilityPreferencesScreen extends StatefulWidget {
  const AccessibilityPreferencesScreen({super.key});

  @override
  State<AccessibilityPreferencesScreen> createState() =>
      _AccessibilityPreferencesScreenState();
}

class _AccessibilityPreferencesScreenState
    extends State<AccessibilityPreferencesScreen> {
  var _highContrast = false;
  var _voiceGuidance = false;
  var _avoidBlocked = true;
  var _loading = true;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = snapshot.data() ?? {};
    if (mounted) {
      setState(() {
        _highContrast = data['highContrast'] as bool? ?? false;
        _voiceGuidance = data['voiceGuidance'] as bool? ?? false;
        _avoidBlocked = data['avoidBlocked'] as bool? ?? true;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    setState(() => _saving = true);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'highContrast': _highContrast,
      'voiceGuidance': _voiceGuidance,
      'avoidBlocked': _avoidBlocked,
    }, SetOptions(merge: true));
    highContrastNotifier.value = _highContrast;
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Preferências salvas.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferências de acessibilidade')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Personalize a forma como o Caminho Livre apresenta as informações.',
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else ...[
            SwitchListTile(
              title: const Text('Alto contraste'),
              subtitle: const Text(
                'Aumenta a diferenciação visual dos elementos.',
              ),
              value: _highContrast,
              onChanged: (value) => setState(() => _highContrast = value),
            ),
            SwitchListTile(
              title: const Text('Orientação por voz'),
              subtitle: const Text(
                'Preparar instruções faladas para o deslocamento.',
              ),
              value: _voiceGuidance,
              onChanged: (value) => setState(() => _voiceGuidance = value),
            ),
            SwitchListTile(
              title: const Text('Evitar trechos bloqueados'),
              subtitle: const Text(
                'Prioriza caminhos sem linhas vermelhas no mapa.',
              ),
              value: _avoidBlocked,
              onChanged: (value) => setState(() => _avoidBlocked = value),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving || _loading ? null : _save,
            child: Text(_saving ? 'Salvando...' : 'Salvar preferências'),
          ),
        ],
      ),
    );
  }
}

class _MobilityProfileScreenState extends State<MobilityProfileScreen> {
  static const options = [
    'Cadeirante',
    'Deficiência visual',
    'Mobilidade reduzida',
    'Acompanhante ou carrinho',
  ];
  String? _selected;
  var _loading = true;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (mounted) {
      setState(() {
        _selected = snapshot.data()?['mobilityProfile'] as String?;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous || _selected == null) return;
    setState(() => _saving = true);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'mobilityProfile': _selected,
    }, SetOptions(merge: true));
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil de mobilidade salvo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de mobilidade')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Conte-nos como você se desloca para personalizar a experiência do mapa.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            RadioGroup<String>(
              groupValue: _selected,
              onChanged: (value) => setState(() => _selected = value),
              child: Column(
                children: [
                  for (final option in options)
                    RadioListTile<String>(value: option, title: Text(option)),
                ],
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving || _selected == null ? null : _save,
            child: Text(_saving ? 'Salvando...' : 'Salvar preferência'),
          ),
        ],
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialRegistering = true});

  final bool initialRegistering;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late var _isRegistering = widget.initialRegistering;
  var _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty ||
        password.length < 6 ||
        (_isRegistering && _nameController.text.trim().isEmpty)) {
      _showMessage(
        context,
        'Preencha os campos. A senha deve ter 6 caracteres.',
      );
      return;
    }

    setState(() => _loading = true);
    try {
      UserCredential credential;
      if (_isRegistering) {
        credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final name = _nameController.text.trim();
        await credential.user?.updateDisplayName(name);
        if (credential.user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .set({
                'displayName': name,
                'email': email,
                'role': 'user',
                'createdAt': FieldValue.serverTimestamp(),
              });
        }
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (mounted) _showMessage(context, _authMessage(error.code));
    } catch (_) {
      if (mounted) {
        _showMessage(context, 'Não foi possível concluir o cadastro.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegistering ? 'Criar conta' : 'Entrar')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  _isRegistering ? 'Criar conta' : 'Entrar',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegistering
                      ? 'Use uma conta válida para enviar e acompanhar suas ocorrências.'
                      : 'Entre para acompanhar suas contribuições.',
                ),
                if (_isRegistering) ...[
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    helperText: 'Mínimo de 6 caracteres',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: Text(
                    _loading
                        ? 'Aguarde...'
                        : (_isRegistering ? 'Criar conta' : 'Entrar'),
                  ),
                ),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => setState(() => _isRegistering = !_isRegistering),
                  child: Text(
                    _isRegistering
                        ? 'Já tenho uma conta'
                        : 'Quero criar uma conta',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _authMessage(String code) {
  switch (code) {
    case 'email-already-in-use':
      return 'Este e-mail já possui uma conta.';
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'E-mail ou senha inválidos.';
    case 'invalid-email':
      return 'Informe um e-mail válido.';
    case 'weak-password':
      return 'Escolha uma senha mais forte.';
    default:
      return 'Não foi possível autenticar agora.';
  }
}

class AdminOccurrencesScreen extends StatelessWidget {
  const AdminOccurrencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moderação de ocorrências')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('occurrences')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _FeedMessage(
              icon: Icons.lock_outline_rounded,
              title: 'Acesso reservado aos administradores.',
              message:
                  'A conta precisa ter a permissão administrativa configurada.',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final pending = docs
              .where((doc) => doc.data()['status'] == 'pendente')
              .toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '${pending.length} pendente(s) de análise',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Registros próximos e da mesma categoria ajudam a confirmar um problema.',
              ),
              const SizedBox(height: 20),
              for (final doc in pending) ...[
                _AdminOccurrenceCard(doc: doc, allPending: pending),
                const SizedBox(height: 12),
              ],
              if (pending.isEmpty)
                const _FeedMessage(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Tudo em dia.',
                  message: 'Não há ocorrências pendentes para moderar.',
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AdminOccurrenceCard extends StatelessWidget {
  const _AdminOccurrenceCard({required this.doc, required this.allPending});

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> allPending;

  int get similarCount {
    final data = doc.data();
    final category = data['category'];
    final latitude = (data['latitude'] as num?)?.toDouble();
    final longitude = (data['longitude'] as num?)?.toDouble();
    if (latitude == null || longitude == null) return 1;

    return allPending.where((other) {
          if (other.id == doc.id || other.data()['category'] != category) {
            return false;
          }
          final otherLatitude = (other.data()['latitude'] as num?)?.toDouble();
          final otherLongitude = (other.data()['longitude'] as num?)
              ?.toDouble();
          if (otherLatitude == null || otherLongitude == null) return false;
          return Geolocator.distanceBetween(
                latitude,
                longitude,
                otherLatitude,
                otherLongitude,
              ) <=
              30;
        }).length +
        1;
  }

  Future<void> _moderate(BuildContext context, String status) async {
    try {
      await doc.reference.update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        _showMessage(context, 'Ocorrência atualizada.');
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'A conta não possui permissão administrativa.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final category = data['category'] as String? ?? 'Obstáculo';
    final description = data['description'] as String? ?? '';

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(description),
            ],
            const SizedBox(height: 8),
            Text('$similarCount registro(s) semelhante(s) em até 30 m.'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => _moderate(context, 'confirmada'),
                  child: const Text('Aprovar'),
                ),
                OutlinedButton(
                  onPressed: () => _moderate(context, 'rejeitada'),
                  child: const Text('Rejeitar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReportObstacleScreen extends StatefulWidget {
  const ReportObstacleScreen({super.key});

  @override
  State<ReportObstacleScreen> createState() => _ReportObstacleScreenState();
}

class _ReportObstacleScreenState extends State<ReportObstacleScreen> {
  var _selectedCategory = 'Calçada danificada';
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  Position? _position;
  XFile? _photo;
  var _saving = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _useLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) {
          _showMessage(
            context,
            'Ative o serviço de localização para continuar.',
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showMessage(context, 'Permissão de localização não concedida.');
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() => _position = position);
        _showMessage(context, 'Localização capturada com sucesso.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage(context, 'Não foi possível obter sua localização.');
      }
    }
  }

  Future<void> _save() async {
    if (_position == null) {
      _showMessage(context, 'Use sua localização antes de salvar o registro.');
      return;
    }

    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.isAnonymous) {
        _showMessage(context, 'Crie uma conta ou entre antes de enviar.');
        return;
      }

      await FirebaseFirestore.instance.collection('occurrences').add({
        'address': 'Localização atual',
        'category': _selectedCategory,
        'createdAt': FieldValue.serverTimestamp(),
        'description': _descriptionController.text.trim(),
        'latitude': _position!.latitude,
        'longitude': _position!.longitude,
        'reporterId': user.uid,
        'status': 'pendente',
      });

      if (mounted) {
        Navigator.of(context).pop();
        _showMessage(context, 'Ocorrência registrada com sucesso.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          context,
          'Não foi possível enviar. Verifique se o login anônimo está ativo no Firebase.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addPhoto() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (photo != null && mounted) {
        setState(() => _photo = photo);
        _showMessage(context, 'Foto capturada localmente; não será enviada.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage(context, 'Não foi possível abrir a câmera.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const categories = [
      'Calçada danificada',
      'Rampa bloqueada ou ausente',
      'Degrau ou desnível',
      'Obstáculo na passagem',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar obstáculo')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              key: const Key('report-list'),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Text(
                  'Ajude a tornar o caminho mais seguro.',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Registre somente situações reais e evite incluir pessoas na fotografia.',
                ),
                const SizedBox(height: 24),
                Text(
                  'Qual é o problema?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                RadioGroup<String>(
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                  child: Column(
                    children: [
                      for (final category in categories)
                        RadioListTile<String>(
                          value: category,
                          contentPadding: EdgeInsets.zero,
                          title: Text(category),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    hintText: 'Conte brevemente o que dificulta a passagem.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _addPhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(
                    _photo == null
                        ? 'Adicionar foto (sem upload)'
                        : 'Foto capturada',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _useLocation,
                  icon: const Icon(Icons.my_location_outlined),
                  label: Text(
                    _position == null
                        ? 'Usar minha localização'
                        : 'Localização capturada',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('save-occurrence'),
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                  ),
                  child: Text(_saving ? 'Enviando...' : 'Salvar registro'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF005F73),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(9),
        child: Icon(Icons.accessible_forward_rounded, color: Colors.white),
      ),
    );
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

enum Severity {
  high('Atenção alta'),
  medium('Atenção média');

  const Severity(this.label);

  final String label;
}

class Obstacle {
  const Obstacle({
    this.id,
    required this.title,
    required this.place,
    required this.time,
    required this.icon,
    required this.severity,
  });

  final String? id;
  final String title;
  final String place;
  final String time;
  final IconData icon;
  final Severity severity;

  factory Obstacle.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final category = data['category'] as String? ?? 'Obstáculo informado';
    final address = data['address'] as String? ?? 'Localização não informada';
    final createdAt = data['createdAt'] as Timestamp?;

    return Obstacle(
      id: doc.id,
      title: category,
      place: address,
      time: createdAt == null ? 'Enviado agora' : 'Registro da comunidade',
      icon: _iconForCategory(category),
      severity: _severityForCategory(category),
    );
  }
}

IconData _iconForCategory(String category) {
  if (category.contains('Rampa')) return Icons.block_rounded;
  if (category.contains('Desnível')) return Icons.construction_rounded;
  return Icons.warning_amber_rounded;
}

Severity _severityForCategory(String category) {
  return category.contains('Desnível') ? Severity.medium : Severity.high;
}

const demoObstacles = [
  Obstacle(
    title: 'Calçada com buracos',
    place: 'Av. Duque de Caxias, Pedreira',
    time: 'Informado hoje',
    icon: Icons.warning_amber_rounded,
    severity: Severity.high,
  ),
  Obstacle(
    title: 'Rampa bloqueada',
    place: 'Tv. Humaitá, Pedreira',
    time: 'Há 2 horas',
    icon: Icons.block_rounded,
    severity: Severity.high,
  ),
  Obstacle(
    title: 'Desnível na calçada',
    place: 'Av. Pedro Miranda, Pedreira',
    time: 'Ontem',
    icon: Icons.construction_rounded,
    severity: Severity.medium,
  ),
];
