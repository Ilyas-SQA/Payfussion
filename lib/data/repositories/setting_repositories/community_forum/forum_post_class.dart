class Reply {
  final String author;
  final String content;

  Reply({required this.author, required this.content});

  factory Reply.fromMap(Map<String, dynamic> map) {
    return Reply(
      author: map['author'],
      content: map['content'],
    );
  }
}

class Comment {
  final String author;
  final String content;
  final List<Reply> replies;

  Comment({
    required this.author,
    required this.content,
    this.replies = const <Reply>[],
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      author: map['author'],
      content: map['content'],
      replies: (map['replies'] as List<dynamic>?)
          ?.map((e) => Reply.fromMap(e))
          .toList() ??
          <Reply>[],
    );
  }
}

class ForumPost {
  final String title;
  final String author;
  final String content;
  final int likes;
  final List<Comment> comments;

  ForumPost({
    required this.title,
    required this.author,
    required this.content,
    this.likes = 0,
    this.comments = const <Comment>[],
  });

  ForumPost copyWith({
    String? title,
    String? author,
    String? content,
    int? likes,
    List<Comment>? comments,
  }) {
    return ForumPost(
      title: title ?? this.title,
      author: author ?? this.author,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }

  factory ForumPost.fromMap(Map<String, dynamic> map) {
    return ForumPost(
      title: map['title'],
      author: map['author'],
      content: map['content'],
      comments: (map['comments'] as List<dynamic>)
          .map((e) => Comment.fromMap(e))
          .toList(),
    );
  }
}