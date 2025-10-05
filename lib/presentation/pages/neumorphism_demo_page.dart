import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/neumorphism_standards.dart';
import '../../presentation/widgets/neumorphism/neumorphism_container.dart';

/// Neumorphism Demo Page
/// Yeni tasarım dilimizi görmek için demo sayfa
class NeumorphismDemoPage extends StatefulWidget {
  const NeumorphismDemoPage({Key? key}) : super(key: key);

  @override
  State<NeumorphismDemoPage> createState() => _NeumorphismDemoPageState();
}

class _NeumorphismDemoPageState extends State<NeumorphismDemoPage> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Neumorphism Demo'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Text(
              'Barter Qween Neumorphism Tasarım',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Doğal yeşil tonları ile modern neumorphism efektleri',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Neumorphism Container Örnekleri
            _buildSectionTitle('Neumorphism Container'),
            const SizedBox(height: 16),
            
            // Outset Container
            NeumorphismContainer(
              type: NeumorphismType.outset,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Outset Container',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dışbükey neumorphism efekti. Eleman yüzeyden çıkıntı yapıyor gibi görünür.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Inset Container
            NeumorphismContainer(
              type: NeumorphismType.inset,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inset Container',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İçbükey neumorphism efekti. Eleman yüzeye gömülü gibi görünür.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Flat Container
            NeumorphismContainer(
              type: NeumorphismType.flat,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flat Container',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Düz neumorphism efekti. Gölge yok, sadece arka plan rengi.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Neumorphism Button Örnekleri
            _buildSectionTitle('Neumorphism Buttons'),
            const SizedBox(height: 16),
            
            // Outset Button
            NeumorphismButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Outset button pressed!')),
                );
              },
              type: NeumorphismType.outset,
              child: const Text(
                'Outset Button',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Inset Button
            NeumorphismButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inset button pressed!')),
                );
              },
              type: NeumorphismType.inset,
              child: const Text(
                'Inset Button',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Flat Button
            NeumorphismButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Flat button pressed!')),
                );
              },
              type: NeumorphismType.flat,
              child: const Text(
                'Flat Button',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Neumorphism Card Örnekleri
            _buildSectionTitle('Neumorphism Cards'),
            const SizedBox(height: 16),
            
            // Outset Card
            NeumorphismCard(
              type: NeumorphismType.outset,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Premium Item',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'High quality product',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bu bir neumorphism card örneğidir. Outset efekti ile eleman yüzeyden çıkıntı yapıyor gibi görünür.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Inset Card
            NeumorphismCard(
              type: NeumorphismType.inset,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Favorite Item',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Liked by you',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bu bir inset neumorphism card örneğidir. Eleman yüzeye gömülü gibi görünür.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Neumorphism TextField Örnekleri
            _buildSectionTitle('Neumorphism Text Fields'),
            const SizedBox(height: 16),
            
            // Outset TextField
            NeumorphismTextField(
              labelText: 'Outset Text Field',
              hintText: 'Bu bir outset text field',
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 16),

            // Inset TextField
            NeumorphismTextField(
              labelText: 'Inset Text Field',
              hintText: 'Bu bir inset text field',
              prefixIcon: Icons.person,
              isPressed: true,
            ),
            const SizedBox(height: 32),

            // Renk Paleti
            _buildSectionTitle('Neumorphism Renk Paleti'),
            const SizedBox(height: 16),
            
            _buildColorPalette(),
            const SizedBox(height: 32),

            // Shadow Örnekleri
            _buildSectionTitle('Neumorphism Shadow Örnekleri'),
            const SizedBox(height: 16),
            
            _buildShadowExamples(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildColorPalette() {
    final colors = [
      {'name': 'Primary', 'color': AppColors.primary},
      {'name': 'Primary Light', 'color': AppColors.primaryLight},
      {'name': 'Primary Dark', 'color': AppColors.primaryDark},
      {'name': 'Secondary', 'color': AppColors.secondary},
      {'name': 'Secondary Light', 'color': AppColors.secondaryLight},
      {'name': 'Secondary Dark', 'color': AppColors.secondaryDark},
      {'name': 'Accent', 'color': AppColors.accent},
      {'name': 'Accent Light', 'color': AppColors.accentLight},
      {'name': 'Accent Dark', 'color': AppColors.accentDark},
      {'name': 'Background', 'color': AppColors.background},
      {'name': 'Surface', 'color': AppColors.surface},
      {'name': 'Surface Variant', 'color': AppColors.surfaceVariant},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final colorData = colors[index];
        return NeumorphismContainer(
          type: NeumorphismType.outset,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorData['color'] as Color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                colorData['name'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShadowExamples() {
    return Column(
      children: [
        // Outset Shadow
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.neumorphismOutsetShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Outset Shadow',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dışbükey neumorphism gölge efekti',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Inset Shadow
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.neumorphismInsetShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inset Shadow',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'İçbükey neumorphism gölge efekti',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
