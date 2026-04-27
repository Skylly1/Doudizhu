# 斗破乾坤 — Production Launch Checklist

> Everything that must be replaced, completed, or verified before App Store submission.

---

## 1. IAP / StoreKit 2

- [x] Replace `PurchaseManager` mock with real StoreKit 2 implementation
- [ ] Configure products in App Store Connect (unlock full version, cosmetics, etc.)
- [x] Implement `Product.products(for:)` to fetch available IAPs
- [x] Handle `Transaction.updates` for background transaction processing
- [ ] Implement receipt validation (server-side recommended)
- [ ] Test in sandbox environment with multiple Apple ID accounts
- [x] Verify restore purchases flow works across devices
- [ ] Handle edge cases: interrupted purchases, deferred transactions, refunds
- [x] Add `SKPaymentQueue.canMakePayments()` check before showing purchase UI
- [x] StoreKit Testing in Xcode: create `.storekit` configuration file

## 2. Analytics

- [x] Replace `Analytics` stub with Firebase Analytics or Amplitude
- [x] Define event taxonomy: `level_start`, `level_complete`, `level_fail`, `purchase`, `shop_visit`
- [x] Track user properties: ascension level, total runs, preferred build
- [x] Implement funnel tracking: tutorial → first run → first purchase → retention
- [x] Add screen view tracking for all major views
- [ ] Configure data retention and privacy settings per GDPR/CCPA
- [ ] Set up real-time dashboards for launch monitoring
- [ ] Verify events fire correctly in debug builds before release

## 3. Crash Reporting

- [x] Replace `CrashReporter` stub with Sentry or Firebase Crashlytics
- [x] Upload dSYM files automatically via build phase script
- [x] Configure breadcrumbs for game state (current floor, jokers, gold)
- [ ] Set up alerts for crash-free rate drops below 99.5%
- [x] Add non-fatal error logging for recoverable failures
- [ ] Test crash reporting in TestFlight builds
- [ ] Create on-call escalation process for P0 crashes

## 4. App Store Connect

- [ ] Upload 6.7" (iPhone 15 Pro Max) screenshots — at least 3, ideally 10
- [ ] Upload 6.5" (iPhone 14 Plus) screenshots
- [ ] Upload 5.5" (iPhone 8 Plus) screenshots if supporting older devices
- [ ] Upload 12.9" iPad Pro screenshots (if supporting iPad)
- [ ] Create App Preview videos (15-30 seconds, gameplay highlight)
- [x] Write compelling app description (4000 char max) in Chinese + English
- [x] Optimize keyword field (100 chars, comma-separated, no spaces)
- [x] Set promotional text (170 chars, updateable without review)
- [x] Configure subtitle (30 chars)
- [ ] Set primary + secondary categories (Games → Card / Strategy)
- [x] Add privacy policy URL
- [x] Add support URL
- [x] Set contact email: doupoqiankun@126.com
- [ ] Set age rating via questionnaire
- [ ] Upload 1024×1024 app icon (no transparency, no rounded corners)

## 5. Privacy Manifest (PrivacyInfo.xcprivacy)

- [x] Create `PrivacyInfo.xcprivacy` in project root
- [x] Declare required reason APIs:
  - [x] `NSPrivacyAccessedAPICategoryUserDefaults` — game saves, settings
  - [ ] `NSPrivacyAccessedAPICategorySystemBootTime` (if used for timing)
  - [ ] `NSPrivacyAccessedAPICategoryDiskSpace` (if checked)
- [x] Declare tracking domains (if any analytics SDK phones home)
- [x] Declare `NSPrivacyCollectedDataTypes` for analytics data
- [x] Set `NSPrivacyTracking` to `false` (unless ATT is used)
- [x] Verify all 3rd-party SDKs include their own privacy manifests
- [ ] Test with Xcode privacy report (Product → Generate Privacy Report)

## 6. Game Center

- [ ] Enable Game Center capability in Xcode project
- [ ] Configure leaderboards in App Store Connect:
  - [ ] "Highest Score" — single run total score
  - [ ] "Highest Ascension" — highest ascension level cleared
  - [ ] "Daily Challenge" — daily high score
  - [ ] "Speed Run" — fastest 15-floor clear
- [ ] Configure achievements in App Store Connect (mirror `Achievement.swift`)
- [x] Implement `GKLocalPlayer.local.authenticateHandler`
- [x] Submit scores via `GKLeaderboard.submitScore()`
- [x] Report achievements via `GKAchievement.report()`
- [x] Handle authentication failures gracefully (offline play still works)
- [ ] Test on real device (Game Center sandbox)

## 7. App Review Preparation

- [ ] Complete content rating questionnaire accurately
- [ ] Card games may trigger "Simulated Gambling" — prepare justification
- [ ] Add gambling disclaimer if needed: "No real money gambling"
- [ ] Ensure no real-money wagering or casino-style mechanics
- [ ] Prepare demo account / instructions for reviewer if needed
- [ ] Set content rating to 4+ or 9+ depending on questionnaire results
- [ ] Verify app doesn't crash on first launch (clean install)
- [ ] Test all IAP flows end-to-end
- [ ] Prepare appeal documentation in case of rejection
- [ ] Review latest App Store Review Guidelines (especially 4.x Gaming)

## 8. Performance

- [ ] Profile memory usage with Instruments (target < 200 MB)
- [ ] Profile CPU usage during gameplay (target < 30% sustained)
- [ ] Measure battery drain per hour of gameplay
- [ ] Optimize startup time (target < 2 seconds to interactive)
- [ ] Test on oldest supported device (iPhone SE 2nd gen / iPhone 8)
- [ ] Verify 60fps during card animations and transitions
- [ ] Check for memory leaks with Instruments Leaks tool
- [ ] Profile energy impact with Instruments Energy Log
- [ ] Test with Low Power Mode enabled
- [ ] Verify app size < 200 MB (ideally < 100 MB)

## 9. Accessibility

- [x] Add VoiceOver labels to all interactive elements
- [ ] Support Dynamic Type for all text (use `.font(.body)` + scaling)
- [ ] Verify color contrast meets WCAG AA (4.5:1 for text)
- [ ] Test with VoiceOver enabled end-to-end
- [x] Add accessibility traits (`.isButton`, `.isHeader`, etc.)
- [ ] Support Reduce Motion preference (`@Environment(\.accessibilityReduceMotion)`)
- [ ] Support Bold Text preference
- [ ] Ensure card suits are distinguishable without color alone (shape + label)
- [ ] Test with Switch Control
- [ ] Verify all game actions are reachable via accessibility API

## 10. Legal

- [x] Create privacy policy page (hosted URL, required for App Store)
- [ ] Create terms of use / EULA
- [ ] Comply with COPPA if targeting under-13 (likely N/A for card games)
- [ ] Comply with GDPR for EU users (data deletion, consent)
- [ ] Comply with CCPA for California users
- [ ] Comply with China's game regulations if publishing in China App Store:
  - [ ] Real-name verification for minors
  - [ ] Anti-addiction time limits
  - [ ] ISBN / approval number (for paid games with IAP)
- [ ] Add open-source license attributions if using any OSS libraries
- [x] Verify no copyrighted assets (fonts, sounds, images)

## 11. Monetization

- [x] Finalize price point for full unlock ($4.99 / ¥25 recommended)
- [ ] Configure regional pricing tiers in App Store Connect
- [ ] Set up introductory offers (free trial, pay-up-front, pay-as-you-go)
- [ ] Configure promotional offers for lapsed users
- [ ] Plan launch promotion: temporary price reduction or bonus content
- [ ] A/B test paywall copy and timing
- [x] Implement "Restore Purchases" button in Settings
- [ ] Consider Family Sharing support
- [ ] Set up App Store subscription offer codes (if subscription model)
- [x] Verify price display uses `Product.displayPrice` (localized)

## 12. CI/CD

- [ ] Set up TestFlight internal testing group
- [ ] Configure automatic builds via Xcode Cloud or GitHub Actions
- [ ] Set up code signing with automatic provisioning
- [ ] Create separate schemes for Debug / TestFlight / Release
- [ ] Automate version bumping (CFBundleShortVersionString + build number)
- [x] Upload dSYMs to crash reporting service in build pipeline
- [ ] Run unit tests in CI before every build
- [ ] Set up external TestFlight beta group (up to 10,000 testers)
- [ ] Create release branch strategy (main → release/1.0)
- [ ] Prepare rollback plan: keep previous build ready for re-release
- [ ] Set up build notifications (Slack, email)
- [ ] Document release process for team

---

## Pre-Submission Final Checks

- [ ] Clean build succeeds on all target devices
- [ ] All placeholder / TODO / FIXME items resolved
- [ ] No debug logging in release build
- [ ] App icon renders correctly at all sizes
- [ ] Launch screen displays correctly
- [ ] Test fresh install (no UserDefaults carry-over)
- [ ] Test upgrade from previous TestFlight build
- [x] Verify all localized strings are present (8 languages: zh/en/ja/ko/fr/de/es/pt)
- [ ] Run full playthrough: tutorial → 15 floors → victory
- [ ] Verify Game Center integration end-to-end
- [ ] Submit for review with ample time (allow 24-48 hours)
