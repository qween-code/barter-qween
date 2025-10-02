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
import 'package:barter_qween/data/datasources/remote/item_remote_datasource.dart'
    as _i72;
import 'package:barter_qween/data/datasources/remote/profile_remote_datasource.dart'
    as _i512;
import 'package:barter_qween/data/repositories/auth_repository_impl.dart'
    as _i828;
import 'package:barter_qween/data/repositories/item_repository_impl.dart'
    as _i703;
import 'package:barter_qween/data/repositories/profile_repository_impl.dart'
    as _i673;
import 'package:barter_qween/domain/repositories/auth_repository.dart' as _i113;
import 'package:barter_qween/domain/repositories/item_repository.dart' as _i754;
import 'package:barter_qween/domain/repositories/profile_repository.dart'
    as _i1043;
import 'package:barter_qween/domain/usecases/auth/get_current_user_usecase.dart'
    as _i599;
import 'package:barter_qween/domain/usecases/auth/google_sign_in_usecase.dart'
    as _i418;
import 'package:barter_qween/domain/usecases/auth/login_usecase.dart' as _i591;
import 'package:barter_qween/domain/usecases/auth/logout_usecase.dart' as _i537;
import 'package:barter_qween/domain/usecases/auth/phone_sign_in_usecase.dart'
    as _i971;
import 'package:barter_qween/domain/usecases/auth/register_usecase.dart'
    as _i265;
import 'package:barter_qween/domain/usecases/auth/reset_password_usecase.dart'
    as _i668;
import 'package:barter_qween/domain/usecases/auth/verify_otp_usecase.dart'
    as _i936;
import 'package:barter_qween/domain/usecases/item/item_usecases.dart' as _i301;
import 'package:barter_qween/domain/usecases/items/delete_item_usecase.dart'
    as _i529;
import 'package:barter_qween/domain/usecases/items/get_user_items_usecase.dart'
    as _i217;
import 'package:barter_qween/domain/usecases/items/update_item_usecase.dart'
    as _i768;
import 'package:barter_qween/domain/usecases/profile/get_user_profile_usecase.dart'
    as _i680;
import 'package:barter_qween/domain/usecases/profile/update_profile_usecase.dart'
    as _i303;
import 'package:barter_qween/domain/usecases/profile/upload_avatar_usecase.dart'
    as _i576;
import 'package:barter_qween/presentation/blocs/auth/auth_bloc.dart' as _i161;
import 'package:barter_qween/presentation/blocs/item/item_bloc.dart' as _i1004;
import 'package:barter_qween/presentation/blocs/profile/profile_bloc.dart'
    as _i527;
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
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
    gh.lazySingleton<_i116.GoogleSignIn>(
      () => firebaseInjectableModule.googleSignIn,
    );
    gh.lazySingleton<_i512.ProfileRemoteDataSource>(
      () => _i512.ProfileRemoteDataSourceImpl(
        firestore: gh<_i974.FirebaseFirestore>(),
        storage: gh<_i457.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i72.ItemRemoteDataSource>(
      () => _i72.ItemRemoteDataSourceImpl(
        firestore: gh<_i974.FirebaseFirestore>(),
        storage: gh<_i457.FirebaseStorage>(),
        auth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i381.AuthRemoteDataSource>(
      () => _i381.AuthRemoteDataSourceImpl(
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        firestore: gh<_i974.FirebaseFirestore>(),
        googleSignIn: gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.lazySingleton<_i754.ItemRepository>(
      () => _i703.ItemRepositoryImpl(
        remoteDataSource: gh<_i72.ItemRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i1043.ProfileRepository>(
      () => _i673.ProfileRepositoryImpl(gh<_i512.ProfileRemoteDataSource>()),
    );
    gh.lazySingleton<_i113.AuthRepository>(
      () => _i828.AuthRepositoryImpl(
        remoteDataSource: gh<_i381.AuthRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i529.DeleteItemUseCase>(
      () => _i529.DeleteItemUseCase(gh<_i754.ItemRepository>()),
    );
    gh.lazySingleton<_i217.GetUserItemsUseCase>(
      () => _i217.GetUserItemsUseCase(gh<_i754.ItemRepository>()),
    );
    gh.lazySingleton<_i768.UpdateItemUseCase>(
      () => _i768.UpdateItemUseCase(gh<_i754.ItemRepository>()),
    );
    gh.factory<_i301.CreateItemUseCase>(
      () => _i301.CreateItemUseCase(gh<_i754.ItemRepository>()),
    );
    gh.factory<_i301.UpdateItemUseCase>(
      () => _i301.UpdateItemUseCase(gh<_i754.ItemRepository>()),
    );
    gh.factory<_i301.DeleteItemUseCase>(
      () => _i301.DeleteItemUseCase(gh<_i754.ItemRepository>()),
    );
    gh.factory<_i301.GetItemUseCase>(
      () => _i301.GetItemUseCase(gh<_i754.ItemRepository>()),
    );
    gh.factory<_i301.GetAllItemsUseCase>(
      () => _i301.GetAllItemsUseCase(gh<_i754.ItemRepository>()),
    );
    gh.factory<_i301.GetUserItemsUseCase>(
      () => _i301.GetUserItemsUseCase(gh<_i754.ItemRepository>()),
    );
    gh.factory<_i301.SearchItemsUseCase>(
      () => _i301.SearchItemsUseCase(gh<_i754.ItemRepository>()),
    );
    gh.factory<_i301.GetFeaturedItemsUseCase>(
      () => _i301.GetFeaturedItemsUseCase(gh<_i754.ItemRepository>()),
    );
    gh.factory<_i301.UploadItemImagesUseCase>(
      () => _i301.UploadItemImagesUseCase(gh<_i754.ItemRepository>()),
    );
    gh.factory<_i680.GetUserProfileUseCase>(
      () => _i680.GetUserProfileUseCase(gh<_i1043.ProfileRepository>()),
    );
    gh.factory<_i303.UpdateProfileUseCase>(
      () => _i303.UpdateProfileUseCase(gh<_i1043.ProfileRepository>()),
    );
    gh.factory<_i576.UploadAvatarUseCase>(
      () => _i576.UploadAvatarUseCase(gh<_i1043.ProfileRepository>()),
    );
    gh.factory<_i1004.ItemBloc>(
      () => _i1004.ItemBloc(
        getAllItemsUseCase: gh<_i301.GetAllItemsUseCase>(),
        getUserItemsUseCase: gh<_i301.GetUserItemsUseCase>(),
        getItemUseCase: gh<_i301.GetItemUseCase>(),
        createItemUseCase: gh<_i301.CreateItemUseCase>(),
        updateItemUseCase: gh<_i301.UpdateItemUseCase>(),
        deleteItemUseCase: gh<_i301.DeleteItemUseCase>(),
        searchItemsUseCase: gh<_i301.SearchItemsUseCase>(),
        getFeaturedItemsUseCase: gh<_i301.GetFeaturedItemsUseCase>(),
      ),
    );
    gh.factory<_i527.ProfileBloc>(
      () => _i527.ProfileBloc(
        getUserProfileUseCase: gh<_i680.GetUserProfileUseCase>(),
        updateProfileUseCase: gh<_i303.UpdateProfileUseCase>(),
        uploadAvatarUseCase: gh<_i576.UploadAvatarUseCase>(),
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
    gh.factory<_i418.GoogleSignInUseCase>(
      () => _i418.GoogleSignInUseCase(gh<_i113.AuthRepository>()),
    );
    gh.factory<_i971.PhoneSignInUseCase>(
      () => _i971.PhoneSignInUseCase(gh<_i113.AuthRepository>()),
    );
    gh.factory<_i668.ResetPasswordUseCase>(
      () => _i668.ResetPasswordUseCase(gh<_i113.AuthRepository>()),
    );
    gh.factory<_i936.VerifyOtpUseCase>(
      () => _i936.VerifyOtpUseCase(gh<_i113.AuthRepository>()),
    );
    gh.factory<_i161.AuthBloc>(
      () => _i161.AuthBloc(
        loginUseCase: gh<_i591.LoginUseCase>(),
        registerUseCase: gh<_i265.RegisterUseCase>(),
        logoutUseCase: gh<_i537.LogoutUseCase>(),
        getCurrentUserUseCase: gh<_i599.GetCurrentUserUseCase>(),
        googleSignInUseCase: gh<_i418.GoogleSignInUseCase>(),
        resetPasswordUseCase: gh<_i668.ResetPasswordUseCase>(),
      ),
    );
    return this;
  }
}

class _$FirebaseInjectableModule extends _i328.FirebaseInjectableModule {}
