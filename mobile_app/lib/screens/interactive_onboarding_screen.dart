import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/app_provider.dart';
import '../models/types.dart';

class InteractiveOnboardingScreen extends StatefulWidget {
  const InteractiveOnboardingScreen({super.key});

  @override
  State<InteractiveOnboardingScreen> createState() => _InteractiveOnboardingScreenState();
}

class _InteractiveOnboardingScreenState extends State<InteractiveOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Selections
  String? _nativeLanguage;
  String? _targetLanguage;
  String? _goal;
  String? _level;
  String? _time;

  final TextEditingController _otherGoalController = TextEditingController();

  final List<String> _nativeLanguages = [
    'O\'zbek tili',
    'Русский',
    'Қазақ тілі',
    'English',
    'Türkçe'
  ];

  final List<String> _targetLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Korean',
    'Russian',
    'Italian',
    'Arabic',
    'Other'
  ];

  final List<String> _goals = [
    'Travel & Tourism',
    'Business & Career',
    'Exams (IELTS, TOEFL)',
    'Study Abroad',
    'General Communication',
    'Other'
  ];

  final List<String> _levels = [
    'Beginner (A1-A2)',
    'Intermediate (B1-B2)',
    'Advanced (C1-C2)'
  ];

  final List<String> _times = [
    '15 minutes/day',
    '30 minutes/day',
    '1 hour/day',
    'More than 1 hour'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _otherGoalController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final provider = context.read<AppProvider>();
    final actualGoal = _goal == 'Other' ? _otherGoalController.text : _goal!;

    await provider.setLanguages(LanguagePair(
      native: _nativeLanguage!,
      target: _targetLanguage!,
    ));

    await provider.completeOnboardingSetup(actualGoal, _level!, _time!);
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _nativeLanguage != null;
      case 1:
        return _targetLanguage != null;
      case 2:
        if (_goal == 'Other') return _otherGoalController.text.trim().isNotEmpty;
        return _goal != null;
      case 3:
        return _level != null;
      case 4:
        return _time != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    )
                  else
                    const SizedBox(width: 48), // Spacer for alignment
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / 5,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildSelectionPage(
                    title: 'What is your native language?',
                    subtitle: 'Instruction language will be exactly this.',
                    items: _nativeLanguages,
                    selectedValue: _nativeLanguage,
                    onSelected: (val) {
                      setState(() => _nativeLanguage = val);
                      if (_canProceed()) _nextPage(); // Auto advance if language changes are simple list selections
                    },
                  ),
                  _buildSelectionPage(
                    title: 'What language do you want to learn?',
                    subtitle: 'AI Tutor will teach you this language.',
                    items: _targetLanguages,
                    selectedValue: _targetLanguage,
                    onSelected: (val) {
                      setState(() => _targetLanguage = val);
                      if (_canProceed()) _nextPage();
                    },
                    iconMap: {
                      'English': '🇺🇸/🇬🇧',
                      'Spanish': '🇪🇸',
                      'French': '🇫🇷',
                      'German': '🇩🇪',
                      'Chinese': '🇨🇳',
                      'Japanese': '🇯🇵',
                      'Korean': '🇰🇷',
                      'Russian': '🇷🇺',
                      'Italian': '🇮🇹',
                      'Arabic': '🇸🇦',
                    },
                  ),
                  _buildSelectionPage(
                    title: 'What is your main goal?',
                    subtitle: 'We will personalize lessons based on this.',
                    items: _goals,
                    selectedValue: _goal,
                    onSelected: (val) => setState(() => _goal = val),
                    extraContent: _goal == 'Other'
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextField(
                              controller: _otherGoalController,
                              decoration: InputDecoration(
                                hintText: 'Type your specific goal...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          )
                        : null,
                  ),
                  _buildSelectionPage(
                    title: 'What is your current level?',
                    subtitle: 'This helps us adjust the difficulty.',
                    items: _levels,
                    selectedValue: _level,
                    onSelected: (val) {
                      setState(() => _level = val);
                      if (_canProceed()) _nextPage();
                    },
                  ),
                  _buildSelectionPage(
                    title: 'How much time will you spend daily?',
                    subtitle: 'Consistency is key to success.',
                    items: _times,
                    selectedValue: _time,
                    onSelected: (val) => setState(() => _time = val),
                  ),
                ],
              ),
            ),

            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _canProceed() ? _nextPage : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  backgroundColor: _canProceed() ? theme.colorScheme.primary : Colors.grey.shade300,
                  foregroundColor: _canProceed() ? Colors.white : Colors.grey.shade500,
                ),
                child: Text(
                  _currentPage == 4 ? 'Generate Lesson Plan' : 'Continue',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionPage({
    required String title,
    required String subtitle,
    required List<String> items,
    required String? selectedValue,
    required Function(String) onSelected,
    Map<String, String>? iconMap,
    Widget? extraContent,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          FadeInDown(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Column(
              children: items.map((item) {
                final isSelected = selectedValue == item;
                final theme = Theme.of(context);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => onSelected(item),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? theme.colorScheme.primary : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected ? [] : [
                          BoxShadow(
                            color: Colors.grey.shade100,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          if (iconMap != null && iconMap.containsKey(item)) ...[
                            Text(iconMap[item]!, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? theme.colorScheme.primary : Colors.black87,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                          else
                            Icon(Icons.circle_outlined, color: Colors.grey.shade300),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (extraContent != null) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: extraContent,
            ),
          ],
          const SizedBox(height: 100), // padding for bottom button
        ],
      ),
    );
  }
}
