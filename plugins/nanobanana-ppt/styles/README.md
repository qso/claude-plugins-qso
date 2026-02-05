# 风格库

本目录包含所有可用的视觉风格定义。每个风格都是一个独立的 Markdown 文件,包含元数据和提示词模板。

## 可用风格

### gradient-glass
- **风格名称**: 渐变毛玻璃卡片风格
- **文件**: [gradient-glass.md](gradient-glass.md)
- **标签**: modern, tech, glass, 3d, futuristic
- **适用场景**: 科技产品、商务演示、数据报告、品牌展示

**特点**:
- Apple Keynote 极简主义
- 玻璃拟态效果
- 霓虹渐变色
- 3D 玻璃物体
- 电影级光照

### vector-illustration
- **风格名称**: 矢量插画风格
- **文件**: [vector-illustration.md](vector-illustration.md)
- **标签**: flat, vector, retro, education, warm
- **适用场景**: 教育培训、创意提案、品牌故事、儿童内容

**特点**:
- 扁平化矢量设计
- 黑色轮廓线
- 复古柔和配色
- 几何化简化
- 玩具模型感

### linear-web
- **风格名称**: 线性网页风格
- **文件**: [linear-web.md](linear-web.md)
- **标签**: minimal, flat, web, modern, clean, swiss
- **适用场景**: 科技创业、产品发布、设计作品集、极简主义品牌展示

**特点**:
- 极致简约主义
- 平面几何设计
- 细线条装饰
- 大量留白
- 严格网格系统
- 左对齐排版
- 现代无衬线字体
- 网页交互元素形式感

## 添加新风格

想要添加自己的风格?按照以下步骤:

### 1. 创建风格文件

在此目录创建新的 `.md` 文件,例如 `my-style.md`

### 2. 添加必填元数据

在文件开头添加 HTML 注释格式的元数据:

```markdown
<!--
风格元数据(必填)
style_id: my-style
style_name: 我的风格名称
version: 1.0.0
author: your-name
tags: tag1, tag2, tag3
use_cases: use-case-1, use-case-2
-->
```

**字段说明**:
- `style_id`: 唯一标识符,使用 kebab-case
- `style_name`: 显示名称
- `version`: 版本号,遵循语义化版本
- `author`: 作者名
- `tags`: 标签,逗号分隔
- `use_cases`: 使用场景,逗号分隔

### 3. 定义基础提示词模板

```markdown
## 基础提示词模板

你是一位专家级设计师...
[你的风格描述和全局指令]
```

### 4. 定义页面类型模板

```markdown
## 页面类型模板

### 封面页模板
构图逻辑: ...
使用场景: ...

### 内容页模板
构图逻辑: ...
使用场景: ...

### 数据页模板
构图逻辑: ...
使用场景: ...
```

### 5. 测试风格

使用 `/nanobanana-ppt:generate` 命令测试你的新风格:

```bash
/nanobanana-ppt:generate my-document.md
# 在风格选择时选择你的新风格
```

### 6. 更新本 README

在"可用风格"部分添加你的风格信息。

## 风格模板规范

### 必填部分
- 元数据注释 (HTML 注释格式)
- 基础提示词模板
- 页面类型模板 (封面页、内容页、数据页)

### 推荐部分
- 风格描述
- 使用示例
- 技术参数
- 最佳实践

### 文件命名
- 使用 kebab-case: `my-style-name.md`
- 与 `style_id` 保持一致
- 避免空格和特殊字符

## 风格开发最佳实践

1. **清晰的视觉定位**: 明确风格的视觉特征和适用场景
2. **详细的提示词**: 提供足够细节让 AI 生成一致的风格
3. **页面类型差异化**: 确保三种页面类型有明显的构图差异
4. **测试验证**: 至少用 3 个不同主题的文档测试
5. **文档完整**: 添加使用示例和效果预览(如果可能)

## 贡献指南

如果你创建了优秀的风格,欢迎通过 Pull Request 贡献到此仓库:

1. Fork 此仓库
2. 创建风格文件并按规范填写
3. 在本 README 添加风格信息
4. 提交 PR 并附上生成效果截图

---

**提示**: 使用 `/nanobanana-ppt:styles` 命令可以快速查看所有可用风格。
