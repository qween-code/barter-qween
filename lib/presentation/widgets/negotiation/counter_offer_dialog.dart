import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/minimal_design_system.dart';
import '../../../domain/entities/negotiation_entity.dart';
import '../../../domain/entities/counter_offer_entity.dart';
import '../../../domain/usecases/send_counter_offer_usecase.dart';

/// Neuromorphic Counter Offer Dialog
/// Professional counter-offer interface with smooth animations
class CounterOfferDialog extends StatefulWidget {
  final NegotiationEntity negotiation;
  final Function(SendCounterOfferParams) onCounterOffer;

  const CounterOfferDialog({
    Key? key,
    required this.negotiation,
    required this.onCounterOffer,
  }) : super(key: key);

  @override
  State<CounterOfferDialog> createState() => _CounterOfferDialogState();
}

class _CounterOfferDialogState extends State<CounterOfferDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  final _formKey = GlobalKey<FormState>();
  final _cashAmountController = TextEditingController();
  final _messageController = TextEditingController();

  CounterOfferType _selectedType = CounterOfferType.cash;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _cashAmountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: MinimalDesignSystem.baseColor,
                  boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [_buildHeader(), _buildContent(), _buildActions()],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        color: MinimalDesignSystem.baseColor,
        boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: MinimalDesignSystem.baseColor,
                    boxShadow: MinimalDesignSystem.neumorphismOutsetShadow,
                  ),
                  child: Icon(
                    Icons.swap_horiz,
                    color: MinimalDesignSystem.primaryColor,
                    size: 20,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Counter Offer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MinimalDesignSystem.ultraDark,
                  ),
                ),
                Text(
                  'Propose new terms for the negotiation',
                  style: TextStyle(
                    fontSize: 12,
                    color: MinimalDesignSystem.softDark,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: MinimalDesignSystem.baseColor,
                boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
              ),
              child: Icon(
                Icons.close,
                color: MinimalDesignSystem.softDark,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer Type Selection
            Text(
              'Offer Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MinimalDesignSystem.ultraDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildOfferTypeSelector(),

            const SizedBox(height: 24),

            // Cash Amount Input (if cash type selected)
            if (_selectedType == CounterOfferType.cash) ...[
              Text(
                'Cash Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MinimalDesignSystem.ultraDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildCashAmountInput(),
              const SizedBox(height: 24),
            ],

            // Message Input
            Text(
              'Message (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MinimalDesignSystem.ultraDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: MinimalDesignSystem.baseColor,
        boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildOfferTypeButton(
              type: CounterOfferType.cash,
              icon: Icons.attach_money,
              label: 'Cash',
            ),
          ),
          Expanded(
            child: _buildOfferTypeButton(
              type: CounterOfferType.location,
              icon: Icons.location_on,
              label: 'Location',
            ),
          ),
          Expanded(
            child: _buildOfferTypeButton(
              type: CounterOfferType.time,
              icon: Icons.schedule,
              label: 'Time',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferTypeButton({
    required CounterOfferType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? MinimalDesignSystem.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          boxShadow: isSelected
              ? MinimalDesignSystem.neumorphismOutsetShadow
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? MinimalDesignSystem.primaryColor
                  : MinimalDesignSystem.softDark,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? MinimalDesignSystem.primaryColor
                    : MinimalDesignSystem.softDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashAmountInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: MinimalDesignSystem.baseColor,
        boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
      ),
      child: TextFormField(
        controller: _cashAmountController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(color: MinimalDesignSystem.ultraDark, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Enter cash amount',
          hintStyle: TextStyle(color: MinimalDesignSystem.lightShadow),
          prefixIcon: Icon(
            Icons.attach_money,
            color: MinimalDesignSystem.softDark,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (_selectedType == CounterOfferType.cash &&
              (value == null || value.isEmpty)) {
            return 'Please enter cash amount';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: MinimalDesignSystem.baseColor,
        boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
      ),
      child: TextFormField(
        controller: _messageController,
        maxLines: 3,
        style: TextStyle(color: MinimalDesignSystem.ultraDark, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Add a message to your counter offer...',
          hintStyle: TextStyle(color: MinimalDesignSystem.lightShadow),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        color: MinimalDesignSystem.baseColor,
        boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context),
              isPrimary: false,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              text: _isSubmitting ? 'Sending...' : 'Send Offer',
              onPressed: _isSubmitting ? null : _submitCounterOffer,
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16),
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

  void _submitCounterOffer() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    // Create counter offer parameters
    final params = SendCounterOfferParams(
      negotiationId: widget.negotiation.id,
      offerId: 'temp_offer_id', // TODO: Generate proper offer ID
      offererId: 'current_user_id', // Get from auth
      targetUserId: widget.negotiation.getOtherPartyId('current_user_id'),
      type: _selectedType,
      proposedCash: _selectedType == CounterOfferType.cash
          ? double.tryParse(_cashAmountController.text) ?? 0.0
          : null,
      message: _messageController.text.isNotEmpty
          ? _messageController.text
          : null,
      proposedMeetupLocation: _selectedType == CounterOfferType.location
          ? 'New location' // Implement location picker
          : null,
      proposedMeetupTime: _selectedType == CounterOfferType.time
          ? DateTime.now().add(const Duration(days: 1))
          : null,
    );

    // Submit counter offer
    widget.onCounterOffer(params);

    // Close dialog after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
}
