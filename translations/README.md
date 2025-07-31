# 国际化 (Internationalization) 说明

## 📋 概述

本项目支持中英文双语切换，翻译文件位于 `translations/` 目录。

## 🌍 支持的语言

- 🇨🇳 中文 (zh_CN) - 默认语言
- 🇺🇸 英文 (en)

## 🎮 使用方法

### 在游戏中切换语言

- 在关卡选择页面按 **Ctrl+L** 切换语言
- 支持实时切换，无需重启游戏

### 添加新的翻译文本

1. 在 `translations/strings.csv` 中添加新的翻译条目
2. 格式：`翻译键,英文文本,中文文本`
3. 在代码中使用 `Tr("翻译键")` 获取翻译文本

## 📁 文件结构

```
translations/
├── strings.csv          # 翻译文件（CSV格式）
├── strings.csv.import   # Godot导入配置
└── README.md           # 本说明文档
```

## 🔧 配置

翻译配置在 `project.godot` 文件的 `[internationalization]` 部分：

```ini
[internationalization]
locale/translations=PackedStringArray("res://translations/strings.csv")
locale/fallback="zh_CN"
```

## 📝 当前翻译键

- `LEVEL_SELECT_TITLE` - 关卡选择页面标题
- `LEVEL_SELECT_INSTRUCTIONS` - 操作说明

## 🚀 开发建议

- 所有用户可见的文本都应使用翻译键
- 翻译键使用大写字母和下划线命名
- 及时更新翻译文件以保持同步
