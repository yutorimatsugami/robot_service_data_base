# Robot Service Database Setup Script for Windows
# Run with: .\start.ps1

Write-Host "🚀 Robot Service Database Setup" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    Write-Host "   https://docs.docker.com/desktop/install/windows-install/" -ForegroundColor Yellow
    exit 1
}

# Create .env if not exists
if (-not (Test-Path ".env")) {
    Write-Host "📝 Creating .env from template..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "   Edit .env to customize settings if needed." -ForegroundColor Gray
}

# Create data directory
if (-not (Test-Path "db/data")) {
    New-Item -ItemType Directory -Path "db/data" -Force | Out-Null
}

# Start containers
Write-Host "🐳 Starting Docker containers..." -ForegroundColor Yellow
docker-compose up -d

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Adminer (DB管理画面): " -NoNewline -ForegroundColor White
Write-Host "http://localhost:8080" -ForegroundColor Cyan
Write-Host "🔗 PostgreSQL: " -NoNewline -ForegroundColor White
Write-Host "localhost:5432" -ForegroundColor Cyan
Write-Host ""
Write-Host "Login info:" -ForegroundColor White
Write-Host "  Server: db"
Write-Host "  User: robot_user"
Write-Host "  Password: robot_pass"
Write-Host "  Database: robot_service_db"
