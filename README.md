# TeamHive

Sport club management app (Flutter) — iOS, Android, and web.

Architecture mirrors [ParkHive](../parking/park_hive): feature-first UI + Riverpod + go_router + Dio.

## Backend

- API: https://backend-production-785b.up.railway.app  
- Swagger: https://backend-production-785b.up.railway.app/swagger-ui/index.html  
- Auth: HttpOnly cookies (`champhive_at`, `champhive_rt`) + CSRF (`XSRF-TOKEN` → `X-XSRF-TOKEN`)

### Wired today
- Login / register / logout / session restore
- Home → **Your clubs** from `GET /api/v1/users/me/clubs`
- Club details from `GET /api/v1/clubs/{id}`

Use real credentials on the Log In form (iOS/Android). Web login may need same-site CORS later because CSRF cookie must be readable.

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
