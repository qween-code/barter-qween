# 🎨 Barter Qween - Design System

**Son Güncelleme:** 5 Ocak 2025  
**Design Language:** Ultra-Deep Neuromorphic (Pinterest-level)

---

## 📋 İçindekiler
1. [Design Philosophy](#design-philosophy)
2. [Color System](#color-system)
3. [Typography](#typography)
4. [Spacing & Layout](#spacing--layout)
5. [Neuromorphic Components](#neuromorphic-components)
6. [Implementation Guide](#implementation-guide)
7. [Best Practices](#best-practices)

---

## 🎯 Design Philosophy

### Neuromorphic Design Nedir?

**Neumorphism** (Yeni-morphism), fiziksel dünyanın ışık, gölge ve derinlik prensiplerini dijital ortama taşıyan bir tasarım dilidir. Pinterest, Dribbble ve modern UI/UX trend'lerinden esinlenilerek geliştirilmiştir.

### Temel Prensipler

1. **Çok Katmanlı Derinlik** (16-24 layer shadows)
2. **Dinamik Işık Hesaplama** (Real-time lighting)
3. **Yumuşak Geçişler** (Soft edges & gradients)
4. **İnteraktif Animasyonlar** (Hover, press, focus states)
5. **Tek Renk Paleti** (Monochromatic base)

### Design Goals

- **Zarafet:** Soft, elegant, premium feel
- **Derinlik:** Ultra-deep 3D perception
- **Performans:** 60 FPS animations
- **Erişilebilirlik:** AA standard contrast
- **Tutarlılık:** Consistent across all screens

---

## 🎨 Color System

### Base Colors

```dart
// core/theme/app_colors.dart

// Primary Palette
static const Color primary = Color(0xFF7C3AED);        // Purple
static const Color primaryLight = Color(0xFF9F7AEA);
static const Color primaryDark = Color(0xFF5B21B6);

// Neumorphism Base
static const Color surfaceBase = Color(0xFFE0E5EC);    // Soft gray
static const Color surface = Color(0xFFE8EAED);
static const Color surfaceLight = Color(0xFFF8F9FA);
static const Color surfaceVariant = Color(0xFFD1D5DB);

// Semantic Colors
static const Color success = Color(0xFF10B981);
static const Color warning = Color(0xFFF59E0B);
static const Color error = Color(0xFFEF4444);
static const Color info = Color(0xFF3B82F6);

// Text Colors
static const Color textPrimary = Color(0xFF1F2937);
static const Color textSecondary = Color(0xFF6B7280);
static const Color textDisabled = Color(0xFF9CA3AF);

// Neumorphism Shadows
static const Color shadowDark = Color(0x00000000);     // Black with opacity
static const Color shadowLight = Color(0xFFFFFFFF);    // White with opacity

// Borders
static const Color border = Color(0xFFD1D5DB);
static const Color borderNeumorphism = Color(0xFFB0B5BD);
```

### Dynamic Color Generation

```dart
// Işığa göre renk hesaplama
Color calculateLightColor(double lightIntensity) {
  if (lightIntensity < 0.3) return Colors.orange;  // Warm light
  if (lightIntensity < 0.7) return Colors.white;   // Neutral light
  return Colors.blue.shade50;                       // Cool light
}

// Gölge rengi hesaplama
Color calculateShadowColor(double depth) {
  final opacity = (depth * 0.1).clamp(0.1, 0.4);
  return Colors.black.withOpacity(opacity);
}
```

---

## ✍️ Typography

### Text Styles

```dart
// core/theme/app_text_styles.dart

// Display (Hero Text)
static const TextStyle displayLarge = TextStyle(
  fontSize: 57,
  fontWeight: FontWeight.w700,
  height: 1.12,
  letterSpacing: -0.25,
);

// Headings
static const TextStyle h1 = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  height: 1.25,
);

static const TextStyle h2 = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w600,
  height: 1.3,
);

static const TextStyle h3 = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  height: 1.35,
);

// Body Text
static const TextStyle bodyLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.5,
);

static const TextStyle bodyMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  height: 1.43,
);

// Buttons & Labels
static const TextStyle buttonLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
);

static const TextStyle buttonMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.4,
);
```

### Font Family

**Default:** System font (Roboto on Android, SF Pro on iOS)

```dart
// For custom fonts (if needed)
static const String fontFamily = 'Inter';  // Or 'Poppins', 'Montserrat'
```

---

## 📐 Spacing & Layout

### Spacing Scale

```dart
// core/theme/app_dimensions.dart

// Base spacing (8px grid)
static const double spacing2 = 2.0;
static const double spacing4 = 4.0;
static const double spacing8 = 8.0;
static const double spacing12 = 12.0;
static const double spacing16 = 16.0;
static const double spacing20 = 20.0;
static const double spacing24 = 24.0;
static const double spacing32 = 32.0;
static const double spacing40 = 40.0;
static const double spacing48 = 48.0;
static const double spacing64 = 64.0;
static const double spacing80 = 80.0;
```

### Border Radius Scale

```dart
// Soft rounded corners
static const double radius4 = 4.0;
static const double radius8 = 8.0;
static const double radius12 = 12.0;
static const double radius16 = 16.0;
static const double radius20 = 20.0;
static const double radius24 = 24.0;
static const double radius32 = 32.0;
static const double radius40 = 40.0;
static const double radiusCircle = 9999.0;
```

### Component Dimensions

```dart
// Buttons
static const double buttonHeight8 = 36.0;
static const double buttonHeight12 = 44.0;
static const double buttonHeight16 = 52.0;
static const double buttonHeight20 = 60.0;

// Input Fields
static const double inputHeight10 = 48.0;
static const double inputHeight12 = 52.0;
static const double inputHeight14 = 56.0;

// Cards
static const double cardHeight12 = 160.0;
static const double cardHeight16 = 200.0;
static const double cardHeight20 = 240.0;
```

---

## ⚡ Neuromorphic Components

### Shadow System

#### Preset Combinations

```dart
// core/theme/neuromorphic_effects.dart

// Button shadows (12 layers)
NeuromorphicPresets.ButtonPresets.primary(
  isPressed: false,
  isHovered: false,
);

// Card shadows (14 layers)
NeuromorphicPresets.CardPresets.standard(
  isHovered: false,
);

// Input shadows (8 layers inset)
NeuromorphicPresets.InputPresets.textField(
  isFocused: false,
);

// Icon shadows (4 layers)
NeuromorphicPresets.IconPresets.standard(
  isActive: false,
);
```

#### Custom Shadow Creation

```dart
// Ultra-deep shadow (16 layers)
List<BoxShadow> createUltraDeepShadow({
  required double depth,
  required Offset lightPosition,
}) {
  final shadows = <BoxShadow>[];
  
  for (int i = 0; i < 16; i++) {
    final layerDepth = depth * (16 - i) / 16;
    final offset = lightPosition * layerDepth;
    
    // Light shadow
    shadows.add(BoxShadow(
      color: Colors.white.withOpacity(0.9 - i * 0.05),
      offset: offset,
      blurRadius: 4 + i * 2.0,
      spreadRadius: -(4 + i * 2.0) * 0.25,
    ));
    
    // Dark shadow
    shadows.add(BoxShadow(
      color: Colors.black.withOpacity(0.1 + i * 0.02),
      offset: -offset,
      blurRadius: 4 + i * 2.0,
      spreadRadius: -(4 + i * 2.0) * 0.25,
    ));
  }
  
  return shadows;
}
```

### Animation System

#### Hover Animation

```dart
class NeuromorphicButton extends StatefulWidget {
  @override
  State<NeuromorphicButton> createState() => _NeuromorphicButtonState();
}

class _NeuromorphicButtonState extends State<NeuromorphicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radius16),
                boxShadow: NeuromorphicPresets.ButtonPresets.primary(
                  isHovered: _isHovered,
                ),
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
```

### Component Library

#### 1. Neuromorphic Button

```dart
// presentation/widgets/primary_button.dart

PrimaryButton(
  text: 'Takas Teklifi Gönder',
  onPressed: () {},
  isLoading: false,
  isFullWidth: true,
  enableUltraEffects: true,  // 12-layer shadows
)
```

#### 2. Neuromorphic Container

```dart
// presentation/widgets/neumorphism/neumorphism_container.dart

NeumorphismContainer(
  type: NeumorphismType.ultraOutset,  // Deep convex
  depth: CardDepth.deep,               // 3x depth
  shape: CardShape.rounded,            // Soft corners
  enableParallax: true,                // Parallax scrolling
  enableInteraction: true,             // Hover/press states
  child: YourWidget(),
)
```

#### 3. Neuromorphic Icon

```dart
// presentation/widgets/neumorphism/neuromorphic_icon.dart

NeuromorphicIcon(
  icon: Icons.favorite,
  size: 24,
  depth: IconDepth.medium,
  enableGlow: true,
  glowColor: AppColors.primary,
)
```

#### 4. Neuromorphic Input Field

```dart
// presentation/widgets/custom_text_field.dart

CustomTextField(
  controller: controller,
  label: 'Ürün Başlığı',
  hintText: 'Örn: iPhone 12 Pro',
  enableNeumorphism: true,
  focusedBorderColor: AppColors.primary,
)
```

---

## 🛠️ Implementation Guide

### Basic Setup

#### 1. Import Theme Files

```dart
import 'package:barter_qween/core/theme/app_colors.dart';
import 'package:barter_qween/core/theme/app_dimensions.dart';
import 'package:barter_qween/core/theme/app_text_styles.dart';
import 'package:barter_qween/core/theme/neuromorphic_effects.dart';
```

#### 2. Apply to MaterialApp

```dart
MaterialApp(
  theme: ThemeData(
    scaffoldBackgroundColor: AppColors.surfaceBase,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      headlineLarge: AppTextStyles.h1,
      bodyLarge: AppTextStyles.bodyLarge,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,  // No elevation for neumorphism
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
        ),
      ),
    ),
  ),
)
```

### Creating Neuromorphic Components

#### Step-by-Step Example

```dart
// 1. Create container with base styling
Container(
  padding: EdgeInsets.all(AppDimensions.spacing16),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppDimensions.radius16),
  ),
  child: YourContent(),
)

// 2. Add neuromorphic shadows
Container(
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppDimensions.radius16),
    boxShadow: NeuromorphicPresets.CardPresets.standard(),
  ),
)

// 3. Add interactivity
MouseRegion(
  onEnter: (_) => setState(() => _isHovered = true),
  onExit: (_) => setState(() => _isHovered = false),
  child: Container(
    decoration: BoxDecoration(
      boxShadow: NeuromorphicPresets.CardPresets.standard(
        isHovered: _isHovered,
      ),
    ),
  ),
)

// 4. Add animation
AnimatedContainer(
  duration: Duration(milliseconds: 150),
  curve: Curves.easeInOut,
  transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
  decoration: BoxDecoration(
    boxShadow: NeuromorphicPresets.CardPresets.standard(
      isHovered: _isHovered,
    ),
  ),
)
```

---

## 📱 Best Practices

### Performance Optimization

1. **Use RepaintBoundary**
```dart
RepaintBoundary(
  child: NeumorphismContainer(...),
)
```

2. **Avoid Nested Shadows**
```dart
// BAD
Container(
  decoration: BoxDecoration(boxShadow: shadows1),
  child: Container(
    decoration: BoxDecoration(boxShadow: shadows2),
  ),
)

// GOOD
Container(
  decoration: BoxDecoration(boxShadow: [...shadows1, ...shadows2]),
  child: Widget(),
)
```

3. **Limit Animation Complexity**
```dart
// Use single AnimationController
// Combine multiple animations
// Use Curves for smooth transitions
```

### Accessibility

1. **Contrast Ratios**
```dart
// Ensure text contrast meets AA standards
// Light text on surface: 4.5:1 minimum
// Primary color contrast: 3:1 minimum
```

2. **Touch Targets**
```dart
// Minimum 44x44 for tap targets
static const double minTouchTarget = 44.0;
```

3. **Focus Indicators**
```dart
// Clear focus states for keyboard navigation
decoration: BoxDecoration(
  border: isFocused 
    ? Border.all(color: AppColors.primary, width: 2)
    : null,
)
```

### Design Tokens

**Use constants, not magic numbers:**
```dart
// BAD
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
  ),
)

// GOOD
Container(
  padding: EdgeInsets.all(AppDimensions.spacing16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppDimensions.radius12),
  ),
)
```

---

## 📚 Resources

### Design Inspiration
- **Pinterest:** Neumorphism designs
- **Dribbble:** UI patterns
- **Behance:** Mobile app designs

### Tools
- **Figma:** Design prototyping
- **Adobe XD:** Alternative design tool
- **Neumorphism.io:** Shadow generator

### Libraries
- `flutter_bloc` - State management
- `get_it` - Dependency injection
- `cached_network_image` - Image optimization

---

**Son Güncelleme:** 5 Ocak 2025  
**Dokümantasyon Versiyonu:** 2.0  
**Design Version:** Ultra-Deep Neuromorphic v1.2
