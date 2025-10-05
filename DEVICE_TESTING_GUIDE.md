# 📱 Device Testing Guide - Neuromorphic Design

## Test Devices Recommended

### High-End Devices (Target: 60 FPS)
- iPhone 14 Pro / 15 Pro
- Samsung Galaxy S23 / S24
- Google Pixel 7 Pro / 8 Pro
- OnePlus 11 / 12

### Mid-Range Devices (Target: 55-60 FPS)
- iPhone 12 / 13
- Samsung Galaxy A54 / A34
- Google Pixel 6a / 7a
- Xiaomi Redmi Note 12 Pro

### Low-End Devices (Target: 50-55 FPS)
- iPhone SE (2022)
- Samsung Galaxy A23 / A13
- Redmi Note 11
- Moto G Power

## Testing Checklist

### 1. Visual Quality Tests ✅

#### Shadow Rendering
- [ ] All shadows render correctly (no clipping)
- [ ] Shadow layers are visible and distinct
- [ ] Ambient glow effects are visible
- [ ] No shadow banding or artifacts
- [ ] Shadows respond to hover/press states

#### Colors & Contrast
- [ ] Background color (#EAEEE5) consistent across pages
- [ ] Text is readable on all neuromorphic surfaces
- [ ] Primary color (#3E7E55) matches design
- [ ] Border separators (1px) are visible but subtle

#### Animations
- [ ] Button press animations are smooth (150ms)
- [ ] Hover effects trigger correctly
- [ ] Parallax scrolling is fluid
- [ ] Breathing animations are organic
- [ ] No animation jank or stuttering

### 2. Performance Tests ⚡

#### Frame Rate Monitoring
```dart
// Enable performance profiler in main.dart:
void main() {
  PerformanceProfiler().start();
  runApp(MyApp());
}

// Check performance after 30 seconds of usage:
final report = PerformanceProfiler().getReport();
print(report); // Should show 55+ FPS
```

#### Memory Usage
- [ ] Initial memory < 150 MB
- [ ] After 5 min usage < 300 MB
- [ ] No memory leaks (stable over time)
- [ ] Shadow cache < 50 MB

#### Battery Impact
- [ ] 5 min usage < 2% battery drain
- [ ] No excessive CPU usage in background
- [ ] Screen brightness at 50% for testing

### 3. Interaction Tests 🖱️

#### Touch Targets
- [ ] All buttons are 48x48dp minimum
- [ ] Navigation icons are easily tappable
- [ ] No accidental taps on nearby elements
- [ ] Ripple effects are visible

#### Gestures
- [ ] Scroll is smooth (no lag)
- [ ] Swipe gestures work correctly
- [ ] Long press activates preview
- [ ] Pull-to-refresh is responsive

#### States
- [ ] Hover state works (on supported devices)
- [ ] Press state immediate feedback
- [ ] Focus state visible (keyboard navigation)
- [ ] Disabled state clearly indicated

### 4. Cross-Platform Tests 🌍

#### iOS Testing
- [ ] Shadows render correctly (Metal)
- [ ] No performance issues on older iOS
- [ ] Safe area insets respected
- [ ] Haptic feedback works

#### Android Testing
- [ ] Shadows render correctly (Skia)
- [ ] Works on Android 8.0+ (API 26+)
- [ ] Material Design 3 integration
- [ ] Back gesture doesn't conflict

### 5. Accessibility Tests ♿

#### Screen Readers
- [ ] All buttons have semantic labels
- [ ] Image buttons have descriptions
- [ ] Focus order is logical
- [ ] Announcements are clear

#### Visual Accessibility
- [ ] Minimum contrast ratio 4.5:1 (text)
- [ ] Minimum contrast ratio 3:1 (UI elements)
- [ ] Color is not the only indicator
- [ ] Text scales correctly (accessibility settings)

#### Motor Accessibility
- [ ] All touch targets ≥ 48dp
- [ ] No time-based interactions
- [ ] Gestures have alternatives
- [ ] No shake-to-undo

## Testing Procedure

### Phase 1: Initial Visual Check (5 min)
1. Open app on test device
2. Navigate through all main pages
3. Check for visual glitches
4. Verify colors and shadows
5. Test dark mode (if implemented)

### Phase 2: Performance Profiling (10 min)
1. Start performance profiler
2. Navigate through app normally
3. Scroll through long lists
4. Open and close modals
5. Trigger all animations
6. Check profiler report

### Phase 3: Interaction Testing (10 min)
1. Test all buttons and links
2. Test form inputs and validation
3. Test navigation (back, tabs, etc.)
4. Test gestures (swipe, long press)
5. Test edge cases (empty states, errors)

### Phase 4: Stress Testing (5 min)
1. Scroll rapidly through lists
2. Tap buttons rapidly
3. Switch pages quickly
4. Open multiple modals
5. Check for memory leaks

### Phase 5: Real-World Usage (10 min)
1. Complete typical user flows
2. Test with real data
3. Test with poor network
4. Test with notifications
5. Test after app backgrounding

## Performance Benchmarks

### Target Metrics (Mid-Range Device)

```
✅ ACCEPTABLE PERFORMANCE:
   FPS:              55-60 fps
   Frame Time:       < 16.67 ms
   Jank:             < 5%
   Build Time:       < 8 ms
   Raster Time:      < 8 ms
   Shadow Render:    < 2 ms per component
   Memory:           < 300 MB
   Battery:          < 2% per 5 min

⚠️ NEEDS OPTIMIZATION:
   FPS:              50-55 fps
   Frame Time:       16.67-20 ms
   Jank:             5-10%
   
❌ UNACCEPTABLE:
   FPS:              < 50 fps
   Frame Time:       > 20 ms
   Jank:             > 10%
```

## Automated Testing Commands

### Run Performance Test
```bash
# Profile app performance
flutter run --profile

# Analyze performance
flutter analyze --watch

# Check for jank
flutter drive --profile --trace-skia
```

### Measure Build Size
```bash
# Android
flutter build apk --analyze-size

# iOS
flutter build ios --analyze-size
```

### Memory Profiling
```bash
# Start with memory timeline
flutter run --profile --enable-impeller

# In DevTools:
# 1. Open Memory tab
# 2. Take snapshots during usage
# 3. Check for leaks
```

## Common Issues & Solutions

### Issue: Shadows Not Rendering
**Solution:** Check device GPU capabilities, reduce shadow count on low-end devices

### Issue: Low FPS
**Solution:** Enable shadow caching, add RepaintBoundary, reduce shadow layers

### Issue: Memory Leaks
**Solution:** Clear shadow cache on page disposal, use const widgets

### Issue: Jank on Scroll
**Solution:** Add RepaintBoundary to list items, lazy load shadows

### Issue: Battery Drain
**Solution:** Reduce animation frequency, disable parallax on battery saver mode

## Reporting Issues

### Bug Report Template
```markdown
**Device:** [e.g., iPhone 13, Android 12]
**Flutter Version:** [e.g., 3.16.0]
**Issue:** [Brief description]
**Steps to Reproduce:**
1. 
2. 
3. 

**Expected:** [What should happen]
**Actual:** [What actually happens]
**Screenshots:** [If applicable]
**Performance Report:** [From profiler]
```

## Sign-Off Criteria

Before releasing, ensure:
- ✅ All visual quality tests pass
- ✅ Performance tests show 55+ FPS on mid-range devices
- ✅ No critical accessibility issues
- ✅ No memory leaks detected
- ✅ Battery impact < 2% per 5 min
- ✅ All user flows work correctly
- ✅ No crashes in 30 min usage session

## Contact

For testing support or questions:
- Technical Lead: [Email]
- QA Team: [Email]
- Performance Issues: Use performance dashboard in app
