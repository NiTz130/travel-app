# Firebase Emulator

Local recovery project id: `travel-app-v2-dev`.

Start the emulators from the repository root:

```powershell
firebase emulators:start --project travel-app-v2-dev
```

In another terminal, seed Firestore:

```powershell
powershell -ExecutionPolicy Bypass -File tool\seed_firestore_emulator.ps1
```

Ports:

- Auth: `9099`
- Firestore: `8080`
- Realtime Database: `9000`
- Emulator UI: `4000`

Android emulator apps reach the host machine at `10.0.2.2`. For a physical Android device, use the development machine's LAN IP address instead and pass it to `configureFirebaseEmulators(host: '<LAN-IP>')` during a device-specific setup.
