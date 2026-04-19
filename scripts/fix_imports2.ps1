# Fix remaining cross-folder imports

# data/games/ files importing core
$files = @('lib/data/games/code_challenges_data.dart', 'lib/data/games/game_data.dart')
foreach ($f in $files) {
    if (Test-Path $f) {
        $c = Get-Content $f -Raw
        $c = $c -replace "import '\.\./core/", "import '../../core/"
        Set-Content $f $c -NoNewline
        Write-Host "Fixed: $f"
    }
}

# app_shell/main_screen.dart
$f = 'lib/screens/app_shell/main_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'roadmap_screen\.dart'", "import '../home/roadmap_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

# app_shell/splash_screen.dart
$f = 'lib/screens/app_shell/splash_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'privacy_policy_screen\.dart'", "import '../settings/privacy_policy_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

# pipeline_challenge/game_pipeline_screen.dart
$f = 'lib/screens/games/pipeline_challenge/game_pipeline_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'module_detail_screen\.dart'", "import '../../home/module_detail_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

# home/module_detail_screen.dart
$f = 'lib/screens/home/module_detail_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'bookmarks_screen\.dart'", "import '../profile/bookmarks_screen.dart'"
$c = $c -replace "import 'flashcard_screen\.dart'", "import '../practice/flashcard_screen.dart'"
$c = $c -replace "import 'quiz_screen\.dart'", "import '../practice/quiz_screen.dart'"
$c = $c -replace "import 'practice_screen\.dart'", "import '../practice/practice_screen.dart'"
$c = $c -replace "import 'paywall_screen\.dart'", "import '../settings/paywall_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

# home/topic_screen.dart
$f = 'lib/screens/home/topic_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'quiz_screen\.dart'", "import '../practice/quiz_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

# practice/flashcard_screen.dart
$f = 'lib/screens/practice/flashcard_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'paywall_screen\.dart'", "import '../settings/paywall_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

# practice/interview_screen.dart
$f = 'lib/screens/practice/interview_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'paywall_screen\.dart'", "import '../settings/paywall_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

# practice/quiz_results_screen.dart
$f = 'lib/screens/practice/quiz_results_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'main_screen\.dart'", "import '../app_shell/main_screen.dart'"
$c = $c -replace "import 'paywall_screen\.dart'", "import '../settings/paywall_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

# practice/quiz_screen.dart
$f = 'lib/screens/practice/quiz_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'topic_screen\.dart'", "import '../home/topic_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

# practice/practice_screen.dart
$f = 'lib/screens/practice/practice_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'quiz_screen\.dart'", "import 'quiz_screen.dart'"
$c = $c -replace "import 'flashcard_screen\.dart'", "import 'flashcard_screen.dart'"
$c = $c -replace "import 'interview_screen\.dart'", "import 'interview_screen.dart'"
$c = $c -replace "import 'paywall_screen\.dart'", "import '../settings/paywall_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

# profile/achievements_screen.dart
$f = 'lib/screens/profile/achievements_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'paywall_screen\.dart'", "import '../settings/paywall_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

# profile/certificate_progression_screen.dart
$f = 'lib/screens/profile/certificate_progression_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'paywall_screen\.dart'", "import '../settings/paywall_screen.dart'"
$c = $c -replace "import 'certificate_screen\.dart'", "import 'certificate_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

# home/roadmap_screen.dart
$f = 'lib/screens/home/roadmap_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'module_detail_screen\.dart'", "import 'module_detail_screen.dart'"
$c = $c -replace "import 'quiz_screen\.dart'", "import '../practice/quiz_screen.dart'"
$c = $c -replace "import 'paywall_screen\.dart'", "import '../settings/paywall_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

# profile/league_home_screen.dart
$f = 'lib/screens/profile/league_home_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'paywall_screen\.dart'", "import '../settings/paywall_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

# quiz_analytics_screen.dart
$f = 'lib/screens/practice/quiz_analytics_screen.dart'
$c = Get-Content $f -Raw
$c = $c -replace "import 'quiz_screen\.dart'", "import 'quiz_screen.dart'"
$c = $c -replace "import 'paywall_screen\.dart'", "import '../settings/paywall_screen.dart'"
Set-Content $f $c -NoNewline
Write-Host "Fixed: $f"

Write-Host "`nAll remaining imports fixed!"
