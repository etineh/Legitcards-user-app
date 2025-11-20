
```bash
flutter clean
flutter pub get
```

```bash
rm -rf ios/Pods ios/Podfile.lock
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

#for playstore production
```bash
flutter build appbundle --release
```

#push to github. Prompt me a message to enter, then prompt a branch to push
```bash
./gitpush.sh
```

#Run on my iOS
```bash
flutter run -d 00008020-0009751A2E82002E
```