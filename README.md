# 💰 Expenser

A comprehensive Flutter expense tracking application with recurring expenses, notifications, analytics, and advanced search capabilities.

## ✨ Features

### Core Expense Management

- ✅ Create, edit, and delete expenses
- ✅ Organize by categories and companies
- ✅ Attach photos and PDF receipts (up to 10 per expense)
- ✅ Smart autocomplete with historical data
- ✅ Monthly expense listing with totals

### Categories & Companies

- ✅ CRUD operations for categories
- ✅ 36 predefined icons and 16 colors
- ✅ CRUD operations for companies
- ✅ Companies linked to categories
- ✅ Active/inactive status toggle

### Analytics & Visualization

- ✅ Monthly view with bar charts by category
- ✅ Annual view with line charts showing evolution
- ✅ Summary cards (total, daily average, highest expense)
- ✅ Detailed breakdowns with percentages
- ✅ Interactive charts with tooltips

### Advanced Search

- ✅ Text search in names and notes
- ✅ Filter by category
- ✅ Filter by company
- ✅ Filter by date range
- ✅ Combine multiple filters
- ✅ Results summary with totals

### Recurring Expenses (🌟 Key Feature)

- ✅ Set up recurring expenses with frequencies:
  - Monthly (specific day of month)
  - Bi-monthly (every 2 months)
  - Weekly (specific day of week)
  - Annual
  - Custom (every N days)
- ✅ Automatic notification 1 day after expected date
- ✅ Confirm or skip payments from notifications
- ✅ Re-notification system (up to 3 attempts)
- ✅ Automatic instance generation (maintains 3 future instances)
- ✅ Management screen with history and statistics
- ✅ Daily background service (9:00 AM)

## 🛠️ Technologies

- **Framework:** Flutter 3.x
- **Language:** Dart
- **State Management:** flutter_bloc (BLoC pattern)
- **Database:** SQLite (sqflite)
- **Charts:** fl_chart
- **Notifications:** flutter_local_notifications
- **Background Tasks:** android_alarm_manager_plus
- **Localization:** Spanish (es_ES)

## 📱 Requirements

- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0
- Android: minSdkVersion 21 (Android 5.0+)
- Android 12+: Exact alarm permissions required
- Android 13+: Notification permissions required

## 🚀 Installation

1. **Clone the repository**

```bash
git clone https://github.com/judev-jbg/expense_manager
cd expense_manager
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run the app**

```bash
flutter run
```

## 📂 Project Structurelib/

```
├── core/
│ └── database/
│ └── database_helper.dart # SQLite database management
├── data/
│ ├── models/ # Data models
│ │ ├── gasto_model.dart
│ │ ├── categoria_model.dart
│ │ ├── empresa_model.dart
│ │ ├── configuracion_recurrencia_model.dart
│ │ └── instancia_recurrente_model.dart
│ └── repositories/ # Repository implementations
├── domain/
│ ├── repositories/ # Repository interfaces
│ └── services/ # Business logic services
│ ├── notification_service.dart
│ ├── generador_instancias_service.dart
│ └── recurrentes_background_service.dart
└── presentation/
├── bloc/ # BLoC state management
│ ├── gastos/
│ ├── categorias/
│ └── empresas/
└── screens/ # UI screens
├── home/
├── agregar_gasto/
├── configuracion/
├── analisis/
├── busqueda/
├── recurrentes/
└── test/
```

## 🏗️ Architecture

The app follows **Clean Architecture** principles with:

- **Presentation Layer:** UI (Widgets) + State Management (BLoC)
- **Domain Layer:** Business logic, use cases, repository interfaces
- **Data Layer:** Repository implementations, data sources, models

### Key Patterns

- **BLoC Pattern:** For state management
- **Repository Pattern:** Data abstraction
- **Singleton Pattern:** For services (Notifications, Database)

## 🎯 How to Use

### 1. Basic Expense Management

1. Tap **+** button on home screen
2. Fill in: name, amount, date, category, company (optional)
3. Add notes and attachments if needed
4. Save

### 2. Set Up Recurring Expense

1. Create a new expense
2. Toggle **"Is this a recurring expense?"**
3. Select frequency (monthly, weekly, etc.)
4. Configure specifics (day of month, day of week, etc.)
5. Save

The system will:

- Generate 3 future instances automatically
- Send notification 1 day after expected date
- Allow you to confirm or skip from notification
- Re-notify up to 3 times if not processed
- Automatically generate new instances

### 3. View Analytics

1. Tap **"Analytics"** in bottom navigation
2. **Monthly:** View bar chart by category
3. **Annual:** View line chart of monthly totals
4. Pull down to refresh

### 4. Search & Filter

1. Tap **search icon** in home screen
2. Type text to search names/notes
3. Apply filters (category, company, dates)
4. Combine multiple filters

### 5. Manage Recurring Expenses

1. Tap **"Recurrentes"** in bottom navigation
2. View active or all recurring expenses
3. Toggle active/inactive status
4. Tap card to view history and statistics
5. Delete if no longer needed

## 🔔 Notifications Setup

### Android 12+

The app requires **exact alarm permissions** to schedule notifications accurately.

**To grant permission:**

1. Go to Settings → Apps → Expense Manager
2. Find "Alarms & reminders" or "Set alarms and timers"
3. Enable the permission

### Android 13+

Also requires **notification permissions** which will be requested automatically.

## 📊 Database Schema

### Tables

- **categorias:** Categories with icons and colors
- **empresas:** Companies linked to categories
- **gastos:** Individual expenses
- **adjuntos:** Attachments (photos/PDFs) for expenses
- **configuraciones_recurrencia:** Recurring expense configurations
- **instancias_recurrentes:** Individual instances of recurring expenses

## 🔮 Future Enhancements

- [ ] Cloud backup and sync
- [ ] Export to CSV/PDF
- [ ] Budget limits and alerts
- [ ] Multi-currency support
- [ ] Tags/labels for expenses
- [ ] Shared expenses (family mode)
- [ ] iOS support
- [ ] Dark mode
- [ ] Expense templates
- [ ] Bill splitting

## 🐛 Known Issues

- None currently reported

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Developer

Developed with ❤️ using Flutter

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

For questions or support, please open an issue in the repository.

---

**Last Updated:** November 2025
**Version:** 1.0.0
