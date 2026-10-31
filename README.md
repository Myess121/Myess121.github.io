# Myess121 的个人博客

网站地址：<https://Myess121.github.io/>

基于 [Hugo](https://gohugo.io/) + [Hugo Theme Stack v4](https://github.com/CaiJimmy/hugo-theme-stack)，从官方模板 [hugo-theme-stack-starter](https://github.com/CaiJimmy/hugo-theme-stack-starter) 创建。全部使用免费服务：GitHub 托管代码，GitHub Actions 自动构建，GitHub Pages 发布网站。

## 网站是怎么运行的

```
本地写 Markdown ──git push──▶ GitHub 仓库 ──触发──▶ GitHub Actions 运行 hugo
                                                        │
                                   浏览器访问 ◀── GitHub Pages ◀── 生成的 HTML
```

- **Hugo**：把 `content/` 里的 Markdown 和主题模板合在一起，生成纯 HTML 网页（输出到 `public/`，这个文件夹不提交）。
- **主题**：通过 Hugo Modules 引用（见 `go.mod` 和 `config/_default/module.toml`），所以仓库里看不到主题源码，构建时自动下载。这也是本机需要装 Go 的原因。
- **部署**：`.github/workflows/deploy.yml` 在每次推送到 `master` 分支后自动运行。

## 目录说明

| 路径 | 作用 |
| --- | --- |
| `content/post/` | 博客文章，每篇一个文件夹（文章 `index.md` + 图片） |
| `content/categories/` | 5 个分类：学习笔记、科研记录、编程技术、大学生活、其他 |
| `content/page/` | 归档、搜索、友情链接等独立页面 |
| `archetypes/post.md` | 新文章模板 |
| `config/_default/` | 网站配置（标题、菜单、侧边栏、功能开关） |
| `assets/img/` | 头像 `avatar.png`、网站图标 `favicon.png` |
| `assets/scss/custom.scss` | 自定义样式（一般不用改） |
| `docs/更新日志.md` | 每次修改的记录，方便接手 |

## 日常使用（Windows PowerShell）

在本文件夹打开 PowerShell。

**新建文章**（文件夹名就是网址的一部分，建议用英文和短横线）：

```powershell
hugo new content post/my-first-note/index.md
```

然后编辑 `content/post/my-first-note/index.md`。模板默认 `draft: true`（草稿），写完改成 `false` 才会发布。

**本地预览**（`-D` 表示连草稿一起显示）：

```powershell
hugo server -D
```

浏览器打开 <http://localhost:1313/>，保存文件后页面会自动刷新。按 `Ctrl+C` 停止。

**发布**：

```powershell
git add .
git commit -m "新文章：xxx"
git push
```

推送后 1～2 分钟，到 GitHub 仓库的 Actions 页面能看到构建进度，绿色对勾表示发布成功。

## 写作要点

- 分类只用这 5 个：`学习笔记`、`科研记录`、`编程技术`、`大学生活`、`其他`。标签（tags）可以随便写。
- 数学公式已全站开启（KaTeX）：行内 `$...$`，块级 `$$...$$`。
- 图片放在文章文件夹里，用 `![说明](文件名.jpg)` 引用；`image: 文件名.jpg` 设为封面。
- 示例文章《我的博客搭建记录》在 `content/post/blog-setup/`，可以参考格式，不需要时删掉整个文件夹。

## 待填写的个人信息

以下内容目前是占位符，搜索 `【待填写】` 能找到：

- 博客标题：`config/_default/config.toml` 和 `config/_default/_languages.toml` 里的 `title`
- 一句话简介：`config/_default/params.toml` 里的 `subtitle`
- 头像：替换 `assets/img/avatar.png`（目前是模板自带图片）

## 主题更新

主题版本记录在 `go.mod`。需要更新时，到 GitHub 仓库 Actions 页面手动运行 “Update theme”（已关闭每日自动更新），然后在本地 `git pull` 同步。也可以在本地运行 `hugo mod get -u` 再 `hugo mod tidy`。

## 一次性设置

GitHub 仓库 Settings → Pages → Build and deployment → Source 选择 **GitHub Actions**，否则推送后网站不会更新。
