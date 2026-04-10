# Fix imports for files at screens/<subfolder>/ depth (2 levels deep from lib)
# These files used '../X/' which now needs '../../X/'
$depth2Folders = @('app_shell', 'home', 'practice', 'profile', 'settings')
foreach ($folder in $depth2Folders) {
    $path = "lib/screens/$folder"
    if (Test-Path $path) {
        Get-ChildItem -Path $path -Filter '*.dart' | ForEach-Object {
            $content = Get-Content $_.FullName -Raw
            $content = $content -replace "import '\.\./core/", "import '../../core/"
            $content = $content -replace "import '\.\./services/", "import '../../services/"
            $content = $content -replace "import '\.\./models/", "import '../../models/"
            $content = $content -replace "import '\.\./widgets/", "import '../../widgets/"
            $content = $content -replace "import '\.\./data/modules_data\.dart", "import '../../data/learning/modules_data.dart"
            $content = $content -replace "import '\.\./data/quiz_data\.dart", "import '../../data/learning/quiz_data.dart"
            $content = $content -replace "import '\.\./data/flashcard_data\.dart", "import '../../data/learning/flashcard_data.dart"
            $content = $content -replace "import '\.\./data/ar_keywords_data\.dart", "import '../../data/learning/ar_keywords_data.dart"
            $content = $content -replace "import '\.\./data/coding_game_data\.dart", "import '../../data/games/coding_game_data.dart"
            $content = $content -replace "import '\.\./data/inspector_game_data\.dart", "import '../../data/games/inspector_game_data.dart"
            $content = $content -replace "import '\.\./data/game_data\.dart", "import '../../data/games/game_data.dart"
            $content = $content -replace "import '\.\./data/code_challenges_data\.dart", "import '../../data/games/code_challenges_data.dart"
            $content = $content -replace "import '\.\./data/xr_builder_config\.dart", "import '../../data/games/xr_builder_config.dart"
            Set-Content $_.FullName $content -NoNewline
            Write-Host "Fixed: $($_.FullName)"
        }
    }
}

# Fix imports for files at screens/games/ depth (2 levels deep)
$gamesPath = "lib/screens/games"
Get-ChildItem -Path $gamesPath -Filter '*.dart' -File | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content = $content -replace "import '\.\./core/", "import '../../core/"
    $content = $content -replace "import '\.\./services/", "import '../../services/"
    $content = $content -replace "import '\.\./models/", "import '../../models/"
    $content = $content -replace "import '\.\./widgets/", "import '../../widgets/"
    $content = $content -replace "import '\.\./data/", "import '../../data/games/"
    # Fix cross-screen imports for play_screen
    $content = $content -replace "import 'inspector_game_map_screen\.dart'", "import 'xr_builder/inspector_game_map_screen.dart'"
    $content = $content -replace "import 'coding_game_map_screen\.dart'", "import 'systems_engineer/coding_game_map_screen.dart'"
    $content = $content -replace "import 'game_map_screen\.dart'", "import 'pipeline_challenge/game_map_screen.dart'"
    $content = $content -replace "import 'ar_debugger_game\.dart'", "import 'ar_debugger/ar_debugger_game.dart'"
    Set-Content $_.FullName $content -NoNewline
    Write-Host "Fixed: $($_.FullName)"
}

# Fix imports for files at screens/games/<subfolder>/ depth (3 levels deep from lib)
$depth3Folders = @('xr_builder', 'systems_engineer', 'pipeline_challenge', 'ar_debugger')
foreach ($folder in $depth3Folders) {
    $path = "lib/screens/games/$folder"
    if (Test-Path $path) {
        Get-ChildItem -Path $path -Filter '*.dart' | ForEach-Object {
            $content = Get-Content $_.FullName -Raw
            $content = $content -replace "import '\.\./core/", "import '../../../core/"
            $content = $content -replace "import '\.\./services/", "import '../../../services/"
            $content = $content -replace "import '\.\./models/", "import '../../../models/"
            $content = $content -replace "import '\.\./widgets/", "import '../../../widgets/"
            $content = $content -replace "import '\.\./data/modules_data\.dart", "import '../../../data/learning/modules_data.dart"
            $content = $content -replace "import '\.\./data/quiz_data\.dart", "import '../../../data/learning/quiz_data.dart"
            $content = $content -replace "import '\.\./data/coding_game_data\.dart", "import '../../../data/games/coding_game_data.dart"
            $content = $content -replace "import '\.\./data/inspector_game_data\.dart", "import '../../../data/games/inspector_game_data.dart"
            $content = $content -replace "import '\.\./data/game_data\.dart", "import '../../../data/games/game_data.dart"
            $content = $content -replace "import '\.\./data/code_challenges_data\.dart", "import '../../../data/games/code_challenges_data.dart"
            $content = $content -replace "import '\.\./data/xr_builder_config\.dart", "import '../../../data/games/xr_builder_config.dart"
            # Fix cross-screen imports that reference screens in other folders
            $content = $content -replace "import 'paywall_screen\.dart'", "import '../../settings/paywall_screen.dart'"
            Set-Content $_.FullName $content -NoNewline
            Write-Host "Fixed: $($_.FullName)"
        }
    }
}

# Fix imports in data/learning/ files
Get-ChildItem -Path "lib/data/learning" -Filter '*.dart' | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content = $content -replace "import '\.\./models/", "import '../../models/"
    Set-Content $_.FullName $content -NoNewline
    Write-Host "Fixed: $($_.FullName)"
}

# Fix imports in data/games/ files
Get-ChildItem -Path "lib/data/games" -Filter '*.dart' | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content = $content -replace "import '\.\./models/", "import '../../models/"
    Set-Content $_.FullName $content -NoNewline
    Write-Host "Fixed: $($_.FullName)"
}

# Fix imports in services/ that reference data/
Get-ChildItem -Path "lib/services" -Filter '*.dart' | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content = $content -replace "import '\.\./data/modules_data\.dart'", "import '../data/learning/modules_data.dart'"
    $content = $content -replace "import '\.\./data/quiz_data\.dart'", "import '../data/learning/quiz_data.dart'"
    Set-Content $_.FullName $content -NoNewline
    Write-Host "Fixed: $($_.FullName)"
}

# Fix cross-screen imports in home/ screens that reference other screen folders
# home_screen imports screens from practice, profile, settings, games
$homeScreen = "lib/screens/home/home_screen.dart"
if (Test-Path $homeScreen) {
    $content = Get-Content $homeScreen -Raw
    $content = $content -replace "import 'quiz_screen\.dart'", "import '../practice/quiz_screen.dart'"
    $content = $content -replace "import 'practice_screen\.dart'", "import '../practice/practice_screen.dart'"
    $content = $content -replace "import 'flashcard_screen\.dart'", "import '../practice/flashcard_screen.dart'"
    $content = $content -replace "import 'interview_screen\.dart'", "import '../practice/interview_screen.dart'"
    $content = $content -replace "import 'quiz_analytics_screen\.dart'", "import '../practice/quiz_analytics_screen.dart'"
    $content = $content -replace "import 'quiz_results_screen\.dart'", "import '../practice/quiz_results_screen.dart'"
    $content = $content -replace "import 'achievements_screen\.dart'", "import '../profile/achievements_screen.dart'"
    $content = $content -replace "import 'certificate_screen\.dart'", "import '../profile/certificate_screen.dart'"
    $content = $content -replace "import 'certificate_progression_screen\.dart'", "import '../profile/certificate_progression_screen.dart'"
    $content = $content -replace "import 'league_home_screen\.dart'", "import '../profile/league_home_screen.dart'"
    $content = $content -replace "import 'bookmarks_screen\.dart'", "import '../profile/bookmarks_screen.dart'"
    $content = $content -replace "import 'about_app_screen\.dart'", "import '../settings/about_app_screen.dart'"
    $content = $content -replace "import 'credits_screen\.dart'", "import '../settings/credits_screen.dart'"
    $content = $content -replace "import 'privacy_policy_screen\.dart'", "import '../settings/privacy_policy_screen.dart'"
    $content = $content -replace "import 'paywall_screen\.dart'", "import '../settings/paywall_screen.dart'"
    $content = $content -replace "import 'play_screen\.dart'", "import '../games/play_screen.dart'"
    $content = $content -replace "import 'module_detail_screen\.dart'", "import 'module_detail_screen.dart'"
    $content = $content -replace "import 'topic_screen\.dart'", "import 'topic_screen.dart'"
    $content = $content -replace "import 'roadmap_screen\.dart'", "import 'roadmap_screen.dart'"
    Set-Content $homeScreen $content -NoNewline
    Write-Host "Fixed: $homeScreen"
}

# Fix main_screen.dart in app_shell — it imports home, play, profile screens
$mainScreen = "lib/screens/app_shell/main_screen.dart"
if (Test-Path $mainScreen) {
    $content = Get-Content $mainScreen -Raw
    $content = $content -replace "import 'home_screen\.dart'", "import '../home/home_screen.dart'"
    $content = $content -replace "import 'play_screen\.dart'", "import '../games/play_screen.dart'"
    $content = $content -replace "import 'league_home_screen\.dart'", "import '../profile/league_home_screen.dart'"
    $content = $content -replace "import 'achievements_screen\.dart'", "import '../profile/achievements_screen.dart'"
    $content = $content -replace "import 'practice_screen\.dart'", "import '../practice/practice_screen.dart'"
    Set-Content $mainScreen $content -NoNewline
    Write-Host "Fixed: $mainScreen"
}

Write-Host "`nAll imports fixed!"
