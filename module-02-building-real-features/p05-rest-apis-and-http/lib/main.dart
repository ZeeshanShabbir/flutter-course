// ============================================================
// P05 — REST APIs & HTTP Networking
// File: lib/main.dart
//
// Demonstrates the complete HTTP stack:
// - Dio with interceptors
// - JSON parsing (manual + json_serializable)
// - Freezed immutable models
// - Loading / success / error / empty states
// - Connectivity awareness
// - Retry logic
//
// API used: https://jsonplaceholder.typicode.com (free, no auth)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// ============================================================
// DIO SETUP — configure once, use everywhere
// ============================================================

// The configured Dio instance — shared across the app
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // ── Auth Interceptor ──────────────────────────────────────
  // Adds Bearer token to every request automatically.
  // Replace the comment with your actual token logic in P06+.
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // options.headers['Authorization'] = 'Bearer $token';
      debugPrint('→ ${options.method} ${options.path}');
      handler.next(options);
    },
    onResponse: (response, handler) {
      debugPrint('← ${response.statusCode} ${response.requestOptions.path}');
      handler.next(response);
    },
    onError: (DioException error, handler) {
      debugPrint('✗ ${error.type}: ${error.message}');
      handler.next(error);
    },
  ));

  return dio;
});

// ============================================================
// MODEL — Post (from JSONPlaceholder API)
//
// In production: use @freezed + @JsonSerializable annotations
// and run: dart run build_runner build
//
// Hand-written version shown here so students see what Freezed generates.
// ============================================================
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int,
        userId: json['userId'] as int,
        title: json['title'] as String,
        body: json['body'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
      };

  Post copyWith({String? title, String? body}) => Post(
        id: id,
        userId: userId,
        title: title ?? this.title,
        body: body ?? this.body,
      );

  @override
  String toString() => 'Post(id: $id, title: $title)';
}

// ============================================================
// API SERVICE — raw HTTP calls
// ============================================================
class PostsApi {
  final Dio _dio;
  PostsApi(this._dio);

  Future<List<Post>> getPosts({int limit = 20}) async {
    final response = await _dio.get(
      '/posts',
      queryParameters: {'_limit': limit},
    );
    final List data = response.data;
    return data.map((json) => Post.fromJson(json)).toList();
  }

  Future<Post> getPost(int id) async {
    final response = await _dio.get('/posts/$id');
    return Post.fromJson(response.data);
  }

  Future<Post> createPost(String title, String body) async {
    final response = await _dio.post('/posts', data: {
      'title': title,
      'body': body,
      'userId': 1,
    });
    return Post.fromJson(response.data);
  }

  Future<Post> updatePost(Post post) async {
    final response = await _dio.put('/posts/${post.id}', data: post.toJson());
    return Post.fromJson(response.data);
  }

  Future<void> deletePost(int id) async {
    await _dio.delete('/posts/$id');
  }
}

final postsApiProvider = Provider<PostsApi>((ref) {
  return PostsApi(ref.watch(dioProvider));
});

// ============================================================
// PROVIDERS — state layer
// ============================================================
final postsProvider = FutureProvider<List<Post>>((ref) async {
  // Check connectivity before making the request
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    throw Exception('No internet connection');
  }
  return ref.watch(postsApiProvider).getPosts();
});

// Connectivity stream — reactive UI banner
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

// ============================================================
// APP
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P05 — REST APIs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0397D6)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0397D6),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const PostsScreen(),
    );
  }
}

// ============================================================
// POSTS SCREEN — shows all 4 async states
// ============================================================
class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  // Track optimistic updates for create/delete
  final List<Post> _localPosts = [];
  bool _showLocalOnly = false;

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsProvider);
    final connectivity = ref.watch(connectivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(postsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── OFFLINE BANNER ─────────────────────────────────
          // Pattern: treat "no internet" as a normal app state
          connectivity.whenData((result) {
            if (result == ConnectivityResult.none) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 16),
                color: Colors.red[700],
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('No internet — showing cached data',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }).value ?? const SizedBox.shrink(),

          // ── MAIN CONTENT — all 4 states ──────────────────
          Expanded(
            child: postsAsync.when(
              // ① LOADING
              loading: () => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Fetching posts from API...'),
                  ],
                ),
              ),

              // ② ERROR — with retry
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => ref.invalidate(postsProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),

              // ③ DATA (or ④ EMPTY inside)
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No posts found'),
                        Text('Pull to refresh or check your connection',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(postsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                const Color(0xFF0397D6).withOpacity(0.1),
                            child: Text(
                              '${post.id}',
                              style: const TextStyle(
                                color: Color(0xFF0397D6),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            post.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            post.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () => _showPostDetail(context, post),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
      ),
    );
  }

  void _showPostDetail(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Post #${post.id}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              post.title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(post.body, style: const TextStyle(height: 1.6)),
            const SizedBox(height: 24),
            // PATCH request demo
            OutlinedButton.icon(
              onPressed: () async {
                try {
                  final api = ref.read(postsApiProvider);
                  await api.updatePost(post.copyWith(title: '✓ ${post.title}'));
                  if (ctx.mounted) Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PUT /posts/${post.id} — 200 OK'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('PUT (update) this post'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                try {
                  final api = ref.read(postsApiProvider);
                  await api.deletePost(post.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('DELETE /posts/${post.id} — 200 OK'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('DELETE this post'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('POST /posts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              decoration: const InputDecoration(labelText: 'Body'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final api = ref.read(postsApiProvider);
                final created = await api.createPost(
                  titleCtrl.text,
                  bodyCtrl.text,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Created: ${created.title} (id: ${created.id})'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('POST'),
          ),
        ],
      ),
    );
  }
}
