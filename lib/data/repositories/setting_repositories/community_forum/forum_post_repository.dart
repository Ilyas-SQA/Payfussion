import 'forum_post_class.dart';

class ForumPostRepository {
  final List<Map<String, dynamic>> _posts = [
    {
      'title': 'How to improve my credit score?',
      'author': 'John Doe',
      'content': 'I need tips on improving my credit score. Any advice?',
      'comments': [
        {
          'author': 'Jane',
          'content': 'Try paying bills on time.',
          'replies': [
            {'author': 'Mark', 'content': 'That’s a great tip!'},
          ],
        },
        {
          'author': 'Mark',
          'content': 'Keep your credit utilization low.',
          'replies': [],
        },
      ],
    },
    {
      'title': 'Best savings account options?',
      'author': 'Jane Smith',
      'content': 'What are the best savings accounts with high interest rates?',
      'comments': [],
    },
  ];

  final List<ForumPost> _dummyPosts = [];

  ForumPostRepository() {
    _dummyPosts.addAll(_posts.map((e) => ForumPost.fromMap(e)));
  }

  List<ForumPost> getPosts() {
    return List<ForumPost>.from(_dummyPosts);
  }

  void addPost(ForumPost post) {
    _dummyPosts.add(post);
  }
}
