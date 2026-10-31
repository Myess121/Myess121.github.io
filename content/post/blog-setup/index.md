---
title: 我的博客搭建记录
description: 【示例内容】记录本博客的搭建过程，同时用来测试标题、目录、表格、代码、图片和数学公式的显示效果。
slug: blog-setup
date: 2026-10-31
image: cover.jpg
math: true
categories:
    - 学学习
tags:
    - Hugo
    - 示例
---

> **这是一篇示例文章**，用来检查博客的各种排版效果是否正常。确认无误后，可以修改或删除它（删除整个 `content/post/blog-setup` 文件夹即可）。

# 一级标题：搭建概览

> 文章标题本身就是页面的一级标题，正文里一般从二级标题（`##`）开始写。这里的一级标题只是为了测试显示效果；目录默认只收录二级到四级标题。

中英文混排测试：Hugo 是用 Go 语言写的 static site generator，单个文件 `hugo.exe` 就能运行；数学和文字混排如 $O(n\log n)$ 的排序算法也能正常显示。

## 二级标题：为什么选择 Hugo

Hugo 是一个**静态网站生成器**：它把我们写的 Markdown 文件，加上主题模板，一次性“编译”成纯 HTML 网页。生成的网页不需要数据库、不需要服务器程序，所以可以免费放在 GitHub Pages 上。

### 三级标题：整体流程

1. 在本地用 Markdown 写文章；
2. 用 `git push` 把代码推送到 GitHub；
3. GitHub Actions 自动运行 Hugo，生成网页；
4. GitHub Pages 把网页发布到 `https://Myess121.github.io/`。

## 表格测试

| 组成部分 | 作用 | 是否收费 |
| --- | --- | :---: |
| Hugo | 把 Markdown 生成网页 | 免费 |
| Stack 主题 | 决定网站长什么样 | 免费 |
| GitHub Actions | 自动构建、部署 | 免费 |
| GitHub Pages | 托管网站 | 免费 |

## 代码块测试

在本地预览博客的命令：

```powershell
hugo server
```

一段 Python 代码：

```python
def fib(n: int) -> int:
    """返回第 n 个斐波那契数"""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

print(fib(10))  # 55
```

## 图片测试

图片和文章放在同一个文件夹里，直接用相对路径引用：

![示例图片](cover.jpg)

## 数学公式测试

行内公式：质能方程 $E = mc^2$，以及欧拉公式 $e^{i\pi} + 1 = 0$。

块级公式（高斯积分）：

$$
\int_{-\infty}^{+\infty} e^{-x^2}\,\mathrm{d}x = \sqrt{\pi}
$$

矩阵：

$$
A = \begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}, \quad \det A = -2
$$

## 目录说明

文章右侧（手机上在文章顶部）会根据二级、三级标题自动生成目录，不需要手写。
