# Profile Tests

This directory contains tests that verify the functionality of the simplified profile system in the dotfiles repository.

## Overview

The profile system has been simplified to use a flag-based approach instead of the previous YAML-based configuration. This makes the system easier to understand, maintain, and extend. Profiles now include:

1. Profile-specific Brewfiles (in `packages/Brewfile.{profile}`)
2. Profile-specific templates (in `config/templates/{profile}/`)
3. A simple `.current_profile` file to track the active profile

## Test Files

### test_profile_switch.sh

This comprehensive test script validates the entire profile system by:

1. **Profile Switching Tests**:
   - Reading and storing the current profile
   - Testing setting each available profile (personal, work, server)
   - Verifying that each profile can be set correctly
   - Restoring the original profile

2. **Directory Structure Validation**:
   - Checking that all profile template directories exist
   - Verifying template directories contain files
   - Confirming all Brewfiles exist for each profile
   - Validating Brewfiles have sufficient content

3. **Installation Script Integration**:
   - Verifying that install.sh supports the --profile flag
   - Confirming install.sh uses the .current_profile file
   - Validating profile handling in the installation process

## Running Tests

To run the profile tests:

```bash
./test_profile_switch.sh
```

The test is designed to be fast and efficient, avoiding the need to run the full installation script which would be time-consuming and require user interaction.

## Test Output

A successful test displays a comprehensive breakdown of all tests performed:

```
==============================================
       PROFILE SYSTEM TEST SUITE            
==============================================
This test validates the simplified profile system by:
1. Testing profile switching for all profiles
2. Verifying existence of all profile-specific files
3. Checking template directories and Brewfiles
4. Validating profile integrity
==============================================

[Info] Original profile: personal

==============================================
[Section 1] Testing profile switching
==============================================

[Testing] Setting profile to: personal
✅ Profile personal set successfully

[Testing] Setting profile to: work
✅ Profile work set successfully

[Testing] Setting profile to: server
✅ Profile server set successfully

✅ Restored original profile: personal
✅ Profile switching tests passed!

==============================================
[Section 2] Verifying directory structure
==============================================

[Testing] Template directories...
✅ Template directory for personal exists
   ✓ Template directory has 3 files/directories
✅ Template directory for work exists
   ✓ Template directory has 3 files/directories
✅ Template directory for server exists
   ✓ Template directory has 2 files/directories

[Testing] Brewfiles...
✅ Brewfile for personal exists
   ✓ Brewfile has 61 lines
✅ Brewfile for work exists
   ✓ Brewfile has 50 lines
✅ Brewfile for server exists
   ✓ Brewfile has 24 lines

==============================================
[Section 3] Validating install.sh profile flags
==============================================
✅ install.sh supports --profile flag
✅ install.sh uses .current_profile file

==============================================
        ALL PROFILE TESTS PASSED!            
==============================================
✅ Profile switching works correctly
✅ All profile-specific directories exist
✅ All profile-specific Brewfiles exist
✅ install.sh supports profile flags
✅ Original profile (personal) was restored
==============================================
```

## Adding New Profiles

When adding a new profile to the system:

1. Create a new Brewfile at `packages/Brewfile.[profile_name]`
2. Create a new template directory at `config/templates/[profile_name]/`
3. Add the profile to the `AVAILABLE_PROFILES` array in `test_profile_switch.sh`

## Troubleshooting

If tests fail, look for the specific error messages:

- **Missing templates** - Create the required template directory and add necessary configuration files
- **Missing Brewfile** - Create the required Brewfile with appropriate packages
- **Profile switching failure** - Check permissions on `.current_profile` file
- **Install.sh integration issues** - Verify that install.sh properly handles profiles
