# 🏆 SportsAlytics

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![MySQL](https://img.shields.io/badge/mysql-%2300f.svg?style=for-the-badge&logo=mysql&logoColor=white)
![Designer](https://img.shields.io/badge/Design-Quantum%20Arena-blueviolet?style=for-the-badge)

**SportsAlytics** is a professional-grade, data-driven sports management platform designed for elite performance analysis. It combines a state-of-the-art "Quantum Arena" aesthetic with a robust role-aware analytics engine to provide unprecedented insights into athlete performance across 9 major sports.

---

## ✨ Key Features

### 🌌 Designer Aesthetic
*   **Quantum Arena Background**: A global, animated background system with dynamic glowing orbs and a geometric mesh grid.
*   **Bespoke Branding**: Features a unique "SA" monogram logo designed for high-end tech organizations.
*   **Glassmorphic UI**: Premium transparency effects and neon-accented components across all modules.

### 🧠 Intelligent Analytics
*   **Role-Aware Engine**: Automatic classification of athlete roles (e.g., Bowler, Goalkeeper, Guard) using name and bio heuristics.
*   **Elite Performance Tracking**: Historically accurate international stats for global superstars (Kohli, Messi, Ronaldo, etc.).
*   **Vital Command Center**: Specialized biometric tracking for 9 sports (VO2 Max, G-Force, Stroke Frequency, etc.) using `fl_chart`.

### 🛡️ Strategic Management
*   **Team Formation**: Role-specific pitch nodes and filters for precise squad building.
*   **Fitness Thresholds**: Unique performance criteria and real-time biometric analysis for every discipline.

---

## 🛠️ Tech Stack

*   **Frontend**: Flutter (Web)
*   **Backend**: Node.js (Express)
*   **Database**: MySQL
*   **State Management**: Dynamic AppState with Shared Preferences
*   **Visuals**: CustomPainter (Mesh Grid), Google Fonts (Outfit), Flutter Animate

---

## 🚀 Getting Started

### 1. Prerequisites
*   Flutter SDK
*   Node.js & npm
*   MySQL Server

### 2. Setup
1.  **Database**: Import `sportsalytics_db.sql` into your MySQL server.
2.  **Backend**:
    ```bash
    cd backend
    npm install
    cp .env.example .env # Update with your DB credentials
    npm start
    ```
3.  **Frontend**:
    ```bash
    cd frontend
    flutter pub get
    flutter run -d chrome
    ```

---

## 📬 License
Distributed under the MIT License. See `LICENSE` for more information.

---
**Developed with ❤️ for the elite sports community.**
