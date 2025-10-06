import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/neuromorphic_effects.dart';
import '../widgets/neumorphism/neuromorphic_icon.dart';
import '../widgets/neumorphism/neumorphism_container.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

/// Animation Showcase Page
/// Demonstrates all neuromorphic animations and effects

class AnimationShowcasePage extends StatefulWidget {
  const AnimationShowcasePage({super.key});

  @override
  State<AnimationShowcasePage> createState() => _AnimationShowcasePageState();
}

class _AnimationShowcasePageState extends State<AnimationShowcasePage>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _pulsingController;
  late AnimationController _shimmerController;
  late AnimationController _waveController;
  
  final ScrollController _scrollController = ScrollController();
  bool _showParallax = true;

  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulsingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulsingController.dispose();
    _shimmerController.dispose();
    _waveController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Animation Showcase'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('Shadow Animations'),
          const SizedBox(height: 20),
          
          _buildBreathingAnimation(),
          const SizedBox(height: 30),
          
          _buildPulsingAnimation(),
          const SizedBox(height: 30),
          
          _buildShimmerAnimation(),
          const SizedBox(height: 30),
          
          _buildWaveAnimation(),
          const SizedBox(height: 40),
          
          _buildSectionTitle('Interactive Animations'),
          const SizedBox(height: 20),
          
          _buildHoverAnimation(),
          const SizedBox(height: 30),
          
          _buildPressAnimation(),
          const SizedBox(height: 30),
          
          _buildMorphingAnimation(),
          const SizedBox(height: 40),
          
          _buildSectionTitle('Lighting Effects'),
          const SizedBox(height: 20),
          
          _buildAmbientGlow(),
          const SizedBox(height: 30),
          
          _buildRimLighting(),
          const SizedBox(height: 30),
          
          _buildVolumetricLight(),
          const SizedBox(height: 40),
          
          _buildSectionTitle('Depth Effects'),
          const SizedBox(height: 20),
          
          _buildDepthLevels(),
          const SizedBox(height: 30),
          
          _buildParallaxEffect(),
          const SizedBox(height: 40),
          
          _buildSectionTitle('Component Gallery'),
          const SizedBox(height: 20),
          
          _buildButtonGallery(),
          const SizedBox(height: 30),
          
          _buildIconGallery(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBreathingAnimation() {
    return _buildDemoCard(
      title: 'Breathing Animation',
      description: 'Organic breathing motion using sine wave modulation',
      child: Center(
        child: AnimatedBuilder(
          animation: _breathingController,
          builder: (context, child) {
            return NeumorphismContainer(
              type: NeumorphismType.breathing,
              depth: CardDepth.deep,
              borderRadius: 24,
              width: 200,
              height: 120,
              child: const Center(
                child: Icon(Icons.favorite, size: 48, color: Colors.red),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPulsingAnimation() {
    return _buildDemoCard(
      title: 'Pulsing Animation',
      description: 'Cardiac rhythm pulsing effect',
      child: Center(
        child: AnimatedBuilder(
          animation: _pulsingController,
          builder: (context, child) {
            final baseShadows = NeuromorphicPresets.CardPresets.standard();
            final shadows = NeuromorphicEffects.animator.createPulsingShadows(
              baseShadows: baseShadows,
              animationValue: _pulsingController.value,
              pulseIntensity: 0.3,
            );
            
            return Container(
              width: 200,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: shadows,
              ),
              child: const Center(
                child: Icon(Icons.notifications_active, size: 48, color: Colors.orange),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerAnimation() {
    return _buildDemoCard(
      title: 'Shimmer Animation',
      description: 'Highlight sweep effect',
      child: Center(
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            final baseShadows = NeuromorphicPresets.CardPresets.standard();
            final shadows = NeuromorphicEffects.animator.createShimmerShadows(
              baseShadows: baseShadows,
              animationValue: _shimmerController.value,
              shimmerColor: AppColors.primary,
            );
            
            return Container(
              width: 200,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: shadows,
              ),
              child: const Center(
                child: Icon(Icons.star, size: 48, color: Colors.amber),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWaveAnimation() {
    return _buildDemoCard(
      title: 'Wave Animation',
      description: 'Ripple wave effect',
      child: Center(
        child: AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            final baseShadows = NeuromorphicPresets.CardPresets.standard();
            final shadows = NeuromorphicEffects.animator.createWaveShadows(
              baseShadows: baseShadows,
              animationValue: _waveController.value,
              waveAmplitude: 5.0,
            );
            
            return Container(
              width: 200,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: shadows,
              ),
              child: const Center(
                child: Icon(Icons.water_drop, size: 48, color: Colors.blue),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHoverAnimation() {
    return _buildDemoCard(
      title: 'Hover Animation',
      description: 'Interactive depth increase on hover',
      child: Center(
        child: NeumorphismContainer(
          type: NeumorphismType.morphing,
          depth: CardDepth.medium,
          borderRadius: 24,
          width: 200,
          height: 120,
          onHover: () {
            // Hover callback
          },
          child: const Center(
            child: Text('Hover me!', style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }

  Widget _buildPressAnimation() {
    return _buildDemoCard(
      title: 'Press Animation',
      description: 'Inset effect on press',
      child: Center(
        child: PrimaryButton(
          text: 'Press Me',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Button pressed!')),
            );
          },
          enableUltraEffects: true,
        ),
      ),
    );
  }

  Widget _buildMorphingAnimation() {
    return _buildDemoCard(
      title: 'Morphing Animation',
      description: 'Shape and shadow morphing',
      child: Center(
        child: NeumorphismContainer(
          type: NeumorphismType.morphing,
          depth: CardDepth.medium,
          borderRadius: 24,
          width: 200,
          height: 120,
          isHovered: true,
          child: const Center(
            child: Icon(Icons.transform, size: 48, color: Colors.purple),
          ),
        ),
      ),
    );
  }

  Widget _buildAmbientGlow() {
    return _buildDemoCard(
      title: 'Ambient Glow',
      description: '3-layer ambient glow effect',
      child: Center(
        child: Container(
          width: 200,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              ...NeuromorphicPresets.CardPresets.standard(),
              ...NeuromorphicEffects.lighting.createAmbientGlow(
                glowColor: AppColors.primary,
                intensity: 0.8,
                radius: 30.0,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.light_mode, size: 48, color: Colors.yellow),
          ),
        ),
      ),
    );
  }

  Widget _buildRimLighting() {
    return _buildDemoCard(
      title: 'Rim Lighting',
      description: 'Angle-based rim light effect',
      child: Center(
        child: Container(
          width: 200,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              ...NeuromorphicPresets.CardPresets.standard(),
              ...NeuromorphicEffects.lighting.createRimLight(
                angle: 45,
                intensity: 0.8,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.wb_sunny, size: 48, color: Colors.orange),
          ),
        ),
      ),
    );
  }

  Widget _buildVolumetricLight() {
    return _buildDemoCard(
      title: 'Volumetric Light',
      description: '6-layer progressive volumetric lighting',
      child: Center(
        child: Container(
          width: 200,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              ...NeuromorphicPresets.CardPresets.standard(),
              ...NeuromorphicEffects.lighting.createVolumetricLight(
                lightDirection: const Offset(-1, -1),
                intensity: 0.6,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.wb_twilight, size: 48, color: Colors.deepPurple),
          ),
        ),
      ),
    );
  }

  Widget _buildDepthLevels() {
    return _buildDemoCard(
      title: 'Depth Levels',
      description: '6 tiers: shallow → mega',
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          _buildDepthCard('Shallow', CardDepth.shallow),
          _buildDepthCard('Medium', CardDepth.medium),
          _buildDepthCard('Deep', CardDepth.deep),
          _buildDepthCard('Ultra', CardDepth.ultra),
          _buildDepthCard('Cinematic', CardDepth.cinematic),
          _buildDepthCard('Mega', CardDepth.mega),
        ],
      ),
    );
  }

  Widget _buildDepthCard(String label, CardDepth depth) {
    return NeumorphismContainer(
      type: NeumorphismType.outset,
      depth: depth,
      borderRadius: 16,
      width: 100,
      height: 80,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildParallaxEffect() {
    return _buildDemoCard(
      title: 'Parallax Effect',
      description: 'Scroll-based depth adjustment',
      child: SizedBox(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: NeumorphismContainer(
                type: NeumorphismType.outset,
                depth: CardDepth.deep,
                borderRadius: 24,
                width: 150,
                enableParallax: _showParallax,
                scrollController: _scrollController,
                parallaxFactor: 0.1 * (index + 1),
                child: Center(
                  child: Text(
                    'Card ${index + 1}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButtonGallery() {
    return _buildDemoCard(
      title: 'Button Gallery',
      description: 'All button variations',
      child: Column(
        children: [
          PrimaryButton(
            text: 'Primary Button',
            onPressed: () {},
            enableUltraEffects: true,
          ),
          const SizedBox(height: 16),
          SecondaryButton(
            text: 'Secondary Button',
            onPressed: () {},
            enableUltraEffects: true,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Cinematic Button',
            onPressed: () {},
            enableCinematicMode: true,
          ),
        ],
      ),
    );
  }

  Widget _buildIconGallery() {
    return _buildDemoCard(
      title: 'Icon Gallery',
      description: 'All icon styles',
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          NeuromorphicIcon(
            icon: Icons.home,
            size: IconSize.large,
            style: IconStyle.standard,
          ),
          NeuromorphicIcon(
            icon: Icons.favorite,
            size: IconSize.large,
            style: IconStyle.circular,
            isActive: true,
            glowColor: Colors.red,
          ),
          NeuromorphicIcon(
            icon: Icons.star,
            size: IconSize.large,
            style: IconStyle.floating,
          ),
          NeuromorphicIcon(
            icon: Icons.settings,
            size: IconSize.large,
            style: IconStyle.embedded,
          ),
          NeuromorphicIcon(
            icon: Icons.notifications,
            size: IconSize.large,
            style: IconStyle.morphing,
            isActive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDemoCard({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: NeuromorphicPresets.CardPresets.standard(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
