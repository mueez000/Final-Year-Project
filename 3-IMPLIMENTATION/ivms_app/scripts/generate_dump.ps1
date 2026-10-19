$fileList = @(
    # Level 1: Root configuration and dependency files
    "pubspec.yaml",
    "analysis_options.yaml",
    "firebase.json",
    "firestore.indexes.json",
    "firestore.rules",
    "storage.rules",
    "functions/package.json",

    # Level 2: Main entry point/initialization files
    "lib/main.dart",
    "lib/firebase_options.dart",
    "functions/index.js",
    "scripts/seed_admin.js",

    # Level 3: Core services, API handlers, and backend logic
    "lib/models/user_model.dart",
    "lib/models/telemetry_model.dart",
    "lib/models/incident_model.dart",
    "lib/models/echallan_model.dart",
    "lib/models/broadcast_model.dart",
    "lib/models/field_report_model.dart",
    "lib/services/auth_service.dart",
    "lib/services/telemetry_service.dart",
    "lib/services/incident_service.dart",
    "lib/services/safety_sensor_service.dart",
    "lib/services/drowsiness_camera_service.dart",
    "lib/services/echallan_service.dart",
    "lib/services/broadcast_service.dart",
    "lib/services/evidence_service.dart",
    "lib/services/user_service.dart",
    "lib/providers/auth_provider.dart",
    "lib/providers/telemetry_provider.dart",
    "lib/providers/incident_provider.dart",
    "lib/providers/hq_provider.dart",

    # Level 4: UI components, screens, and styling
    "lib/theme/app_theme.dart",
    "lib/widgets/fleet_map_view.dart",
    "lib/widgets/ai_placeholder.dart",
    "lib/widgets/map_placeholder.dart",
    "lib/screens/role_selection_screen.dart",
    "lib/screens/auth/driver_login_screen.dart",
    "lib/screens/auth/driver_signup_screen.dart",
    "lib/screens/auth/officer_login_screen.dart",
    "lib/screens/auth/officer_signup_screen.dart",
    "lib/screens/auth/admin_login_screen.dart",
    "lib/screens/auth/admin_signup_screen.dart",
    "lib/screens/dashboard/driver_main_screen.dart",
    "lib/screens/dashboard/driver_dashboard_tab.dart",
    "lib/screens/dashboard/driver_safety_tab.dart",
    "lib/screens/dashboard/driver_violations_tab.dart",
    "lib/screens/dashboard/driver_profile_tab.dart",
    "lib/screens/dashboard/officer_main_screen.dart",
    "lib/screens/dashboard/officer_dashboard_tab.dart",
    "lib/screens/dashboard/officer_map_tab.dart",
    "lib/screens/dashboard/officer_field_report_tab.dart",
    "lib/screens/dashboard/officer_profile_tab.dart",
    "lib/screens/admin/admin_main_screen.dart",
    "lib/screens/admin/admin_dashboard_tab.dart",
    "lib/screens/admin/admin_fleet_database_tab.dart",
    "lib/screens/admin/admin_driver_management_tab.dart",
    "lib/screens/admin/admin_officer_management_tab.dart",
    "lib/screens/admin/admin_echallan_management_tab.dart",
    "lib/screens/admin/admin_incident_review_tab.dart",
    "lib/screens/admin/admin_analytics_tab.dart",
    "lib/screens/admin/admin_broadcasts_tab.dart",
    "lib/screens/admin/admin_settings_tab.dart",

    # Level 5: Platform-specific configurations and deployment scripts
    "web/index.html",
    "web/manifest.json",
    "android/app/src/main/AndroidManifest.xml",
    "android/app/build.gradle.kts",
    "android/build.gradle.kts",
    "android/settings.gradle.kts",

    # Project Documentation & Architecture Guides
    "README.md",
    "HOW_TO_RUN.md",
    "FIREBASE_BACKEND_README.md",
    "FIREBASE_SETUP_AND_TESTING_GUIDE.md"
)

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$writer = New-Object System.IO.StreamWriter("full_project_dump.txt", $false, $utf8NoBom)

$count = 0
foreach ($f in $fileList) {
    if (Test-Path $f) {
        $writer.WriteLine("--- FILE: $f ---")
        $content = [System.IO.File]::ReadAllText((Resolve-Path $f).Path, [System.Text.Encoding]::UTF8)
        $writer.WriteLine($content.TrimEnd())
        $writer.WriteLine()
        $count++
    } else {
        Write-Error "Missing: $f"
    }
}

$writer.Flush()
$writer.Close()
Write-Output "Successfully wrote $count files to full_project_dump.txt"
