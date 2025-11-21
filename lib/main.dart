import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/categorias_repository_impl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/repositories/empresas_repository_impl.dart';
import 'data/repositories/gastos_repository_impl.dart';
import 'presentation/bloc/categorias/categorias_bloc.dart';
import 'presentation/bloc/categorias/categorias_event.dart';
import 'presentation/bloc/empresas/empresas_bloc.dart';
import 'presentation/bloc/gastos/gastos_bloc.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/recurrentes/confirmar_instancia_screen.dart';
import 'domain/services/notification_service.dart';
import 'domain/services/recurrentes_background_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  final notificationService = NotificationService();
  await notificationService.initialize();
  NotificationService.onNotificationTap = (instanciaId) {
    print('🚀 Navegando a confirmación: $instanciaId');

    // Esperar un frame para asegurar que el navigator está listo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                ConfirmarInstanciaScreen(instanciaId: instanciaId),
          ),
          (route) => false,
        );
      } else {
        print('⚠️ NavigatorKey.currentState es null');
      }
    });
  };
  await RecurrentesBackgroundService.initialize();
  await RecurrentesBackgroundService.scheduleDailyCheck();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provider de CategoriasBloc
        BlocProvider(
          create: (context) =>
              CategoriasBloc(categoriasRepository: CategoriasRepositoryImpl())
                ..add(LoadCategorias()),
        ),

        // Provider de EmpresasBloc
        BlocProvider(
          create: (context) =>
              EmpresasBloc(empresasRepository: EmpresasRepositoryImpl()),
        ),

        // Provider de GastosBloc
        BlocProvider(
          create: (context) =>
              GastosBloc(gastosRepository: GastosRepositoryImpl()),
        ),
      ],
      child: MaterialApp(
        title: 'Gestor Gastos',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: AppTheme.lightTheme,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('es', 'ES'), Locale('en', 'US')],
        locale: Locale('es', 'ES'),
        home: HomeScreen(),
      ),
    );
  }
}
