# AGENTS.md

给接手本项目的 AI 助手（如 Codex）或开发者的说明。

## 项目架构

- 个人博客：Hugo（extended）+ Hugo Theme Stack v4，起点为官方 `CaiJimmy/hugo-theme-stack-starter`。
- 主题通过 Hugo Modules 引入（`go.mod` 锁定版本，当前 v4.0.3），本地构建需要 Go 和 Git。不要把主题源码复制进仓库，不要重写博客框架。
- 部署：推送到 `master` 分支后，`.github/workflows/deploy.yml` 用固定版本 Hugo（`HUGO_VERSION`，当前 0.169.0）构建，再用官方 `actions/deploy-pages` 发布到 GitHub Pages。构建时 `--baseURL` 由 `actions/configure-pages` 提供，`config.toml` 中的 `baseurl` 也是 `https://Myess121.github.io/`。
- `update-theme.yml` 只能手动触发（已删除定时任务）。依赖版本手动维护。
- 无服务器、无数据库、无评论、无登录、无第三方统计、无付费服务。

## 配置文件（`config/_default/`）

| 文件 | 内容 |
| --- | --- |
| `config.toml` | baseurl、语言（`zh`，对应主题 `i18n/zh.toml`，不要改成 `zh-cn`）、`hasCJKLanguage`、分页 |
| `params.toml` | 侧边栏、站点描述、日期格式（`2006-01-02`）、全站 KaTeX、评论关闭、小工具、配色切换 |
| `menu.toml` | 社交链接（GitHub） |
| `markup.toml` | Goldmark passthrough（保护 LaTeX）、目录层级、代码高亮 |
| `permalinks.toml` | 文章网址 `/p/:slug/` |
| `_languages.toml` | 多语言模板，文件名带下划线所以未启用 |

主导航菜单写在各页面的 front matter 里（`content/_index.md`、`content/page/*/index.md`）。

## 内容目录约定

```
content/
├── _index.md               首页（菜单项“首页”）
├── categories/<分类名>/     2 个分类：学学习、碎碎念
├── tags/_index.md          标签列表页标题
├── page/                   独立页面：about、archives、search、links
└── post/<slug>/index.md    文章（page bundle，图片放同一文件夹）
```

- 新文章：`hugo new content post/<slug>/index.md`，模板为 `archetypes/post.md`（默认 `draft: true`）。
- 新增分类时在 `content/categories/` 建同名文件夹和 `_index.md`，并同步更新 README、模板注释。
- 个人信息不得编造，未提供的一律用 `【待填写】` 占位。

## 主题修改原则

1. 优先改 `config/_default/` 里的配置。
2. 样式微调放 `assets/scss/custom.scss`。
3. 必须改模板时，在本仓库 `layouts/` 下建同路径文件覆盖（Hugo 会优先使用项目里的文件），不要改模块缓存里的主题本体。
4. 现有覆盖：`layouts/_partials/head/custom-font.html` 置空，去掉 Google Fonts（中国大陆访问问题）；`layouts/_partials/head/custom.html` 输出 noindex（站主不希望被搜索引擎收录，不要移除）；`layouts/robots.txt`。`config.toml` 中 `disableKinds = ["sitemap"]`。
5. 外部资源：KaTeX、PhotoSwipe 由主题从 jsDelivr 加载（`data/external.toml` 在主题中）。如要自托管，在本仓库新建 `data/external.toml` 覆盖。
6. 保留页脚主题署名、`LICENSE`（Starter，MIT）；主题本身为 GPL-3.0。

## 构建与测试要求

每次修改后至少做：

1. `hugo --gc --minify` 构建无 `ERROR`。`WARN deprecated: css.Sass: libsass` 来自主题，可忽略。
2. 检查 `public/` 中存在：`index.html`、`p/<slug>/index.html`、`categories/`、`tags/`、`archives/`、`search/`、`about/`、`index.xml`（RSS）。
3. 草稿（`draft: true`）不得出现在 `public/` 中。
4. 公式按文章开启（`params.toml` 中 `article.math = false`，文章 front matter 写 `math: true` 才加载 KaTeX）。改动涉及公式时，确认该页面包含 KaTeX 脚本。
5. 有条件时运行 `hugo server -D` 在浏览器中检查，包括手机宽度和深色模式。

不要提交 `public/`、`resources/`、`.hugo_build.lock`、密钥或本地配置（见 `.gitignore`）。

## 维护注意事项

- 站主是网页开发初学者：改动尽量小，用通俗中文解释原因。
- 每次修改在 `docs/更新日志.md` 顶部追加记录：日期、做了什么、为什么、涉及文件、验证、遗留事项。
- 未经站主确认，不要 `git push`、改写历史（force push、rebase 已推送提交）或批量删除。
- 升级 Hugo 时同时更新 `deploy.yml` 的 `HUGO_VERSION`，且不低于主题要求的最低版本（v4.0.3 要求 0.157.0）。
- 环境：Windows + PowerShell。
