# 示例文档

本目录包含用于测试 NanoBanana PPT 插件的示例文档。

## 文件列表

### sample-document.md

一份关于 AI 产品设计的完整示例文档，包含：

- **5 个主要章节**
- **清晰的结构层次**
- **要点和子要点**
- **案例研究**
- **数据和建议**

适合测试不同页数的 PPT 生成：
- **5 页版本**：每章一页 + 封面
- **10 页版本**：详细展开核心章节
- **15 页版本**：包含所有案例和详细内容
- **20+ 页版本**：完整深入的演示

## 使用方法

### 快速测试

```bash
# 生成 5 页 PPT
/nanobanana-ppt:generate examples/sample-document.md

# 选择：
# - 幻灯片数量：5
# - 风格：渐变毛玻璃卡片风格
# - 分辨率：2K
```

### 测试不同风格

**渐变毛玻璃风格**（适合此文档）：
```bash
/nanobanana-ppt:generate examples/sample-document.md
# 选择 Gradient Glass 风格
```

原因：技术和商务内容，适合未来科技感

**矢量插画风格**：
```bash
/nanobanana-ppt:generate examples/sample-document.md
# 选择 Vector Illustration 风格
```

原因：如果想要更温暖、友好的视觉效果

### 测试不同页数

#### 5 页精简版

重点内容：
1. 封面
2. AI 设计原则
3. 用户体验
4. 技术实现
5. 总结与展望

```bash
/nanobanana-ppt:generate examples/sample-document.md
# 选择 5 页
```

#### 10 页标准版

详细内容：
1. 封面
2. 概述和背景
3-4. 设计原则（拆分为 2 页）
5-6. 用户体验设计
7. 技术实现
8-9. 案例研究
10. 未来展望和总结

```bash
/nanobanana-ppt:generate examples/sample-document.md
# 选择 10 页
```

#### 15 页详细版

完整内容，每个章节深入展开。

```bash
/nanobanana-ppt:generate examples/sample-document.md
# 选择 15 页
```

## 预期结果

生成的 PPT 将包含：

- **封面页**：标题和主题
- **内容页**：章节要点，使用 Bento 网格或矢量插画布局
- **数据页**：案例研究、数据对比、总结

所有页面将使用选定的视觉风格，保持一致的美学。

## 测试清单

测试时验证以下内容：

- [ ] 文档内容被正确分析
- [ ] 章节结构被识别
- [ ] 要点被提取
- [ ] 页面类型正确分配（cover/content/data）
- [ ] 生成的提示词合理
- [ ] 图片质量符合预期
- [ ] 播放器正常工作
- [ ] 所有快捷键可用

## 创建自己的测试文档

### 好的测试文档特征

✅ **清晰的结构**
```markdown
# 主标题

## 第一章
### 小节
- 要点 1
- 要点 2

## 第二章
...
```

✅ **适当的长度**
- 5 页 PPT：2-3 个主要章节
- 10 页 PPT：4-5 个主要章节
- 15 页 PPT：5-7 个主要章节

✅ **内容组织**
- 每个章节有明确主题
- 使用列表整理要点
- 包含关键数据或案例
- 有清晰的开头和结尾

❌ **避免**
- 过长的段落（难以提取要点）
- 没有结构的流水文字
- 过于复杂的嵌套
- 缺乏关键信息

## 反馈和改进

如果生成的 PPT 不符合预期：

1. **检查文档结构**：确保有清晰的章节划分
2. **查看生成的 JSON**：`slides_plan.json` 显示了内容规划
3. **调整页数**：尝试不同的页数选择
4. **更换风格**：尝试另一种视觉风格
5. **提供反馈**：在 GitHub Issues 报告问题

## 更多示例

你可以使用任何 Markdown 文档测试插件：

```bash
# 使用项目中的其他文档
/nanobanana-ppt:generate README.md
/nanobanana-ppt:generate QUICKSTART.md
/nanobanana-ppt:generate ENV_SETUP.md

# 使用你自己的文档
/nanobanana-ppt:generate ~/Documents/my-project-plan.md
```

---

**开始测试吧！** 🚀

```bash
/nanobanana-ppt:generate examples/sample-document.md
```

