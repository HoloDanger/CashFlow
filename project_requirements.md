# Project Requirements

## Introduction

This document outlines the core requirements and features for the CashFlow application. The purpose of this guide is to detail the functionalities that the application must support and the expectations for each future. These requirements will guide the development process and ensure that all critical aspects of the application are addressed.

## Features

### Transaction Logging

- **Description**: Allows users to record their income and expenses. Users can categorize transactions and view them in a list.
- **Detailed Requirements**:
  - **Types of Transactions**:
    - Users can log **income**, **one-time expenses**, and **recurring expenses**.
    - Recurring expenses can be set with a frequency of **daily**, **weekly**, or **monthly**.
  - **Fields Required**:
    - **Date**: Must be a valid date format (e.g., YYYY-MM-DD).
    - **Amount**: Numeric value with up to two decimal places.
    - **Category**: Dropdown with predefined categories (e.g., Groceries, Utilities).
    - **Description**: Optional text field with a maximum of 255 characters.
  - **Validation Rules**:
    - Amount must be greater than 0.
    - Date must be a valid date in the past or present (no future dates).
  - **User Permissions**:
    - **Regular Users**: Can add, edit, or delete their own transactions.
    - **Admins**: Can view, add, edit, or delete transactions for any user.
  - **User Interface (UI) Design**:
    - A form with fields for date, amount, category, and description.
    - Date picker for selecting the date.
    - Dropdown menu for categories.
    - Save and Cancel buttons.
  - **Data Storage and Retrieval**:
    - Transactions are stored in a SQL database with fields: id, date, amount, category, description.
    - Indexed by date and category for efficient retrieval.
  - **Localization and Currency**:
    - Amounts are displayed according to the user's selected currency.
    - Dates and numbers formatted based on user locale settings.
- **Scenarios**:
  - User logs a new expense under the 'Groceries' category.
  - User views a list of all recent transactions.
- **Acceptance Criteria**:
  - Transactions are saved in the database.
  - Users can view a list of transactions with correct details.

### Budgeting

- **Description**: Set and manage budgets.
- **Detailed Requirements**:
  - **Setting Budgets**:
    - Users can set budgets with a **fixed amount** or as a **percentage** of income.
    - Budgets can be set for different categories (e.g., Groceries, Entertainment).
  - **Notifications**:
    - Users receive notifications when approaching or exceeding budget limits.
    - Notification types: **email**, **push notifications**.
  - **UI Design**:
    - Budget setting interface with fields for amount or percentage and category selection.
    - Notification settings page to configure preferences.
  - **Data Storage**:
    - Budgets are stored in the database with fields: id, amount, category, user_id, and notification preferences.
- **Scenarios**:
  - User sets a budget of ₱500 for Groceries.
  - User receives a notification when spending reaches ₱450.
- **Acceptance Criteria**:
  - Users can set, update, and delete budgets.
  - Notifications are sent when budget limits are approached or exceeded.

### Reports

- **Description**: Visualize spending with graphs.
- **Detailed Requirements**:
  - **Types of Reports**:
    - Monthly spending reports.
    - Category-wise spending breakdown.
  - **Customization**:
    - Users can filter reports by date ranges and categories.
    - Options to export reports as PDF or CSV.
  - **UI Design**:
    - Graphical representation of spending (e.g., pie charts, bar graphs).
    - Filters and customization options.
  - **Data Retrieval**:
    - Reports are generated based on transaction data from the database.
- **Scenarios**:
  - User view a monthly spending report.
  - User customizes a report to show spending by category for the past three months.
- **Acceptance Criteria**:
  - Reports accurately reflect transaction data.
  - Users can customize and export reports.

### Export

- **Description**: Export data to CSV.
- **Detailed Requirements**:
  - **Export Options**:
    - Users can export transactions for different date ranges.
    - Users can select specific categories for export.
  - **CSV Format**:
    - The CSV file includes columns: Date, Amount, Category, Description.
  - **UI Design**:
    - Export button with options for date range and categories.
- **Scenarios**:
  - User exports transactions from January to June.
  - User exports only Groceries-related transactions.
- **Acceptance Criteria**:
  - CSV file contains accurate transaction details as specified.

## Feature Interactions

- **Transaction Loggin and Budgeting**: The budgeting feature relies on accurate transaction data. Users should be able to view how their spending impacts their budget.
- **Reports and Transaction Logging**: The reporting feature uses transaction data to generate insights and charts. Accurate transaction logging is crucial for reliable reports.

## Objectives and Goals

- **Primary Objective**: To develop a mobile application that allows users to track their income and expenses, set budgets, and generate financial reports.
- **Goals**:
  - Provide a user-friendly interface for managing transactions.
  - Enable users to set and monitor budgets.
  - Generate comprehensive reports to help users understand their financial situation.
