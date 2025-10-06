import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/minimal_design_system.dart';
import '../../../domain/entities/negotiation_entity.dart';
import '../../../domain/entities/counter_offer_entity.dart';
import '../../../domain/usecases/create_negotiation_usecase.dart';
import '../../../domain/usecases/send_counter_offer_usecase.dart';
import '../../bloc/negotiation/negotiation_cubit.dart';
import '../../bloc/negotiation/negotiation_state.dart';
import '../../widgets/negotiation/negotiation_timeline_widget.dart';
import '../../widgets/negotiation/counter_offer_dialog.dart';
import '../../widgets/negotiation/negotiation_chat_widget.dart';

/// Neuromorphic Negotiation Page
/// World-class negotiation interface with real-time updates
class NegotiationPage extends StatefulWidget {
  final String negotiationId;
  final String sourceItemId;
  final String targetItemId;
  final String otherUserId;
  final String otherUserName;

  const NegotiationPage({
    Key? key,
    required this.negotiationId,
    required this.sourceItemId,
    required this.targetItemId,
    required this.otherUserId,
    required this.otherUserName,
  }) : super(key: key);

  @override
  State<NegotiationPage> createState() => _NegotiationPageState();
}

class _NegotiationPageState extends State<NegotiationPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadNegotiation();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _loadNegotiation() {
    // Load negotiation data
    // This would typically load from repository
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NegotiationCubit>(),
      child: Scaffold(
        backgroundColor: MinimalDesignSystem.baseColor,
        appBar: _buildAppBar(),
        body: BlocBuilder<NegotiationCubit, NegotiationState>(
          builder: (context, state) {
            return AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _slideAnimation.value)),
                  child: Opacity(
                    opacity: _slideAnimation.value,
                    child: _buildBody(context, state),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: MinimalDesignSystem.baseColor,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: MinimalDesignSystem.baseColor,
          boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: MinimalDesignSystem.softDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Negotiation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: MinimalDesignSystem.ultraDark,
              fontSize: 18,
            ),
          ),
          Text(
            'with ${widget.otherUserName}',
            style: TextStyle(
              color: MinimalDesignSystem.softDark,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: MinimalDesignSystem.baseColor,
            boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
          ),
          child: IconButton(
            icon: Icon(
              Icons.more_vert,
              color: MinimalDesignSystem.softDark,
            ),
            onPressed: _showOptionsMenu,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, NegotiationState state) {
    if (state is NegotiationLoading) {
      return _buildLoadingState();
    }

    if (state is NegotiationError) {
      return _buildErrorState(state.message);
    }

    if (state is NegotiationActive) {
      return _buildActiveNegotiation(context, state);
    }

    return _buildInitialState();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: MinimalDesignSystem.baseColor,
              boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
            ),
            child: Icon(
              Icons.handshake,
              size: 40,
              color: MinimalDesignSystem.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading negotiation...',
            style: TextStyle(
              fontSize: 16,
              color: MinimalDesignSystem.softDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: MinimalDesignSystem.baseColor,
          boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: MinimalDesignSystem.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MinimalDesignSystem.ultraDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: MinimalDesignSystem.softDark,
              ),
            ),
            const SizedBox(height: 24),
            _buildNeuromorphicButton(
              text: 'Try Again',
              onPressed: () => _loadNegotiation(),
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: MinimalDesignSystem.baseColor,
          boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: MinimalDesignSystem.baseColor,
                      boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
                    ),
                    child: Icon(
                      Icons.handshake,
                      size: 50,
                      color: MinimalDesignSystem.primaryColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Start Negotiation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: MinimalDesignSystem.ultraDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Begin negotiating with ${widget.otherUserName}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: MinimalDesignSystem.softDark,
              ),
            ),
            const SizedBox(height: 32),
            _buildNeuromorphicButton(
              text: 'Start Negotiation',
              onPressed: _startNegotiation,
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveNegotiation(BuildContext context, NegotiationActive state) {
    return Column(
      children: [
        // Negotiation Timeline
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: MinimalDesignSystem.baseColor,
              boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
            ),
            child: NegotiationTimelineWidget(
              negotiation: state.negotiation,
              onCounterOffer: _showCounterOfferDialog,
            ),
          ),
        ),
        
        // Chat Section
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: MinimalDesignSystem.baseColor,
              boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
            ),
            child: NegotiationChatWidget(
              negotiationId: widget.negotiationId,
              otherUserId: widget.otherUserId,
              otherUserName: widget.otherUserName,
            ),
          ),
        ),
        
        // Action Buttons
        _buildActionButtons(context, state),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, NegotiationActive state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalDesignSystem.baseColor,
        boxShadow: [
          BoxShadow(
            color: MinimalDesignSystem.secondaryGray,
            offset: const Offset(0, -4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildNeuromorphicButton(
              text: 'Counter Offer',
              onPressed: () => _showCounterOfferDialog(state.negotiation),
              isPrimary: false,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildNeuromorphicButton(
              text: 'Accept',
              onPressed: () => _acceptNegotiation(state.negotiation),
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeuromorphicButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: MinimalDesignSystem.baseColor,
          boxShadow: isPrimary
              ? MinimalDesignSystem.neumorphismInsetShadow
              : MinimalDesignSystem.neumorphismOutsetShadow,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPrimary
                ? MinimalDesignSystem.primaryColor
                : MinimalDesignSystem.softDark,
          ),
        ),
      ),
    );
  }

  void _startNegotiation() {
    // Implement negotiation start logic
    context.read<NegotiationCubit>().createNegotiation(
      CreateNegotiationParams.fromOffer(
        tradeOfferId: 'temp_offer_id', // TODO: Get from actual offer
        initiatorId: 'current_user_id', // Get from auth
        responderId: widget.otherUserId,
        message: 'Takas şartlarını görüşmek istiyorum',
      ),
    );
  }

  void _showCounterOfferDialog(NegotiationEntity negotiation) {
    showDialog(
      context: context,
      builder: (context) => CounterOfferDialog(
        negotiation: negotiation,
        onCounterOffer: (params) {
          context.read<NegotiationCubit>().sendCounterOffer(params);
        },
      ),
    );
  }

  void _acceptNegotiation(NegotiationEntity negotiation) {
    // Implement accept logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MinimalDesignSystem.baseColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Accept Negotiation',
          style: TextStyle(
            color: MinimalDesignSystem.ultraDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to accept this negotiation?',
          style: TextStyle(
            color: MinimalDesignSystem.softDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: MinimalDesignSystem.softDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement accept logic
            },
            child: Text(
              'Accept',
              style: TextStyle(
                color: MinimalDesignSystem.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: MinimalDesignSystem.baseColor,
          boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.block,
                color: MinimalDesignSystem.errorColor,
              ),
              title: Text(
                'Block User',
                style: TextStyle(
                  color: MinimalDesignSystem.ultraDark,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implement block logic
              },
            ),
            ListTile(
              leading: Icon(
                Icons.report,
                color: MinimalDesignSystem.warningColor,
              ),
              title: Text(
                'Report',
                style: TextStyle(
                  color: MinimalDesignSystem.ultraDark,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implement report logic
              },
            ),
            ListTile(
              leading: Icon(
                Icons.close,
                color: MinimalDesignSystem.softDark,
              ),
              title: Text(
                'Cancel',
                style: TextStyle(
                  color: MinimalDesignSystem.softDark,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
