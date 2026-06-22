// ============================================================
// P12 — AI Features in Your App
// File: lib/main.dart
//
// Slide reference: "AI Features Inside Flutter Apps"
// Key quotes:
//   "Two types of AI in mobile: cloud APIs (OpenAI) and
//    on-device models (ML Kit). Know when to use each."
//   "Rate limiting, cost management, and user trust."
//
// CLOUD vs ON-DEVICE:
// ┌─────────────────┬──────────────────┬──────────────────┐
// │                 │ Cloud (OpenAI)   │ On-Device (MLKit)│
// ├─────────────────┼──────────────────┼──────────────────┤
// │ Cost            │ $/request        │ Free             │
// │ Privacy         │ Data leaves phone│ Stays on device  │
// │ Offline         │ Requires internet│ Works offline    │
// │ Quality         │ State-of-the-art │ Good for tasks   │
// │ Speed           │ 1-3s latency     │ <100ms           │
// └─────────────────┴──────────────────┴──────────────────┘
//
// SETUP (OpenAI):
// 1. Create account at platform.openai.com
// 2. Get API key (keep it in .env, NEVER commit to git)
// 3. Add key to: String.fromEnvironment('OPENAI_API_KEY')
//    or use flutter_dotenv package
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P12 — AI Features',
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
      home: const AiFeaturesHomeScreen(),
    );
  }
}

class AiFeaturesHomeScreen extends StatelessWidget {
  const AiFeaturesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('P12 — AI Features')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NavCard(
            icon: '💬',
            title: 'OpenAI Chatbot',
            subtitle: 'Streaming chat with GPT-4o-mini via REST API',
            color: const Color(0xFF6CB33E),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _NavCard(
            icon: '📷',
            title: 'ML Kit OCR',
            subtitle: 'On-device text extraction from images (offline, free)',
            color: const Color(0xFF0397D6),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MlKitOcrScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _NavCard(
            icon: '🌍',
            title: 'Language Detection',
            subtitle: 'Identify language of text on-device with ML Kit',
            color: const Color(0xFF544DCF),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const LanguageDetectionScreen()),
            ),
          ),
          const SizedBox(height: 24),
          const _SecurityNote(),
        ],
      ),
    );
  }
}

// ============================================================
// OPENAI CHATBOT — streaming responses
// ============================================================

// Chat message model
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

// Chat state using Riverpod
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([
    ChatMessage(
      content: 'Hello! I\'m an AI assistant for the D4WEE Flutter Course. '
          'Ask me anything about Flutter, Dart, or mobile development!',
      isUser: false,
    ),
  ]);

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.openai.com/v1',
    // ⚠️ NEVER hardcode API keys — use environment variables
    // Run with: flutter run --dart-define=OPENAI_API_KEY=sk-...
    headers: {
      'Authorization':
          'Bearer ${const String.fromEnvironment('OPENAI_API_KEY', defaultValue: 'YOUR_API_KEY_HERE')}',
      'Content-Type': 'application/json',
    },
  ));

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty || _isLoading) return;

    // Add user message immediately (optimistic)
    state = [...state, ChatMessage(content: userMessage, isUser: true)];
    _isLoading = true;

    // Add placeholder for AI response
    state = [...state, ChatMessage(content: '', isUser: false)];

    try {
      // ── STREAMING request ────────────────────────────────
      // stream: true → server sends chunks as SSE (Server-Sent Events)
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'gpt-4o-mini', // cheapest capable model
          'stream': true,
          'max_tokens': 500,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful Flutter development tutor for the D4WEE '
                  'programme by Code for Pakistan. Keep answers concise and '
                  'practical. Use code examples when helpful.',
            },
            // Include conversation history (last 10 messages for context)
            ...state
                .take(state.length - 1) // exclude the empty placeholder
                .map((m) => {
                      'role': m.isUser ? 'user' : 'assistant',
                      'content': m.content,
                    }),
          ],
        },
        options: Options(responseType: ResponseType.stream),
      );

      // Process streaming response
      String fullContent = '';
      await for (final chunk in (response.data as ResponseBody).stream) {
        final lines = utf8.decode(chunk).split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') break;
            try {
              final json = jsonDecode(data);
              final delta = json['choices'][0]['delta']['content'] as String?;
              if (delta != null) {
                fullContent += delta;
                // Update the last message (AI placeholder) with accumulated text
                state = [
                  ...state.take(state.length - 1),
                  ChatMessage(content: fullContent, isUser: false),
                ];
              }
            } catch (_) {
              // Skip malformed chunks
            }
          }
        }
      }
    } catch (e) {
      // Replace placeholder with error message
      state = [
        ...state.take(state.length - 1),
        ChatMessage(
          content: 'Sorry, I couldn\'t connect. '
              'Make sure OPENAI_API_KEY is set.\n\nError: $e',
          isUser: false,
        ),
      ];
    } finally {
      _isLoading = false;
    }
  }

  void clearChat() {
    state = [
      ChatMessage(
        content: 'Chat cleared. How can I help you with Flutter?',
        isUser: false,
      ),
    ];
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    ref.read(chatProvider.notifier).sendMessage(text);
    // Scroll to bottom after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final isLoading = ref.read(chatProvider.notifier).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chatbot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => ref.read(chatProvider.notifier).clearChat(),
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // API key warning
          if (const String.fromEnvironment('OPENAI_API_KEY',
                  defaultValue: 'YOUR_API_KEY_HERE') ==
              'YOUR_API_KEY_HERE')
            Container(
              padding: const EdgeInsets.all(10),
              color: const Color(0xFFDDB307).withOpacity(0.15),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Color(0xFFDDB307), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Run with: flutter run --dart-define=OPENAI_API_KEY=sk-...',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _ChatBubble(message: msg);
              },
            ),
          ),

          // Loading indicator
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('AI is thinking...',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),

          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Ask about Flutter...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F7),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF0397D6),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFF0397D6)
              : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : null,
            bottomLeft: !message.isUser ? const Radius.circular(4) : null,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: message.content.isEmpty
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                message.content,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
      ),
    );
  }
}

// ============================================================
// ML KIT OCR SCREEN — on-device text recognition
// ============================================================
class MlKitOcrScreen extends StatefulWidget {
  const MlKitOcrScreen({super.key});

  @override
  State<MlKitOcrScreen> createState() => _MlKitOcrScreenState();
}

class _MlKitOcrScreenState extends State<MlKitOcrScreen> {
  File? _image;
  String _extractedText = '';
  bool _isProcessing = false;

  Future<void> _pickAndExtract(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: source);
    if (file == null) return;

    setState(() {
      _image = File(file.path);
      _isProcessing = true;
      _extractedText = '';
    });

    try {
      // ── ML Kit Text Recognition ──────────────────────────
      // In production: import and use the actual ML Kit package.
      // Since we can't install packages here, we simulate the result.
      //
      // ACTUAL CODE (after flutter pub get):
      // import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
      //
      // final textRecognizer = TextRecognizer(
      //   script: TextRecognitionScript.latin,
      // );
      // final InputImage inputImage = InputImage.fromFile(_image!);
      // final RecognizedText recognizedText =
      //     await textRecognizer.processImage(inputImage);
      // textRecognizer.close();
      //
      // setState(() {
      //   _extractedText = recognizedText.text;
      // });

      // Simulated delay for demo:
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _extractedText = '🔴 ML Kit not initialised in this demo.\n\n'
            'To enable:\n'
            '1. flutter pub add google_mlkit_text_recognition\n'
            '2. Uncomment the ML Kit code in this file\n'
            '3. flutter pub get && flutter run\n\n'
            'ML Kit runs entirely ON-DEVICE:\n'
            '✓ No internet required\n'
            '✓ No API key needed\n'
            '✓ No cost per request\n'
            '✓ Fast: ~50-100ms per image\n'
            '✓ Privacy: image never leaves the device';
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ML Kit — Text Recognition')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0397D6).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '📷 Take a photo of any printed text — a book page, '
                'receipt, billboard, or whiteboard — and ML Kit extracts '
                'the text entirely on-device. No internet, no cost.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ),

            const SizedBox(height: 16),

            // Image preview
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _image!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 12),

            // Pick image buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickAndExtract(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickAndExtract(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0397D6),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Result
            if (_isProcessing)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Extracting text on-device...'),
                  ],
                ),
              )
            else if (_extractedText.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Extracted Text:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: SelectableText(
                      _extractedText,
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LANGUAGE DETECTION SCREEN
// ============================================================
class LanguageDetectionScreen extends StatefulWidget {
  const LanguageDetectionScreen({super.key});

  @override
  State<LanguageDetectionScreen> createState() =>
      _LanguageDetectionScreenState();
}

class _LanguageDetectionScreenState extends State<LanguageDetectionScreen> {
  final _ctrl = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  static const _samples = {
    'Urdu': 'میں فلٹر سیکھ رہا ہوں',
    'English': 'I am learning Flutter',
    'Arabic': 'أنا أتعلم Flutter',
    'French': 'J\'apprends Flutter',
    'German': 'Ich lerne Flutter',
  };

  Future<void> _detect() async {
    if (_ctrl.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
      _result = '🔴 ML Kit not initialised in demo.\n\n'
          'ACTUAL CODE:\n'
          'final languageIdentifier = LanguageIdentifier(\n'
          '  confidenceThreshold: 0.5,\n'
          ');\n'
          'final language = await languageIdentifier\n'
          '  .identifyLanguage(text);\n'
          'languageIdentifier.close();\n\n'
          '// Returns BCP-47 codes: "en", "ur", "ar", etc.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language Detection')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Type or paste text to detect its language (on-device):',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // Sample texts
          const Text('Quick samples:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _samples.entries
                .map((e) => ActionChip(
                      label: Text(e.key, style: const TextStyle(fontSize: 12)),
                      onPressed: () => _ctrl.text = e.value,
                    ))
                .toList(),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _ctrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Enter text to analyse',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: _isLoading ? null : _detect,
            icon: const Icon(Icons.language),
            label: const Text('Detect Language'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF544DCF),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),

          if (_result.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D1F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _result,
                style: const TextStyle(
                  color: Color(0xFFE5E5E5),
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Shared nav card widget ────────────────────────────────────
class _NavCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD31145).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFFD31145).withOpacity(0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Color(0xFFD31145), size: 18),
              SizedBox(width: 8),
              Text(
                'API Key Security Rules',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD31145)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '❌ NEVER put API keys in source code\n'
            '❌ NEVER commit .env files to git\n'
            '✅ Use --dart-define for local dev\n'
            '✅ Use CI/CD secrets for production builds\n'
            '✅ Use a backend proxy to keep keys server-side\n'
            '✅ Add rate limiting to prevent cost overruns',
            style: TextStyle(fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}
