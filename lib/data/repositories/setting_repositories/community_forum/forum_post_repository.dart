import 'forum_post_class.dart';

class ForumPostRepository {
  final List<Map<String, dynamic>> _posts = <Map<String, dynamic>>[
    <String, dynamic>{
      'title': 'How to improve my credit score?',
      'author': 'John Doe',
      'content': 'I need tips on improving my credit score. Any advice?',
      'comments': <Map<String, Object>>[
        <String, Object>{
          'author': 'Jane',
          'content': 'Try paying bills on time.',
          'replies': <Map<String, String>>[
            <String, String>{'author': 'Mark', 'content': 'That’s a great tip!'},
          ],
        },
        <String, Object>{
          'author': 'Mark',
          'content': 'Keep your credit utilization low.',
          'replies': <dynamic>[],
        },
      ],
    },
    <String, dynamic>{
      'title': 'Best savings account options?',
      'author': 'Jane Smith',
      'content': 'What are the best savings accounts with high interest rates?',
      'comments': <dynamic>[],
    },
  ];

  final List<ForumPost> _dummyPosts = <ForumPost>[];

  ForumPostRepository() {
    _dummyPosts.addAll(_posts.map((Map<String, dynamic> e) => ForumPost.fromMap(e)));
  }

  List<ForumPost> getPosts() {
    return List<ForumPost>.from(_dummyPosts);
  }

  void addPost(ForumPost post) {
    _dummyPosts.add(post);
  }
}
