// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

enum GitPath {
  loadingScreen('loading_screen', 'loading_page_config.json'),
  authors('authors', 'authors_config.json'),
  birthday('birthday', 'birthday_greetings.json');

  static const String branch = 'develop';
  final String directory;
  final String configFile;

  const GitPath(this.directory, this.configFile);

  String pathAt(String revision) => '$revision/$directory';
}
