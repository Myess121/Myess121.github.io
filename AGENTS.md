# AGENTS.md

给接手本项目的 AI 助手或开发者的说明。

## 项目概况

- 个人博客，Hugo + Hugo Theme Stack v4，起点为官方 `hugo-theme-stack-starter`。
- 主题通过 Hugo Modules 引入（`go.mod`），不要把主题源码复制进仓库，不要重写博客框架。
- 部署：推送到 `master` 分支后由 `.github/workflows/deploy.yml` 构建并发布到 GitHub Pages（https://Myess121.github.io/）。
- 只用免费方案：不引入付费服务器、数据库、云端 AI API、付费插件。
- 评论系统已关闭（`params.toml` 中 `comments.enabled = false`），不要添加评论服务。
- 主题更新工作流 `update-theme.yml` 仅手动触发。

## 约定

- 站主是网页开发初学者：改动尽量小，用通俗中文解释原因。
- 分类固定为 5 个：学习笔记、科研记录、编程技术、大学生活、其他（`content/categories/`）。
- 文章使用页面包（page bundle）：`content/post/<slug>/index.md`，图片放同一文件夹。
- 新文章模板：`archetypes/post.md`。
- 个人信息不要编造，未提供的一律用 `【待填写】` 占位。
- 优先通过配置（`config/_default/`）和 `assets/scss/custom.scss` 定制；需要改模板时用 `layouts/` 覆盖，不改主题本身。

## 每次修改后

1. 本地运行 `hugo --gc --minify` 确认构建无 ERROR（libsass 弃用的 WARN 来自主题，可忽略；CI 中使用 Dart Sass）。
2. 在 `docs/更新日志.md` 顶部追加一条记录：日期、改了什么、为什么、涉及的文件、遗留问题。
3. 未经站主确认，不要 `git push`、改写历史或批量删除。

## 环境

- Windows，PowerShell。本机已装 Hugo extended、Go、Git。
- 本地预览：`hugo server -D`，访问 http://localhost:1313/。
