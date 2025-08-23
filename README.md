# Ultimate Alarm Clock: Wear OS Companion

This project is the official Wear OS companion app for the **Ultimate Alarm Clock (UAC)**, built as part of **Google Summer of Code 2025**. It brings UAC's core alarm management and smart features to your wrist, with seamless, real-time synchronization between your phone and watch.

<p align="center">
  <a href="https://summerofcode.withgoogle.com/programs/2025/projects/gdx2hkoP">
    <img src="./assets/images/gsoc.jpg" alt="GSoC">
  </a>
</p>


## Table of Contents
- [What's New (GSoC'25)](#whats-new-gsoc-25)
- [Core Architecture](#core-architecture)
- [Communication Flow](#communication-flow)
- [Database Schema](#database-schema)
- [Installation & Setup](#installation--setup)
- [Project Status](#project-status)
- [Contribution Guidelines](#contribution-guidelines)
- [Future Plans](#future-plans)
- [Community](#community)



## What's New (GSoC'25)
During the GSoC'25 period, the following features were implemented by Contributor Abhishek Gupta:
### 1. Full Wear OS Companion App
- A complete **Flutter application**, built specifically for Wear OS devices.
- Designed for both round and square screens.
- Provides a user-friendly interface to manage alarms directly on the watch.
### 2. Hybrid Flutter & Kotlin Architecture
- **Flutter**: UI and database ownership.
- **Kotlin**: Native tasks (scheduling, broadcasts, snooze, dismiss).
- Delivers a responsive UI and battery-efficient background alarm scheduling.
### 3. Real-Time, Two-Way Data Synchronization
- Built on the **Google Data Layer API (DataClient)**.
- Keeps **all alarms and smart control settings** in sync between phone and watch.
- Any change on one device is instantly reflected on the other.
### 4. Native Alarm Scheduling and Execution
- Alarms scheduled in Kotlin using **AlarmManager**.
- Only the **single next alarm** is scheduled for efficiency.
- Ensures maximum reliability.
### 5. Smart Control Integration
- Watch gathers **location, activity, guardian, weather** data.
- Sends to phone → phone evaluates conditions.
- Sending evaluation results back to the watch is **partially done** (completed for location and weather conditions).



## Core Architecture
The companion app uses a **hybrid model**:
- **Flutter (UI & Database Owner)**
  - UI built in Flutter.
  - State managed via **GetX**.
  - SQLite database is the single source of truth (on both phone and watch).
- **Kotlin (Native Logic)**
  - Alarm scheduling via **AlarmManager**.
  - `BroadcastReceiver` for alarm triggers and boot events.
  - Native snooze implementation.
  - Data sync handling (watch ↔ phone).



## GetX Pattern
The project employs the GetX pattern for state management. The GetX pattern is a popular state management solution in the Flutter ecosystem, known for its simplicity, efficiency, and developer-friendly approach. It simplifies the process of managing the state of a Flutter application and helps in building reactive and performant user interfaces.

#### Purpose of Different Files (use of MVC)
*Controller*: The controller is responsible for handling the business logic and state management of a page. It connects the UI (View) with the underlying data and functions.

*View*: The view represents the UI of the page. It defines how the page should look and interact with users.

*Binding*: The binding connects the controller and view, ensuring that they work together seamlessly. It sets up dependencies and other configurations required for the page.

To learn more about GetX, you can read the official documentation [_here_](https://chornthorn.github.io/getx-docs/).



## Communication Flow
- **Flutter ↔ Kotlin (on-device)**
  - Uses **MethodChannel**.
  - Example: Saving an alarm → Flutter tells Kotlin to schedule it.

- **Phone ↔ Watch**
  - Uses **Google Data Layer API (DataClient)**.
  - Sends serialized **alarm objects** and smart control data.
  - Ensures data consistency across devices.




## Database Schema
The database is managed with **sqflite** in Flutter (and is also accessed natively by Kotlin to handle incoming data).  
Main table: `alarms`
**unique_sync_id** -> is the unique global sync ID, and is same for alarmID on UAC Mobile App.

| Field                      | Type     | Description                                                                 |
|---------------------------|----------|-----------------------------------------------------------------------------|
| `id`                      | INTEGER  | Local auto-increment ID (not used for syncing).                             |
| `unique_sync_id`          | TEXT     | Globally unique alarm ID used for syncing across devices.                   |
| `time`                    | TEXT     | Alarm time in `HH:mm` format.                                               |
| `days`                    | TEXT     | JSON string for repeat days, e.g., `[true,false,...]`.                      |
| `is_enabled`              | INTEGER  | 1 = enabled, 0 = disabled.                                                  |
| `is_one_time`             | INTEGER  | 1 = one-time alarm, 0 = repeating.                                          |
| `from_watch`              | INTEGER  | Identifies origin (1 = created on watch).                                   |
| `is_activity_enabled`     | INTEGER  | Enables activity-based smart control.                                       |
| `activity_interval`       | INTEGER  | Interval in minutes for activity monitoring.                                |
| `activity_condition_type` | INTEGER  | Condition type for activity check.                                          |
| `is_guardian`             | INTEGER  | Guardian smart control flag.                                                |
| `guardian`                | TEXT     | Guardian contact or identifier.                                             |
| `guardian_timer`          | INTEGER  | Guardian timeout.                                                           |
| `is_call`                 | INTEGER  | Enables call-triggered alarms.                                              |
| `is_weather_enabled`      | INTEGER  | Weather-based control flag.                                                 |
| `weather_condition_type`  | INTEGER  | Condition type for weather evaluation.                                      |
| `weather_types`           | TEXT     | Allowed weather conditions (e.g., list of codes).                           |
| `is_location_enabled`     | INTEGER  | Location-based control flag.                                                |
| `location`                | TEXT     | Target location string or coordinates.                                      |
| `location_condition_type` | INTEGER  | Condition type for location.                                                |




## Installation & Setup
### Prerequisites
- Flutter SDK **v3.22.2+** (make sure to not change versions)
- **Ensure Java 17 is used** by removing other Java versions.
- Android Studio (with Flutter and Dart plugins) OR VS Code with flutter and Kotlin setup
- Wear OS emulator or physical device
- Make sure that your WearOS and Android devices are connected properly.



### **Steps to Fix Environment Issues**
- **Downgrade Flutter** to version `3.22.2`.
- **Install Android Studio Koala** version `2024.1.2.8` instead of latest Android Studio.
- **Ensure Java 17 is used** by removing other Java versions.
- **Restart your system** and then run the following commands:
  ```sh
  flutter clean
  flutter pub get
  flutter run
  ```

Following these steps should help resolve common setup-related issues for new contributors.




## Project Status
### Completed
-Full CRUD for alarms on Wear OS.
-MVC and GetX controlled data flow.
-Two-way sync for alarms + smart controls.
-Location & Weather smart control evaluation loop.
-Native snooze scheduling and handling.
-Alarms can be synced/received by the watch even in background or doze mode.

### Partially done
-The feedback loop for sending smart control results for Activity & Guardian to the watch is still in progress.
-Configurable snooze duration and its syncing.
-Add more features from UAC Mobile app and sync them.



## Contribution Guidelines
Thank you for your interest in contributing to the "Ultimate Alarm Clock" project. Contributions from the open-source community are highly valued and help improve the application. Please read the following guidelines to understand how you can contribute effectively.
- Be respectful and considerate when contributing and interacting with the community.
- Follow the project's coding style, conventions, and best practices.
- Keep your PR focused on a single issue or feature. If you wish to contribute multiple changes, create separate branches and PRs for each.
- Provide a detailed and clear description of your PR, including the purpose of the changes and any related issues.
- Ensure that your code is well-documented and that any new features or changes are reflected in the project's documentation.
- Make sure your contributions do not introduce security vulnerabilities or cause regressions.

### How to Contribute
1. **Fork the Repository**: Start by forking the project's repository to your own GitHub account.
2. **Clone the Repository**: Clone the forked repository to your local development environment using the `git clone` command.
    ```bash
   git clone https://github.com/CCExtractor/uac_companion.git
   ```
3. **Create a Branch**: Create a new branch for your contributions, giving it a descriptive name.
   ```bash
   git checkout -b your-feature-name
   ```
4. **Make Changes**: Make your desired changes, improvements, or bug fixes in your local environment.
5. **Test**: Ensure that your changes do not introduce new issues and do not break existing features. Test your code thoroughly.
6. **Documentation**: If your changes impact the user interface, configuration, or functionality, update the documentation to reflect the changes.
7. **Commit**: Commit your changes with a clear and concise message.
   ```bash
   git commit -m "Add feature/fix: Describe your changes here"
   ```
8. **Push Changes**: Push your changes to your GitHub fork.
   ```bash
   git push origin your-feature-name
   ```
9. **Pull Request**: Create a Pull Request (PR) from your fork to the original repository. Ensure your PR has a clear title and description outlining the changes.
10. **Code Review**: Your PR will undergo code review. Make any necessary adjustments based on feedback.
11. **Merge**: Once your PR is approved, it will be merged into the main project repository.

### Reporting Issues
If you find a bug or have a suggestion for improvement, please create an [issue](https://github.com/CCExtractor/uac_companion/issues/new) on the project's GitHub repository. Be sure to include a clear and detailed description of the problem or enhancement.

We appreciate your contributions to the "Ultimate Alarm Clock" project, and your help is invaluable in making it even better.

If you have any questions regarding something in the project, do not hesitate to ask :)




## Future Plans
- Implement a Kotlin function on the main UAC app to enable background alarm syncing.
- Implement the `BootReceiver` to make alarm scheduling persistent across reboots.
- Finalize the Smart Control Suite so all controls are fully integrated.
- Integrate the [CapabilityClient](https://developer.android.com/training/wearables/data/discover-devices) to check for app reachability before sending data.



## Community
We would love to hear from you! You may join the CCExtractor community through Slack:

[![Zulip](https://img.shields.io/badge/chat-on_zulip-purple.svg?style=for-the-badge&logo=zulip)](https://ccextractor.org/public/general/support/)



## Flutter
For help in getting started with Flutter, view
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.