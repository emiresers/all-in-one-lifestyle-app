import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/quote.dart';
import '../../services/quote_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_account_actions.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/app_loading_state.dart';
import '../../widgets/app_screen_header.dart';

class QuotesScreen extends StatefulWidget {
  final int userId;
  final ScrollController? scrollController;

  const QuotesScreen({super.key, required this.userId, this.scrollController});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final QuoteService _quoteService = QuoteService();

  late Future<List<Quote>> _quotesFuture;

  @override
  void initState() {
    super.initState();

    _loadQuotes();
  }

  void _loadQuotes() {
    _quotesFuture = _quoteService.getQuotes();
  }

  Future<void> _refreshQuotes() async {
    setState(() {
      _loadQuotes();
    });

    await _quotesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPrimaryHeaderSurface(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.lg,
                AppSpacing.screenH,
                AppSpacing.lg,
              ),
              child: AppScreenHeader(
                title: 'Quotes',
                subtitle: 'Thoughts worth remembering',
                foregroundColor: Colors.white,
                action: AppAccountActions(userId: widget.userId),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Expanded(
            child: FutureBuilder<List<Quote>>(
              future: _quotesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingState();
                }

                if (snapshot.hasError) {
                  return AppErrorState(
                    message: '${snapshot.error}',
                    onRetry: () {
                      setState(() {
                        _loadQuotes();
                      });
                    },
                  );
                }

                final quotes = snapshot.data ?? [];

                if (quotes.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshQuotes,
                    child: const AppRefreshableEmptyState(
                      icon: Icons.format_quote_rounded,
                      title: 'No quotes found',
                      subtitle: 'Pull down to refresh and try again.',
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshQuotes,
                  child: ListView.separated(
                    controller: widget.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      2,
                      AppSpacing.screenH,
                      AppSpacing.xxl,
                    ),
                    itemCount: quotes.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.listGap),
                    itemBuilder: (context, index) {
                      return _QuoteCard(quote: quotes[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final Quote quote;

  const _QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.largeCard,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            size: 22,
            color: AppColors.textTertiary,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            quote.quote,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          const Divider(color: AppColors.border, height: 1),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 15,
                color: AppColors.textTertiary,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  quote.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
