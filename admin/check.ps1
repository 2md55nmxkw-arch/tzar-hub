# Same checks as CI: format, lint, strict types, unit tests, bundle up to date.
# -Fix formats and rebuilds instead of only checking.
param([switch]$Fix)
$bin = "D:\Projects\tzar.cc\luau\.tools\bin"
$fail = 0
if ($Fix) {
    & "$bin\stylua.exe" src tests build.luau
} else {
    & "$bin\stylua.exe" --check src tests build.luau; if ($LASTEXITCODE) { $fail = 1 }
}
& "$bin\selene.exe" --display-style quiet src; if ($LASTEXITCODE) { $fail = 1 }
& "$bin\luau-lsp.exe" analyze --flag LuauSolverV2=true --platform roblox --definitions defs/roblox.d.luau --definitions defs/potassium.d.luau src 2>&1 | Where-Object { $_ -notmatch '^\[INFO\]' }
if ($LASTEXITCODE) { $fail = 1 }
& "$bin\lune.exe" run tests/unit/fuzzy; if ($LASTEXITCODE) { $fail = 1 }
if ($Fix) {
    & "$bin\lune.exe" run build
} else {
    & "$bin\lune.exe" run build -- --check; if ($LASTEXITCODE) { $fail = 1 }
}
exit $fail
