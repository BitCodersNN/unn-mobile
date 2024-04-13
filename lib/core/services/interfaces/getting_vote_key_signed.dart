abstract interface class GettingVoteKeySigned {
  Future<String?> getVoteKeySigned(
    int userId,
    int id,
  );
}
