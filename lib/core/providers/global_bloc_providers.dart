import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/injection.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_event.dart';
import '../../presentation/blocs/favorite/favorite_bloc.dart';
import '../../presentation/blocs/profile/profile_bloc.dart';
import '../../presentation/blocs/search/search_bloc.dart';
import '../../presentation/blocs/item/item_bloc.dart';
import '../../presentation/blocs/home/home_bloc.dart';
import '../../domain/usecases/get_item_usecase.dart';
import '../../domain/usecases/items/get_all_items_usecase.dart';
import '../../domain/usecases/items/get_trending_items_usecase.dart';
import '../../domain/usecases/items/get_recent_items_usecase.dart';

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
          create: (_) => AuthBloc()..add(AuthCheckRequested()),
          lazy: false,
        ),
        
        // Favorite bloc - persist state across page visits
        BlocProvider<FavoriteBloc>(
          create: (_) => getIt<FavoriteBloc>(),
          lazy: false,
        ),
        
        // Profile bloc - single instance for entire app
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(),
          lazy: false,
        ),
        
        // Search bloc - global search functionality
        BlocProvider<SearchBloc>(
          create: (_) => getIt<SearchBloc>(),
          lazy: false,
        ),
        
        // Item bloc - global item management
        BlocProvider<ItemBloc>(
          create: (_) => ItemBloc(
            getIt<GetItemUsecase>(),
            getIt<GetAllItemsUseCase>(),
            getIt<GetTrendingItemsUseCase>(),
            getIt<GetRecentItemsUseCase>(),
          ),
          lazy: false,
        ),
        
        // Home bloc - global home page management
        BlocProvider<HomeBloc>(
          create: (_) => getIt<HomeBloc>(),
          lazy: false,
        ),
      ],
      child: child,
    );
  }
}
