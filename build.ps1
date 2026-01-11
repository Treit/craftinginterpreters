# Build script for Crafting Interpreters on Windows
# Builds both clox (C interpreter) and jlox (Java interpreter)

Write-Host "Building Crafting Interpreters..." -ForegroundColor Cyan
Write-Host ""

# Build clox (C interpreter)
Write-Host "Building clox (C interpreter)..." -ForegroundColor Green
try {
    # Create build directories
    if (!(Test-Path build\release\clox)) { 
        New-Item -ItemType Directory -Force -Path build\release\clox | Out-Null 
    }
    
    # Compile C source files
    Write-Host "  Compiling C source files..." -ForegroundColor Gray
    gcc -std=c99 -Wall -Wextra -Werror -Wno-unused-parameter -O3 -flto -c c\*.c
    if ($LASTEXITCODE -ne 0) { throw "C compilation failed" }
    
    # Move object files
    Move-Item *.o build\release\clox\ -Force
    
    # Link executable
    Write-Host "  Linking clox.exe..." -ForegroundColor Gray
    gcc -std=c99 -Wall -Wextra -Werror -Wno-unused-parameter -O3 -flto build\release\clox\*.o -o build\clox.exe
    if ($LASTEXITCODE -ne 0) { throw "Linking failed" }
    
    # Copy to root
    Copy-Item build\clox.exe clox.exe -Force
    
    Write-Host "  clox.exe built successfully" -ForegroundColor Green
} catch {
    Write-Host "  Failed to build clox: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Build jlox (Java interpreter)
Write-Host "Building jlox (Java interpreter)..." -ForegroundColor Green
try {
    # Create build directories
    if (!(Test-Path build\java\com)) { 
        New-Item -ItemType Directory -Force -Path build\java\com | Out-Null 
    }
    
    # Compile AST generator tool
    Write-Host "  Compiling AST generator..." -ForegroundColor Gray
    javac -cp java -d build\java java\com\craftinginterpreters\tool\*.java
    if ($LASTEXITCODE -ne 0) { throw "AST generator compilation failed" }
    
    # Run AST generator
    Write-Host "  Generating AST classes..." -ForegroundColor Gray
    java -cp build\java com.craftinginterpreters.tool.GenerateAst java\com\craftinginterpreters\lox
    if ($LASTEXITCODE -ne 0) { throw "AST generation failed" }
    
    # Compile jlox interpreter
    Write-Host "  Compiling jlox interpreter..." -ForegroundColor Gray
    javac -cp java -d build\java java\com\craftinginterpreters\lox\*.java
    if ($LASTEXITCODE -ne 0) { throw "jlox compilation failed" }
    
    # Create jlox.ps1 if it doesn't exist
    if (!(Test-Path jlox.ps1)) {
        Write-Host "  Creating jlox.ps1 wrapper..." -ForegroundColor Gray
        @'
#!/usr/bin/env pwsh
# Wrapper script to run jlox (Java interpreter)
java -cp build\java com.craftinginterpreters.lox.Lox $args
'@ | Out-File -Encoding UTF8 jlox.ps1
    }
    
    Write-Host "  jlox built successfully" -ForegroundColor Green
} catch {
    Write-Host "  Failed to build jlox: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Build complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "To run the interpreters:" -ForegroundColor White
Write-Host "  .\clox.exe       - C interpreter" -ForegroundColor Gray
Write-Host "  .\jlox.ps1       - Java interpreter" -ForegroundColor Gray
Write-Host ""
