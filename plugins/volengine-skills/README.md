# Volcengine Skills Plugin

> 火山引擎多技能插件 - 集成字节火山引擎多种 AI 能力

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-orange.svg)](../../LICENSE)
[![Volcengine](https://img.shields.io/badge/Volcengine-AI-green.svg)](https://www.volcengine.com/)

## ✨ 当前技能

### 🎤 ASR Transcriber (音频转文字)
- 使用字节火山引擎 ASR API 将录音转换为文本
- 支持中英文及多种方言、日语韩语等 10+ 种语言
- 自动上传本地文件（最大 100MB）
- 智能模型选择（优先 Model 2.0，自动降级到 Model 1.0）
- 生成 JSON 和 TXT 双格式输出

[查看 ASR 文档 →](skills/asr-transcriber/SKILL.md)

## 📦 安装

### 前置要求

- **Claude Code**: 最新版本
- **Volcengine API 密钥**: 从 [火山引擎控制台](https://console.volcengine.com/openspeech) 获取

### 安装插件

```bash
/plugin install https://github.com/qso/claude-plugins-qso?path=plugins/volengine-skills
```

### 配置 API 密钥

```bash
export VOLCENGINE_API_APP_KEY='your-app-key'
export VOLCENGINE_API_ACCESS_KEY='your-access-key'
```

将此行添加到 `~/.bashrc` 或 `~/.zshrc` 以永久保存。

## 🚀 快速开始

### ASR 转写示例

```bash
# 转写本地文件（自动上传）
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "/path/to/meeting.mp3"

# 转写网络音频
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "https://example.com/audio.mp3"

# 指定输出目录
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "/path/to/audio.mp3" mp3 "" 3 "$CLAUDE_PROJECT_DIR/transcripts"
```

### 查找输出

```bash
# 默认输出位置
ls "$CLAUDE_PROJECT_DIR/assets/"
```

## 📖 文档

- [ASR Transcriber Skill 文档](skills/asr-transcriber/SKILL.md)
- [ASR 命令参考](commands/transcribe.md)
- [ASR 变更日志](skills/asr-transcriber/CHANGELOG.md)
- [插件变更日志](CHANGELOG.md)

## 🤝 贡献

欢迎贡献！请随时提交 Issue 或 Pull Request。

## 📄 许可证

MIT License - see [LICENSE](../../LICENSE)

## 🙏 致谢

- **字节火山引擎**: 提供强大的 AI 能力
- **Claude Code**: 提供插件平台

## 📮 支持

- **Issues**: https://github.com/qso/claude-plugins-qso/issues
- **Discussions**: https://github.com/qso/claude-plugins-qso/discussions
