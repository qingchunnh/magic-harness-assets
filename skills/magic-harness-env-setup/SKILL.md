---
name: magic-harness-env-setup
description: 为 Magic Harness 配置可选的增强运行环境（Node.js 24.22.1、Python 3.14、uv），并可选配两个 MCP：联网搜索（exa）与电脑控制（windows-mcp，仅支持 Windows）。当用户提到"初始化 magic harness"、"配置 magic harness 环境"、"帮我安装电脑控制"时使用本技能；用户抱怨"电脑控制没反应"、"为什么 AI 不能操作我的电脑"等故障类表述时同样使用，先检查环境是否就绪，即使他们没有明确提到配置环境。环境检查后会逐项询问要安装和配置哪些，可选 MCP 仅在用户明确选择后才执行。这些均为可选，未安装不影响基础功能。
---

# Magic Harness 环境配置

## 背景

本技能在已安装的 Magic Harness 内运行，只负责配置环境工具，不涉及 Magic Harness 自身的安装。

"联网搜索"由 exa 远程 MCP（`https://mcp.exa.ai/mcp`）提供，无需本地安装，写入 Magic Harness 的 MCP 配置即可，全平台可用。

"电脑控制"指 AI 直接操作 Windows 桌面：点击、输入、截图、启动应用等，由 windows-mcp 这个 MCP 提供，依赖 Python 与 uv，仅在 Windows 上安装。

两个 MCP 相互独立，都需写入 Magic Harness 的 MCP 配置才能使用（见第 4、5 步）。

## 目标

Magic Harness 的基础功能开箱即用，不依赖外部工具。但安装以下工具后，AI 的能力边界会显著扩展：

| 工具    | 为 AI 解锁的能力                                          | 版本策略                                        |
| ------- | --------------------------------------------------------- | ----------------------------------------------- |
| Python  | 电脑控制 MCP（windows-mcp）的运行时，以及 Python 脚本、自动化 | 安装时锁定 3.14；已有 ≥3.14 即可                |
| uv      | 安装和运行 windows-mcp，秒级创建虚拟环境、安装 Python 包   | 任意可用版                                      |
| Node.js | 运行基于 npm/npx 分发的 MCP 服务器与命令行工具 | 安装时锁定 24.22.1（macOS 装 24.x 即可）；已有 24.x 或更高即可 |

锁定版本只约束从零安装或升级时的目标版本；用户已装的版本高于锁定版本时视为符合，不做任何改动。

**这些都是可选增强项，不是运行的前提条件。** 用户可以选择全装、只装部分或全部跳过。

**可选 MCP**：第 2 步会统一询问是否启用两个相互独立的 MCP——联网搜索（exa）：全平台可用，无需安装，写入配置即可；电脑控制（windows-mcp）：仅 Windows，需先本地安装再写配置。用户未选择的 MCP 不安装、不写配置。

## 工作流程

### 第 1 步：确认平台并检查环境（只读，无需询问）

先确认操作系统（Windows / macOS / Linux）：电脑控制 MCP 只在 Windows 上安装；非 Windows 用户提到"电脑控制"时，如实说明该能力目前只在 Windows 提供，其余增强工具与联网搜索 MCP 照常配置。

然后并行执行以下命令，记录每项的版本号或"未安装"：

```bash
node --version
uv --version
python --version    # Windows
python3 --version   # macOS / Linux
```

同时检查两个 MCP 的现有状态：

- 读取 MCP 配置文件（Windows：`%USERPROFILE%\.magic-harness\cli\config.json`；macOS / Linux：`~/.magic-harness/cli/config.json`），确认 `mcp.servers` 中是否已有 `exa`、`windows-mcp` 条目。文件不存在视为未配置。
- Windows 额外执行 `uv tool list`，确认 windows-mcp 是否已安装。

检查是只读的，无论用户此行的意图是什么都执行，以便第 2 步完整汇报。

注意：

- 命令不存在或报错，记为"未安装"；`python` 与 `python3` 只需一个可用。
- 版本判定（按语义化版本比较，不是字符串比较）：
  - Node.js 大版本 ≥ 24 → ✅ 符合（如 24.9.0、24.22.1、25.x 均符合）；大版本低于 24 → ⚠️ 版本过低
  - Python ≥ 3.14 → ✅ 符合；低于 3.14 → ⚠️ 版本过低
  - uv 能输出版本号 → ✅ 符合
- ⚠️ 版本过低的，第 2 步询问用户是否按锁定版本安装 / 升级。Python 3.14 与旧版本共存，安装不破坏现有版本。

### 第 2 步：汇报结果并逐项询问

用表格向用户汇报，并说明每项能为 AI 带来什么能力：

| 项目        | 状态            | 当前版本 | 不装 / 不配的影响           |
| ----------- | --------------- | -------- | --------------------------- |
| Python      | ✅ 已安装        | 3.14.1   | -                           |
| Node.js     | ✅ 已安装        | 24.9.0   | -                           |
| uv          | ⚪ 未安装（可选） | -        | 无法运行 windows-mcp 等 uv 工具 |
| exa 联网搜索 | ⚪ 未配置（可选） | -        | AI 无法联网搜索              |
| windows-mcp | ⚪ 未安装（可选） | -        | 无法使用电脑控制（仅 Windows） |

windows-mcp 一行仅在 Windows 出现；非 Windows 平台不展示、不询问。

**逐项询问用户要安装 / 配置哪些**——三个基础工具中可以只装缺失的；两个可选 MCP（联网搜索、电脑控制）默认不装，用户明确选择才执行。**未获用户明确同意前，不执行任何安装或写配置命令**——这些操作会改动用户系统和软件配置，同意权必须在用户手里。

### 第 3 步：安装基础工具

**安装顺序固定为 Node.js → Python → uv，每装完一项立即验证，通过后再装下一项。** 逐项验证是因为存在依赖链：uv 经 pip 安装，Python 没就绪时装 uv 必然失败；Node 与 Python 互不依赖，但按同一节奏执行能让用户清楚进度。

验证方式与失败处理：

- 验证命令即 `node --version`、`python --version`、`uv --version`（macOS / Linux 用 `python3`）。
- 验证失败多半是 PATH 未刷新：重开终端再验证，或用安装路径下的完整命令，例如 Windows 上 `C:\Program Files\nodejs\node.exe --version`、`%LOCALAPPDATA%\Programs\Python\Python314\python.exe --version`。
- 重试仍失败：Node 失败不阻挡 Python，可继续；Python 失败则 uv 暂停，先把该项的真实错误输出报告给用户。

#### 中文用户：镜像加速

用户使用中文交流时，默认用以下镜像替换官方源，避免跨境下载缓慢或失败：

| 内容                     | 官方源                            | 镜像                                                                 |
| ------------------------ | --------------------------------- | -------------------------------------------------------------------- |
| Node.js 安装包           | nodejs.org                        | `https://npmmirror.com/mirrors/node/`                                 |
| npm registry             | registry.npmjs.org                | `https://registry.npmmirror.com`                                      |
| Python 安装包            | python.org                        | `https://mirrors.aliyun.com/python-release/`（Windows 在 `windows/` 子目录，另有 `macos/`） |
| PyPI（pip / uv tool 安装）| pypi.org                          | `https://mirrors.aliyun.com/pypi/simple/`                             |
| uv 本体                  | winget / astral.sh                | Python 就绪后走 PyPI 镜像：`pip install uv`                           |

#### Windows

非中文用户（优先 winget）：

```powershell
winget install OpenJS.NodeJS.LTS --version 24.22.1
winget install Python.Python.3.14
winget install astral-sh.uv
```

中文用户（优先镜像）：

```powershell
# 1. Node.js 24.22.1：从镜像下载 msi 后安装（弹 UAC 属正常）
Invoke-WebRequest https://npmmirror.com/mirrors/node/v24.22.1/node-v24.22.1-x64.msi -OutFile "$env:TEMP\node-24.22.1.msi"
msiexec /i "$env:TEMP\node-24.22.1.msi"
# 验证 node --version 后继续

# 2. Python 3.14.8：从镜像下载，静默安装到当前用户并加入 PATH
Invoke-WebRequest https://mirrors.aliyun.com/python-release/windows/python-3.14.8-amd64.exe -OutFile "$env:TEMP\python-3.14.8.exe"
& "$env:TEMP\python-3.14.8.exe" /quiet InstallAllUsers=0 PrependPath=1
# 验证 python --version 后继续

# 3. uv：Python 就绪后走 PyPI 镜像
pip install uv -i https://mirrors.aliyun.com/pypi/simple/
# 验证 uv --version
```

#### macOS

```bash
brew install node@24   # 24.x 即可，无需精确版本；验证后继续
brew install python@3.14
brew install uv
```

#### Linux

```bash
# Node.js 24.22.1 → Python 3.14 → uv，按顺序安装并逐步验证
# Node / Python 走发行版包管理器，或从官方与镜像站下载 tarball
# 中文用户镜像域名同上（npmmirror.com / mirrors.aliyun.com）
curl -LsSf https://astral.sh/uv/install.sh | sh   # 中文用户改用 pip 安装
```

#### 通用注意

- 包管理器不可用或源中缺少指定版本时，改用上述安装包方式，不擅自安装包管理器本身。
- 已符合要求的版本不会被改动，直接跳过其安装与验证；已装更低版本 Node 的情况下安装会替换为锁定版本。
- 不使用 `sudo` 安装，除非用户明确要求。

### 第 4 步：配置联网搜索 MCP exa（第 2 步用户选择时执行，否则跳过）

exa 是远程 HTTP MCP，无需本地安装，也不依赖第 3 步的任何工具，全平台可用。把 exa 写入用户级 MCP 配置文件（Windows：`%USERPROFILE%\.magic-harness\cli\config.json`；macOS / Linux：`~/.magic-harness/cli/config.json`）：

```json
{
  "mcp": {
    "servers": {
      "exa": {
        "type": "http",
        "url": "https://mcp.exa.ai/mcp",
        "enabled": true
      }
    }
  }
}
```

注意：

- 编辑现有 config.json 时增量修改，只动 `mcp.servers` 下的 `exa` 条目；文件不存在才新建（含父目录）。
- 已有 `exa` 条目且内容一致 → 跳过；不一致 → 向用户展示差异，经同意后更新。
- 写入完成后，提示用户**重启 Magic Harness** 使联网搜索生效；重启后可在 MCP 设置页确认 exa 已连接。

### 第 5 步：安装并配置电脑控制 MCP windows-mcp（仅 Windows，且第 2 步用户选择时执行，否则跳过）

uv 就绪后，安装 windows-mcp：

```powershell
uv tool install windows-mcp
# 中文用户走 PyPI 镜像（也可设置 UV_INDEX_URL 环境变量）：
uv tool install windows-mcp --index-url https://mirrors.aliyun.com/pypi/simple/
```

在这里装好还有一个附带好处：windows-mcp 首次运行时会下载依赖，耗时可能达 1-2 分钟甚至导致首次连接超时——现在装好，用户第一次使用电脑控制时就不会卡顿。

注意：

- 验证安装：`uv tool list` 输出中应包含 `windows-mcp`。不要运行 `windows-mcp serve` 来验证——它是长驻服务，会一直占用终端。
- 安装后可执行文件位于 `%USERPROFILE%\.local\bin\windows-mcp.exe`，下面写配置要用这个完整路径。
- 语言限制：Windows 首选语言为 English 时体验最佳；非 English 系统上按开始菜单名称启动应用的 App-Tool 可能不可靠，需如实告知用户这一限制。
- 开机自启（`windows-mcp install`，创建计划任务）不需要——Magic Harness 会按需通过 stdio 拉起 MCP。

安装验证通过后，把 windows-mcp 写入用户级 MCP 配置文件 `%USERPROFILE%\.magic-harness\cli\config.json`：

```json
{
  "mcp": {
    "servers": {
      "windows-mcp": {
        "type": "stdio",
        "command": "C:\\Users\\<用户名>\\.local\\bin\\windows-mcp.exe",
        "args": ["serve"],
        "enabled": true
      }
    }
  }
}
```

注意：

- 编辑现有 config.json 时增量修改，只动 `mcp.servers` 下的 `windows-mcp` 条目；文件不存在才新建（含父目录）。
- `command` 必须用完整路径并把 `<用户名>` 替换为实际值：Magic Harness 桌面端不继承终端 PATH，写 `uvx` 或 `windows-mcp` 这种裸命令会连接失败。
- 已有 `windows-mcp` 条目且内容一致 → 跳过；不一致 → 向用户展示差异，经同意后更新。
- 写入完成后，提示用户**重启 Magic Harness** 使电脑控制生效；重启后可在 MCP 设置页确认 windows-mcp 已连接。

### 第 6 步：总结

输出最终结果汇总：

- 已就绪项 → 说明 AI 现在具备了哪些能力（联网搜索、npm 生态工具、电脑控制等）。
- 用户选择跳过或安装失败项 → 如实说明对应的能力限制，告知以后随时可以重新配置。

## 约束

- 安装类命令和写配置操作必须经用户同意后执行，执行前展示具体命令。
- 尊重用户的跳过选择，不反复劝说安装——这些本就是可选增强项。
- 不修改用户系统配置（如系统 PATH、系统语言、npm/uv 持久配置），除非用户同意。
- 安装失败时报告真实错误输出，不伪装成功。