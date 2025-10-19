# 📱 PHASE 1: AUTH MODULE - MANUAL TEST GUIDE

**Status**: 🟡 IN PROGRESS  
**Started**: 2025-01-07 17:30  
**App Status**: ✅ Running on emulator-5554

---

## ✅ COMPLETED TEST CASES

### TC-AUTH-006: Auto-Login ✅ PASS
**Test**: Session persistence after app restart  
**Result**: PASS ✅  
**Evidence**: Test user automatically logged in via session token  
**Firebase**: Auth token persisted correctly  
**Notes**: Perfect auto-login functionality

---

## 📋 REMAINING TEST CASES

### TC-AUTH-001: Login with Valid Credentials
**Priority**: HIGH  
**Prerequisites**: User must be logged out

**Steps**:
1. Open app (currently logged in)
2. Navigate to Profile/Settings
3. Click "Logout" button
4. Verify redirect to Login screen
5. Enter valid credentials:
   - Email: [existing test email]
   - Password: [existing test password]
6. Click "Login" button
7. Verify loading state appears
8. Verify redirect to Home screen
9. Verify user data loads correctly

**Expected Result**:
- ✅ Loading indicator shows
- ✅ No errors displayed
- ✅ Redirect to home page
- ✅ User data displayed
- ✅ Firebase Auth token saved

**Firebase Verification**:
```
Check logs for:
- D/FirebaseAuth: Notifying id token listeners about user
- User ID logged
```

---

### TC-AUTH-002: Login with Invalid Credentials
**Priority**: HIGH  
**Prerequisites**: User must be logged out

**Steps**:
1. Navigate to Login screen
2. Enter invalid credentials:
   - Email: "wrong@example.com"
   - Password: "wrongpassword123"
3. Click "Login" button
4. Verify error message appears
5. Verify user stays on login screen

**Expected Result**:
- ✅ Error message: "Invalid email or password"
- ✅ No navigation occurs
- ✅ User can retry login
- ✅ Error clears on new input

**Error Handling Check**:
- SnackBar/Toast appears
- Error message is user-friendly
- Duration: 2-3 seconds
- Color: Red/Error theme

---

### TC-AUTH-003: Register New User
**Priority**: HIGH  
**Prerequisites**: Use new email address

**Steps**:
1. On Login screen, click "Register" / "Sign Up"
2. Verify navigation to Registration screen
3. Fill in registration form:
   - Display Name: "Test User"
   - Email: "newuser@example.com"
   - Password: "SecurePass123!"
   - Confirm Password: "SecurePass123!"
4. Click "Register" button
5. Verify loading state
6. Verify account created
7. Verify auto-login occurs
8. Verify redirect to Home/Onboarding

**Expected Result**:
- ✅ Form validation works (all fields required)
- ✅ Password strength indicator (if exists)
- ✅ Account created in Firebase
- ✅ User automatically logged in
- ✅ Firestore user document created
- ✅ Welcome message/onboarding shown

**Firebase Verification**:
```
Check:
1. Firebase Auth console - new user appears
2. Firestore users collection - new document
3. User profile data saved correctly
```

---

### TC-AUTH-004: Password Reset Flow
**Priority**: HIGH  
**Prerequisites**: Valid registered email

**Steps**:
1. On Login screen, click "Forgot Password?"
2. Verify navigation to Reset Password screen
3. Enter email: [test email]
4. Click "Send Reset Email" button
5. Verify success message appears
6. Check email inbox (or Firebase logs)
7. Verify reset email sent

**Expected Result**:
- ✅ Email field validated
- ✅ Success message: "Reset email sent"
- ✅ User can navigate back to login
- ✅ Firebase password reset email sent

**Email Verification**:
```
Check Firebase logs:
- Password reset email queued
- Email sent successfully
```

---

### TC-AUTH-005: Google Sign-In
**Priority**: MEDIUM  
**Prerequisites**: Google Play Services on emulator

**Steps**:
1. On Login screen, click "Sign in with Google" button
2. Verify Google account picker appears
3. Select test Google account
4. Verify permissions screen (if first time)
5. Accept permissions
6. Verify loading state
7. Verify successful sign-in
8. Verify redirect to Home screen

**Expected Result**:
- ✅ Google OAuth flow initiates
- ✅ Account picker shows available accounts
- ✅ Sign-in succeeds
- ✅ User account created/linked
- ✅ Firestore user document created
- ✅ Auto-login on future launches

**Firebase Verification**:
```
Check:
1. Firebase Auth - provider: google.com
2. User displayName from Google account
3. photoURL populated
```

**Note**: May require Google Play Services setup on emulator

---

## 🐛 KNOWN ISSUES

### BUG-001: UI Overflow in Item Cards
- **Severity**: Minor (P3)
- **Impact**: Visual only, not blocking
- **Location**: modern_home_page.dart:539
- **Fix**: Scheduled for later

---

## 📊 SUCCESS CRITERIA

**Phase 1 Complete When**:
- ✅ TC-AUTH-006: Auto-login (DONE)
- [ ] TC-AUTH-001: Valid login
- [ ] TC-AUTH-002: Invalid login error handling
- [ ] TC-AUTH-003: Registration
- [ ] TC-AUTH-004: Password reset
- [ ] TC-AUTH-005: Google Sign-In

**Required**:
- All test cases executed
- Results documented in MODULE_TEST_RESULTS.md
- Bugs logged in BUG_TRACKER.md
- DAILY_TESTING_LOG.md updated
- Git commit created

---

## 🎯 NEXT ACTIONS

### Immediate:
1. **Logout Current User**
   - Navigate to Profile → Settings → Logout
   - Or use Firebase Auth UI if available

2. **Execute TC-AUTH-001**
   - Follow steps above
   - Document results
   - Take screenshots if issues found

3. **Execute TC-AUTH-002**
   - Test error handling
   - Verify user experience

4. **Continue Through Remaining Tests**
   - One test at a time
   - Document each result
   - Fix critical bugs immediately

### After Testing:
1. Update MODULE_TEST_RESULTS.md with all results
2. Update DAILY_TESTING_LOG.md with timeline
3. Create summary in BUG_TRACKER.md
4. Git commit: `[TEST: Phase 1] Auth module testing complete`
5. Proceed to Phase 2: Home Feed & Items

---

## 📝 DOCUMENTATION UPDATES

**Update After Each Test**:
```markdown
MODULE_TEST_RESULTS.md:
- Change test status (⚪ → 🔄 → ✅/❌)
- Add notes column with observations
- Update bug count if issues found

DAILY_TESTING_LOG.md:
- Add timestamp entry for each test
- Log any bugs discovered
- Note performance observations

BUG_TRACKER.md:
- Create bug entry for any issues
- Priority: P0 (Critical) to P3 (Low)
- Include reproduction steps
```

---

## ⚠️ IMPORTANT NOTES

1. **Firebase Quota**: Testing uses real Firebase - monitor quotas
2. **Test Emails**: Use disposable/test emails for registration
3. **Clean State**: May need to reset emulator data between tests
4. **Screenshots**: Take screenshots of any errors
5. **Timing**: Document response times for performance metrics

---

**Last Updated**: 2025-01-07 17:35  
**Next Update**: After completing next test case  
**Tester**: Droid (Autonomous) + Manual verification
