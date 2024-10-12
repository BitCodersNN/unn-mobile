part of 'library.dart';

typedef ReactionCacheKey = int;

class ReactionViewModelFactory
    extends CachedViewModelFactoryBase<ReactionCacheKey, ReactionViewModel> {
  ReactionViewModelFactory() : super(100);

  @override
  @protected
  ReactionViewModel createViewModel(key) {
    return ReactionViewModel(
      getService<GettingVoteKeySigned>(),
      getService<GettingRatingList>(),
      getService<ReactionManager>(),
      getService<CurrentUserSyncStorage>(),
    );
  }
}
