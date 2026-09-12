# mxp — MoonBit Extension Toolkit

`mxp` 是一个用于开发 **VSCode 扩展**与 **Chrome 扩展**的 MoonBit 工具集
（2026 MoonBit 九月黑客松参赛项目）。所有库以 `obitare` 命名空间发布到
[mooncakes.io](https://mooncakes.io)。

> 项目名暂定表述为 "MoonBit eXtension Platform"。

## 模块结构（monorepo + moon workspace）

| 模块 | 路径 | 职责 |
|------|------|------|
| `obitare/mxp-core` | `packages/mxp-core` | 与宿主无关的核心逻辑（清单模型/解析/校验） |
| `obitare/mxp-vsc` | `packages/mxp-vsc` | VSCode 扩展 API 绑定/适配层 |
| `obitare/mxp-crx` | `packages/mxp-crx` | Chrome 扩展 API 绑定/适配层 |
| `obitare/mxp` | `packages/mxp` | CLI 入口，一键生成扩展项目模板（类似 `create-vue`） |

依赖方向：`mxp → mxp-vsc / mxp-crx → mxp-core`。后端以 wasm/js 为主。

## 快速开始

```bash
# 类型检查全部成员（workspace 根执行）
moon check --target all

# 运行全部测试
moon test
```

### 用 mxp 脚手架生成扩展项目

```bash
# 生成一个 MoonBit 驱动的 VSCode 扩展
moon run --target wasm packages/mxp/cmd/main -- new vscode-basic my-extension

# 生成一个 MoonBit 驱动的 Chrome MV3 扩展
moon run --target wasm packages/mxp/cmd/main -- new chrome-basic my-extension

# 查看可用模板
moon run --target wasm packages/mxp/cmd/main -- list
```

生成的项目含 MoonBit 源码（`src/`）与宿主工程文件（`package.json` /
`manifest.json`），构建产物路径已在模板中配好：

```bash
cd my-extension
moon build --target js --release
```

## 状态

项目处于早期开发阶段（9 月黑客松周期）。路线图见仓库 Issues。

## License

Apache-2.0
