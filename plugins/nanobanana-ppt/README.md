# NanoBanana PPT Generator

> 使用 Google Gemini Nano Banana Pro AI 生成专业 PPT 演示文稿的 Claude Code 插件

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)
[![MCP](https://img.shields.io/badge/MCP-integrated-green.svg)](https://modelcontextprotocol.io)
[![License](https://img.shields.io/badge/license-MIT-orange.svg)](../../LICENSE)

## ✨ 特性

### 🎨 双风格系统
- **渐变毛玻璃卡片风格**: 现代科技感,适合商务演示和产品发布
- **矢量插画风格**: 温暖创意风格,适合教育培训和品牌故事

### 📊 精细化页数控制 (v2.0 新特性)
- **自动分配**: 基于内容长度智能分配每章页数
- **自定义分配**: 手动指定每章的确切页数
- **实时验证**: 确保总页数符合预期

### ⚡ MCP 集成 (v2.0 重大更新)
- 使用 Model Context Protocol 进行图片生成
- 无需安装 Python SDK 依赖
- 自动模型选择 (Flash/Pro)
- 更稳定的 API 调用

### 🎬 交互式播放器
- HTML5 全屏播放器
- 键盘快捷键控制
- 自动播放模式
- 响应式设计

## 📦 安装

### 前置要求

- **Claude Code**: 最新版本
- **uvx**: Python 包运行器
  ```bash
  pip install uv
  ```
- **Gemini API Key**: 从 [Google AI Studio](https://makersuite.google.com/app/apikey) 获取

### 安装插件

```bash
/plugin install https://github.com/qso/claude-plugins-qso?path=plugins/nanobanana-ppt
```

### 配置 API Key

```bash
export GEMINI_API_KEY='your-google-ai-api-key'
```

将此行添加到 `~/.bashrc` 或 `~/.zshrc` 以永久保存。

### 验证安装

运行 setup 命令验证配置:

```bash
/nanobanana-ppt:setup
```

## 🚀 快速开始

### 基础用法

```bash
/nanobanana-ppt:generate my-document.md
```

然后按照交互式提示:
1. 选择幻灯片总数 (5/10/15/20+)
2. 选择视觉风格
3. 选择分辨率 (2K/4K)
4. 选择页数分配方式
5. 等待生成完成

### 自然语言调用

也可以使用自然语言:

```
帮我用 gradient-glass 风格生成一个 15 页的 PPT，用我的产品路线图文档
```

### 查看可用风格

```bash
/nanobanana-ppt:styles
```

## 📖 使用场景

### 场景 1: 快速 5 页演示

**需求**: 会议纪要转 PPT

```bash
/nanobanana-ppt:generate meeting-notes.md
# 选择: 5 页 → gradient-glass → 2K → 接受自动分配
```

**生成时间**: ~2.5 分钟 (每页约 30 秒)

### 场景 2: 自定义分配的 15 页演示

**需求**: 产品路线图,重点突出实施章节

```bash
/nanobanana-ppt:generate product-roadmap.md
# 选择: 15 页 → vector-illustration → 2K → 自定义分配
```

**自定义分配示例**:
```
封面: 1 页
第1章 "背景": 2 页
第2章 "规划": 2 页
第3章 "实施": 7 页 ← 重点章节
第4章 "发布": 2 页
总结: 1 页
━━━━━━━━━━━━━━━
总计: 15 页 ✓
```

### 场景 3: 高质量 4K 演示

**需求**: 大屏展示或打印

```bash
/nanobanana-ppt:generate annual-report.md
# 选择: 20 页 → gradient-glass → 4K → 自动分配
```

**注意**: 4K 生成速度较慢 (~60 秒/页),总时间约 20 分钟

## 🎨 风格指南

### Gradient Glass (渐变毛玻璃)

**视觉特征**:
- Apple Keynote 极简主义
- 玻璃拟态效果
- 霓虹渐变色 (#00D9FF / #7B2CFF)
- 3D 玻璃物体
- 电影级光照

**适用场景**:
- 科技产品发布
- 商务演示
- 数据报告
- 品牌展示

**示例提示词**:
```
使用 gradient-glass 风格生成产品发布 PPT
```

### Vector Illustration (矢量插画)

**视觉特征**:
- 扁平化矢量设计
- 黑色轮廓线 (3-5px)
- 复古柔和配色
- 几何化简化
- 玩具模型感

**适用场景**:
- 教育培训
- 创意提案
- 品牌故事
- 儿童内容

**示例提示词**:
```
使用 vector-illustration 风格生成培训课件
```

## 📁 输出结构

生成完成后,文件会保存在:

```
outputs/YYYYMMDD_HHMMSS/
├── images/
│   ├── slide-01.png
│   ├── slide-02.png
│   └── ...
├── slides_plan.json      # 内容规划和页数分配
├── prompts.json          # 生成提示词日志
└── index.html            # HTML5 播放器
```

### 播放器快捷键

- `→` / `←` : 切换幻灯片
- `Home` / `End` : 跳到首页/尾页
- `Space` : 暂停/继续自动播放
- `Esc` : 全屏模式
- `H` : 隐藏/显示控件

## ⚙️ 高级配置

### slides_plan.json 结构

v2.0 增强了元数据:

```json
{
  "metadata": {
    "title": "Presentation Title",
    "total_slides": 15,
    "style": "gradient-glass",
    "resolution": "2K",
    "allocation_strategy": "custom",
    "created_at": "2026-01-22T10:30:00Z"
  },
  "allocation": {
    "cover": 1,
    "chapters": [
      {
        "chapter_number": 1,
        "chapter_title": "Introduction",
        "slides_allocated": 2,
        "slide_numbers": [2, 3]
      }
    ],
    "summary": 2
  },
  "slides": [...]
}
```

### MCP 配置

插件使用 `.claude-plugin/.mcp.json` 配置 MCP 服务器:

```json
{
  "mcpServers": {
    "nanobanana": {
      "command": "uvx",
      "args": ["nanobanana-pro-mcp-server"],
      "env": {
        "GEMINI_API_KEY": "${GEMINI_API_KEY}"
      }
    }
  }
}
```

### 模型选择逻辑

MCP 服务器会自动选择模型:

- **Flash Model** (gemini-2.5-flash-image):
  - 速度: ~2-3 秒/图
  - 最大分辨率: 1024px
  - 用于: 2K 输出, 快速原型

- **Pro Model** (gemini-3-pro-image):
  - 速度: ~5-8 秒/图
  - 最大分辨率: 4K (3840px)
  - 特性: Google Search grounding, 高级推理
  - 用于: 4K 输出, 文字渲染

## 🔄 从 v1.0 迁移

### 卸载旧版本

```bash
/plugin uninstall nanobanana-ppt
```

### 安装新版本

```bash
/plugin install https://github.com/qso/claude-plugins-qso?path=plugins/nanobanana-ppt
```

### 主要变更

| 特性 | v1.0.0 | v2.0.0 |
|------|--------|--------|
| **图片生成** | 直接 SDK | MCP |
| **Python 依赖** | 必需 | 可选 |
| **安装方式** | 手动 | Plugin URL |
| **模型选择** | 手动 | 自动 (MCP) |
| **页数分配** | 固定 | 精细化 |
| **风格系统** | 静态 | 动态 |
| **仓库** | 独立 | Marketplace |

### 不兼容变更

- 安装路径改变
- 不再需要 `google-genai` Python 包
- MCP 配置必需
- slides_plan.json 格式增强

完整变更日志: [CHANGELOG.md](CHANGELOG.md)

## 🛠️ 故障排除

### MCP 服务器未配置

**错误**: `nanobanana MCP server not found`

**解决方案**:
```bash
# 确保 .mcp.json 配置正确
# 验证 uvx 已安装
pip install uv

# 运行 setup 命令
/nanobanana-ppt:setup
```

### API Key 未设置

**错误**: `GEMINI_API_KEY environment variable not set`

**解决方案**:
```bash
export GEMINI_API_KEY='your-api-key'

# 永久保存
echo 'export GEMINI_API_KEY="your-api-key"' >> ~/.zshrc
source ~/.zshrc
```

### MCP 工具调用失败

**错误**: `generate_image tool failed`

**解决方案**:
1. 检查 MCP 服务器运行状态
2. 验证 API key 有效性
3. 检查网络连接
4. 重试失败的幻灯片

### 页数分配不匹配

**错误**: `Total allocated pages don't match requested count`

**解决方案**:
- 重新计算分配
- 调整各章页数
- 使用自动分配模式

## 📚 文档

- [快速开始](../../QUICKSTART.md)
- [完整 Skill 文档](skills/ppt-generator/SKILL.md)
- [命令参考](commands/)
- [风格开发指南](styles/README.md)
- [变更日志](CHANGELOG.md)

## 🤝 贡献

欢迎贡献新风格! 参考 [风格开发指南](styles/README.md)

贡献流程:
1. Fork 仓库
2. 创建风格文件并测试
3. 更新 `styles/README.md`
4. 提交 PR 并附上效果截图

## 📄 许可证

MIT License - see [LICENSE](../../LICENSE)

## 🙏 致谢

- **Google Gemini**: 提供 Nano Banana Pro 图片生成能力
- **Claude Code**: 提供强大的插件平台
- **MCP**: 提供标准化工具集成协议

## 📮 支持

- **Issues**: https://github.com/qso/claude-plugins-qso/issues
- **Discussions**: https://github.com/qso/claude-plugins-qso/discussions

---

**提示**: 使用 `/nanobanana-ppt:styles` 快速查看所有可用风格
