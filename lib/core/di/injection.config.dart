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
import 'package:barter_qween/data/datasources/barter_offer_remote_datasource.dart'
    as _i696;
import 'package:barter_qween/data/datasources/remote/chat_remote_datasource.dart'
    as _i1020;
import 'package:barter_qween/data/datasources/remote/favorite_remote_datasource.dart'
    as _i548;
import 'package:barter_qween/data/datasources/remote/item_remote_datasource.dart'
    as _i72;
import 'package:barter_qween/data/datasources/remote/profile_remote_datasource.dart'
    as _i512;
import 'package:barter_qween/data/datasources/remote/trade_remote_datasource.dart'
    as _i411;
import 'package:barter_qween/data/datasources/search_local_data_source.dart'
    as _i493;
import 'package:barter_qween/data/datasources/search_remote_data_source.dart'
    as _i955;
import 'package:barter_qween/data/repositories/auth_repository_impl.dart'
    as _i828;
import 'package:barter_qween/data/repositories/barter_offer_repository_impl.dart'
    as _i419;
import 'package:barter_qween/data/repositories/chat_repository_impl.dart'
    as _i66;
import 'package:barter_qween/data/repositories/favorite_repository_impl.dart'
    as _i451;
import 'package:barter_qween/data/repositories/item_repository_impl.dart'
    as _i703;
import 'package:barter_qween/data/repositories/profile_repository_impl.dart'
    as _i673;
import 'package:barter_qween/data/repositories/search_repository_impl.dart'
    as _i290;
import 'package:barter_qween/data/repositories/trade_repository_impl.dart'
    as _i429;
import 'package:barter_qween/domain/repositories/auth_repository.dart' as _i113;
import 'package:barter_qween/domain/repositories/barter_offer_repository.dart'
    as _i1029;
import 'package:barter_qween/domain/repositories/chat_repository.dart' as _i920;
import 'package:barter_qween/domain/repositories/favorite_repository.dart'
    as _i933;
import 'package:barter_qween/domain/repositories/item_repository.dart' as _i754;
import 'package:barter_qween/domain/repositories/profile_repository.dart'
    as _i1043;
import 'package:barter_qween/domain/repositories/search_repository.dart'
    as _i948;
import 'package:barter_qween/domain/repositories/trade_repository.dart' as _i48;
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
import 'package:barter_qween/domain/usecases/chat/get_conversations_usecase.dart'
    as _i610;
import 'package:barter_qween/domain/usecases/chat/get_messages_usecase.dart'
    as _i982;
import 'package:barter_qween/domain/usecases/chat/get_or_create_conversation_usecase.dart'
    as _i232;
import 'package:barter_qween/domain/usecases/chat/mark_as_read_usecase.dart'
    as _i1052;
import 'package:barter_qween/domain/usecases/chat/send_message_usecase.dart'
    as _i116;
import 'package:barter_qween/domain/usecases/favorites/add_favorite_usecase.dart'
    as _i191;
import 'package:barter_qween/domain/usecases/favorites/get_favorite_items_usecase.dart'
    as _i2;
import 'package:barter_qween/domain/usecases/favorites/remove_favorite_usecase.dart'
    as _i469;
import 'package:barter_qween/domain/usecases/item/item_usecases.dart' as _i301;
import 'package:barter_qween/domain/usecases/items/delete_item_usecase.dart'
    as _i529;
import 'package:barter_qween/domain/usecases/items/get_user_items_usecase.dart'
    as _i217;
import 'package:barter_qween/domain/usecases/items/update_item_usecase.dart'
    as _i768;
import 'package:barter_qween/domain/usecases/profile/get_user_profile_usecase.dart'
    as _i680;
import 'package:barter_qween/domain/usecases/profile/get_user_stats_usecase.dart'
    as _i566;
import 'package:barter_qween/domain/usecases/profile/update_profile_usecase.dart'
    as _i303;
import 'package:barter_qween/domain/usecases/profile/upload_avatar_usecase.dart'
    as _i576;
import 'package:barter_qween/domain/usecases/search/get_search_suggestions_usecase.dart'
    as _i803;
import 'package:barter_qween/domain/usecases/search/search_items_usecase.dart'
    as _i481;
import 'package:barter_qween/domain/usecases/trade/trade_usecases.dart'
    as _i773;
import 'package:barter_qween/presentation/blocs/auth/auth_bloc.dart' as _i161;
import 'package:barter_qween/presentation/blocs/chat/chat_bloc.dart' as _i241;
import 'package:barter_qween/presentation/blocs/favorite/favorite_bloc.dart'
    as _i935;
import 'package:barter_qween/presentation/blocs/item/item_bloc.dart' as _i1004;
import 'package:barter_qween/presentation/blocs/offer/offer_bloc.dart' as _i2;
import 'package:barter_qween/presentation/blocs/profile/profile_bloc.dart'
    as _i527;
import 'package:barter_qween/presentation/blocs/search/search_bloc.dart'
    as _i742;
import 'package:barter_qween/presentation/blocs/trade/trade_bloc.dart' as _i503;
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
    gh.factory<_i493.SearchLocalDataSource>(
      () => _i493.SearchLocalDataSource(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i955.SearchRemoteDataSource>(
      () => _i955.SearchRemoteDataSource(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i548.FavoriteRemoteDataSource>(
      () => _i548.FavoriteRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i512.ProfileRemoteDataSource>(
      () => _i512.ProfileRemoteDataSourceImpl(
        firestore: gh<_i974.FirebaseFirestore>(),
        storage: gh<_i457.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i933.FavoriteRepository>(
      () => _i451.FavoriteRepositoryImpl(gh<_i548.FavoriteRemoteDataSource>()),
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
    gh.factory<_i948.SearchRepository>(
      () => _i290.SearchRepositoryImpl(
        remoteDataSource: gh<_i955.SearchRemoteDataSource>(),
        localDataSource: gh<_i493.SearchLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i1020.ChatRemoteDataSource>(
      () => _i1020.ChatRemoteDataSource(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i696.BarterOfferRemoteDataSource>(
      () => _i696.BarterOfferRemoteDataSource(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i1029.BarterOfferRepository>(
      () => _i419.BarterOfferRepositoryImpl(
        gh<_i696.BarterOfferRemoteDataSource>(),
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
    gh.lazySingleton<_i411.TradeRemoteDataSource>(
      () => _i411.TradeRemoteDataSourceImpl(
        firestore: gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i113.AuthRepository>(
      () => _i828.AuthRepositoryImpl(
        remoteDataSource: gh<_i381.AuthRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i920.ChatRepository>(
      () => _i66.ChatRepositoryImpl(gh<_i1020.ChatRemoteDataSource>()),
    );
    gh.factory<_i803.GetSearchSuggestionsUseCase>(
      () => _i803.GetSearchSuggestionsUseCase(gh<_i948.SearchRepository>()),
    );
    gh.factory<_i803.GetRecentSearchesUseCase>(
      () => _i803.GetRecentSearchesUseCase(gh<_i948.SearchRepository>()),
    );
    gh.factory<_i803.SaveRecentSearchUseCase>(
      () => _i803.SaveRecentSearchUseCase(gh<_i948.SearchRepository>()),
    );
    gh.factory<_i803.ClearRecentSearchesUseCase>(
      () => _i803.ClearRecentSearchesUseCase(gh<_i948.SearchRepository>()),
    );
    gh.factory<_i803.DeleteRecentSearchUseCase>(
      () => _i803.DeleteRecentSearchUseCase(gh<_i948.SearchRepository>()),
    );
    gh.factory<_i803.GetPopularSearchesUseCase>(
      () => _i803.GetPopularSearchesUseCase(gh<_i948.SearchRepository>()),
    );
    gh.factory<_i481.SearchItemsUseCase>(
      () => _i481.SearchItemsUseCase(gh<_i948.SearchRepository>()),
    );
    gh.factory<_i2.OfferBloc>(
      () => _i2.OfferBloc(gh<_i1029.BarterOfferRepository>()),
    );
    gh.factory<_i191.AddFavoriteUseCase>(
      () => _i191.AddFavoriteUseCase(gh<_i933.FavoriteRepository>()),
    );
    gh.factory<_i2.GetFavoriteItemsUseCase>(
      () => _i2.GetFavoriteItemsUseCase(gh<_i933.FavoriteRepository>()),
    );
    gh.factory<_i469.RemoveFavoriteUseCase>(
      () => _i469.RemoveFavoriteUseCase(gh<_i933.FavoriteRepository>()),
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
    gh.lazySingleton<_i610.GetConversationsUseCase>(
      () => _i610.GetConversationsUseCase(gh<_i920.ChatRepository>()),
    );
    gh.lazySingleton<_i982.GetMessagesUseCase>(
      () => _i982.GetMessagesUseCase(gh<_i920.ChatRepository>()),
    );
    gh.lazySingleton<_i232.GetOrCreateConversationUseCase>(
      () => _i232.GetOrCreateConversationUseCase(gh<_i920.ChatRepository>()),
    );
    gh.lazySingleton<_i1052.MarkAsReadUseCase>(
      () => _i1052.MarkAsReadUseCase(gh<_i920.ChatRepository>()),
    );
    gh.lazySingleton<_i116.SendMessageUseCase>(
      () => _i116.SendMessageUseCase(gh<_i920.ChatRepository>()),
    );
    gh.factory<_i680.GetUserProfileUseCase>(
      () => _i680.GetUserProfileUseCase(gh<_i1043.ProfileRepository>()),
    );
    gh.factory<_i566.GetUserStatsUseCase>(
      () => _i566.GetUserStatsUseCase(gh<_i1043.ProfileRepository>()),
    );
    gh.factory<_i303.UpdateProfileUseCase>(
      () => _i303.UpdateProfileUseCase(gh<_i1043.ProfileRepository>()),
    );
    gh.factory<_i576.UploadAvatarUseCase>(
      () => _i576.UploadAvatarUseCase(gh<_i1043.ProfileRepository>()),
    );
    gh.factory<_i742.SearchBloc>(
      () => _i742.SearchBloc(
        searchItemsUseCase: gh<_i481.SearchItemsUseCase>(),
        getSuggestionsUseCase: gh<_i803.GetSearchSuggestionsUseCase>(),
      ),
    );
    gh.factory<_i241.ChatBloc>(
      () => _i241.ChatBloc(
        getConversationsUseCase: gh<_i610.GetConversationsUseCase>(),
        getMessagesUseCase: gh<_i982.GetMessagesUseCase>(),
        sendMessageUseCase: gh<_i116.SendMessageUseCase>(),
        markAsReadUseCase: gh<_i1052.MarkAsReadUseCase>(),
        getOrCreateConversationUseCase:
            gh<_i232.GetOrCreateConversationUseCase>(),
        chatRepository: gh<_i920.ChatRepository>(),
      ),
    );
    gh.factory<_i935.FavoriteBloc>(
      () => _i935.FavoriteBloc(
        addFavoriteUseCase: gh<_i191.AddFavoriteUseCase>(),
        removeFavoriteUseCase: gh<_i469.RemoveFavoriteUseCase>(),
        getFavoriteItemsUseCase: gh<_i2.GetFavoriteItemsUseCase>(),
      ),
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
        getUserStatsUseCase: gh<_i566.GetUserStatsUseCase>(),
        updateProfileUseCase: gh<_i303.UpdateProfileUseCase>(),
        uploadAvatarUseCase: gh<_i576.UploadAvatarUseCase>(),
      ),
    );
    gh.lazySingleton<_i48.TradeRepository>(
      () => _i429.TradeRepositoryImpl(
        remoteDataSource: gh<_i411.TradeRemoteDataSource>(),
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
    gh.factory<_i773.SendTradeOfferUseCase>(
      () => _i773.SendTradeOfferUseCase(gh<_i48.TradeRepository>()),
    );
    gh.factory<_i773.AcceptTradeOfferUseCase>(
      () => _i773.AcceptTradeOfferUseCase(gh<_i48.TradeRepository>()),
    );
    gh.factory<_i773.RejectTradeOfferUseCase>(
      () => _i773.RejectTradeOfferUseCase(gh<_i48.TradeRepository>()),
    );
    gh.factory<_i773.CancelTradeOfferUseCase>(
      () => _i773.CancelTradeOfferUseCase(gh<_i48.TradeRepository>()),
    );
    gh.factory<_i773.CompleteTradeUseCase>(
      () => _i773.CompleteTradeUseCase(gh<_i48.TradeRepository>()),
    );
    gh.factory<_i773.GetTradeOfferUseCase>(
      () => _i773.GetTradeOfferUseCase(gh<_i48.TradeRepository>()),
    );
    gh.factory<_i773.GetUserTradeOffersUseCase>(
      () => _i773.GetUserTradeOffersUseCase(gh<_i48.TradeRepository>()),
    );
    gh.factory<_i773.GetSentTradeOffersUseCase>(
      () => _i773.GetSentTradeOffersUseCase(gh<_i48.TradeRepository>()),
    );
    gh.factory<_i773.GetReceivedTradeOffersUseCase>(
      () => _i773.GetReceivedTradeOffersUseCase(gh<_i48.TradeRepository>()),
    );
    gh.factory<_i773.GetTradeOffersByStatusUseCase>(
      () => _i773.GetTradeOffersByStatusUseCase(gh<_i48.TradeRepository>()),
    );
    gh.factory<_i773.GetItemTradeHistoryUseCase>(
      () => _i773.GetItemTradeHistoryUseCase(gh<_i48.TradeRepository>()),
    );
    gh.factory<_i773.GetPendingReceivedCountUseCase>(
      () => _i773.GetPendingReceivedCountUseCase(gh<_i48.TradeRepository>()),
    );
    gh.factory<_i503.TradeBloc>(
      () => _i503.TradeBloc(
        sendTradeOfferUseCase: gh<_i773.SendTradeOfferUseCase>(),
        acceptTradeOfferUseCase: gh<_i773.AcceptTradeOfferUseCase>(),
        rejectTradeOfferUseCase: gh<_i773.RejectTradeOfferUseCase>(),
        cancelTradeOfferUseCase: gh<_i773.CancelTradeOfferUseCase>(),
        completeTradeUseCase: gh<_i773.CompleteTradeUseCase>(),
        getTradeOfferUseCase: gh<_i773.GetTradeOfferUseCase>(),
        getUserTradeOffersUseCase: gh<_i773.GetUserTradeOffersUseCase>(),
        getSentTradeOffersUseCase: gh<_i773.GetSentTradeOffersUseCase>(),
        getReceivedTradeOffersUseCase:
            gh<_i773.GetReceivedTradeOffersUseCase>(),
        getTradeOffersByStatusUseCase:
            gh<_i773.GetTradeOffersByStatusUseCase>(),
        getItemTradeHistoryUseCase: gh<_i773.GetItemTradeHistoryUseCase>(),
        getPendingReceivedCountUseCase:
            gh<_i773.GetPendingReceivedCountUseCase>(),
      ),
    );
    return this;
  }
}

class _$FirebaseInjectableModule extends _i328.FirebaseInjectableModule {}
