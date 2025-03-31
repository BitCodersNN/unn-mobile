Map<int, Map> buildUserMap(List usersJson) {
  return <int, Map<String, dynamic>>{
    for (final user in usersJson.cast<Map<String, dynamic>>())
      user['id'] as int: user,
  };
}
