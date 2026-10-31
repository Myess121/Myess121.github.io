# Myess121 的个人博客

网站地址：<https://Myess121.github.io/>

基于 [Hugo](https://gohugo.io/) + [Hugo Theme Stack v4](https://github.com/CaiJimmy/hugo-theme-stack)，从官方模板 [hugo-theme-stack-starter](https://github.com/CaiJimmy/hugo-theme-stack-starter) 创建。全部使用免费服务：GitHub 托管代码，GitHub Actions 自动构建，GitHub Pages 发布网站。没有服务器、没有数据库。

## 一、网站是怎么运行的

```
本地写 Markdown ──git push──▶ GitHub 仓库 ──触发──▶ GitHub Actions 运行 hugo
                                                        │
                                   浏览器访问 ◀── GitHub Pages ◀── 生成的 HTML
```

- **Hugo** 是“静态网站生成器”：把 `content/` 里的 Markdown 和主题模板合在一起，生成一堆纯 HTML/CSS/JS 文件（输出到 `public/`）。生成后的网站就是普通文件，任何静态托管都能放。
- **主题** 通过 Hugo Modules 引用（见 `go.mod` 和 `config/_default/module.toml`），仓库里看不到主题源码，构建时自动下载。这就是本机需要装 Go 和 Git 的原因。
- **部署**：`.github/workflows/deploy.yml` 在每次推送到 `master` 分支后，在 GitHub 的服务器上运行 Hugo，并把结果发布到 GitHub Pages。`public/` 不需要、也不应该提交。

## 二、目录说明

| 路径 | 作用 |
| --- | --- |
| `content/post/` | 博客文章，每篇一个文件夹（`index.md` + 图片） |
| `content/categories/` | 5 个分类：学习笔记、科研记录、编程技术、大学生活、其他 |
| `content/page/` | 关于我、归档、搜索、友情链接等独立页面 |
| `archetypes/post.md` | `hugo new` 使用的新文章模板 |
| `config/_default/` | 网站配置（标题、菜单、侧边栏、功能开关） |
| `assets/img/` | 头像 `avatar.jpg`、网站图标 `favicon.png` |
| `assets/scss/custom.scss` | 自定义样式（一般不用改） |
| `layouts/` | 对主题个别模板的覆盖（目前只有去掉 Google Fonts） |
| `docs/文章模板.md` | 可复制的文章模板和字段说明 |
| `docs/更新日志.md` | 每次修改的记录，方便接手 |
| `docs/验收清单.md` | 第一版的验收检查项 |

## 三、在 Windows 上安装依赖

需要三个工具：**Git**、**Go**、**Hugo extended**（必须是 extended 版本，主题要用它编译样式）。在 PowerShell 里用 Windows 自带的 winget 安装：

```powershell
winget install Git.Git
winget install GoLang.Go
winget install Hugo.Hugo.Extended
```

安装后**关闭并重新打开** PowerShell，检查版本：

```powershell
git --version
go version
hugo version
```

`hugo version` 的输出里要有 `+extended`，版本不低于 0.157.0（主题要求）。云端部署固定使用 0.169.0，本地最好一致。

## 四、日常使用

以下命令都在本文件夹（`E:\project\website\Myess121.github.io`）的 PowerShell 里执行。VS Code 里可以用“终端 → 新建终端”。

### 1. 本地预览

```powershell
hugo server -D
```

浏览器打开 <http://localhost:1313/>。保存文件后页面会自动刷新，按 `Ctrl+C` 停止。`-D` 表示连草稿一起显示，正式网站不会显示草稿。

### 2. 新建文章

```powershell
hugo new content post/my-first-note/index.md
```

然后编辑 `content/post/my-first-note/index.md`。文件夹名就是网址的一部分（`/p/my-first-note/`），建议用英文小写和短横线。模板默认 `draft: true`（草稿），写完改成 `false` 才会发布。完整模板见 [docs/文章模板.md](docs/文章模板.md)。

### 3. 本地构建（可选，用来检查有没有错误）

```powershell
hugo --gc --minify
```

成功后会生成 `public/` 文件夹（已被 `.gitignore` 忽略，不会提交）。输出里没有 `ERROR` 就说明没问题。

### 4. 提交并发布

```powershell
git add .
git commit -m "新文章：xxx"
git push
```

推送后到仓库的 [Actions 页面](https://github.com/Myess121/Myess121.github.io/actions) 看构建进度，出现绿色对勾就是发布成功，一般 1～3 分钟。之后刷新 <https://Myess121.github.io/> 即可（浏览器有缓存时按 `Ctrl+F5`）。

## 五、写作要点

- 分类只用这 5 个：`学习笔记`、`科研记录`、`编程技术`、`大学生活`、`其他`。标签（tags）可以随便写。
- 数学公式已全站开启（KaTeX）：行内 `$...$`，块级 `$$...$$`。
- 图片放在文章文件夹里，用 `![说明](文件名.jpg)` 引用；front matter 里写 `image: 文件名.jpg` 设为封面。
- 示例文章《我的博客搭建记录》在 `content/post/blog-setup/`，可以参考格式，不需要时删掉整个文件夹。

## 六、待填写的个人信息

以下内容目前是占位符，在 VS Code 里全局搜索 `【待填写】` 就能找到（简介和头像已设置：简介在 `params.toml` 的 `sidebar.subtitle`，同时用作网站描述；头像是 `assets/img/avatar.jpg`，换头像时替换这个文件，建议正方形）：

| 内容 | 位置 |
| --- | --- |
| 博客标题（也作为侧边栏昵称） | `config/_default/config.toml` 的 `title` |
| 关于我 | `content/page/about/index.md` |

## 七、常见问题

**`hugo` 不是内部或外部命令**
安装后没有重开 PowerShell，或安装失败。重开终端再试；仍不行就重新执行 winget 安装命令。

**报错 `failed to download modules` / `go: command not found`**
主题需要 Go 和 Git 下载。确认 `go version`、`git --version` 正常。网络不稳定时可以设置国内 Go 代理后重试：
```powershell
go env -w GOPROXY=https://goproxy.cn,direct
```

**报错提示需要 extended 版本 / SCSS 相关错误**
装成了普通版 Hugo，按第三节重新安装 `Hugo.Hugo.Extended`。

**`WARN deprecated: css.Sass: libsass was deprecated`**
来自主题本身的提示，不影响使用，可以忽略。

**端口 1313 被占用**
可能已经有一个 `hugo server` 在运行。关掉那个窗口，或用 `hugo server -D -p 1314` 换个端口。

**新文章本地能看到，网站上没有**
依次检查：`draft` 是否为 `false`；`date` 是不是写成了未来时间；是否已经 `git push`；Actions 页面是否显示失败（点进去看红色步骤的日志）。

**推送后网站没变化 / 显示 404**
仓库 Settings → Pages → Build and deployment → Source 必须选 **GitHub Actions**。首次部署成功后可能要等几分钟。

**`git push` 被拒绝（rejected）**
远程有你本地没有的提交（比如手动运行了“Update theme”）。先 `git pull`，再 `git push`。

**图片不显示**
图片要和 `index.md` 放在同一个文件夹，文件名大小写要一致（GitHub 上区分大小写）。

## 八、关于访问速度

主题字体原本从 Google Fonts 加载，中国大陆通常访问不了，已在 `layouts/_partials/head/custom-font.html` 中关闭，改用系统字体。数学公式（KaTeX）和图片放大功能（PhotoSwipe）仍从 jsDelivr CDN 加载，只在用到的页面加载。GitHub Pages 在国内的访问速度没有经过测试，不作保证；以后如有需要，可以把 KaTeX 改为放在本仓库内自托管。

## 九、主题更新

主题版本记录在 `go.mod`（当前 v4.0.3）。“每日自动更新”已关闭，避免主题升级在不知情的情况下弄坏网站。需要更新时，在本地运行：

```powershell
hugo mod get -u
hugo mod tidy
hugo server -D
```

预览没问题再提交推送。也可以在 Actions 页面手动运行 “Update theme”，之后在本地 `git pull`。

## 十、许可证

- 模板代码来自 hugo-theme-stack-starter，见 `LICENSE`（MIT）。
- 主题 Hugo Theme Stack 采用 GPL-3.0，页脚的“主题 Stack 由 Jimmy 设计”请保留。
- 文章默认显示 “Licensed under CC BY-NC-SA 4.0”（在 `params.toml` 的 `article.license` 中修改）。
