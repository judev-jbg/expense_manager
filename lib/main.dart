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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
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
