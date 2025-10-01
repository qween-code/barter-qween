// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:barter_qween/core/di/injection.dart' as _i328;
import 'package:barter_qween/data/datasources/auth_remote_datasource.dart'
    as _i381;
import 'package:barter_qween/data/repositories/auth_repository_impl.dart'
    as _i828;
import 'package:barter_qween/domain/repositories/auth_repository.dart' as _i113;
import 'package:barter_qween/domain/usecases/auth/get_current_user_usecase.dart'
    as _i599;
import 'package:barter_qween/domain/usecases/auth/login_usecase.dart' as _i591;
import 'package:barter_qween/domain/usecases/auth/logout_usecase.dart' as _i537;
import 'package:barter_qween/domain/usecases/auth/register_usecase.dart'
    as _i265;
import 'package:barter_qween/presentation/blocs/auth/auth_bloc.dart' as _i161;
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseInjectableModule = _$FirebaseInjectableModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => firebaseInjectableModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i59.FirebaseAuth>(
      () => firebaseInjectableModule.firebaseAuth,
    );
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => firebaseInjectableModule.firestore,
    );
    gh.lazySingleton<_i457.FirebaseStorage>(
      () => firebaseInjectableModule.storage,
    );
    gh.lazySingleton<_i381.AuthRemoteDataSource>(
      () => _i381.AuthRemoteDataSourceImpl(
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        firestore: gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i113.AuthRepository>(
      () => _i828.AuthRepositoryImpl(
        remoteDataSource: gh<_i381.AuthRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i599.GetCurrentUserUseCase>(
      () => _i599.GetCurrentUserUseCase(gh<_i113.AuthRepository>()),
    );
    gh.lazySingleton<_i591.LoginUseCase>(
      () => _i591.LoginUseCase(gh<_i113.AuthRepository>()),
    );
    gh.lazySingleton<_i537.LogoutUseCase>(
      () => _i537.LogoutUseCase(gh<_i113.AuthRepository>()),
    );
    gh.lazySingleton<_i265.RegisterUseCase>(
      () => _i265.RegisterUseCase(gh<_i113.AuthRepository>()),
    );
    gh.factory<_i161.AuthBloc>(
      () => _i161.AuthBloc(
        loginUseCase: gh<_i591.LoginUseCase>(),
        registerUseCase: gh<_i265.RegisterUseCase>(),
        logoutUseCase: gh<_i537.LogoutUseCase>(),
        getCurrentUserUseCase: gh<_i599.GetCurrentUserUseCase>(),
      ),
    );
    return this;
  }
}

class _$FirebaseInjectableModule extends _i328.FirebaseInjectableModule {}
