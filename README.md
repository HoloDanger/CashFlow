# CashFlow - Money Tracker

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Architecture Overview](#architecture-overview)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Development Plan](#development-plan)
- [Risks and Mitigation Strategies](#risks-and-mitigation-strategies)
- [Security Practices](#security-practices)
- [Testing Strategy](#testing-strategy)
- [Time Estimation](#time-estimation)
- [Future Roadmap](#future-roadmap)
- [Contribution Guidelines](#contribution-guidelines)
- [Contribution to Documentation or Translations](#contribution-to-documentation-or-translations)
- [Coding Conventions and Style Guide](#coding-conventions-and-style-guide)
- [Troubleshooting Section](#troubleshooting-section)
- [FAQ Section](#faq-section)

## Introduction

CashFlow is a mobile application developed to address common challenges in personal finance management. It aims to help users efficiently track and manage their income and expenses, offering a comprehensive solution for budgeting, spending analysis, and financial planning. By providing tools for logging transactions, setting budgets, and generating insightful reports, CashFlow empowers users to make informed financial decisions and achieve their financial goals.

**Target Audience**

CashFlow is designed for individuals seeking to gain better control over their personal finances. Whether you're a student managing a tight budget, a working professional tracking monthly expenses, or a family planning for future financial goals, CashFlow provides a user-friendly platform to simplify and enhance your financial management.

**Key Benefits**

- **Ease of Use**: Intuitive interfaces and simple navigation make financial tracking straightforward and hassle-free.
- **Comprehensive Tracking**: Track various categories of income and expenses to get a complete view of your financial situation.
- **Customizable Budgeting**: Set and monitor budgets to control spending and save more effectively.
- **Insightful Reports**: Visual reports and graphs help you understand spending patterns and make informed decisions.
- **Data Export**: Export your transaction history for detailed analysis or record-keeping.

**How It Works**

The CashFlow app works by allowing users to input and categorize their financial transactions. Users can set budgets for different categories and monitor their spending against these budgets. The app generates visual reports to highlight spending patterns and financial trends. Users can also export their data for additional analysis or record-keeping.

**Motivation Behind Development**

CashFlow aims to simplify personal financial management by providing an accessible tool for tracking, budgeting, and planning, helping users make informed financial decisions.Our goal is to promote financial literacy and empower users to achieve greater financial stability and success.

## Features

- **Transaction Logging**: Effortlessly add income and expenses, such as groceries or salary, and categorize them for a detailed financial overview.
- **Budgeting**: Set monthly or weekly budgets and track your spending against these budgets.
- **Reports**: Visualize your transaction history with beautiful and intuitive graphs.
- **Export**: Export your transaction history to CSV for further analysis.

## Technology Stack

CashFlow is built using Flutter and Dart, offering the following benefits for mobile app development:

- **Flutter**: Provides a single codebase for both iOS and Android, enabling faster development and consistent UI across platforms.
- **Dart**: Offers a reactive and performant programming language that integrates seamlessly with Flutter for building robust mobile applications.

## Architecture Overview

The CashFlow project follows a typical Flutter architecture pattern, utilizing the **Provider** pattern for state management. This patterns ensures a clear and maintainable separation of concerns, making the codebase easier to manage and extend.

### Key Components

1. **UI Layer**: Contains Flutter widgets responsible for displaying the user interface.
   - **Widgets**: Build the user interface and interact with the state managed by Provider.
2. **Business Logic Layer**: Manages application state using Provider.
   - **Providers**: Handle the state of various parts of the application, such as user transactions, budgeting, and reports. Providers manage the state and notify listeners about changes.
3. **Data Layer**: Handles data storage and retrieval. This includes:
   - **Local Databases**: For persistent data storage (e.g., SQLite, Hive).
   - **External APIs**: For fetching data from remote sources.

### Interaction Flow

1. **User Actions**: User interacts with the UI, triggering events (e.g., adding a transaction, setting a budget).
2. **State Management**: UI components use `Provider.of` or `Consumer` to access and modify the state. Providers handle state changes and notify listeners.
3. **Data Handling**: Providers interact with the data layer to fetch or persist data. For example, adding a new transaction may involve saving the data to a local database.
4. **UI Update**: State changes trigger UI updates. When the state managed by a Provider changes, it notifies the widgets listening to it, leading t a re-render of the relevant parts of the UI.

### Implementation Details

**Provider Pattern:**

- **Providers**: Manage the application's state and provide it to widgets. Providers encapsulate business logic and interact with the data layer.
- **ChangeNotifier**: Used in Provider to manage state and notify listeners when the state changes. Widgets subscribe to changes using `Consumer` or `Provider.of`.
- **Dependency Injection**: Provider also handles dependency injection, simplifying the management of dependencies across the app.

**Example Usage:**

- TransactionProvider: Manages the state related to transactions. It provides methods to add, remove, or retrieve transactions and notifies listeners about changes.
- HomeScreen Widget: Uses `Consumer<TransactionProvider>` to display a list of transactions. When the transaction list changes, the widget automatically updates.

## Getting Started

### Prerequisites

- **Flutter 2.0 or later**: [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart 2.12.0 or later**: Dart is included with the Flutter SDK, but you can find more information [here](https://dart.dev/get-dart)
- **Android Studio**: [Install Android Studio](https://developer.android.com/studio)
  - Ensure you have an emulator set up. Follow the instructions [here](https://developer.android.com/studio/run/emulator) to set up an emulator.
- **Visual Studio Code**: [Install Visual Studio Code](https://code.visualstudio.com/Download)
  - Ensure you have the Flutter and Dart plugins installed. Instructions can be found [here](https://docs.flutter.dev/get-started/editor)

### Emulator Setup in Android Studio

1. Open Android Studio.
2. Navigate to `Tools` > `AVD Manager`.
3. Click on `Create Virtual Device`.
4. Select a device definition and click `Next`.
5. Select a system image, click `Next`, and then click `Finish`.
6. Start the emulator by clicking the play button.

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/HoloDanger/CashFlow.git
   ```
2. **Navigate into the project directory:**
   ```
   cd CashFlow
   ```
3. **Install dependencies:**
   ```
   flutter pub get
   ```
4. **Run the app:**
   ```
   flutter run
   ```

## Development Plan

The development of the CashFlow app is divided into several steps:

1. **Understand Project Requirements**

   - **Example**: Review the feature list document to understand the necessary functionalities such as transaction logging and budget tracking.

2. **Set Up Development Environment**

   - **Example**: Install Flutter SDK and set up Android Studio to ensure a functional development environment. Verify setup by creating and running a simple "Hello World" app.

3. **Plan App Features and UI**

   - **Example**: Create wireframes for the main screens, such as the transaction list view, budgeting page, and reports dashboard.

4. **Develop Basic UI**

   - **Example**: Implement the home screen with a transaction list by the end of Week 2.

5. **Implement State Management**

   - **Example**: Set up `TransactionProvider` to manage and provide transaction data to the UI.

6. **Set Up Local Database**

   - **Example**: Integrate SQLite for storing transaction records and implement CRUD operations.

7. **Create Database Functions**

   - **Example**: Write functions for adding, retrieving, and deleting transactions from the SQLite database.

8. **Integrate Frontend and Backend**

   - **Example**: Connect `TransactionProvider` with database functions to display and manage transactions.

9. **Test the App**

   - **Example**: Write unit tests for `TransactionProvider` and integration tests for the transaction logging feature.

10. **Implement Additional Features**

    - **Example**: Add a budgeting feature where users can set monthly budgets and track spending.

11. **Test Additional Features**

    - **Example**: Test the budgeting feature by setting different budget limits and ensuring accurate tracking and notifications.

12. **Final Testing**

    - **Example**: Perform end-to-end testing with various user scenarios, such as adding, editing, and deleting transactions.

13. **Prepare for Release**
    - **Example**: Create app builds for iOS and Android, test on real devices, and prepare app store listings.

Each step in the development plan corresponds to specific tasks that are essential for the successful completion of the CashFlow app. For more detailed information about each step, please refer to the [Project Requirements](project_requirements.md) section in the project documentation.

## Risks and Mitigation Strategies

### Risk: Difficulty in Setting Up the Development Environment

**Description**: New developers might struggle with setting up Flutter and Dart, which could delay the development process.

**Mitigation Strategy**:

1. **Detailed Setup Guide**: Provide a comprehensive and updated setup guide in the documentation, including troubleshooting tips.
2. **Pre-Configured Environments**: Use pre-configured development environments or Docker images to simplify setup.
3. **Support Channels**: Offer support through forums or a dedicated Slack channel where developers can seek help.

**Example Scenario**: A developer new to Flutter encounters issues with configuring the Android SDK. The setup guide provides step-by-step instructions, and the developer posts a question in the Slack channel. A community member helps resolve the issue quickly.

### Risk: Inconsistent State Management Leading to UI Issues

**Description**: Improper state management can lead to UI components not reflecting the correct state, resulting in bugs and a poor user experience.

**Mitigation Strategy**:

1. **Adopt Best Practices**: Follow best practices for state management as outlined in the [Provider documentation](https://pub.dev/packages/provider).
2. **Code Reviews**: Conduct regular code reviews to ensure that state management is implemented correctly.
3. **Automated Tests**: Implement automated tests to check state changes and their impact on the UI.

**Example Scenario**: A widget fails to update when the transaction list changes. Code reviews identify that the `notifyListeners` method was not called after state changes. The issue is fixed, and automated tests are added to catch similar issues in the future.

### Risk: Data Loss or Corruption in the Local Database

**Description**: Data loss or corruption in the local database can result in the loss of critical user information.

**Mitigation Strategy**:

1. **Data Validation**: Implement data validation and integrity checks to prevent corrupt data entries.
2. **Backup Mechanisms**: Create regular backups of the database and provide options for users to export their data.
3. **Thorough Testing**: Perform rigorous testing, including edge cases, to ensure data is handled correctly.

**Example Scenario**: Users report that some transactions are missing after an app crash. The issue is traced to improper error handling during data writes. The data validation code is enhanced, and a backup mechanism is put in place to prevent future data loss.

### Risk: Security Vulnerabilities

**Description**: Potential security vulnerabilities could lead to unauthorized access to user data.

**Mitigiation Strategy**:

1. **Use Secure Storage**: Utilize secure storage solutions like `flutter_secure_storage` for sensitive information.
2. **Regular Security Audits**: Conduct regular security audits and penetration testing to identify and fix vulnerabilities.
3. **Follow Security Best Practices**: Implement encryption for data at rest and in transit, and follow security best practices.

**Example Scenario**: An audit reveals that sensitive user information is not encrypted in local storage. The issue is addressed by integrating `flutter_secure_storage` and updating the documentation with security best practices.

## Security Practices

1. **Data Encryption**

   - **Example**: Use `flutter_secure_storage` to securely store sensitive information like user authentication tokens.

2. **Secure Storage Mechanisms**

   - **Example**: Implement encrypted local storage for user transaction data using SQLite with encryption.

3. **User Authentication**

   - **Example**: Integrate Firebase Authentication for secure user sign-in and sign-up processes.

4. **Best Practices for Data Privacy**
   - **Example**: Implement GDPR-compliant data deletion features allowing users to request data deletion.

## Testing Strategy

### Types of Testing

#### Unit Tests

Unit tests focus on individual components or functions to ensure they work correctly in isolation. They verify that each function or method produces the expected output for given inputs.

**Example Code**:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cashflow/providers/transaction_provider.dart';

void main() {
   test('Calculate total expenses for the month', () {
      final provider = TransactionProvider();
      provider.addTransaction(Transaction(amount: 100, category: 'Food', date: DateTime(2024, 7, 1)));
      provider.addTransaction(Transaction(amount: 50, category: 'Transport', date: DateTime(2024, 7, 15)));

      final totalExpenses = provider.calculateMonthlyExpenses(DateTime(2024, 7));
      expect(totalExpenses, 150);
   });
}
```

#### Integration Tests

Integration tests check the interactions between different components or modules to ensure they work together correctly.

**Example Code**:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cashflow/providers/transaction_provider.dart';
import 'package:cashflow/services/database_service.dart';

void main() {
   testWidgets('Add and retrieve transaction', (WidgetTester tester) async {
      final provider = TransactionProvider(databaseService: MockDatabaseService());
      await provider.addTransaction(Transaction(amount: 100, category: 'Food', date: DateTime(2024, 7, 1)));

      final transactions = await provider.getTransactions(DateTime(2024, 7));
      expect(transactions.length, 1);
      expect(transactions.first.amount, 100);
   });
}
```

#### System Tests

System tests validate the complete and integrated application to ensure it meets the specified requirements.

**Example Code**:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cashflow/main.dart';

void main() {
   testWidgets('End-to-end transaction flow', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Add a transaction
      await tester.tap(find.byIcon(Icons.add));
      await tester.enterText(find.byKey(Key('amountField')), '100');
      await tester.enterText(find.byKey(Key('categoryField')), 'Food');
      await tester.tap(find.byKey(Key('saveButton')));
      await tester.pump();

      // Verify transaction appears in list
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('\$100'), findsOneWidget);
   });
}
```

#### Performance Tests

Performance tests evaluate the app's performance, including load times and responsiveness under various conditions.

**Purpose**: Ensures the app performs well, especially with large datasets or high user loads.

**Example Code**:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cashflow/providers/report_provider.dart';

void main() {
   test('Performance test for report generation', () async {
      final provider = ReportProvider();

      // Simulate adding a large number of transaction
      for (int i = 0; i < 1000; i++) {
         provider.addTransaction(Transaction(amount: i.toDouble(), category: 'Category: $i', date: DateTime.now()));
      }

      final stopwatch = Stopwatch()..start();
      await provider.generateReport(DateTime.now());
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // Ensure report generation is under 2 seconds
   });
}
```

### Testing Tools

- **Flutter Test Framework**: [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- **Mockito**: [Mockito Documentation](https://pub.dev/packages/mockito)
- **Integration Test Package**: [Integration Testing Documentation](https://flutter.dev/docs/testing/integration-tests)
- **Firebase Performance Monitoring**: [Firebase Performance Documentation](https://firebase.google.com/docs/perf-mon)

### Best Practices

1. **Write Clear and Descriptive Tests**
2. **Use Mocks and Stubs**
3. **Automate Testing**
4. **Test Edge Cases**
5. **Maintain Test Coverage**

### Test Automation

1. **CI/CD Integration**: Use tools like Github Actions, Travis CI, or CircleCI for automated test execution.
2. **Test Reports**: Regularly review test reports to monitor results.
3. **Test Data Management**: Use fixtures or mock data for consistent testing.

## Time Estimation

Development is estimated at 8 weeks, broken down as follows: Design (2 weeks), Development (4 weeks), Testing (2 weeks), with an additional 20% buffer for unforeseen issues.

## Future Roadmap

The future enhancements planned for the CashFlow app include:

- Integration with cloud storage for data backup.
- Implementation of predictive budgeting features based on spending patterns.
- Enhancement of reporting capabilities with customizable graphs and charts.

## Contribution Guidelines

If you would like to contribute to the CashFlow project, please follow these guidelines:

- For bug reporting or feature requests, please open an issue on the GitHub repository.
- To contribute code, submit a pull request with a clear description of the changes.

## Contribution to Documentation or Translations

Contributors are encouraged to improve the project by contributing to documentation or translations. Guidelines are provided on how to contribute to the project's documentation, including the process for suggesting edits, creating new content, or translating existing documentation into different languages.

## Coding Conventions and Style Guide

To maintain consistency in the codebase, CashFlow follows the Dart and Flutter style guide. It includes conventions for naming variables, classes, and functions, as well as formatting rules for code readability. Contributors are encouraged to follow these guidelines to ensure uniformity in the project.

## Troubleshooting Section

If you encounter any issues during installation or development, refer to the following solutions:

1. **Issue**: Difficulty in setting up the development environment.

- **Solution**: If encountering issues with Flutter SDK installation, check the SDK path configuration and ensure it matches the installation directory. Refer to the [Flutter installation guide](https://docs.flutter.dev/get-started/install)

2. **Issue**: Inconsistent state management leading to UI issues.

- **Solution**: If UI components are not updating as expected, verify that `notifyListeners` is called after state changes and ensure widgets are wrapped with `Consumer` or `Provider.of`. Review the state management best practices and examples in the [Provider documentation](https://pub.dev/packages/provider).

3. **Issue**: Flutter version conflicts or emulator setup problems.

- **Solution**:
  1. Run `flutter doctor` to check for environment issues.
  2. Update Flutter to the latest version using `flutter upgrade`.
  3. Verify emulator setup by checking the available devices with `flutter devices` to list available devices. For further emulator setup details, refer to the [Android Emulator documentation](https://developer.android.com/studio/run/emulator)

## FAQ Section

1. **Q: How do I add a new transaction?**

   - **A**: Go to the home screen and click the "Add Transaction" button. Enter the details such as title, amount, and date, and then save.

2. \*\*Q: What should I do if the app crashes when adding a transaction?

   - **A**: Check the error logs for detailed information. Ensure that all required fields are filled and validate the input data.

3. **Q: How can I export my transaction history?**
   - **A**: Navigate to the Reports section and click on "Export to CSV." Follow the prompts to download the transaction history.
