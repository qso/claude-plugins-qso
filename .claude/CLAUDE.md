# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

QSO 插件市场，包含多个高质量的 Claude Code 插件，提供 AI 演示生成、深度调研和火山引擎 AI 能力集成。

## 核心架构

### 三层结构
```
Marketplace (市场配置)
  ↓
Plugins (独立插件)
  ↓
Components (commands/skills/hooks)
```

### 关键配置文件

1. **市场配置** (`/.claude-plugin/marketplace.json`)
   - 定义市场信息和插件列表
   - 每个插件包含：name、source、description、version、author

2. **插件配置** (`/plugins/<name>/.claude-plugin/plugin.json`)
   - 定义单个插件的元信息
   - 声明 commands/skills/hooks 目录路径

### 三种组件类型

**Commands（命令）**
- 位置：`plugins/<name>/commands/*.md`
- 用途：用户可显式调用的命令（如 `/plugin:command`）
- 特点：
  - Front matter 中通过 `allowed-tools` 声明权限
  - 可用 `!`command`` 注入动态上下文
  - 一个 .md 文件对应一个命令

**Skills（技能）**
- 位置：`plugins/<name>/skills/<skill-name>/SKILL.md`
- 用途：Claude 根据用户意图自动激活的知识库
- 特点：
  - Front matter 包含 name 和 description
  - 存储完整的知识、代码示例、最佳实践
  - Claude 自动匹配用户需求并应用相关 skill

**Hooks（钩子）**
- 位置：`plugins/<name>/hooks/hooks.json`
- 用途：在特定事件触发时执行脚本
- 特点：
  - 监听事件：`UserPromptSubmit`、`Stop`、`Notification` 等
  - 脚本通过 stdin 接收 JSON 数据
  - 使用 `${CLAUDE_PLUGIN_ROOT}` 引用插件目录

## 命名约定

- **所有配置和插件名**：使用 kebab-case（如 `nanobanana-ppt`、`deep-research`）
- **版本号**：遵循语义化版本（x.y.z）
- **描述信息**：统一使用中文
- **Commit 规范**：遵循 Conventional Commits（feat/fix/docs/chore/refactor）

## 版本号管理规范

**⚠️ 重要：插件变更后必须修改版本号**

每次对插件进行修改后，必须严格遵守以下版本号更新规则：

### 版本号格式：x.y.z

- **x**：主版本号（Major）
- **y**：次版本号（Minor）
- **z**：修订号（Patch）

### 版本号更新规则

1. **修订号（z）更新** - Bug 修复、小问题修正
   - **适用场景**：
     - 修复 Bug
     - 修复路径引用问题
     - 修复脚本错误
     - 文档错误修正
     - 代码优化（不影响功能）
   - **示例**：`1.1.0` → `1.1.1`
   - **说明**：向后兼容，仅修复问题

2. **次版本号（y）更新** - 新增功能、需求迭代
   - **适用场景**：
     - 添加新的技能（Skill）
     - 添加新的命令（Command）
     - 添加新的配置选项
     - 功能增强和改进
     - 新增 API 支持
   - **示例**：`1.1.0` → `1.2.0`
   - **说明**：向后兼容，添加新功能
   - **注意**：次版本号更新时，修订号重置为 0

3. **主版本号（x）更新** - 大规模能力更新、架构调整
   - **适用场景**：
     - 插件架构重构
     - 不兼容的 API 变更
     - 核心功能大规模重写
     - 移除已废弃的功能
     - 重大功能升级
   - **示例**：`1.2.0` → `2.0.0`
   - **说明**：可能不向后兼容
   - **注意**：主版本号更新时，次版本号和修订号都重置为 0

### 版本更新流程

每次修改插件时，必须按照以下流程更新版本：

1. **修改插件代码**
   - 修复 Bug、添加功能或重构代码

2. **更新 `plugin.json` 版本号**
   - 文件位置：`plugins/<plugin-name>/.claude-plugin/plugin.json`
   - 修改 `version` 字段
   - 可选：在 `description` 字段中添加版本说明

3. **更新 `marketplace.json` 版本号** ⚠️ 必须同步
   - 文件位置：`.claude-plugin/marketplace.json`
   - 找到对应插件的配置项
   - 修改 `version` 字段（与 plugin.json 保持一致）
   - 同时更新 marketplace 的 `metadata.version`

4. **提交代码**
   - Commit 消息应包含版本信息
   - 示例：`feat: 添加参考资料保存功能 (v1.2.0)`

### 实际示例

**示例 1：Bug 修复（修订号更新）**
```diff
{
  "name": "deep-research",
- "version": "1.2.0",
+ "version": "1.2.1",
}
```
Commit: `fix: 修复中文显示问题 (v1.2.1)`

**示例 2：新增功能（次版本号更新）**
```diff
{
  "name": "deep-research",
- "version": "1.2.0",
+ "version": "1.3.0",
}
```
Commit: `feat: 添加参考资料保存机制 (v1.3.0)`

**示例 3：架构重构（主版本号更新）**
```diff
{
  "name": "deep-research",
- "version": "1.3.0",
+ "version": "2.0.0",
}
```
Commit: `feat!: 重构研究流程，采用新的 8 阶段管道 (v2.0.0)`

### 检查清单

在提交代码前，请确认：

- [ ] 已根据变更类型更新版本号
- [ ] 已更新 `plugin.json` 中的 `version` 字段
- [ ] 已更新 `marketplace.json` 中对应插件的 `version` 字段（与 plugin.json 一致）
- [ ] 已更新 `marketplace.json` 中的 `metadata.version`（市场版本号）
- [ ] 版本号遵循语义化版本规范
- [ ] Commit 消息包含版本号
- [ ] 版本号更新与实际变更匹配

## 开发任务

### 添加新插件

1. 在 `plugins/` 下创建插件目录
2. 创建 `.claude-plugin/plugin.json`：
   ```json
   {
       "name": "plugin-name",
       "version": "1.0.0",
       "description": "插件描述",
       "author": {"name": "作者名"},
       "license": "MIT",
       "commands": "./commands",
       "skills": "./skills",
       "hooks": "./hooks/hooks.json"
   }
   ```
3. 实现 commands/skills/hooks（按需选择）
4. 更新 `/.claude-plugin/marketplace.json`，在 `plugins` 数组中注册

### 添加新命令

1. 在 `plugins/<name>/commands/` 创建 `command-name.md`
2. 定义 Front Matter：
   ```markdown
   ---
   allowed-tools: Bash(action:*), Read:*, Edit:*
   description: 命令的简洁描述
   ---

   ## Context
   - Current state: !`git status`

   ## Your task
   具体任务说明和期望行为
   ```
3. 命令自动注册（无需修改 plugin.json）

### 添加新技能

1. 在 `plugins/<name>/skills/` 创建 `skill-name/` 目录
2. 创建 `SKILL.md`：
   ```markdown
   ---
   name: 技能中文名称
   description: 简洁描述何时使用此技能
   ---

   # 技能标题

   ## 触发场景
   描述用户何时需要此技能

   ## 核心知识和规范
   详细的知识、代码示例、最佳实践

   ## 执行流程
   当用户请求此技能时的步骤
   ```
3. 可选：创建 `README.md` 作为用户文档
4. 技能自动注册（无需修改 plugin.json）

### 添加新 Hook

1. 编写 Hook 处理脚本（Python/Shell）到 `plugins/<name>/scripts/`
2. 在 `plugins/<name>/hooks/hooks.json` 中注册：
   ```json
   {
       "description": "Hook 功能说明",
       "hooks": {
           "EventName": [
               {
                   "hooks": [
                       {
                           "type": "command",
                           "command": "${CLAUDE_PLUGIN_ROOT}/scripts/script.py EventName"
                       }
                   ]
               }
           ]
       }
   }
   ```
3. 确保脚本有执行权限：`chmod +x script.py`

## 现有插件说明

### nanobanana-ppt 插件
使用 Google Nano Banana Pro AI 生成专业 PPT 演示文稿。

**核心功能**:
- 多种视觉风格支持
- 细粒度页面分配
- 插件式动态风格系统
- 基于 MCP 的图像生成

### deep-research 插件
企业级深度调研，支持多源综合、引用跟踪和验证。

**核心功能**:
- 8 阶段研究管道
- 来源可信度评分
- 并行信息检索
- 参考资料保存机制
- 默认中文输出，LLM 驱动 HTML 生成

**Research Types**:
- technical: 技术框架深度调研
- comparison: 对比分析
- market: 市场/商业分析
- stock: 股票投资分析
- general: 通用调研
- exploratory: 探索性研究

### volengine-skills 插件
火山引擎 AI 能力集成，目前包含 ASR 语音识别。

**核心功能**:
- 自动语音识别（ASR）
- 多语言和多说话人支持
- 音频转文字转录

## 权限配置

### Commands 权限控制
通过 `allowed-tools` 声明命令可使用的工具：
- 格式：`ToolName(action:permission)`
- 通配符：`*` 表示所有权限
- 示例：
  - `Bash(git add:*)`: 允许所有 git add 操作
  - `Read:*`: 允许读取所有文件
  - `Edit(/path/to/file:*)`: 仅允许编辑特定文件

### 本地权限配置
位置：`/.claude/settings.local.json`
- 控制 Claude Code 在本地执行的权限
- 允许特定命令、路径访问等

## 技术实现细节

### Commands 的上下文注入
在 Front Matter 中使用 `!`command`` 可在调用时动态执行：
```markdown
## Context
- Current branch: !`git branch --show-current`
- Status: !`git status --short`
```

### Skills 的自动激活
Claude 会：
1. 分析用户意图
2. 匹配相关 skill 的 description
3. 自动读取并应用 SKILL.md 中的知识
4. 执行相应的任务

### Hooks 的数据传递
Hook 脚本接收 JSON 数据通过 stdin：
```json
{
    "session_id": "会话 ID",
    "prompt": "用户输入",
    "cwd": "工作目录",
    "hook_event_name": "事件名称"
}
```

脚本通过命令行参数获取事件类型：
```bash
python script.py EventName < input.json
```

### 脚本路径引用规范

#### 在 SKILL.md 文档中

**标准格式**：使用 `${CLAUDE_PLUGIN_ROOT}` 环境变量

```bash
# 执行脚本示例
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/script.py --option value
```

**说明**：
- Claude Code 在执行技能时会自动设置 `CLAUDE_PLUGIN_ROOT` 环境变量
- 该变量指向插件根目录
- 使用环境变量确保脚本在开发和运行时环境都能正常工作

## 依赖要求

### nanobanana-ppt 插件
- MCP 服务器：nanobanana-pro-mcp-server
- API Key 配置

### deep-research 插件
- Python 3
- Exa MCP（可选，需要 EXA_API_KEY）
- WebSearch 工具（内置）
- WebFetch 工具（内置）

### volengine-skills 插件
- Python 3
- 火山引擎 API 访问权限

### 通用依赖
- Git（所有插件）
- Python 3（脚本类插件）

## 插件安装与注册

```bash
# 在 Claude Code 中添加市场（从 GitHub）
/plugin marketplace add https://github.com/qso/claude-plugins-qso.git

# 验证插件配置
cat plugins/<plugin-name>/.claude-plugin/plugin.json
```

## 参考示例

查看现有插件代码了解实现细节：
- **Skills 示例**:
  - `plugins/deep-research/skills/deep-research/SKILL.md` - 完整的深度调研流程
  - `plugins/nanobanana-ppt/skills/nanobanana-ppt:generate/SKILL.md` - PPT 生成技能
- **配置示例**:
  - `plugins/deep-research/.claude-plugin/plugin.json` - 标准插件配置
  - `.claude-plugin/marketplace.json` - 市场配置
