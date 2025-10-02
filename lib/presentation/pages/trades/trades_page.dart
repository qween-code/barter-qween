import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/trade_offer_entity.dart';
import '../../blocs/trade/trade_bloc.dart';
import '../../blocs/trade/trade_event.dart';
import '../../blocs/trade/trade_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class TradesPage extends StatefulWidget {
  const TradesPage({super.key});

  @override
  State<TradesPage> createState() => _TradesPageState();
}

class _TradesPageState extends State<TradesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTrades();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTrades() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<TradeBloc>().add(LoadUserTradeOffers(authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trades'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Received', icon: Icon(Icons.inbox, size: 20)),
            Tab(text: 'Sent', icon: Icon(Icons.send, size: 20)),
          ],
        ),
      ),
      body: BlocBuilder<TradeBloc, TradeState>(
        builder: (context, state) {
          if (state is TradeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TradeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTrades,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TradeOffersLoaded || state is FilteredTradeOffersLoaded) {
            final offers = state is TradeOffersLoaded
                ? state.offers
                : (state as FilteredTradeOffersLoaded).offers;

            if (offers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swap_horiz, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'No trade offers yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start trading items!',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }

            final authState = context.read<AuthBloc>().state;
            final currentUserId = authState is Authenticated ? authState.user.uid : '';

            final receivedOffers = offers.where((o) => o.toUserId == currentUserId).toList();
            final sentOffers = offers.where((o) => o.fromUserId == currentUserId).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildTradeList(receivedOffers, isReceived: true),
                _buildTradeList(sentOffers, isReceived: false),
              ],
            );
          }

          return const Center(child: Text('Loading trades...'));
        },
      ),
    );
  }

  Widget _buildTradeList(List<TradeOfferEntity> offers, {required bool isReceived}) {
    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isReceived ? Icons.inbox : Icons.send,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isReceived ? 'No received offers' : 'No sent offers',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadTrades(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: offers.length,
        itemBuilder: (context, index) => _buildTradeCard(offers[index], isReceived: isReceived),
      ),
    );
  }

  Widget _buildTradeCard(TradeOfferEntity offer, {required bool isReceived}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isReceived ? 'From: ${offer.fromUserName}' : 'To: ${offer.toUserName}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildStatusBadge(offer.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            // Items
            Row(
              children: [
                // Your item
                Expanded(
                  child: _buildItemPreview(
                    title: isReceived ? offer.requestedItemTitle : offer.offeredItemTitle,
                    image: isReceived 
                        ? (offer.requestedItemImages.isNotEmpty ? offer.requestedItemImages.first : null)
                        : (offer.offeredItemImages.isNotEmpty ? offer.offeredItemImages.first : null),
                    label: 'Your Item',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.swap_horiz, color: Theme.of(context).primaryColor),
                ),
                // Their item
                Expanded(
                  child: _buildItemPreview(
                    title: isReceived ? offer.offeredItemTitle : offer.requestedItemTitle,
                    image: isReceived
                        ? (offer.offeredItemImages.isNotEmpty ? offer.offeredItemImages.first : null)
                        : (offer.requestedItemImages.isNotEmpty ? offer.requestedItemImages.first : null),
                    label: 'Their Item',
                  ),
                ),
              ],
            ),
            if (offer.message != null && offer.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${offer.message}"',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              _formatDate(offer.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            // Action buttons for pending received offers
            if (isReceived && offer.status.isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<TradeBloc>().add(AcceptTradeOffer(offer.id));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Accept'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<TradeBloc>().add(RejectTradeOffer(offer.id));
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
            // Cancel button for pending sent offers
            if (!isReceived && offer.status.isPending) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<TradeBloc>().add(CancelTradeOffer(offer.id));
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                  child: const Text('Cancel Offer'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemPreview({required String title, String? image, required String label}) {
    return Column(
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            image: image != null
                ? DecorationImage(image: NetworkImage(image), fit: BoxFit.cover)
                : null,
          ),
          child: image == null
              ? Center(child: Icon(Icons.inventory_2_outlined, color: Colors.grey.shade400))
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(TradeStatus status) {
    Color color;
    String text = status.displayName;

    switch (status) {
      case TradeStatus.pending:
        color = Colors.orange;
        break;
      case TradeStatus.accepted:
        color = Colors.green;
        break;
      case TradeStatus.rejected:
        color = Colors.red;
        break;
      case TradeStatus.completed:
        color = Colors.blue;
        break;
      case TradeStatus.cancelled:
        color = Colors.grey;
        break;
      case TradeStatus.expired:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
