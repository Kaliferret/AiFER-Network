import 'package:flutter/material.dart';

class TodoStatisticsWidget extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const TodoStatisticsWidget({
    Key? key,
    required this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalTodos = statistics['total_todos'] ?? 0;
    final completedTodos = statistics['completed_todos'] ?? 0;
    final pendingTodos = statistics['pending_todos'] ?? 0;
    final overdueTodos = statistics['overdue_todos'] ?? 0;
    final completionRate = statistics['completion_rate'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Todo Statistics',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 24),

        // Progress circle
        Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: totalTodos > 0 ? completedTodos / totalTodos : 0,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completionRate >= 80
                        ? Colors.green
                        : completionRate >= 50
                            ? Colors.orange
                            : Colors.blue,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${completionRate.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Complete',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Statistics cards
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              title: 'Total Todos',
              value: totalTodos.toString(),
              icon: Icons.list_alt,
              color: Colors.blue,
            ),
            _buildStatCard(
              title: 'Completed',
              value: completedTodos.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            _buildStatCard(
              title: 'Pending',
              value: pendingTodos.toString(),
              icon: Icons.pending_actions,
              color: Colors.orange,
            ),
            _buildStatCard(
              title: 'Overdue',
              value: overdueTodos.toString(),
              icon: Icons.warning,
              color: Colors.red,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Insights
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Insights',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._generateInsights(
                  totalTodos, completedTodos, overdueTodos, completionRate),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _generateInsights(
      int total, int completed, int overdue, double completionRate) {
    List<Widget> insights = [];

    if (total == 0) {
      insights.add(const Text('• Start by adding your first todo!'));
    } else if (completionRate == 100) {
      insights
          .add(const Text('• 🎉 Amazing! You\'ve completed all your todos!'));
      insights.add(const Text('• Keep up the great work!'));
    } else {
      if (completionRate >= 80) {
        insights
            .add(const Text('• 🌟 Excellent progress! You\'re almost done!'));
      } else if (completionRate >= 50) {
        insights.add(const Text('• 💪 Good progress! Keep going!'));
      } else if (completionRate >= 25) {
        insights.add(const Text('• 📈 You\'re making progress, stay focused!'));
      } else {
        insights.add(const Text('• 🚀 Time to tackle those todos!'));
      }

      if (overdue > 0) {
        insights.add(Text(
            '• ⚠️ You have $overdue overdue task${overdue > 1 ? 's' : ''} that need attention.'));
      } else {
        insights.add(const Text('• ✅ Great! No overdue tasks.'));
      }

      if (completionRate < 50 && total > 5) {
        insights.add(const Text(
            '• 💡 Try breaking large tasks into smaller, manageable ones.'));
      }
    }

    return insights
        .map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: insight,
            ))
        .toList();
  }
}
