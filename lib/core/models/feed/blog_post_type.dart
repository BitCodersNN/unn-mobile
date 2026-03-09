// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

const _blogPostTypeToString = {
  BlogPostType.regular: 'regular',
  BlogPostType.pinned: 'pinned',
  BlogPostType.important: 'important',
};

enum BlogPostType {
  regular,
  pinned,
  important,
}

enum ExtendedBlogPostType {
  regular,
  pinned,
  important,
  importantPinned,
}

extension BlogPostTypeExtension on BlogPostType {
  String get stringValue => _blogPostTypeToString[this]!;
}
