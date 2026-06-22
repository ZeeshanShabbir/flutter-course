// ============================================================
// P11 — AI Dev Tools
// File: lib/main.dart
//
// Slide reference: "AI Tools Every Developer Should Know"
// Key quotes:
//   "An honest look at what AI tools are actually good at."
//   "How to evaluate AI output critically instead of copying it."
//   "Writing better prompts to get useful code suggestions."
//
// This part is mainly CONCEPTS + PROMPTS, not code.
// The app shows a reference guide for AI tools.
// See: lib/prompt_library.dart for reusable prompt templates.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P11 — AI Dev Tools',
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
      home: const AiToolsScreen(),
    );
  }
}

// ============================================================
// PROMPT LIBRARY — reusable prompts from the slides
// Save these and customise for your projects.
// ============================================================
class PromptLibrary {
  static const List<Map<String, dynamic>> prompts = [
    {
      'category': 'Code Generation',
      'icon': '⚡',
      'title': 'Generate Riverpod Provider',
      'prompt': '''Create a Riverpod AsyncNotifier for managing a list of [ModelName] objects.

Requirements:
- Use flutter_riverpod ^2.5 with AsyncNotifier pattern
- Include: load(), create(), update(), delete() methods
- Add optimistic updates with rollback on error
- Repository pattern: pass a [RepositoryInterface] in the constructor
- All methods handle DioException and return user-friendly error messages

Model fields: [list your fields here]''',
    },
    {
      'category': 'Debugging',
      'icon': '🐛',
      'title': 'Debug Error Message',
      'prompt': '''I\'m getting this error in my Flutter app:

[Paste the full error message and stack trace here]

Context:
- Flutter version: [version]
- Package versions: [relevant packages]
- What I was doing: [describe the action]
- What I expected: [expected behavior]

Please:
1. Explain what this error means
2. Identify the root cause
3. Provide a fix with explanation
4. Suggest how to prevent it in the future''',
    },
    {
      'category': 'Test Generation',
      'icon': '🧪',
      'title': 'Generate Widget Tests',
      'prompt': '''Write comprehensive Flutter widget tests for this widget:

```dart
[Paste your widget code here]
```

Cover these scenarios:
1. Renders correctly with default props
2. Displays correct content for each state (loading, data, error, empty)
3. User interactions (taps, form input, swipe)
4. Accessibility (contrast, tap target size)
5. Edge cases (null values, empty strings, long text overflow)

Use flutter_test package. Add comments explaining each test.''',
    },
    {
      'category': 'Code Review',
      'icon': '👁️',
      'title': 'Review My Code',
      'prompt': '''Review this Flutter/Dart code for a production app:

```dart
[Paste your code here]
```

Please check for:
1. Performance issues (unnecessary rebuilds, missing const, etc.)
2. Memory leaks (undisposed controllers, unclosed streams)
3. Error handling gaps
4. Security concerns (hardcoded values, exposed secrets)
5. Dart/Flutter best practices violations
6. Code that could be simplified
7. Missing null safety checks

Format your response as a numbered list of issues with severity (Critical/Warning/Info).''',
    },
    {
      'category': 'Refactoring',
      'icon': '🔄',
      'title': 'Refactor to Feature-First',
      'prompt': '''Refactor this Flutter code from layer-first to feature-first structure.

Current structure (layer-first):
[Paste your current folder structure]

Current code:
```dart
[Paste relevant code]
```

Rules:
- One folder per feature under lib/features/
- Each feature has: screens/, providers/, models/, repositories/
- Shared code goes in lib/shared/widgets/ and lib/shared/utils/
- Core infrastructure in lib/core/
- Keep all imports valid after refactoring
- Add brief comments explaining the structure''',
    },
    {
      'category': 'Cursor IDE',
      'icon': '🖥️',
      'title': 'Cursor Codebase Context',
      'prompt': '''You are helping me build a Flutter app.

Context about my codebase:
- Architecture: Feature-first with Riverpod
- Router: GoRouter
- State: AsyncNotifier + FutureProvider
- HTTP: Dio with interceptors
- Local storage: Hive
- Backend: Firebase (Auth + Firestore)

My coding style:
- Immutable models with copyWith()
- Repository pattern separating data/domain/presentation
- Meaningful variable names, no abbreviations
- Comments explaining WHY, not WHAT
- Const constructors everywhere possible

Current task: [describe what you want to build]''',
    },
  ];
}

// ============================================================
// AI TOOLS SCREEN
// ============================================================
class AiToolsScreen extends StatelessWidget {
  const AiToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('P11 — AI Dev Tools'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Tools'),
              Tab(text: 'Prompts'),
              Tab(text: 'Workflow'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ToolsTab(),
            _PromptsTab(),
            _WorkflowTab(),
          ],
        ),
      ),
    );
  }
}

class _ToolsTab extends StatelessWidget {
  const _ToolsTab();

  static const tools = [
    {
      'name': 'ChatGPT (GPT-4o)',
      'use': 'Best for: architecture decisions, explaining concepts, debugging complex issues',
      'avoid': 'Avoid: blindly trusting generated code, skipping verification',
      'color': Color(0xFF6CB33E),
      'icon': '🤖',
    },
    {
      'name': 'Claude (Anthropic)',
      'use': 'Best for: long code analysis, writing documentation, explaining nuanced concepts',
      'avoid': 'Avoid: assuming it knows your specific package versions',
      'color': Color(0xFF0397D6),
      'icon': '🧠',
    },
    {
      'name': 'GitHub Copilot',
      'use': 'Best for: autocomplete in VS Code, boilerplate generation while typing',
      'avoid': 'Avoid: accepting suggestions without reading them',
      'color': Color(0xFF1D1D1F),
      'icon': '⭐',
    },
    {
      'name': 'Cursor IDE',
      'use': 'Best for: codebase-aware suggestions, multi-file edits, inline chat',
      'avoid': 'Avoid: relying on it for learning fundamentals',
      'color': Color(0xFF544DCF),
      'icon': '✏️',
    },
    {
      'name': 'Codeium (Free)',
      'use': 'Best for: free Copilot alternative, works in VS Code + JetBrains',
      'avoid': 'Avoid: expecting same quality as paid tools for complex tasks',
      'color': Color(0xFF897966),
      'icon': '🆓',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(tool['icon'] as String,
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Text(
                      tool['name'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: tool['color'] as Color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 16, color: Color(0xFF6CB33E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(tool['use'] as String,
                          style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_outlined,
                        size: 16, color: Color(0xFFDDB307)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(tool['avoid'] as String,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PromptsTab extends StatelessWidget {
  const _PromptsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: PromptLibrary.prompts.length,
      itemBuilder: (context, index) {
        final prompt = PromptLibrary.prompts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Text(prompt['icon'] as String,
                style: const TextStyle(fontSize: 20)),
            title: Text(
              prompt['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              prompt['category'] as String,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF0397D6)),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1D1F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        prompt['prompt'] as String,
                        style: const TextStyle(
                          color: Color(0xFFE5E5E5),
                          fontFamily: 'monospace',
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: prompt['prompt'] as String));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Prompt copied to clipboard!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Prompt'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorkflowTab extends StatelessWidget {
  const _WorkflowTab();

  static const _steps = [
    {
      'step': '1',
      'title': 'Start with the spec',
      'detail': 'Before asking AI to write code, write down exactly what you need in plain English. Vague prompts → vague code.',
      'color': Color(0xFF0397D6),
    },
    {
      'step': '2',
      'title': 'Give context',
      'detail': 'Tell the AI your stack: Flutter version, packages, architecture pattern. AI without context generates generic code that won\'t fit.',
      'color': Color(0xFF544DCF),
    },
    {
      'step': '3',
      'title': 'Ask for one thing at a time',
      'detail': '"Build me the entire app" → bad. "Write the TaskRepository with these 4 methods" → good. Smaller scope = better output.',
      'color': Color(0xFF6CB33E),
    },
    {
      'step': '4',
      'title': 'Read before you run',
      'detail': 'Never copy-paste AI code without reading it. You\'re responsible for understanding every line you commit.',
      'color': Color(0xFFDDB307),
    },
    {
      'step': '5',
      'title': 'Test AI output',
      'detail': 'AI makes subtle mistakes. Write tests for every function AI generates. Tests catch what reading misses.',
      'color': Color(0xFFD31145),
    },
    {
      'step': '6',
      'title': 'Iterate on prompts',
      'detail': 'Bad output → improve the prompt, don\'t just try again. A better prompt library is more valuable than any specific answer.',
      'color': Color(0xFF897966),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _steps.length,
      itemBuilder: (context, index) {
        final step = _steps[index];
        final color = step['color'] as Color;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      step['step'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['detail'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
