import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

// BLoCs
import 'onboarding/bloc/welcome_bloc.dart';
import 'auth/bloc/auth/login_bloc.dart';
import 'auth/bloc/register/register_bloc.dart';
import 'materias/bloc/materias_bloc.dart';
import 'materias/bloc/agregar_materia_bloc.dart';
import 'tareas/bloc/agregar_tarea_bloc.dart';
import 'tareas/bloc/editar_tarea_bloc.dart';
import 'tareas/bloc/tareas_bloc.dart';
import 'actividades/bloc/actividades_bloc.dart';
import 'actividades/bloc/crear_actividad_bloc.dart';
import 'calificaciones/bloc/calificaciones_bloc.dart';
import 'perfil/bloc/perfil_bloc.dart';
import 'home/bloc/home_bloc.dart';
import 'notas/bloc/notas_bloc.dart';
import 'curso/bloc/curso_bloc.dart';
import 'nube/bloc/nube_bloc.dart';

// Repositorios
import 'auth/repository/auth_repository.dart';
import 'tareas/repository/tareas_repository.dart';
import 'materias/repository/materias_repository.dart';
import 'actividades/repository/actividades_repository.dart';
import 'calificaciones/repository/calificaciones_repository.dart';
import 'perfil/repository/perfil_repository.dart';
import 'notas/repository/notas_repository.dart';
import 'curso/repository/curso_repository.dart';
import 'nube/repository/nube_repository.dart';

// Pantalla inicial
import 'onboarding/screens/welcome_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _inicializarNotificaciones(); // 🔔 Inicializa notificaciones locales
  runApp(const AppEntry());
}

Future<void> _inicializarNotificaciones() async {
  tz.initializeTimeZones(); // 🌍 Timezones necesarias para programar por hora

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final tareasRepository = TareasRepository();
    final materiasRepository = MateriasRepository();
    final actividadesRepository = ActividadesRepository();
    final actividadRepository = ActividadesRepository();
    final calificacionesRepository = CalificacionesRepository();
    final perfilRepository = PerfilRepository();
    final notasRepository = NotasRepository();
    final cursoRepository = CursoRepository();
    final nubeRepository = NubeRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: tareasRepository),
        RepositoryProvider.value(value: materiasRepository),
        RepositoryProvider.value(value: actividadesRepository),
        RepositoryProvider.value(value: actividadRepository),
        RepositoryProvider.value(value: calificacionesRepository),
        RepositoryProvider.value(value: perfilRepository),
        RepositoryProvider.value(value: notasRepository),
        RepositoryProvider.value(value: cursoRepository),
        RepositoryProvider.value(value: nubeRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => WelcomeBloc()..add(WelcomeStarted())),
          BlocProvider(create: (_) => LoginBloc(authRepository: authRepository)),
          BlocProvider(create: (_) => RegisterBloc(authRepository: authRepository)),
          BlocProvider(create: (_) => MateriasBloc(materiasRepository)),
          BlocProvider(create: (_) => AgregarMateriaBloc(repository: materiasRepository)),
          BlocProvider(create: (_) => AgregarTareaBloc(tareasRepository: tareasRepository)),
          BlocProvider(create: (_) => EditarTareaBloc(tareasRepository: tareasRepository)),
          BlocProvider(create: (_) => TareasBloc(repository: tareasRepository)),
          BlocProvider(create: (_) => ActividadesBloc(repository: actividadesRepository)),
          BlocProvider(create: (_) => CrearActividadBloc(repository: actividadRepository)),
          BlocProvider(create: (_) => CalificacionesBloc(repository: calificacionesRepository)),
          BlocProvider(create: (_) => PerfilBloc(repository: perfilRepository)),
          BlocProvider(create: (_) => NotasBloc(repository: notasRepository)),
          BlocProvider(create: (_) => CursoBloc(cursoRepository)),
          BlocProvider(create: (_) => NubeBloc(repository: nubeRepository)),
          BlocProvider(create: (_) => HomeBloc()),
        ],
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}
