---
title: "{{ replace .File.ContentBaseName "-" " " }}"
description: "一句话简介，会显示在文章列表里"
slug: "{{ .File.ContentBaseName }}"
date: {{ .Date }}
# 封面图：把图片放进本文件夹，再写文件名，例如 cover.jpg；不需要就留空
image:
# 分类只从这 5 个里选：学习笔记、科研记录、编程技术、大学生活、其他
categories:
    - 其他
tags:
    -
# true 表示草稿：本地 hugo server -D 能看到，正式网站不会发布
draft: true
---

## 第一个小标题

正文从这里开始。图片放在本文件夹里，用 `![说明](图片文件名.jpg)` 引用。

行内公式写 $a^2+b^2=c^2$，块级公式写在两个 `$$` 之间。
