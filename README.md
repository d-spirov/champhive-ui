# TeamHive

Sport club management app (Flutter) — iOS, Android, and web.

Architecture mirrors [ParkHive](../parking/park_hive): feature-first UI + Riverpod + go_router + Dio.

## Backend

- API: https://api.champhive.app  
- Docs: https://api.champhive.app/scalar/v1  
- OpenAPI: https://api.champhive.app/openapi/v1.json  
- Auth: Bearer JWT access token + rotating refresh (`client: "mobile"`)

### Live app flows (ClubPlatform)
1. Login → `GET /me` → clubs from grants  
2. Calendar / home → club **schedule occurrences**  
3. Session detail → open/locked from **roster-snapshot**  
4. Take attendance → mark roster → **POST /attendance/batch**  
5. Report → `GET /occurrences/{id}/attendance`  
6. Members → `GET /clubs/{id}/members` (+ photo)

## App icon

ParkHive-style vector hexagon + H. Regenerate:

```bash
dart run tools/generate_app_icon.dart
dart run tools/add_icon_padding.dart
dart run flutter_launcher_icons
```

## Run

```bash
flutter pub get
flutter gen-l10n
flutter run                 # device / simulator
flutter run -d chrome       # web
```

## Structure

```
lib/
├── main.dart
├── app.dart                 # GoRouter + MaterialApp.router
├── l10n/
├── features/
│   ├── auth/                # splash, login, register, session
│   ├── clubs/               # home (my clubs) + club hub
│   ├── teams/               # (scaffold)
│   ├── players/             # (scaffold)
│   ├── events/              # (scaffold)
│   └── attendance/          # (scaffold)
└── shared/
    ├── models/
    ├── services/            # AuthApi, ClubsApi, Dio helpers
    ├── theme/
    ├── utils/
    └── widgets/
```

## UI

ChampHive-inspired screens with:
- **Light theme** — white + green accent
- **Dark theme** — navy + gold accent (switch in More → Appearance)

Bottom nav: Home · Calendar · Teams · Messages · More

Tap **Explore demo UI** on the login screen to browse with sample data (no backend required).
