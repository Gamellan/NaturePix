# NaturePix - Release and AdMob checklist

## Pending when Google account is verified
1. Create Google Play app with package com.yourname.naturepix.
2. Create AdMob app and 3 IDs (App, Banner, Interstitial).
3. Replace IDs in:
   - lib/core/constants/app_constants.dart
   - android/app/src/main/AndroidManifest.xml
4. Configure keystore and android/key.properties.
5. Build internal test release and validate ads + wallpaper flow.

## Unsplash config
- Access key is in lib/constants.dart
- UTM source: nature_pix
- UTM medium: referral


