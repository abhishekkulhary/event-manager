# Event Manager

An offline app for organising large family events, from one Flutter codebase
for Android, iOS, macOS, Windows, Linux and the web.

- **Guests** — guest lists by category, place and relation, with how many people
  each invitation covers and whether the invitation card has been delivered;
  live totals per category.
- **Money** — a ledger of gifts and expenses with a payment status for every item.
- **CSV import and export** for both, so lists can be prepared in a spreadsheet.

All data is stored locally in SQLite: `sqflite` on Android, iOS and macOS, its
FFI build on Windows and Linux, and a WASM build in the browser
([`lib/db/configure_database.dart`](lib/db/configure_database.dart)).

## Sample data

A fresh install is seeded with **fictional** guests
([`lib/data/sample_guests.dart`](lib/data/sample_guests.dart)) so the app and the
public web demo show how it works. Real guest lists are personal data and are
not part of this repository: keep them out of git (the `private/` folder is
ignored) and load them with **Import CSV** on the guest list screen.

CSV columns: `ID, Name, Place, Relation, Number, Category, Status`
(Status is `Done` or `Not Done`). Export a list first to get a template.

## Running

```bash
flutter pub get
flutter run -d chrome     # or macos, windows, linux, an Android device…
flutter analyze && flutter test
```

The browser build needs `web/sqlite3.wasm` and `web/sqflite_sw.js`; after
upgrading the sqflite packages refresh them with
`dart run sqflite_common_ffi_web:setup --force`.

## Builds, releases and downloads

GitHub Actions builds every platform from this repository:

- **Web** — [`.github/workflows/deploy-web.yml`](.github/workflows/deploy-web.yml) runs on every push to `main` (analyze → test → `flutter build web`) and publishes to GitHub Pages at `https://abhishekkulhary.github.io/event-manager/`. One-time setup: *Settings → Pages → Source: GitHub Actions*.
- **Native apps** — [`.github/workflows/release.yml`](.github/workflows/release.yml) runs when a version tag is pushed and attaches the builds to a GitHub Release:

  ```bash
  git tag v1.0.0
  git push origin v1.0.0
  ```

  | Asset | Notes |
  | --- | --- |
  | `event-manager-android.apk` | Signed with your release key when the `ANDROID_*` secrets are set (below); otherwise a throwaway debug key. |
  | `event-manager-windows-x64.zip` | Includes the MSVC runtime DLLs. |
  | `event-manager-macos.dmg` | Universal, ad-hoc signed: allow it under *System Settings → Privacy & Security* on first launch. |
  | `event-manager-linux-x64.tar.gz` | Built on Ubuntu 24.04. |

  iOS is not distributed: installing outside the App Store needs an Apple developer account.

The web build has a **Get the app** button (hidden in the native apps) that lists these downloads from the latest release via the GitHub API ([`lib/features/get_the_app/`](lib/features/get_the_app/)).

### Android signing

Android only installs an update over an existing app when both are signed with the same key. Create one key per app, keep it outside the repository, and never commit it (`*.jks`, `*.keystore` and `key.properties` are git-ignored).

```bash
keytool -genkeypair -v -keystore ~/event-manager-release.jks -storetype PKCS12 \
  -keyalg RSA -keysize 4096 -validity 10000 -alias event-manager
base64 -i ~/event-manager-release.jks | pbcopy   # macOS; Linux: base64 -w0 …
```

Add four repository secrets under *Settings → Secrets and variables → Actions*: `ANDROID_KEYSTORE_BASE64` (the base64 text), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`event-manager`) and `ANDROID_KEY_PASSWORD` (same password for PKCS12). Set all four or none.

To sign local release builds too, create `android/key.properties` with `storeFile`, `storePassword`, `keyAlias` and `keyPassword`.
