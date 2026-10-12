@echo off
chcp 65001 >nul

REM ============================================================
REM  Magic Harness 技能安装脚本
REM
REM  用法：右键 -> 以管理员身份运行
REM  行为：
REM    1. 安装 skills\ 下的技能到 %USERPROFILE%\.magic-harness\skills
REM  规则：目标已存在同名文件夹则跳过。
REM ============================================================

set "DATA_DIR=%USERPROFILE%\.magic-harness"
set "SKILLS_DIR=%DATA_DIR%\skills"
set "SRC_ROOT=%~dp0"

REM ---------- 前置检查 1：必须以管理员身份运行 ----------
net session >nul 2>&1
if errorlevel 1 (
    echo [错误] 权限不足，请右键本脚本，选择“以管理员身份运行”。
    echo.
    pause
    exit /b 1
)

REM ---------- 前置检查 2：Magic Harness 不能在运行 ----------
tasklist /FI "IMAGENAME eq Magic Harness.exe" 2>nul | find /I "Magic Harness.exe" >nul
if not errorlevel 1 (
    echo [错误] 检测到 Magic Harness 正在运行。
    echo        请先关闭 Magic Harness，然后重新运行本脚本。
    echo.
    pause
    exit /b 1
)

echo ==========================================
echo   Magic Harness 技能安装脚本
echo ==========================================
echo.

REM ---------- 安装技能（依赖 Magic Harness 数据目录） ----------
echo [1/1] 安装技能 -^> %SKILLS_DIR%
if not exist "%DATA_DIR%\" (
    echo [错误] 未找到 Magic Harness 数据目录：
    echo        %DATA_DIR%
    echo        技能安装已跳过。
) else (
    if not exist "%SKILLS_DIR%\" mkdir "%SKILLS_DIR%"
    call :InstallItem "%SRC_ROOT%skills\grilling"                "%SKILLS_DIR%\grilling"                "技能 grilling"
    call :InstallItem "%SRC_ROOT%skills\magic-harness-env-setup" "%SKILLS_DIR%\magic-harness-env-setup" "技能 magic-harness-env-setup"
)
echo.

echo 安装完成，启动 Magic Harness 后生效。
pause
exit /b 0

REM ============================================================
REM  InstallItem：安装单个技能目录
REM    %1 = 源目录   %2 = 目标目录   %3 = 显示名称
REM ============================================================
:InstallItem
if not exist "%~1\" (
    echo   %~3：安装失败（源目录缺失：%~1）
    exit /b 1
)
if exist "%~2\" (
    echo   %~3：已存在，跳过
    exit /b 0
)
robocopy "%~1" "%~2" /E /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 (
    echo   %~3：安装失败
    exit /b 1
)
echo   %~3：安装成功
exit /b 0
