# AGENTS.md

2026 MoonBit 九月黑客松参赛项目：辅助开发 VSCode 扩展与 Chrome 扩展的 MoonBit 工具集。
库发布到 mooncakes.io，命名空间 `obitare`（已 `moon login`）。

## 比赛约束（验收硬标准）

- 赛程：9 月第一周—24 日集中开发；**9 月 24 日项目验收，兼报名截止**
- MoonBit 为主要实现语言；公开仓库持续提交（≥5 次有意义提交），保留 commits/Issues/PR
- 仓库 CI 必须跑 `moon check` / `moon test`
- 清晰 README、可运行示例、核心路径测试；根目录 LICENSE；移植/参考须注明来源与许可证
- AI 可解释：可以使用 AI 辅助，但目标、路径与质量由参赛者掌握并负责
- 重复提交、拆分项目或仅做简单修改，不计入验收
- 官方页面：https://moonbitlang.github.io/Hackathon2026 ；章程：https://bxup9uklfcb.feishu.cn/wiki/Dx4Bwd6D1i3GfHkajQCcF7SznEd ；参赛指南 skill：https://github.com/Milky2018/osc2026-guide

## 仓库结构（monorepo + moon workspace）

根目录：`moon.work`（`moon work init` 生成）+ LICENSE + README。
成员模块统一放在二级目录 `packages/` 下（`moon work use packages/<name>` 登记），各自有 `moon.mod`，可独立发布：

| 模块 | 职责 |
|------|------|
| `packages/mxp-core` | 与宿主无关的核心逻辑 |
| `packages/mxp-vsc` | VSCode 扩展 API 绑定/适配层 |
| `packages/mxp-crx` | Chrome 扩展 API 绑定/适配层 |
| `packages/mxp` | 可执行 CLI 入口（`is-main`），快速生成扩展项目模板，类似 `create-vue` |

依赖方向：`mxp → mxp-vsc / mxp-crx → mxp-core`。
后端以 wasm/js 为主，后期兼容 native；不依赖外部 FFI。

## 运行环境边界

- ZCode 运行在 WSL 内，宿主文件通过 `/mnt` 暴露，访问范围受硬性约束（`~/.zcode/hooks/fs_guard.py` PreToolUse hook 强制拦截）+ 本节软规则：
  - `/mnt/e/` 仅可读；`/mnt/f/` 可读写；**其余 `/mnt/*` 路径一律不得进入**（含 `ls`、`cd`、glob）
  - `/home/u/` 下可写范围仅限 `~/.zcode/` 与 `~/agent/zcode/moonbit/`；其余路径（含 `~/.moon`）不得写入/删除
  - WSL 内除 `/mnt/*` 受限路径外，默认目录均可**读**（工具链文件、系统库等）
  - `/tmp` 可读写（选定的临时目录方案；工具链子进程隐式依赖它）
  - 破坏性命令（rm/mv/dd/重定向等）目标路径必须在上述可写范围内
- 硬拦截覆盖结构化路径（Write/Edit/Read 等）与 Bash 命令字符串分析；后者是启发式，不构成 OS 级沙箱，不得主动尝试绕过

## 分支与提交规则

- **`main` 只通过 PR 合并，不要默认直推 main**（本地 `.git/hooks/pre-push` 会拦截；确需直推时显式 `MXP_ALLOW_MAIN_PUSH=1` 覆盖）
- 日常开发、提交与推送默认走 `develop` 分支
- PR 合并同时满足比赛「保留 commits/Issues/PR 记录」的验收要求

## 工具链

- moon 0.1.20260904，安装于 `~/.moon/bin`（`~/.bashrc` 已加 PATH）
- 工具链缺失时安装：`curl -fsSL https://cli.moonbitlang.cn/install/unix.sh | bash`
- 使用新版 `moon.mod` / `moon.pkg` 格式；不要创建旧版 `moon.mod.json`
- MoonBit 语言/工具链版本状态与项目上下文集见根目录 `CONTEXT.md`（逐版本变更摘录在其指向的 `docs/moonbit-updates-digest.md`）；写代码遇到废弃警告或设计公共 API 时先查那里

## 常用命令

- `moon check --target all` — 类型检查全部成员（workspace 根执行，快，常跑）
- `moon test` — 全部测试；快照更新用 `moon test --update`，更新后必须 review diff
- `moon fmt` / `moon info` — 交付前必跑；`moon info` 后 review 生成的 `.mbti` diff 作为公共 API 变更信号
- `moon -C packages/mxp-core publish` — 发布是 module-only 操作，必须逐成员执行，不能在 workspace 根发布
- `moon work sync` — 成员模块互相依赖时对齐版本
- 新增成员模块后用 `moon work use <path>` 登记进 `moon.work`

## 编码硬约束

- 禁用弃用语法：不用 `fn!(…)`、`fn(…)?`、不用 `try` 做错误传播；错误处理用 `raise`/`catch`
- 公共 API 默认黑盒测试（`*_test.mbt`）+ docstring 示例；快照测试用 `inspect`/`debug_inspect`
- `pkg.generated.mbti` 纳入版本控制，作为公共 API 面的变更信号
- agent 编写的自动化脚本只用 `.mbtx`（`moon run`），不写 shell/Python 脚本
- 顶层声明用 `///|` 分隔；文件名不构成命名空间，按功能组织小文件
- API 所有权：公共具体类型放在门面模块或非 internal 公共包；实现细节放 `internal/*`

## 已定决策

- 各成员模块初始版本号统一 `0.1.0`
- `mxp` CLI 首批模板（最小集）：`vscode-basic`（最简 VSCode 扩展）+ `chrome-basic`（Manifest V3 最简 Chrome 扩展）
- 仓库：GitHub 公开仓库，本地 monorepo 推送，commit 分批有语义

## 待定

以下事项未定，不要当成规则编造：

- CI 具体方案（GitHub Actions workflow 待建，要求：一条命令覆盖 `moon check` + `moon test`）
- 模块名 `mxp` 的含义/全称，README 里如何表述项目名（暂占位「MoonBit eXtension Platform」）
