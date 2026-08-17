# TeamHive

Sport club management app (Flutter) — iOS, Android, and web.

Architecture mirrors [ParkHive](../parking/park_hive): feature-first UI + Riverpod + go_router + Dio.

## Backend

- API: https://api.champhive.app  
- Docs: https://api.champhive.app/scalar/v1  
- OpenAPI: https://api.champhive.app/openapi/v1.json  
- Auth: Bearer JWT access token + rotating refresh (`client: "mobile"`)

### Wired today
- Login / register / logout / session restore (`POST /api/v1/auth/*`, `GET /api/v1/me`)
- Home → clubs from `/me` grants + `GET /api/v1/clubs/{id}`
- Members (`/clubs/{id}/members`), schedule occurrences, attendance batch

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
