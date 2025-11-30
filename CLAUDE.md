# CLAUDE.md - AI Assistant Guide for VacShop

## 📋 Project Overview

**VacShop** is a Flutter mobile application that uses Vision Language Model (VLM) technology to scan and automatically convert prices into different currencies, allowing travelers to manage their budget in real-time, 100% offline.

**Tagline:** "Voyagez malin, budgétez simple" (Travel smart, budget simple)

### Key Stats
- **Lines of Code:** ~4,203 lines of Dart
- **Source Files:** 23 Dart files
- **Services:** 4 complete services
- **Data Models:** 5 Isar models
- **UI Screens:** 8 screens
- **Reusable Widgets:** 3+ widgets
- **Supported Currencies:** 35+ currencies

### Project Status
- **Version:** 1.0.0 (MVP)
- **Development Stage:** 80% complete
- **Last Updated:** November 2024
- **Funding:** CNRC (National Research Council of Canada)
- **Developer:** Olivier Bertsrand / DaVinci Nova Corp

---

## 🏗️ Architecture

### Tech Stack
- **Framework:** Flutter 3.2+
- **State Management:** Riverpod
- **Local Database:** Isar (NoSQL)
- **ML/AI:** TFLite Flutter (on-device VLM)
- **Authentication:** Firebase Auth (Google, Facebook, Email/Password)
- **Secure Storage:** flutter_secure_storage
- **Camera:** camera package
- **Image Processing:** image package
- **Charts:** fl_chart

### Directory Structure

```
/home/user/vacshop/
├── .git/                           # Git repository
└── vacshop/                        # Flutter app root
    ├── lib/                        # Source code
    │   ├── main.dart               # ✅ Entry point
    │   ├── config/                 # ✅ Configuration
    │   │   ├── theme.dart          # Complete design system
    │   │   └── constants.dart      # App constants
    │   ├── models/                 # ✅ Isar data models (5 models)
    │   │   ├── user.dart
    │   │   ├── budget.dart
    │   │   ├── article.dart
    │   │   ├── exchange_rate.dart
    │   │   └── scan_result.dart
    │   ├── services/               # ✅ Business services (4 services)
    │   │   ├── database_service.dart     # Complete CRUD
    │   │   ├── auth_service.dart         # Complete auth
    │   │   ├── vlm_service.dart          # ⚠️ Ready for model
    │   │   └── currency_service.dart     # Offline conversion
    │   ├── providers/              # ⏳ To be implemented (Riverpod)
    │   ├── screens/                # ✅ UI screens (8 screens)
    │   │   ├── splash_screen.dart
    │   │   ├── onboarding_screen.dart
    │   │   ├── auth/
    │   │   │   ├── login_screen.dart
    │   │   │   └── signup_screen.dart
    │   │   ├── home/
    │   │   │   └── home_screen.dart
    │   │   ├── scan/
    │   │   │   └── scan_screen.dart
    │   │   ├── dashboard/
    │   │   │   └── dashboard_screen.dart
    │   │   └── settings/
    │   │       └── settings_screen.dart
    │   └── widgets/                # ✅ Reusable components
    │       ├── custom_button.dart
    │       ├── custom_text_field.dart
    │       └── social_auth_button.dart
    ├── assets/
    │   ├── images/                 # 📁 To be filled
    │   ├── icons/                  # 📁 To add (Google, Facebook SVG)
    │   ├── models/
    │   │   └── vacshop_vlm.tflite # ⚠️ VLM model to receive
    │   ├── data/
    │   │   └── exchange_rates.json # ✅ 35+ currencies
    │   └── fonts/
    │       └── Inter/              # 📁 To add .ttf files
    ├── pubspec.yaml                # ✅ Complete dependencies
    ├── README.md                   # ✅ Detailed documentation
    ├── INTEGRATION_VLM.md          # ✅ VLM integration guide
    ├── DELIVERABLE.md              # ✅ Project status
    ├── PROJECT_SUMMARY.txt         # ✅ Visual summary
    └── QUICKSTART.md               # ✅ Quick start guide
```

---

## 🎯 Core Features

### ✅ Implemented (100%)
1. **Authentication**
   - Email/Password signup and login
   - OAuth (Google & Facebook)
   - Offline mode with cached credentials
   - Secure storage (AES-256)
   - Firebase integration

2. **Local Database (Isar)**
   - 5 complete data models
   - Full CRUD operations
   - Optimized queries with indexes
   - Relations between entities
   - Statistics and aggregations

3. **Currency Conversion**
   - 35+ currencies supported
   - 100% offline operation
   - Exchange rates cached locally
   - Optional online updates
   - Multi-currency conversion with USD pivot

4. **UI/UX (80% complete)**
   - 8 main screens implemented
   - Complete design system
   - Responsive design
   - Smooth animations
   - Loading states and error handling

### ⚠️ Partially Implemented (80%)
**VLM Service** - Ready for model integration:
- ✅ Complete TFLite architecture
- ✅ Optimized image preprocessing
- ✅ Flexible post-processing structure
- ✅ Error handling and timeouts
- ⏳ Awaiting trained .tflite model
- ⏳ Need exact input/output specifications
- ⏳ Need currency mapping (indices → ISO codes)

**See:** `vacshop/INTEGRATION_VLM.md` for complete integration guide

### ⏳ To Be Implemented
- **Riverpod Providers** - State management layer
- **Additional Screens** - ScanResult, ArticleDetails, History, etc.
- **Unit Tests** - Service and widget tests
- **Firebase Configuration** - google-services.json, etc.
- **Missing Assets** - Fonts, icons, images

---

## 📊 Data Models (Isar)

### 1. User (`lib/models/user.dart`)
```dart
- uid: String                 // Firebase UID
- email: String               // Email address
- displayName: String?        // Display name
- defaultCurrency: String     // Default currency (CAD, EUR, etc.)
- isOnline: bool             // Online/offline status
- createdAt: DateTime
- lastLoginAt: DateTime
```

### 2. Budget (`lib/models/budget.dart`)
```dart
- userId: String             // Owner user ID
- name: String               // Budget name (e.g., "Tokyo Trip 2024")
- description: String?       // Optional description
- totalAmount: double        // Total budget amount
- currency: String           // Budget currency
- startDate: DateTime?       // Start date
- endDate: DateTime?         // End date
- isActive: bool            // Active status
```

### 3. Article (`lib/models/article.dart`)
```dart
- budgetId: Id              // Parent budget
- amount: double            // Detected amount
- detectedCurrency: String  // Detected currency
- convertedAmount: double   // Converted to budget currency
- confidence: double        // VLM confidence (0.0-1.0)
- category: String          // Category (Restaurant, Transport, etc.)
- quantity: int             // Quantity
- imagePath: String?        // Scanned image path
- notes: String?            // User notes
```

### 4. ExchangeRate (`lib/models/exchange_rate.dart`)
```dart
- fromCurrency: String      // Source currency (e.g., "USD")
- toCurrency: String        // Target currency (e.g., "CAD")
- rate: double             // Exchange rate
- lastUpdated: DateTime    // Last update timestamp
```

### 5. ScanResult (`lib/models/scan_result.dart`)
```dart
- amount: double           // Detected price amount
- currency: String         // Detected currency code
- confidence: double       // Detection confidence
- imagePath: String        // Path to scanned image
- timestamp: DateTime      // Scan timestamp
```

---

## 🔧 Services

### 1. DatabaseService (`lib/services/database_service.dart`)
**Purpose:** Manages all Isar database operations

**Key Methods:**
- `initialize()` - Initialize Isar database
- `createUser(User user)` - Create new user
- `getUserByUid(String uid)` - Get user by Firebase UID
- `createBudget(Budget budget)` - Create budget
- `getBudgetsByUser(String userId)` - Get user's budgets
- `createArticle(Article article)` - Create article/transaction
- `getArticlesByBudget(Id budgetId)` - Get budget articles
- `getBudgetStats(Id budgetId)` - Get budget statistics
- `updateExchangeRates(List<ExchangeRate> rates)` - Update rates

**Usage:**
```dart
final db = DatabaseService.instance;
await db.initialize();
final user = await db.getUserByUid(firebaseUid);
```

### 2. AuthService (`lib/services/auth_service.dart`)
**Purpose:** Handles authentication (Firebase + Offline)

**Key Methods:**
- `signUpWithEmail({email, password, displayName})` - Email signup
- `signInWithEmail(email, password)` - Email login
- `signInWithGoogle()` - Google OAuth
- `signInWithFacebook()` - Facebook OAuth
- `signInOffline()` - Offline mode login
- `signOut()` - Sign out
- `get currentFirebaseUser` - Current Firebase user
- `get authStateChanges` - Auth state stream

**Usage:**
```dart
final auth = AuthService();
final user = await auth.signInWithEmail('email@example.com', 'password');
```

**Offline Mode:**
- Credentials cached securely after first login
- Works without internet connection
- Uses flutter_secure_storage (AES-256)

### 3. CurrencyService (`lib/services/currency_service.dart`)
**Purpose:** Handles currency conversion (100% offline)

**Key Methods:**
- `initialize()` - Load exchange rates from JSON
- `convert(amount, from, to)` - Convert currency
- `getRate(from, to)` - Get exchange rate
- `getAllCurrencies()` - Get all supported currencies
- `formatAmount(amount, currencyCode)` - Format with symbol
- `updateRatesFromAPI()` - Optional online update

**Usage:**
```dart
final currency = CurrencyService.instance;
await currency.initialize();
final converted = await currency.convert(100.0, 'USD', 'CAD'); // 135.0
```

**Supported Currencies:**
CAD, USD, EUR, GBP, JPY, CHF, AUD, CNY, MXN, BRL, INR, KRW, THB, SGD, NZD, SEK, NOK, DKK, PLN, TRY, ZAR, AED, SAR, HKD, TWD, PHP, IDR, MYR, VND, CZK, HUF, RON, ILS, CLP, COP, ARS (35+ total)

### 4. VLMService (`lib/services/vlm_service.dart`) ⚠️
**Purpose:** TFLite inference for price detection

**Status:** Architecture complete, awaiting trained model

**Key Methods:**
- `initialize()` - Load TFLite model
- `scanImage(String imagePath)` - Detect price from image
- `_preprocessImage(imagePath)` - Prepare image for inference
- `_postprocessOutput(output, imagePath)` - Parse model output
- `dispose()` - Clean up resources

**Configuration:**
- Input size: 224x224 (configurable)
- Confidence threshold: 0.75
- Timeout: 5 seconds
- CPU optimization: 4 threads, XNNPACK delegate
- Android: NNAPI support

**Critical Integration Points:**
See `vacshop/INTEGRATION_VLM.md` for detailed integration guide:
1. Preprocessing adaptation (normalization, resolution)
2. Postprocessing adaptation (output parsing)
3. Currency mapping (index → ISO code)
4. Model file: `assets/models/vacshop_vlm.tflite`

---

## 🎨 Design System

### Colors (lib/config/theme.dart)
```dart
Primary:   #4A90E2  // Blue
Secondary: #2DD4BF  // Turquoise
Accent:    #8B5CF6  // Purple
Success:   #10B981  // Green
Warning:   #F59E0B  // Orange
Error:     #EF4444  // Red
```

### Typography
- **Font Family:** Inter (Regular, Medium, SemiBold, Bold)
- **Sizes:**
  - H1: 32px (Bold)
  - H2: 24px (SemiBold)
  - H3: 20px (SemiBold)
  - Body: 16px (Regular)
  - Caption: 12px (Regular)

### Common Widgets
- `CustomButton` - Styled button with loading state
- `CustomTextField` - Styled text input with validation
- `SocialAuthButton` - OAuth button (Google/Facebook)

---

## 💻 Development Workflows

### Initial Setup

**Prerequisites:**
- Flutter SDK 3.2.0+
- Dart 3.0.0+
- Android Studio / VS Code
- Firebase project (for authentication)

**Installation:**
```bash
cd /home/user/vacshop/vacshop
flutter pub get
flutter pub run build_runner build
```

**Note:** `build_runner` generates Isar model files (.g.dart)

### Common Commands

```bash
# Get dependencies
flutter pub get

# Generate Isar files
flutter pub run build_runner build

# Generate with clean build
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

### Git Workflow

**Branch Structure:**
- `main` - Production-ready code
- `claude/claude-md-*` - AI assistant development branches

**Current Branch:**
```bash
claude/claude-md-mim8kdflxmn1j62d-01E6MZ8EKS2RVPcFm767LHvt
```

**Committing Changes:**
```bash
git add .
git commit -m "feat: Add comprehensive CLAUDE.md documentation"
git push -u origin claude/claude-md-mim8kdflxmn1j62d-01E6MZ8EKS2RVPcFm767LHvt
```

---

## 🧪 Testing Strategy

### Unit Tests (To Be Implemented)
**Location:** `test/services/`

**Priority Services to Test:**
1. `CurrencyService` - Conversion logic
2. `DatabaseService` - CRUD operations
3. `AuthService` - Authentication flows
4. `VLMService` - Inference pipeline

**Example Test Structure:**
```dart
test('Currency conversion USD to CAD', () async {
  final service = CurrencyService.instance;
  await service.initialize();

  final result = await service.convert(100.0, 'USD', 'CAD');
  expect(result, 135.0);
});
```

### Widget Tests (To Be Implemented)
**Location:** `test/widgets/`

**Priority Widgets:**
- Login/Signup screens
- Custom input components
- Dashboard stats cards

### Integration Tests (To Be Implemented)
**Location:** `test/integration/`

**Test Scenarios:**
- Complete signup → login → scan → add to budget flow
- Offline mode functionality
- Currency conversion across multiple budgets

---

## 🚨 Known Issues & Limitations

### Critical Issues ⚠️

1. **VLM Model Missing**
   - Location: `assets/models/vacshop_vlm.tflite`
   - Status: Awaiting trained model from ML team
   - Impact: Price scanning not functional
   - Workaround: App works in degraded mode (manual entry)

2. **Firebase Configuration Required**
   - Missing: `google-services.json` (Android)
   - Missing: `GoogleService-Info.plist` (iOS)
   - Impact: Authentication won't work
   - Setup: See Firebase Console setup guide

3. **Missing Assets**
   - Inter font files (.ttf) - Referenced but not included
   - OAuth icons (Google/Facebook SVG)
   - App logo/branding images

### Non-Critical Issues

4. **Riverpod Providers Not Implemented**
   - State management architecture ready
   - Providers need to be created
   - Impact: Manual service instantiation required

5. **Limited Error Localization**
   - Error messages in French only
   - No i18n/l10n implementation yet

6. **No Unit Tests**
   - Test structure ready
   - Tests need to be written

---

## 🔐 Security Considerations

### Implemented Security Measures

1. **Credential Storage**
   - Using `flutter_secure_storage`
   - AES-256 encryption
   - Platform keychain integration (iOS) / KeyStore (Android)

2. **Firebase Authentication**
   - SSL/TLS encrypted communications
   - OAuth 2.0 for social logins
   - Secure token management

3. **Local Database**
   - Isar database encrypted at app level
   - No sensitive data in plain text
   - User data isolated per app installation

4. **Input Validation**
   - Email regex validation
   - Password strength requirements (min 8 chars)
   - Input sanitization

### Security Best Practices for AI Assistants

**DO:**
- Always validate user input before database operations
- Use parameterized queries (Isar handles this)
- Keep Firebase credentials in secure environment variables
- Implement proper error handling without exposing sensitive details

**DON'T:**
- Never commit Firebase config files to git
- Never log sensitive user data (passwords, tokens)
- Avoid storing API keys in code
- Don't bypass authentication checks

---

## 📝 Coding Conventions

### File Naming
- **Files:** `snake_case.dart` (e.g., `database_service.dart`)
- **Classes:** `PascalCase` (e.g., `DatabaseService`)
- **Variables:** `camelCase` (e.g., `currentUser`)
- **Constants:** `camelCase` with `static const` (e.g., `appName`)

### Code Organization

**Imports Order:**
1. Dart SDK imports
2. Flutter imports
3. Package imports
4. Relative imports

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../models/user.dart';
```

**Class Structure:**
1. Static/constant fields
2. Instance fields
3. Constructors
4. Public methods
5. Private methods
6. Getters/setters

### Documentation
- Use `///` for public API documentation
- Use `//` for inline comments
- Document all public methods with parameters and return values
- Add `@Deprecated` for deprecated APIs

**Example:**
```dart
/// Converts amount from one currency to another.
///
/// Parameters:
/// - [amount]: The amount to convert
/// - [from]: Source currency code (e.g., 'USD')
/// - [to]: Target currency code (e.g., 'CAD')
///
/// Returns the converted amount as a double.
///
/// Throws [CurrencyNotFoundException] if currency not supported.
Future<double> convert(double amount, String from, String to) async {
  // Implementation
}
```

### State Management Patterns

**Current:** Direct service calls
```dart
final user = await AuthService().signIn(email, password);
```

**Future (with Riverpod):**
```dart
final user = ref.watch(authProvider);
```

### Error Handling

**Pattern:**
```dart
try {
  // Operation
  final result = await riskyOperation();
  return result;
} catch (e) {
  print('❌ Error in operation: $e');
  throw Exception('User-friendly message');
}
```

**Logging Conventions:**
- ✅ Success: Green checkmark
- ⚠️ Warning: Warning symbol
- ❌ Error: Red X
- ⚡ Performance: Lightning bolt

---

## 🎯 Performance Targets

### App Performance
- **Launch Time:** < 2 seconds
- **VLM Inference:** < 1.5 seconds
- **Database Queries:** < 100ms (indexed)
- **UI Rendering:** 60 FPS smooth

### App Size
- **Target APK Size:** < 50 MB (with VLM model)
- **Isar Database:** < 10 MB (1000 scans)
- **RAM Usage:** < 200 MB

### Optimization Tips for AI Assistants

1. **Database:**
   - Use `@Index()` on frequently queried fields
   - Batch operations when possible
   - Lazy load large lists

2. **Images:**
   - Compress images before storage
   - Use cached_network_image for remote images
   - Resize images before VLM inference

3. **State Management:**
   - Use Riverpod providers for global state
   - Minimize widget rebuilds
   - Implement `const` constructors where possible

---

## 🚀 Next Steps (Priority Order)

### Phase 1: Critical (Required for MVP) 🔴
**Estimated: 2-3 days**

1. **VLM Integration**
   - Receive trained .tflite model
   - Adapt preprocessing/postprocessing
   - Test on real images
   - Validate performance

2. **Firebase Configuration**
   - Set up Firebase project
   - Add google-services.json
   - Configure OAuth providers
   - Test authentication flow

3. **Missing Assets**
   - Add Inter font files
   - Add OAuth provider icons
   - Add app logo

### Phase 2: Important (Enhanced Functionality) 🟡
**Estimated: 3-5 days**

4. **Additional Screens**
   - ScanResultScreen - Display detected price
   - ArticleDetailsScreen - Add/edit article form
   - HistoryScreen - Filterable transaction list
   - BudgetManagementScreen - CRUD for budgets
   - CurrencySelectionScreen - Multi-currency picker

5. **Riverpod Providers**
   - AuthProvider - User state
   - BudgetProvider - Budget state
   - ArticleProvider - Article state
   - CurrencyProvider - Currency state
   - ScanProvider - Scan state

### Phase 3: Nice to Have (Polish) 🟢
**Estimated: 2-3 days**

6. **Testing**
   - Unit tests for services
   - Widget tests for screens
   - Integration tests
   - E2E test scenarios

7. **UI Enhancements**
   - Dark mode support
   - Advanced animations
   - Accessibility improvements
   - Localization (i18n)

**Total MVP Time:** 7-12 days

---

## 🤖 AI Assistant Guidelines

### When Working on This Project

1. **Always Read Documentation First**
   - Check README.md for project overview
   - Check INTEGRATION_VLM.md for VLM specifics
   - Check this file (CLAUDE.md) for conventions

2. **Before Making Changes**
   - Understand the existing architecture
   - Follow established patterns
   - Maintain code consistency
   - Update documentation if needed

3. **Service Integration**
   - Services are singletons (use `.instance`)
   - Always initialize services before use
   - Handle errors gracefully
   - Log operations for debugging

4. **Database Operations**
   - Always use DatabaseService, never direct Isar calls
   - Use transactions for multiple related operations
   - Validate data before insertion
   - Handle null values properly

5. **UI Development**
   - Follow the design system colors/typography
   - Use existing widgets when possible
   - Maintain responsive design
   - Handle loading and error states

6. **State Management**
   - Currently: Direct service calls
   - Future: Migrate to Riverpod providers
   - Keep UI logic separate from business logic

7. **Testing**
   - Write tests for new services
   - Test edge cases
   - Mock external dependencies
   - Validate error handling

### Common Tasks Reference

#### Adding a New Screen
```dart
// 1. Create file: lib/screens/feature/new_screen.dart
import 'package:flutter/material.dart';

class NewScreen extends StatelessWidget {
  const NewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Title')),
      body: Container(),
    );
  }
}

// 2. Add route in lib/config/constants.dart
static const String routeNewScreen = '/new-screen';

// 3. Register route in lib/main.dart
'/new-screen': (context) => const NewScreen(),
```

#### Adding a New Service Method
```dart
// 1. Add to appropriate service
Future<Result> newOperation() async {
  try {
    // Validate input
    // Perform operation
    // Return result
  } catch (e) {
    print('❌ Error in newOperation: $e');
    throw Exception('User message');
  }
}

// 2. Document the method
/// Brief description
///
/// Parameters: ...
/// Returns: ...
/// Throws: ...

// 3. Write unit test
test('newOperation success case', () async {
  // Arrange
  // Act
  // Assert
});
```

#### Adding Currency Support
```dart
// Update: assets/data/exchange_rates.json
{
  "rates": {
    "NEW": 1.234  // Add new currency rate
  }
}

// No code changes needed - CurrencyService loads dynamically
```

### Debugging Tips

1. **VLM Issues:**
   - Check model file exists: `assets/models/vacshop_vlm.tflite`
   - Verify input shape matches model expectations
   - Check inference timeout (5s default)
   - Validate image preprocessing

2. **Database Issues:**
   - Run `flutter pub run build_runner build` after model changes
   - Check Isar inspector: `flutter pub run isar:inspect`
   - Verify indexes on queried fields

3. **Authentication Issues:**
   - Verify Firebase configuration
   - Check OAuth provider setup
   - Test offline mode separately
   - Validate secure storage permissions

4. **Currency Issues:**
   - Verify exchange_rates.json is valid JSON
   - Check currency codes are uppercase 3-letter ISO
   - Validate rate values are positive numbers

---

## 📚 Additional Resources

### Documentation Files
- **README.md** - Complete project documentation
- **QUICKSTART.md** - 5-minute quick start guide
- **INTEGRATION_VLM.md** - Detailed VLM integration guide
- **DELIVERABLE.md** - Project status and deliverables
- **PROJECT_SUMMARY.txt** - Visual project summary

### External Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Isar Documentation](https://isar.dev)
- [TFLite Flutter](https://pub.dev/packages/tflite_flutter)
- [Firebase Auth](https://firebase.google.com/docs/auth)

### Key File Locations
- **App Entry:** `lib/main.dart`
- **Constants:** `lib/config/constants.dart`
- **Theme:** `lib/config/theme.dart`
- **Services:** `lib/services/`
- **Models:** `lib/models/`
- **Screens:** `lib/screens/`
- **Exchange Rates:** `assets/data/exchange_rates.json`

---

## 🎓 Project Context

### Business Model
VacShop helps travelers manage their budget while traveling by:
1. Scanning price tags with camera
2. Detecting price and currency using VLM
3. Converting to traveler's home currency
4. Tracking expenses against budget
5. Providing statistics and insights

### Unique Value Proposition
- **100% Offline:** No internet required after initial setup
- **On-device ML:** Privacy-first, VLM runs locally
- **Multi-currency:** Supports 35+ currencies
- **Real-time:** Instant price detection and conversion
- **Budget-focused:** Track spending against trip budgets

### Target Users
- International travelers
- Budget-conscious tourists
- Business travelers
- Digital nomads
- Students studying abroad

### Patentable Aspects
1. Embedded offline VLM architecture (vs cloud OCR)
2. Model compression/quantization for mobile
3. Intelligent exchange rate caching system
4. Optimized preprocessing for multi-currency detection
5. Contextual management (photos → structured data)

---

## 🏆 Code Quality Standards

### Before Committing Code

**Checklist:**
- [ ] Code follows naming conventions
- [ ] All imports organized properly
- [ ] No unused imports or variables
- [ ] Error handling implemented
- [ ] Logging added for debugging
- [ ] Documentation updated
- [ ] No hardcoded values (use constants)
- [ ] Input validation added
- [ ] Code formatted (`dart format lib/`)
- [ ] No analyzer warnings (`flutter analyze`)

### Pull Request Guidelines

**PR Title Format:**
```
feat: Add user profile screen
fix: Resolve currency conversion bug
docs: Update CLAUDE.md with testing section
refactor: Improve VLM preprocessing
```

**PR Description Should Include:**
- What changed and why
- Testing performed
- Screenshots (for UI changes)
- Related issues/docs
- Breaking changes (if any)

---

## 📞 Contact & Support

### Project Team
- **Lead Developer:** Olivier Bertsrand
- **Company:** DaVinci Nova Corp
- **Funding:** CNRC (National Research Council of Canada)

### For AI Assistants
- **Questions about VLM:** See `INTEGRATION_VLM.md`
- **General questions:** See `README.md`
- **Quick start:** See `QUICKSTART.md`
- **Project status:** See `DELIVERABLE.md`

### Getting Help
1. Check existing documentation first
2. Search codebase for similar implementations
3. Review service architecture
4. Check error logs
5. Consult Flutter/package documentation

---

## 📊 Project Metrics

### Current Completion Status
- **Architecture:** 100% ✅
- **Authentication:** 100% ✅
- **Database:** 100% ✅
- **Currency Service:** 100% ✅
- **VLM Service:** 80% ⚠️ (awaiting model)
- **UI/UX:** 80% ⚠️ (8/13 screens)
- **Providers:** 0% ⏳
- **Tests:** 0% ⏳

### Overall Progress: 80% Complete

**Next Milestone:** Integrate VLM model and complete remaining screens for MVP release.

---

**Last Updated:** 2024-11-30
**Document Version:** 1.0
**Maintained by:** AI Assistant (Claude)

*This document serves as the primary reference for AI assistants working on the VacShop project. Keep it updated as the project evolves.*
