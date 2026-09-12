# CONTEXT — 项目上下文集

按主题收录项目的外部上下文与已裁定事实。本文件保持紧凑（目标百行以内），每次会话可整体进入上下文；长篇细节放 `docs/`，各节给出指针。新增主题就增设新节，不要让单个主题占满文件结构。

## MoonBit 版本状态

- 本机工具链：moon 0.1.20260904 / moonc v0.10.9（截至 2026-09-13）。官方目标 MoonBit 1.0 为 2026 Q3，届时复查废弃项是否落地。
- 逐版本变更完整摘录（0.6.33 → 0.10.9）：[docs/moonbit-updates-digest.md](docs/moonbit-updates-digest.md)。

当前最要紧的硬规则（细节与来源见 digest）：

1. **`impl` 不再隐式挂载为方法**（0.10.4）：点调用需显式 `extend Type with Trait::{f, g}`；设计 mxp-core 公共 API 按 trait 关系与点调用方法分离声明。
2. **pre-1.0 版本互相兼容**（0.9.0）：下游自动解析到最新 0.x，`obitare/*` 的破坏性变更必须升次版本号承载。
3. **`#module("path")` + `extern "js"`**：绑定宿主 API 与 npm 包的关键机制（生成 ESM import）；js 后端 `Int64`/`UInt64` 编译为 JS `BigInt`。
4. **默认 target 为 `wasm`**（0.10.9）：CI 与脚本显式指定 target，不依赖默认值。
5. **调试用 `Debug`**：`derive(Debug)` + `debug_inspect` + `@debug.assert_eq`；`derive(Show)` 仅用于有特定文本表示的类型。
6. **`Iter` 只能遍历一次**（外部迭代器），用 `.iter()` 不用 `.iterator()`。
7. **资源清理用 `defer`/`errdefer`**，不用 `catch`（`fragile_catch_all` 警告预示 catch 语义将变）。
8. **旧配置格式死线**：`moon.pkg.json` / `moon.mod.json` 支持即将移除，只用 `moon.pkg` / `moon.mod`。

## 其他主题

按需增设（候选：VSCode/Chrome 宿主 API 要点、比赛交付自查清单、调研笔记指针）。
