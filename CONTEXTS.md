# CONTEXTS — 外部上下文摘录

本文件收录从外部来源吸收、与本项目（mxp）相关的上下文摘录。内容是二次整理，遇具体问题以来源原文为准。

- 时效：截至 2026-09-13（本机 moon 0.1.20260904 / moonc v0.10.9）。官方目标 MoonBit 1.0 于 2026 Q3 发布，届时需复查废弃项是否落地。
- 版本变更来源：[moonbitlang/website updates](https://github.com/moonbitlang/website/tree/main/updates)，摘要范围 2025-12-02 → 2026-08-19 共 9 篇。
- 摘要起点依据见下节「基线」。

## 基线：MiniMoonbit2025

- 来源：<https://github.com/moonbitlang/MiniMoonbit2025>（Apache-2.0）
- 用 MoonBit 编写的 MiniMoonbit（MoonBit 子集）编译器，含 LLVM IR / AArch64 / RISC-V 64 后端，基于 MoonLLVM、MoonMIR。
- 其 `examples/` 提交区间为 2025-10-30 ～ 2025-11-19，即该子集语法面在 2025-11 的工具链（≈ 0.6.x）上持续编译通过——视为「已验证基线」。
- 因此本文件版本变更摘要以 **2025-11-19 为起点**：更早的语言演变已沉淀在该基线与官方文档中，不再收录。
- 若参考/移植其代码：按比赛规则注明来源，并保留 Apache-2.0 版权声明。

## 版本时间线

| 日期 | 版本 | 来源 |
|------|------|------|
| 2025-12-02 | 0.6.33 | [updates/2025-12-02](https://github.com/moonbitlang/website/tree/main/updates/2025-12-02) |
| 2026-01-12 | 0.7.1 | [updates/2026-01-12](https://github.com/moonbitlang/website/tree/main/updates/2026-01-12) |
| 2026-02-09 | 0.8.0 | [release](https://github.com/moonbitlang/website/tree/main/updates/2026-02-09-moonbit-0-8-0-release) |
| 2026-03-10 | 0.8.3 | [updates/2026-03-10](https://github.com/moonbitlang/website/tree/main/updates/2026-03-10) |
| 2026-04-07 | 0.9.0 | [updates/2026-04-07](https://github.com/moonbitlang/website/tree/main/updates/2026-04-07) |
| 2026-05-13 | 0.9.2 | [updates/2026-05-13](https://github.com/moonbitlang/website/tree/main/updates/2026-05-13) |
| 2026-06-08 | 0.10.0 | [release](https://github.com/moonbitlang/website/tree/main/updates/2026-06-08-moonbit-0-10-0-release) |
| 2026-07-13 | 0.10.4 | [release](https://github.com/moonbitlang/website/tree/main/updates/2026-07-13-moonbit-0-10-4-release) |
| 2026-08-19 | 0.10.9 | [updates/2026-08-19](https://github.com/moonbitlang/website/tree/main/updates/2026-08-19) |

## 工具链 / 构建系统（与 mxp 直接相关）

- **默认 target 变为 `wasm`**（08-19）。与本项目 wasm/js 优先一致，但 CI 与脚本应显式指定 target，不依赖默认值。
- **旧配置格式的死线**：`moon.pkg.json` / `moon.mod.json` 的支持将在 0.10.4 之后的版本移除（07-13 预告），本项目已用新格式，勿回退。
- **pre-1.0 版本互相兼容**（04-07）：依赖图中同一包的多个 0.x 版本解析为最新（如 async@0.15/0.16 → 0.16）。发布 `obitare/*` 0.1.x 后，下游无法锁定精确补丁版本，破坏性变更只能靠大版本号承载。
- **workspace 工作流**（04-07）：`moon work init/use/sync`，`moon -C <module> publish` 逐模块发布——即 AGENTS.md 现行流程的出处。
- **`supported_targets` 语法**（03-10）：`"+js+wasm"` 白名单 / `"+all-js"` 黑名单，moon.mod 与 moon.pkg 取交集。
- **`pkgtype(kind:)`**（07-13）：`pkgtype(kind: "executable")` 取代 `options("is-main": true)`；`"foreign_library"` 取代 `options(link: true)`。
- **`#export_name`**（07-13）：foreign library 包中指定生成产物里的导出符号名（wasm/js），可用于稳定 mxp-vsc/crx 的 JS 侧入口名。
- **`moon ide analyze`**（03-10）：按 `.mbti` 格式输出公共 API 及使用统计（总数/测试数/是否定义于 `exports.mbt`）。配套新约定：供外部使用的公共 API 放 `exports.mbt`。可用于发布前裁剪 mxp-core API 面。
- **`moonx`**（08-19）：`moonx user/pkg[@ver]` 直接运行 mooncakes.io 上的可执行包（默认 wasm）。
- **`moon run -c '<script>'`**（05-13）与 `moon run -` stdin 模式（03-10）：临时脚本免建文件。
- **`moon test` 增强**：`-j` 并行、`--outline` 列出测试、`--index 0-2` 选段（02-09）。
- **`moon cram test`**（06-08，实验）：CLI 端到端测试，但需 native 后端构建——本机无 C 编译器，暂不可用。
- **warning 配置**：`@`（升级为 error）开关将废弃（07-13），CI 建议改用 `--deny-warn`。
- **`.mbt.md` / docstring 代码块**：`mbt`/`moonbit` 块默认不再参与编译，需显式 `mbt check`（12-02）；`moon fmt` 会把裸 `moonbit` 块改为 `moonbit nocheck`（02-09）。写 docstring 示例时注意标注。
- **`moonbitlang/async` js 后端**（12-02 起）：`js_async` 提供 MoonBit async fn ↔ JS Promise 双向转换（基于 AbortSignal 的取消）；03-10 起 `async/http` 提供 Fetch API 客户端（含浏览器环境）。若 mxp 需要异步网络/IO 可评估。

## 语言：废弃与迁移（写代码时必须避开）

- `try?` 语法弃用（06-08）；`loop` 语法弃用（04-07，改 `for` + `match`）；`for { ... }` 无限循环弃用（03-10，改 `for ;; {}` 或 `while true`）。与 AGENTS.md「禁用 try 传播」一致。
- **`impl` 不再隐式挂载为方法**（07-13）：`impl Trait for Type` 的方法默认不可再用 `Type.f()` 点调用，需显式 `extend Type with Trait::{f, g}`（可加 `pub`）；配套 `implicit_impl_as_method` 警告（下版本默认开启）。`&Trait` 与受约束类型参数上调用超 trait 方法也弃用，改 `Trait::f(..)` 形式。**设计 mxp-core 公共 API 时按此模型**：trait 关系与点调用方法分离声明。
- **trait/impl 语法要求 `fn` 关键字**（06-08）：`trait I { fn f(Self) -> Unit }`、`impl I for Int with fn f(_) {}`；`moon fmt` 可迁移。
- **无方法 trait 的隐式实现弃用**（03-10）：需显式 `impl Trait for Type`。
- **自定义构造器统一为 `fn Type::Type(..)`**（05-13 引入新语法，06-08 移除旧 `fn new`）；07-13 起任意类型均可定义（不仅 struct）。
- **`derive(Show)` 弃用于调试**（02-09 起推进）：调试用 `derive(Debug)` + `debug_inspect` + `@debug.assert_eq`；仅在有特定文本表示（Json/Html 类）时手写 `Show`。`Show::output` 对 String/Char 改为原样输出（05-13）。AGENTS.md 的 inspect/debug_inspect 规则与此对应。
- **Iter 迁移为外部迭代器**（01-12）：`.iterator()` 弃用改 `.iter()`；`Iterator` 成为弃用别名；**Iter 只能遍历一次**，重复遍历是反模式。
- `string[x]` 返回 `UInt16`，字符取值用 `code_unit_at`（12-02）。
- `Container::of` / `from_array` 弃用：改用与类型同名的构造器（12-02、07-13 core 统一）。
- `immut/array` 已移除，改 `immut/vector`（04-07 引入替代，08-19 移除旧包）。
- `moonbitlang/sys` 弃用，环境变量/参数等用 `core/env`（08-19）。
- **`catch` 作清理用法受警告**（08-19）：新 `errdefer`（作用域内出错/取消时执行清理后重抛）；`fragile_catch_all` 警告预示未来 `catch` 不再拦截异步取消信号。资源清理一律 `defer`/`errdefer`，不用 catch。
- `with`-pattern 分支需显式括号（08-19，`moon fmt` 迁移）；`guard` 非穷尽模式告警，需 panic 语义用 `guard!`（08-19）。
- 空 `{}` 字面量歧义警告（07-13）：空 JSON 对象用 `Json::empty_object()`，空 Map 用 `Map([])`，空语句块用 `...`。
- 视图切片不再支持负索引（07-13）。
- 本地 `fn` 不再隐式互递归，需 `letrec f = .. and g = ..`（05-13）；带参构造器不能直接作高阶函数，需包 lambda（02-09）；struct 字面量推断 `Ref` 弃用，用 `Ref::new`（01-12）。

## 语言：可用的新特性（按需采用）

- 列表推导式 `[for i in xs if cond => body]`，可构造数组/Bytes/String/`Iter`（惰性，05-13；06-08 支持额外状态变量与副作用 body）。
- 模板写语法 `buf <+ "a\{b}"`（直接分解为 StringBuilder 写入，零开销）与条件版 `logger <? "..."`（06-08）；Bytes 插值 `b"...\{x}"`（07-13）。
- `Iter` 显式字面量 `[| 1, 2, 3 |]` 与条件展开 `..if cond { expr }`、or-pattern 默认值 `Some(x) | None with x = 0`（均 07-13）。
- **稳定 regex**：`s =~ re"..."` 匹配表达式、`re"..."` 字面量可 const 复用（04-07）；实验性 `lexmatch` → 升级为 `lexscan`（07-13），08-19 稳定并支持流式。若 mxp 需要文本扫描（如生成器模板）用这套而非自写解析。
- **`#module("path")` 导入第三方 JS 模块**（12-02）：`#module("path") extern "js" fn dirname(p: String) -> String = "dirname"` 生成 ESM `import`——**mxp-vsc/mxp-crx 绑定宿主 API 与 npm 包的关键机制**。
- js 后端 `Int64`/`UInt64` 编译为 JS `BigInt`（04-07）——与宿主互操作时的类型对齐依据。
- 多态 trait 方法（trait 方法可带自己的类型参数，06-08）；可扩展枚举 `extenum` + `+=`（05-13）。
- `declare` 关键字声明待实现签名/类型，缺实现仅告警（02-09，取代 01-12 的 `#declaration_only`）——适合模板生成占位。
- 标记扩散改进：`for .. in` 支持状态变量默认更新（06-08）；管线 `|>` lambda 简写与反向管线 `<|`（01-12/04-07/05-13）。
- `core/argparse`（03-10；07-13 增加子命令拼写建议与默认子命令分发）——mxp CLI 参数解析候选。

## 不相关但留档

- 形式化验证 `proof_ensure` / `moon prove`（04-07、08-19）；`V128` 内建类型与 bitstring `v128le`（06-08、08-19）；新 native 后端（06-08 起，本机无 C 编译器不适用）；`moon runwasm` 与 skills 市场商店（06-08）。
- `moonbitlang/async` 0.21.0 breaking 变更（08-19）：`@http.Headers` 大小写不敏感、`@fs.open` 的 `create/truncate` 参数改为 `create_mode/permission`——仅当引入 async 时需注意。

## 查证路径

- 语言/工具链问题第一入口：`moonbit-orientation` skill。
- 逐版本细节：updates 目录各期原文（上表链接）；`moonbit-evolution` 仓库有各特性 proposal。
