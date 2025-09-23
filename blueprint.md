# Project Blueprint

## Overview

This document outlines the architecture, features, and ongoing development plan for the Coffee Shop mobile application.

## Core Features & Design

*   **State Management:** GetX for reactive state management.
*   **Authentication:** Firebase Auth for user login and registration.
*   **Database:** Firestore for storing user data, products, orders, and chats.
*   **UI:** Modern, coffee-themed design with a brown and golden color palette.
*   **Navigation:** Centralized bottom navigation bar (`Home`, `Category`, `Cart`, `Account`).
*   **Cart Management:** Reactive cart controller that updates the UI in real-time.
*   **Profile Management:** Users can view and edit their profile information, including their name and profile picture.

## Current Task: Enhance Chat Timestamp Formatting

**Objective:** Improve the readability of chat messages by providing more context to the timestamps, rather than just showing the time.

**Plan:**

1.  **Add `intl` Package:** Add the `intl` package to `pubspec.yaml` for advanced date and time formatting.
2.  **Create a Time Formatting Helper:**
    *   Create a new file, likely under `lib/common/widgets/` or a similar utility path.
    *   Implement a function `formatChatMessageTime(Timestamp timestamp)` that contains the following logic:
        *   If the message was sent today, format as `HH:mm` (e.g., `17:45`).
        *   If the message was sent within the last 7 days (but not today), format as `EEE, HH:mm` (e.g., `Mon, 17:45`).
        *   If the message is older, format as `d MMM y, HH:mm` (e.g., `5 Aug 2025, 17:45`).
3.  **Update UI Components:**
    *   Locate the widget responsible for rendering individual chat messages (likely in `chat_screen.dart` and/or `admin_messages_screen.dart`).
    *   Import the new helper function.
    *   Use the function to format the `created_on` timestamp for each message before it's displayed.
