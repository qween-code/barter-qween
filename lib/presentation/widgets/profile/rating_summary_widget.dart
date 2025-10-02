import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../../../domain/usecases/rating/get_user_rating_stats_usecase.dart';
import '../../../domain/entities/rating_entity.dart';

class RatingSummaryWidget extends StatefulWidget {
  final String userId;
  const RatingSummaryWidget({super.key, required this.userId});

  @override
  State<RatingSummaryWidget> createState() => _RatingSummaryWidgetState();
}

class _RatingSummaryWidgetState extends State<RatingSummaryWidget> {
  Future<UserRatingStats>? _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<GetUserRatingStatsUseCase>().call(widget.userId).then((e) => e.fold((l) => const UserRatingStats(userId: '', averageRating: 0, totalRatings: 0, ratingDistribution: {}), (r) => r));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRatingStats>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final stats = snapshot.data!;
        final avg = stats.averageRating;
        final total = stats.totalRatings;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(5, (i) {
              final filled = avg >= i + 1;
              final half = !filled && avg > i && avg < i + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  filled
                      ? Icons.star
                      : half
                          ? Icons.star_half
                          : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              );
            }),
            const SizedBox(width: 8),
            Text(avg.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Text('($total)', style: TextStyle(color: Colors.grey.shade600)),
          ],
        );
      },
    );
  }
}