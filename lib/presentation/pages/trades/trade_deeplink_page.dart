import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../blocs/trade/trade_bloc.dart';
import '../../blocs/trade/trade_event.dart';
import '../../blocs/trade/trade_state.dart';
import 'trade_detail_page.dart';

class TradeDeepLinkPage extends StatelessWidget {
  final String tradeId;
  const TradeDeepLinkPage({super.key, required this.tradeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TradeBloc>()..add(LoadTradeOffer(tradeId)),
      child: BlocConsumer<TradeBloc, TradeState>(
        listener: (context, state) {
          if (state is TradeOfferLoaded) {
            // Navigate to detail and replace this page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<TradeBloc>(),
                  child: TradeDetailPage(offer: state.offer),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TradeError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Trade')),
              body: Center(child: Text('Failed to load trade: ${state.message}')),
            );
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}