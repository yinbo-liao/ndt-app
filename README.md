# NDT Management Mobile App

Non-Destructive Testing (NDT) Operations Management application built with Flutter.

## Features

- **Contractor Register**: Manage NDT certificates with validation status tracking and expiry alerts
- **Project Management**: Create and track NDT projects with location, client, and trade details
- **NDT Planning**: Schedule NDT tasks per project with priority and status tracking
- **Team Deployments**: Deploy NDT teams with day/night shift support, team member composition, and equipment tracking
- **Summaries & Charts**: Daily deployment summaries, shift comparison charts, weekly trends, and contractor compliance reports
- **Role-Based Access**: Admin, NDT Company, and NDT Team roles with row-level security

## Tech Stack

- **Frontend**: Flutter 3.x + Dart 3.12+
- **Backend**: Supabase (PostgreSQL + Auth + Realtime)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Charts**: fl_chart
- **Notifications**: flutter_local_notifications

## Getting Started

### Prerequisites
- Flutter SDK 3.12+
- A Supabase project (free tier at [supabase.com](https://supabase.com))
- Android Studio / Xcode for device builds

### Setup

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd ndt_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a project on [Supabase](https://supabase.com)
   - Copy your project URL and anon key
   - Update `lib/core/constants/supabase_config.dart` with your credentials
   - Run the SQL migration in `supabase/migrations/001_initial_schema.sql` in the Supabase SQL Editor

4. **Run the app**
   ```bash
   flutter run
   ```

### Project Structure

```
lib/
├── main.dart              # App entry point (Supabase init)
├── app.dart               # MaterialApp.router
├── core/                  # Constants, theme, router, services, utils
├── data/                  # Models, repositories, DTOs
├── features/              # Feature modules (auth, dashboard, contractor, etc.)
├── widgets/               # Reusable UI components
└── providers/             # Global Riverpod providers
```

### Supabase Database Setup

Run the migration file in the Supabase SQL Editor:
```
supabase/migrations/001_initial_schema.sql
```

This creates all tables, indexes, RLS policies, triggers, and summary functions.

## License

Proprietary — All rights reserved.
