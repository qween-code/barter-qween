import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/trade_offer_entity.dart';
import '../../blocs/trade/trade_bloc.dart';
import '../../blocs/trade/trade_event.dart';
import '../../blocs/trade/trade_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/rating/rating_bloc.dart';
import '../../blocs/rating/rating_event.dart';
import '../../widgets/rating_dialog.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/analytics_service.dart';

class TradeDetailPage extends StatelessWidget {
  final TradeOfferEntity offer;

  const TradeDetailPage({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Trade Details'),
        elevation: 0,
        actions: [
          if (offer.status.isPending)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showMoreOptions(context),
            ),
        ],
      ),
      body: BlocListener<TradeBloc, TradeState>(
        listener: (context, state) {
          if (state is TradeOfferAccepted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Trade accepted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is TradeOfferRejected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Trade rejected'),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pop(context);
          } else if (state is TradeOfferCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Trade cancelled'),
                backgroundColor: Colors.grey,
              ),
            );
            Navigator.pop(context);
          } else if (state is TradeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusHeader(context),
              const SizedBox(height: 16),
              _buildTradeOverview(context),
              const SizedBox(height: 16),
              _buildItemsSection(context),
              if (offer.message != null && offer.message!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildMessageSection(context),
              ],
              const SizedBox(height: 16),
              _buildTimelineSection(context),
              const SizedBox(height: 24),
              if (offer.status.isPending) _buildActionButtons(context),
              if (offer.status == TradeStatus.completed) ...[
                const SizedBox(height: 16),
                _buildRatingSection(context),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText = offer.status.displayName;

    switch (offer.status) {
      case TradeStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case TradeStatus.accepted:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case TradeStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case TradeStatus.completed:
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        break;
      case TradeStatus.cancelled:
        statusColor = Colors.grey;
        statusIcon = Icons.block;
        break;
      case TradeStatus.expired:
        statusColor = Colors.grey;
        statusIcon = Icons.access_time;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: statusColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        children: [
          Icon(statusIcon, size: 48, color: statusColor),
          const SizedBox(height: 12),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Trade ID: ${offer.id.substring(0, 8)}...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeOverview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trade Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'From',
            value: offer.fromUserName,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.person,
            label: 'To',
            value: offer.toUserName,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Created',
            value: _formatDateTime(offer.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items in Trade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Offered Item
          _buildItemCard(
            title: offer.offeredItemTitle,
            images: offer.offeredItemImages,
            label: 'Offering',
            color: Colors.green,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.swap_horiz,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
          ),
          // Requested Item
          _buildItemCard(
            title: offer.requestedItemTitle,
            images: offer.requestedItemImages,
            label: 'Requesting',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard({
    required String title,
    required List<String> images,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey.shade200,
              child: images.isNotEmpty
                  ? Image.network(
                      images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.inventory_2_outlined, color: Colors.grey.shade400),
                    )
                  : Icon(Icons.inventory_2_outlined, color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.message, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Message',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"${offer.message}"',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            icon: Icons.add_circle,
            title: 'Trade Offer Created',
            time: offer.createdAt,
            isCompleted: true,
          ),
          if (offer.status != TradeStatus.pending)
            _buildTimelineItem(
              icon: _getStatusIcon(),
              title: 'Trade ${offer.status.displayName}',
              time: DateTime.now(), // In real app, would be updatedAt
              isCompleted: true,
            ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (offer.status) {
      case TradeStatus.accepted:
        return Icons.check_circle;
      case TradeStatus.rejected:
        return Icons.cancel;
      case TradeStatus.completed:
        return Icons.done_all;
      case TradeStatus.cancelled:
        return Icons.block;
      case TradeStatus.expired:
        return Icons.access_time;
      default:
        return Icons.help;
    }
  }

  Widget _buildRatingSection(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RatingBloc>(),
      child: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final auth = context.read<AuthBloc>().state;
                  String? fromUserId;
                  String toUserId;
                  if (auth is AuthAuthenticated) {
                    fromUserId = auth.user.uid;
                  }
                  // Determine the other user
                  toUserId = (fromUserId == offer.fromUserId) ? offer.toUserId : offer.fromUserId;

                  await showDialog(
                    context: context,
                    builder: (_) => RatingDialog(
                      userName: offer.toUserName,
                      onSubmit: (rating, comment) {
                        if (fromUserId != null) {
                          context.read<RatingBloc>().add(SubmitRating(
                                fromUserId: fromUserId,
                                toUserId: toUserId,
                                tradeId: offer.id,
                                rating: rating,
                                comment: comment,
                              ));
                        }
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.star_rate_rounded),
                label: const Text('Rate user'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required DateTime time,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? Colors.green.withValues(alpha: 0.1) 
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isCompleted ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatDateTime(time),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Log analytics
                try {
                  getIt<AnalyticsService>().logTradeAccepted(tradeId: offer.id);
                } catch (_) {}
                
                context.read<TradeBloc>().add(AcceptTradeOffer(offer.id));
              },
              icon: const Icon(Icons.check),
              label: const Text('Accept Trade'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showRejectDialog(context);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Open chat with user
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chat feature coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Trade'),
        content: const Text('Are you sure you want to reject this trade offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Log analytics
              try {
                getIt<AnalyticsService>().logTradeRejected(tradeId: offer.id);
              } catch (_) {}
              
              context.read<TradeBloc>().add(RejectTradeOffer(offer.id));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Cancel Trade'),
              onTap: () {
                Navigator.pop(context);
                _showCancelDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.orange),
              title: const Text('Report Issue'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Trade'),
        content: const Text('Are you sure you want to cancel this trade offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              context.read<TradeBloc>().add(CancelTradeOffer(offer.id));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      final format = DateFormat('HH:mm');
      return 'Today at ${format.format(date)}';
    } else if (difference.inDays == 1) {
      final format = DateFormat('HH:mm');
      return 'Yesterday at ${format.format(date)}';
    } else if (difference.inDays < 7) {
      final format = DateFormat('EEEE HH:mm');
      return format.format(date);
    } else {
      final format = DateFormat('MMM dd, yyyy');
      return format.format(date);
    }
  }
}
