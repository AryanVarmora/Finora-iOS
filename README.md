# 📱 Finora – Smart Expense Tracker (iOS)

**Smarter spending. Brighter future.**

Finora is a modern and intelligent iOS expense tracking application built with SwiftUI, Core Data, and REST API integration. It empowers users to take control of their finances by tracking daily expenses, visualizing spending patterns, converting currencies in real-time, and managing financial habits efficiently.

---

## ✨ Features

### 🔹 Expense Management (CRUD)
- Add, edit, and delete expenses with ease
- Assign categories (Food, Travel, Shopping, Utilities, Entertainment, etc.)
- Filter expenses by date, keyword, or category
- Local offline storage using Core Data
- Add notes and receipts to expenses

### 🔹 Multi-Currency Support
- Real-time currency exchange rates via REST API
- Enter expenses in any currency
- Auto-convert to your base currency
- Track spending across multiple currencies

### 🔹 Analytics & Visualization
- Clean, interactive charts (Pie & Bar charts)
- Weekly and monthly spending summaries
- Category-based visual spending insights
- Identify spending trends over time

### 🔹 Authentication & Sync
- JWT-based authentication (LAMP backend)
- Sign in with Apple (alternative option)
- Optional cloud sync for cross-device access
- Secure data encryption

### 🔹 Modern UI/UX
- Beautiful SwiftUI interface with smooth animations
- Full support for light and dark mode
- Real-time UI updates with MVVM architecture
- Optimized for all iPhone screen sizes

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Language** | Swift 5 |
| **UI Framework** | SwiftUI (MVVM Architecture) |
| **Local Storage** | Core Data |
| **Networking** | URLSession + JSON REST APIs |
| **Backend** | LAMP Stack (Linux + Apache + MySQL + PHP) *(Optional)* |
| **Authentication** | JWT (JSON Web Token) |
| **Charts** | Swift Charts Framework |
| **IDE** | Xcode 15+ |

---

## 📁 Project Structure
```
Finora-iOS/
│
├── Models/
│   ├── Expense.swift
│   ├── ExpenseCategory.swift
│   └── CurrencyRate.swift
│
├── ViewModels/
│   └── ExpenseViewModel.swift
│
├── Views/
│   ├── DashboardView.swift
│   ├── AddExpenseView.swift
│   ├── ExpenseListView.swift
│   ├── AnalyticsView.swift
│   └── AuthenticationView.swift
│
├── Networking/
│   ├── CurrencyAPIService.swift
│   └── AuthService.swift
│
├── CoreData/
│   └── FinoraModel.xcdatamodeld
│
├── Assets.xcassets/
│   └── FinoraLogo.appiconset
│
├── Resources/
│   └── LaunchScreen.storyboard
│
└── README.md
```

---

## 🚀 Installation & Setup

### Prerequisites
- macOS 13.0 or later
- Xcode 15.0 or later
- iOS 15.0+ device or simulator

### 1. Clone the Repository
```bash
git clone https://github.com/<your-username>/Finora-iOS.git
cd Finora-iOS
```

### 2. Open in Xcode
```bash
open Finora.xcodeproj
```

### 3. Install Dependencies (if any)

If using CocoaPods:
```bash
pod install
open Finora.xcworkspace
```

### 4. Configure API Keys

Update the currency API endpoint in:
```swift
Networking/CurrencyAPIService.swift
```

### 5. Run the App

- Select your target device or simulator (e.g., iPhone 15 Pro)
- Press `⌘ + R` to build and run

---

## 🌍 API Configuration

### Currency Exchange API

Finora uses a free currency exchange API for real-time rates. Supported options:

- **ExchangeRate-API**: `https://api.exchangerate-api.com/v4/latest/USD`
- **Exchangerate.host**: `https://api.exchangerate.host/latest`
- **Fixer.io**: `https://api.fixer.io/latest` *(requires API key)*

Configure your preferred API in `Networking/CurrencyAPIService.swift`:
```swift
private let baseURL = "https://api.exchangerate.host/latest"
```

---

## 🔐 Backend Setup (Optional)

If you want to enable cloud sync and authentication, set up the LAMP backend:

### Backend Endpoints

- `POST /api/register.php` - User registration
- `POST /api/login.php` - User authentication (returns JWT)
- `GET /api/expenses.php` - Fetch user expenses
- `POST /api/syncExpenses.php` - Sync local expenses to cloud

### Configuration

1. Set up MySQL database with the provided schema
2. Configure JWT secret key in `config.php`
3. Enable CORS if accessing from different domains
4. Update backend URL in `AuthService.swift`

### Database Schema
```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE expenses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    amount DECIMAL(10,2),
    currency VARCHAR(3),
    category VARCHAR(50),
    description TEXT,
    date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

---

## 🧪 Testing

Finora includes comprehensive test coverage:

- Unit tests for ViewModels
- UI tests for critical user flows
- API response handling tests
- Core Data persistence tests
- Currency conversion logic tests

### Run Tests
```bash
# Run all tests
⌘ + U
```

---

## 📸 Screenshots

| Dashboard | Add Expense | Analytics |
|-----------|-------------|-----------|
| *Coming Soon* | *Coming Soon* | *Coming Soon* |

---

## 🗺️ Roadmap

- [ ] Widget support for iOS home screen
- [ ] Budget tracking and alerts
- [ ] Receipt scanning with OCR
- [ ] Export to CSV/PDF
- [ ] Recurring expense automation
- [ ] Multi-user family accounts
- [ ] Apple Watch companion app
- [ ] Siri shortcuts integration

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👥 Contributors

- **Aryan Varmora** - Lead Developer
- **Akash Yadav** - Backend & API Integration

---

## 📄 License

This project is licensed under the MIT License.
```
MIT License

Copyright (c) 2025 Finora Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Acknowledgments

- Currency exchange data provided by ExchangeRate-API
- Built with ❤️ using SwiftUI

---

## 📧 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/<your-username>/Finora-iOS/issues)
- **Email**: support@finora.app

---

## ⭐ Show Your Support

If you find this project helpful, please consider giving it a ⭐ on GitHub!

---

Made with ❤️ by the Finora Team
