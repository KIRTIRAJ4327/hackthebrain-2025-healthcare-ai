import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../core/providers/auth_provider.dart';

/// Modern Healthcare AI Home Screen with Dynamic Health Status
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _healthAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _healthPulseAnimation;
  late Animation<Offset> _cardSlideAnimation;

  // Dynamic health status state
  String _healthStatus = 'All Good! 💚';
  String _lastCheckup = '2 weeks ago';
  String _nextAppointment = 'Schedule one';
  Color _healthColor = const Color(0xFF10B981);
  String _healthMessage = 'Your health metrics are looking great!';

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _healthAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _healthPulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _healthAnimationController,
      curve: Curves.easeInOut,
    ));

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _healthAnimationController.repeat(reverse: true);
    _cardAnimationController.forward();

    // Simulate dynamic health data update
    _updateHealthStatus();
  }

  @override
  void dispose() {
    _healthAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _updateHealthStatus() {
    // Simulate real health data - in real app this would come from APIs
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          final hour = DateTime.now().hour;
          if (hour < 12) {
            _healthMessage = 'Good morning! Your vitals are stable.';
          } else if (hour < 17) {
            _healthMessage = 'Afternoon check - everything looks normal.';
          } else {
            _healthMessage = 'Evening status - you\'re doing well!';
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final userName = authState is AuthAuthenticated
        ? authState.user.email?.split('@')[0] ?? 'User'
        : 'User';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with user greeting - FIXED LAYOUT
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF2563EB),
            leading: Container(), // Remove back button for home
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(height: 20), // Space from top
                        Text(
                          'Good ${_getTimeOfDay()}, $userName',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'How can we help you today?',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Lottie.network(
                                'https://assets5.lottiefiles.com/packages/lf20_5njp3vgg.json',
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.health_and_safety,
                                    color: Colors.white,
                                    size: 20,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  onPressed: () => _showNotifications(context),
                ),
              ),
            ],
          ),

          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health Status Card with better spacing
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: _buildHealthStatusCard(),
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions Section
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionsGrid(context),

                  const SizedBox(height: 32),

                  // Recent Activity & Insights
                  const Text(
                    'Your Health Insights',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHealthInsights(),

                  const SizedBox(height: 32),

                  // System Performance (compact)
                  _buildSystemStatus(),

                  const SizedBox(height: 32),

                  // Competition Info (redesigned)
                  _buildCompetitionCard(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildHealthStatusCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([_healthPulseAnimation, _cardSlideAnimation]),
      builder: (context, child) {
        return SlideTransition(
          position: _cardSlideAnimation,
          child: Transform.scale(
            scale: _healthPulseAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_healthColor, _healthColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _healthColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Lottie.network(
                      'https://assets2.lottiefiles.com/packages/lf20_l5qvxwtf.json',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      repeat: true,
                      animate: true,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 28,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Health Status: $_healthStatus',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _healthMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last check-up: $_lastCheckup',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Next appointment: $_nextAppointment',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Health status indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.psychology_outlined,
        title: 'AI Triage',
        subtitle: 'Get instant health assessment',
        color: const Color(0xFF8B5CF6),
        route: '/triage',
        badge: 'AI',
        lottieUrl:
            'https://assets9.lottiefiles.com/packages/lf20_khstwcmk.json',
      ),
      _QuickAction(
        icon: Icons.calendar_today_outlined,
        title: 'Book Appointment',
        subtitle: 'Find available slots',
        color: const Color(0xFF06B6D4),
        route: '/appointments',
        lottieUrl:
            'https://assets4.lottiefiles.com/packages/lf20_jsgkqej5.json',
      ),
      _QuickAction(
        icon: Icons.local_hospital_outlined,
        title: 'Find Specialists',
        subtitle: 'Locate nearby providers',
        color: const Color(0xFFF59E0B),
        route: '/providers',
        lottieUrl:
            'https://assets9.lottiefiles.com/packages/lf20_jsgpwnul.json',
      ),
      _QuickAction(
        icon: Icons.emergency_outlined,
        title: 'Emergency',
        subtitle: 'Immediate assistance',
        color: const Color(0xFFEF4444),
        route: '/emergency',
        urgent: true,
        lottieUrl:
            'https://assets10.lottiefiles.com/packages/lf20_kmlg0kbw.json',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildModernActionCard(context, action);
      },
    );
  }

  Widget _buildModernActionCard(BuildContext context, _QuickAction action) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            action.urgent ? Border.all(color: action.color, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(action.route),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: action.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Lottie.network(
                        action.lottieUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        repeat: true,
                        animate: true,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            action.icon,
                            size: 28,
                            color: action.color,
                          );
                        },
                      ),
                    ),
                    if (action.badge != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: action.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            action.badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (action.urgent)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: action.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  action.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  action.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthInsights() {
    return Column(
      children: [
        _buildInsightCard(
          icon: Icons.trending_down,
          title: 'Wait Time Improvement',
          value: '40% faster',
          subtitle: 'Average wait time reduced by our AI optimization',
          color: const Color(0xFF10B981),
          iconBg: const Color(0xFFD1FAE5),
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          icon: Icons.location_on_outlined,
          title: 'Nearest Clinic',
          value: '2.3 km away',
          subtitle: 'Toronto General Hospital - 15 min wait',
          color: const Color(0xFF3B82F6),
          iconBg: const Color(0xFFDBEAFE),
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          icon: Icons.schedule,
          title: 'Best Time to Visit',
          value: 'Tomorrow 2 PM',
          subtitle: 'Predicted lowest wait time for your area',
          color: const Color(0xFF8B5CF6),
          iconBg: const Color(0xFFEDE9FE),
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_done, color: Colors.green[600], size: 20),
              const SizedBox(width: 8),
              const Text(
                'System Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'All Systems Operational',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatusIndicator('AI Engine', true),
              const SizedBox(width: 16),
              _buildStatusIndicator('Database', true),
              const SizedBox(width: 16),
              _buildStatusIndicator('Real-time', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, bool isOnline) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildCompetitionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Lottie.network(
              'https://assets1.lottiefiles.com/packages/lf20_jygwp8se.json', // Rocket launch animation
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              repeat: true,
              animate: true,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  '🚀',
                  style: TextStyle(fontSize: 24),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HackTheBrain 2025',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Healthcare AI Solution - Live Demo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications, color: Color(0xFF3B82F6)),
            SizedBox(width: 8),
            Text('Notifications'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.schedule, color: Color(0xFF10B981)),
              title: Text('Appointment Reminder'),
              subtitle: Text('Your next check-up is in 2 weeks'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: Icon(Icons.local_hospital, color: Color(0xFF3B82F6)),
              title: Text('New Clinic Available'),
              subtitle: Text('Toronto West Clinic now accepting patients'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;
  final String? badge;
  final bool urgent;
  final String lottieUrl;

  _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
    this.badge,
    this.urgent = false,
    required this.lottieUrl,
  });
}
