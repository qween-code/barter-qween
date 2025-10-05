import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/injection.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_event.dart';
import '../../presentation/blocs/favorite/favorite_bloc.dart';
import '../../presentation/blocs/profile/profile_bloc.dart';

/// Global BlocProviders that should be available throughout the app
class GlobalBlocProviders extends StatelessWidget {
  final Widget child;

  const GlobalBlocProviders({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth bloc is global and shared across entire app
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested()),
          lazy: false,
        ),
        
        // Favorite bloc - persist state across page visits
        BlocProvider<FavoriteBloc>(
          create: (_) => getIt<FavoriteBloc>(),
          lazy: false,
        ),
        
        // Profile bloc - single instance for entire app
        BlocProvider<ProfileBloc>(
          create: (_) => getIt<ProfileBloc>(),
          lazy: false,
        ),
      ],
      child: child,
    );
  }
}
