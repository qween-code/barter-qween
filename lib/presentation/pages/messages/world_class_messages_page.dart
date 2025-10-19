// 💬 WORLD CLASS MESSAGES PAGE
// Real-time chat with trade offers

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/di/injection.dart';
import '../../../core/routes/app_router.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/entities/trade_offer_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/profile/get_user_profile_usecase.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../blocs/trade/trade_bloc.dart';
import '../../blocs/trade/trade_event.dart';
import '../../blocs/trade/trade_state.dart';
import '../chat/chat_detail_page.dart';
import '../trades/trade_detail_page.dart';

const _itemPlaceholderImage =
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&auto=format&fit=crop';

class WorldClassMessagesPage extends StatefulWidget {
  const WorldClassMessagesPage({Key? key}) : super(key: key);

  @override
  State<WorldClassMessagesPage> createState() => _WorldClassMessagesPageState();
}

class _WorldClassMessagesPageState extends State<WorldClassMessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ChatBloc _chatBloc;
  late final TradeBloc _tradeBloc;
  late final GetUserProfileUseCase _getUserProfileUseCase;

  String? _currentUserId;
  bool _hasRequestedConversations = false;
  bool _hasRequestedTrades = false;
  bool _isProcessingTradeAction = false;

  final Map<String, UserEntity> _userCache = {};
  List<ConversationEntity> _conversations = [];
  List<TradeOfferEntity> _tradeOffers = [];
  int _totalUnread = 0;
  int _pendingOffersCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chatBloc = getIt<ChatBloc>();
    _tradeBloc = getIt<TradeBloc>();
    _getUserProfileUseCase = getIt<GetUserProfileUseCase>();
    timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;
      _synchronizeWithAuthState(authState);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatBloc.close();
    _tradeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allLabel = _totalUnread > 0 ? 'All ($_totalUnread)' : 'All';
    final offersLabel = _pendingOffersCount > 0
        ? 'Offers ($_pendingOffersCount)'
        : 'Offers';

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            _synchronizeWithAuthState(state);
          },
        ),
        BlocListener<ChatBloc, ChatState>(
          bloc: _chatBloc,
          listener: (context, state) {
            if (state is ConversationsLoaded) {
              if (!mounted) return;
              setState(() {
                _conversations = state.conversations;
                _totalUnread = state.totalUnreadCount;
              });
              _preloadUserProfiles(state.conversations);
            } else if (state is ChatError && _conversations.isEmpty) {
              _showSnackBar(state.message, isError: true);
            }
          },
        ),
        BlocListener<TradeBloc, TradeState>(
          bloc: _tradeBloc,
          listener: (context, state) {
            if (state is TradeOffersLoaded) {
              if (!mounted) return;
              setState(() {
                _tradeOffers = state.offers;
                _pendingOffersCount = _calculatePendingOffers(state.offers);
                _isProcessingTradeAction = false;
              });
            } else if (state is TradeActionInProgress) {
              if (!mounted) return;
              setState(() => _isProcessingTradeAction = true);
            } else if (state is TradeOfferAccepted) {
              _showSnackBar('Trade accepted successfully!');
              if (_currentUserId != null) {
                _tradeBloc.add(RefreshTradeOffers(_currentUserId!));
              }
            } else if (state is TradeOfferRejected) {
              _showSnackBar('Trade rejected');
              if (_currentUserId != null) {
                _tradeBloc.add(RefreshTradeOffers(_currentUserId!));
              }
            } else if (state is TradeOfferCancelled) {
              _showSnackBar('Trade cancelled');
              if (_currentUserId != null) {
                _tradeBloc.add(RefreshTradeOffers(_currentUserId!));
              }
            } else if (state is TradeError) {
              if (!mounted) return;
              setState(() => _isProcessingTradeAction = false);
              _showSnackBar(state.message, isError: true);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(_isProcessingTradeAction ? 64 : 48),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: allLabel),
                    Tab(text: offersLabel),
                  ],
                ),
                if (_isProcessingTradeAction)
                  const LinearProgressIndicator(minHeight: 2),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildChatList(), _buildOffersList()],
        ),
      ),
    );
  }

  void _synchronizeWithAuthState(AuthState state) {
    if (state is AuthAuthenticated) {
      _applyAuthenticatedState(state);
    } else if (state is AuthUnauthenticated) {
      _resetAuthData();
    }
  }

  void _applyAuthenticatedState(AuthAuthenticated state) {
    final userId = state.user.uid;

    if (_currentUserId != userId) {
      if (mounted) {
        setState(() {
          _currentUserId = userId;
        });
      } else {
        _currentUserId = userId;
      }
    }

    if (!_hasRequestedConversations) {
      _chatBloc.add(LoadConversations(userId));
      _hasRequestedConversations = true;
    }

    if (!_hasRequestedTrades) {
      _tradeBloc.add(LoadUserTradeOffers(userId));
      _hasRequestedTrades = true;
    }
  }

  void _resetAuthData() {
    if (mounted) {
      setState(() {
        _currentUserId = null;
        _conversations = [];
        _tradeOffers = [];
        _totalUnread = 0;
        _pendingOffersCount = 0;
        _isProcessingTradeAction = false;
      });
    } else {
      _currentUserId = null;
      _conversations = [];
      _tradeOffers = [];
      _totalUnread = 0;
      _pendingOffersCount = 0;
      _isProcessingTradeAction = false;
    }
    _hasRequestedConversations = false;
    _hasRequestedTrades = false;
  }

  Future<void> _preloadUserProfiles(
    List<ConversationEntity> conversations,
  ) async {
    if (_currentUserId == null) return;
    final ids = <String>{};
    for (final conversation in conversations) {
      for (final participant in conversation.participants) {
        if (participant != _currentUserId &&
            !_userCache.containsKey(participant)) {
          ids.add(participant);
        }
      }
    }

    for (final userId in ids) {
      final result = await _getUserProfileUseCase(userId);
      result.fold((_) {}, (user) {
        if (!mounted) return;
        setState(() {
          _userCache[userId] = user;
        });
      });
    }
  }

  int _calculatePendingOffers(List<TradeOfferEntity> offers) {
    if (_currentUserId == null) return 0;
    return offers
        .where(
          (offer) =>
              offer.status == TradeStatus.pending &&
              offer.toUserId == _currentUserId,
        )
        .length;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  Widget _buildChatList() {
    if (_currentUserId == null) {
      return _buildAuthPlaceholder();
    }

    return BlocBuilder<ChatBloc, ChatState>(
      bloc: _chatBloc,
      builder: (context, state) {
        if ((state is ChatLoading || state is ChatInitial) &&
            _conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatError && _conversations.isEmpty) {
          return _buildErrorPlaceholder(
            message: state.message,
            onRetry: () {
              if (_currentUserId != null) {
                _chatBloc.add(LoadConversations(_currentUserId!));
              }
            },
          );
        }

        if (_conversations.isEmpty) {
          return _buildEmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'Henüz mesaj yok',
            subtitle: 'Teklif göndererek ilk sohbetini başlat.',
          );
        }

        return ListView.separated(
          itemCount: _conversations.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final conversation = _conversations[index];
            return _buildConversationTile(conversation);
          },
        );
      },
    );
  }

  Widget _buildOffersList() {
    if (_currentUserId == null) {
      return _buildAuthPlaceholder();
    }

    return BlocBuilder<TradeBloc, TradeState>(
      bloc: _tradeBloc,
      builder: (context, state) {
        if ((state is TradeLoading || state is TradeInitial) &&
            _tradeOffers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TradeError && _tradeOffers.isEmpty) {
          return _buildErrorPlaceholder(
            message: state.message,
            onRetry: () {
              if (_currentUserId != null) {
                _tradeBloc.add(LoadUserTradeOffers(_currentUserId!));
              }
            },
          );
        }

        if (_tradeOffers.isEmpty) {
          return _buildEmptyState(
            icon: Icons.swap_horiz,
            title: 'Henüz teklif yok',
            subtitle:
                'Keşfet sayfasından ürünleri inceleyip teklif gönderebilirsin.',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshTrades,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _tradeOffers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final offer = _tradeOffers[index];
              return _buildTradeCard(offer);
            },
          ),
        );
      },
    );
  }

  Widget _buildConversationTile(ConversationEntity conversation) {
    final otherUserId = conversation.getOtherParticipantId(_currentUserId!);
    final user = _userCache[otherUserId];
    final displayName = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : user?.email ?? 'Misafir';
    final photoUrl = user?.photoUrl;
    final unread = conversation.getUnreadCountForUser(_currentUserId!);
    final lastMessage = conversation.lastMessage.isNotEmpty
        ? conversation.lastMessage
        : 'Yeni sohbet';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: photoUrl != null && photoUrl.isNotEmpty
            ? NetworkImage(photoUrl)
            : null,
        child: (photoUrl == null || photoUrl.isEmpty)
            ? Text(
                displayName.isNotEmpty
                    ? displayName.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: TextStyle(
                fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Text(
            _formatTime(conversation.lastMessageTime),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
          color: unread > 0 ? Colors.black87 : Colors.grey[600],
        ),
      ),
      trailing: unread > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unread.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : null,
      onTap: () => _openConversation(conversation),
    );
  }

  Widget _buildTradeCard(TradeOfferEntity offer) {
    final partnerName = offer.getOtherUserName(_currentUserId ?? '');
    final isReceiver =
        _currentUserId != null && offer.isReceiver(_currentUserId!);
    final hasCash = (offer.cashDifferential ?? 0) > 0;

    final primaryItemTitle = isReceiver
        ? offer.offeredItemTitle
        : offer.requestedItemTitle;
    final primaryImage = isReceiver
        ? (offer.offeredItemImages.isNotEmpty
              ? offer.offeredItemImages.first
              : null)
        : (offer.requestedItemImages.isNotEmpty
              ? offer.requestedItemImages.first
              : null);

    final secondaryItemTitle = isReceiver
        ? offer.requestedItemTitle
        : offer.offeredItemTitle;
    final secondaryImage = isReceiver
        ? (offer.requestedItemImages.isNotEmpty
              ? offer.requestedItemImages.first
              : null)
        : (offer.offeredItemImages.isNotEmpty
              ? offer.offeredItemImages.first
              : null);

    return InkWell(
      onTap: () => _openTradeDetail(offer),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _statusColor(offer.status).withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    partnerName.isNotEmpty
                        ? partnerName.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partnerName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatTime(offer.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildTradeStatusBadge(offer.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildItemPreview(
                    label: isReceiver ? 'Onların ürünü' : 'Teklif ettiğin',
                    title: primaryItemTitle,
                    imageUrl: primaryImage,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.swap_horiz, color: Colors.grey[400]),
                ),
                Expanded(
                  child: _buildItemPreview(
                    label: isReceiver ? 'Senin ürünün' : 'İstedikleri',
                    title: secondaryItemTitle,
                    imageUrl: secondaryImage,
                  ),
                ),
              ],
            ),
            if (hasCash) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+ ₺${(offer.cashDifferential ?? 0).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (offer.status == TradeStatus.pending) ...[
              const SizedBox(height: 16),
              if (isReceiver)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessingTradeAction
                            ? null
                            : () => _tradeBloc.add(RejectTradeOffer(offer.id)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessingTradeAction
                            ? null
                            : () => _tradeBloc.add(AcceptTradeOffer(offer.id)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                )
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Yanıt bekleniyor',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTradeStatusBadge(TradeStatus status) {
    final color = _statusColor(status);
    IconData icon;
    switch (status) {
      case TradeStatus.pending:
        icon = Icons.schedule;
        break;
      case TradeStatus.accepted:
        icon = Icons.check_circle;
        break;
      case TradeStatus.rejected:
        icon = Icons.cancel;
        break;
      case TradeStatus.completed:
        icon = Icons.done_all;
        break;
      case TradeStatus.cancelled:
        icon = Icons.block;
        break;
      case TradeStatus.expired:
        icon = Icons.hourglass_bottom;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(TradeStatus status) {
    switch (status) {
      case TradeStatus.pending:
        return Colors.orange;
      case TradeStatus.accepted:
        return Colors.green;
      case TradeStatus.rejected:
        return Colors.red;
      case TradeStatus.completed:
        return Colors.blue;
      case TradeStatus.cancelled:
      case TradeStatus.expired:
        return Colors.grey;
    }
  }

  Widget _buildItemPreview({
    required String label,
    required String title,
    String? imageUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(imageUrl ?? _itemPlaceholderImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildErrorPlaceholder({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => AppRouter.toExplore(context),
              child: const Text('Keşfet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Mesajları görmek için giriş yapmalısın'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => AppRouter.toLogin(context),
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }

  void _openConversation(ConversationEntity conversation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _chatBloc,
          child: ChatDetailPage(conversation: conversation),
        ),
      ),
    );
  }

  void _openTradeDetail(TradeOfferEntity offer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _tradeBloc,
          child: TradeDetailPage(offer: offer),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'en_short');
  }

  Future<void> _refreshTrades() async {
    if (_currentUserId != null) {
      _tradeBloc.add(RefreshTradeOffers(_currentUserId!));
    }
  }
}
