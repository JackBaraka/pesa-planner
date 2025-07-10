# Pesa Planner Project Structure Generator
# Run this script from your project root (where lib/ is located)
$projectRoot = $PWD.Path
$libPath = Join-Path $projectRoot "lib"

# Create directories and files
$structure = @{
    # Core components
    "core/constants" = @(
        "app_constants.dart",
        "kenyan_constants.dart",
        "firebase_constants.dart"
    )
    
    "core/errors" = @()
    "core/extensions" = @()
    
    "core/routes" = @(
        "app_router.dart",
        "route_names.dart"
    )
    
    "core/theme" = @(
        "app_colors.dart",
        "app_text_styles.dart",
        "input_decoration.dart",
        "app_theme.dart"
    )
    
    "core/utils" = @(
        "currency_formatter.dart",
        "date_utils.dart",
        "file_export.dart"
    )
    
    "core/widgets/buttons" = @()
    "core/widgets/dialogs" = @()
    "core/widgets/loaders" = @()
    "core/widgets/empty_states" = @()
    
    # Data layer
    "data/models" = @(
        "budget_model.dart",
        "expense_model.dart",
        "user_model.dart",
        "mpesa_transaction.dart"
    )
    
    "data/datasources/local" = @(
        "hive_service.dart",
        "local_datasource.dart"
    )
    
    "data/datasources/remote" = @(
        "firestore_service.dart",
        "mpesa_api.dart",
        "bank_api.dart"
    )
    
    "data/repositories" = @(
        "auth_repository.dart",
        "budget_repository.dart",
        "expense_repository.dart"
    )
    
    # Domain layer
    "domain/entities" = @()
    "domain/repositories" = @()
    
    "domain/usecases" = @(
        "auth_usecases.dart",
        "budget_usecases.dart",
        "export_usecases.dart"
    )
    
    # Feature modules
    "features/auth/presentation/screens" = @(
        "login_screen.dart",
        "phone_verify_screen.dart",
        "signup_screen.dart"
    )
    
    "features/auth/presentation/widgets" = @(
        "kenyan_phone_field.dart",
        "auth_header.dart"
    )
    
    "features/auth/providers" = @(
        "auth_provider.dart"
    )
    
    "features/dashboard" = @()
    "features/budget" = @()
    "features/expenses" = @()
    "features/reports" = @()
    
    "features/utilities/presentation/screens" = @(
        "kplc_bill_screen.dart",
        "water_bill_screen.dart"
    )
    
    "features/utilities/presentation/widgets" = @(
        "bill_history_card.dart",
        "bill_reminder.dart"
    )
    
    "features/utilities/providers" = @(
        "utilities_provider.dart"
    )
    
    "features/transport/presentation/screens" = @(
        "matatu_tracker.dart",
        "uber_tracker.dart"
    )
    
    "features/transport/presentation/widgets" = @(
        "route_picker.dart",
        "fare_calculator.dart"
    )
    
    "features/transport/providers" = @(
        "transport_provider.dart"
    )
    
    "features/settings" = @()
    
    # Services
    "services" = @(
        "auth_service.dart",
        "database_service.dart",
        "mpesa_service.dart",
        "notification_service.dart",
        "pdf_service.dart"
    )
}

# Create all directories and files
foreach ($folder in $structure.Keys) {
    $fullPath = Join-Path $libPath $folder
    New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
    
    foreach ($file in $structure[$folder]) {
        $filePath = Join-Path $fullPath $file
        $content = "// ${file.Replace('.dart', '')}"
        $content | Out-File -FilePath $filePath -Encoding utf8
        Write-Host "Created: $filePath"
    }
}

# Create root files
@("app_widget.dart", "main.dart") | ForEach-Object {
    $filePath = Join-Path $libPath $_
    "# $_ placeholder" | Out-File -FilePath $filePath -Encoding utf8
    Write-Host "Created: $filePath"
}

Write-Host "`nProject structure created successfully!`n"
Write-Host "Next steps:"
Write-Host "1. Run 'flutter pub get' to install dependencies"
Write-Host "2. Start implementing your core functionality"