# 思维小岛 · 把本项目推送到 GitHub
# 用法（在本目录开一个普通 PowerShell 窗口）：
#   powershell -ExecutionPolicy Bypass -File .\push_to_github.ps1
# 走 SSH：使用 ~/.ssh/id_ed25519（指纹 SHA256:o3yoc61R/3uS0btf0Pf/7DAALE09+HC2IhmMJT2uhYQ，已加到 GitHub 账号）
$ErrorActionPreference = 'Stop'
$repoUrl = 'git@github.com:mmdxbdz/logic_quest.git'
$keyPath = Join-Path $env:USERPROFILE '.ssh\id_ed25519'
$env:GIT_SSH_COMMAND = 'ssh -i "' + $keyPath + '" -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new'
Set-Location $PSScriptRoot

if (-not (Test-Path '.git')) {
  Write-Host '>> git init'
  git init -b main
  if ($LASTEXITCODE -ne 0) { throw 'git init 失败' }
}

$remotes = @(git remote)
if ($remotes -notcontains 'origin') {
  git remote add origin $repoUrl
} else {
  git remote set-url origin $repoUrl
}

git add -A
$changes = git status --porcelain
if ([string]::IsNullOrWhiteSpace($changes)) {
  Write-Host '>> 没有需要提交的改动'
} else {
  Write-Host '>> git commit'
  git commit -m "初始提交：思维小岛 —— Flutter 离线逻辑思维小游戏（6 岛 / 48 关 / 中文语音）"
  if ($LASTEXITCODE -ne 0) { throw 'git commit 失败' }
}

Write-Host '>> git push'
git push -u origin main
if ($LASTEXITCODE -ne 0) {
  Write-Host '推送失败：先确认 SSH 密钥已加到 GitHub 账号，并手动试一次 ssh -T git@github.com。'
  exit 1
}
Write-Host '完成：https://github.com/mmdxbdz/logic_quest'
