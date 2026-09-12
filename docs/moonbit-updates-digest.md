# MoonBit 版本变更摘录

MoonBit 官方 update 日志的二次整理，供本项目开发时快速查证废弃迁移与新特性。入口在根目录 `CONTEXT.md` 的「MoonBit 版本状态」节。

- 摘要范围：0.6.33 → 0.10.9 共 9 篇（2025-12-02 → 2026-08-19 发布）。
- 时效：截至 2026-09-13（本机 moon 0.1.20260904 / moonc v0.10.9）。官方目标 MoonBit 1.0 于 2026 Q3 发布，届时需复查废弃项是否落地。
- 遇具体问题以原文为准。

| 版本 | 对应目录 |
|------|----------|
| 0.6.33 | `2025-12-02` |
| 0.7.1 | `2026-01-12` |
| 0.8.0 | `2026-02-09-moonbit-0-8-0-release` |
| 0.8.3 | `2026-03-10` |
| 0.9.0 | `2026-04-07` |
| 0.9.2 | `2026-05-13` |
| 0.10.0 | `2026-06-08-moonbit-0-10-0-release` |
| 0.10.4 | `2026-07-13-moonbit-0-10-4-release` |
| 0.10.9 | `2026-08-19` |

> 各目录均位于 <https://github.com/moonbitlang/website/tree/main/updates> 。摘要起点为 2025-11-19（0.6.x 工具链）：MiniMoonbit2025 的 `examples/` 截至该日持续编译通过，视为已验证基线，更早的变更不再收录。

## 工具链 / 构建系统（与 mxp 直接相关）

- **默认 target 变为 `wasm`**（0.10.9）。与本项目 wasm/js 优先一致，但 CI 与脚本应显式指定 target，不依赖默认值。
- **旧配置格式的死线**：`moon.pkg.json` / `moon.mod.json` 的支持将在 0.10.4 之后的版本移除（0.10.4 预告），本项目已用新格式，勿回退。
- **pre-1.0 版本互相兼容**（0.9.0）：依赖图中同一包的多个 0.x 版本解析为最新（如 async@0.15/0.16 → 0.16）。发布 `obitare/*` 0.1.x 后，下游无法锁定精确补丁版本，破坏性变更只能靠大版本号承载。
- **workspace 工作流**（0.9.0）：`moon work init/use/sync`，`moon -C <module> publish` 逐模块发布——即 AGENTS.md 现行流程的出处。
- **`supported_targets` 语法**（0.8.3）：`"+js+wasm"` 白名单 / `"+all-js"` 黑名单，moon.mod 与 moon.pkg 取交集。
- **`pkgtype(kind:)`**（0.10.4）：`pkgtype(kind: "executable")` 取代 `options("is-main": true)`；`"foreign_library"` 取代 `options(link: true)`。
- **`#export_name`**（0.10.4）：foreign library 包中指定生成产物里的导出符号名（wasm/js），可用于稳定 mxp-vsc/crx 的 JS 侧入口名。
- **`moon ide analyze`**（0.8.3）：按 `.mbti` 格式输出公共 API 及使用统计（总数/测试数/是否定义于 `exports.mbt`）。配套新约定：供外部使用的公共 API 放 `exports.mbt`。可用于发布前裁剪 mxp-core API 面。
- **`moonx`**（0.10.9）：`moonx user/pkg[@ver]` 直接运行 mooncakes.io 上的可执行包（默认 wasm）。
- **`moon run -c '<script>'`**（0.9.2）与 `moon run -` stdin 模式（0.8.3）：临时脚本免建文件。
- **`moon test` 增强**：`-j` 并行、`--outline` 列出测试、`--index 0-2` 选段（0.8.0）。
- **`moon cram test`**（0.10.0，实验）：CLI 端到端测试，但需 native 后端构建——本机无 C 编译器，暂不可用。
- **warning 配置**：`@`（升级为 error）开关将废弃（0.10.4），CI 建议改用 `--deny-warn`。
- **`.mbt.md` / docstring 代码块**：`mbt`/`moonbit` 块默认不再参与编译，需显式 `mbt check`（0.6.33）；`moon fmt` 会把裸 `moonbit` 块改为 `moonbit nocheck`（0.8.0）。写 docstring 示例时注意标注。
- **`moonbitlang/async` js 后端**（0.6.33 起）：`js_async` 提供 MoonBit async fn ↔ JS Promise 双向转换（基于 AbortSignal 的取消）；0.8.3 起 `async/http` 提供 Fetch API 客户端（含浏览器环境）。若 mxp 需要异步网络/IO 可评估。

## 语言：废弃与迁移（写代码时必须避开）

- `try?` 语法弃用（0.10.0）；`loop` 语法弃用（0.9.0，改 `for` + `match`）；`for { ... }` 无限循环弃用（0.8.3，改 `for ;; {}` 或 `while true`）。与 AGENTS.md「禁用 try 传播」一致。
- **`impl` 不再隐式挂载为方法**（0.10.4）：`impl Trait for Type` 的方法默认不可再用 `Type.f()` 点调用，需显式 `extend Type with Trait::{f, g}`（可加 `pub`）；配套 `implicit_impl_as_method` 警告（下版本默认开启）。`&Trait` 与受约束类型参数上调用超 trait 方法也弃用，改 `Trait::f(..)` 形式。**设计 mxp-core 公共 API 时按此模型**：trait 关系与点调用方法分离声明。
- **trait/impl 语法要求 `fn` 关键字**（0.10.0）：`trait I { fn f(Self) -> Unit }`、`impl I for Int with fn f(_) {}`；`moon fmt` 可迁移。
- **无方法 trait 的隐式实现弃用**（0.8.3）：需显式 `impl Trait for Type`。
- **自定义构造器统一为 `fn Type::Type(..)`**（0.9.2 引入新语法，0.10.0 移除旧 `fn new`）；0.10.4 起任意类型均可定义（不仅 struct）。
- **`derive(Show)` 弃用于调试**（0.8.0 起推进）：调试用 `derive(Debug)` + `debug_inspect` + `@debug.assert_eq`；仅在有特定文本表示（Json/Html 类）时手写 `Show`。`Show::output` 对 String/Char 改为原样输出（0.9.2）。AGENTS.md 的 inspect/debug_inspect 规则与此对应。
- **Iter 迁移为外部迭代器**（0.7.1）：`.iterator()` 弃用改 `.iter()`；`Iterator` 成为弃用别名；**Iter 只能遍历一次**，重复遍历是反模式。
- `string[x]` 返回 `UInt16`，字符取值用 `code_unit_at`（0.6.33）。
- `Container::of` / `from_array` 弃用：改用与类型同名的构造器（0.6.33、0.10.4 core 统一）。
- `immut/array` 已移除，改 `immut/vector`（0.9.0 引入替代，0.10.9 移除旧包）。
- `moonbitlang/sys` 弃用，环境变量/参数等用 `core/env`（0.10.9）。
- **`catch` 作清理用法受警告**（0.10.9）：新 `errdefer`（作用域内出错/取消时执行清理后重抛）；`fragile_catch_all` 警告预示未来 `catch` 不再拦截异步取消信号。资源清理一律 `defer`/`errdefer`，不用 catch。
- `with`-pattern 分支需显式括号（0.10.9，`moon fmt` 迁移）；`guard` 非穷尽模式告警，需 panic 语义用 `guard!`（0.10.9）。
- 空 `{}` 字面量歧义警告（0.10.4）：空 JSON 对象用 `Json::empty_object()`，空 Map 用 `Map([])`，空语句块用 `...`。
- 视图切片不再支持负索引（0.10.4）。
- 本地 `fn` 不再隐式互递归，需 `letrec f = .. and g = ..`（0.9.2）；带参构造器不能直接作高阶函数，需包 lambda（0.8.0）；struct 字面量推断 `Ref` 弃用，用 `Ref::new`（0.7.1）。

## 语言：可用的新特性（按需采用）

- 列表推导式 `[for i in xs if cond => body]`，可构造数组/Bytes/String/`Iter`（惰性，0.9.2；0.10.0 支持额外状态变量与副作用 body）。
- 模板写语法 `buf <+ "a\{b}"`（直接分解为 StringBuilder 写入，零开销）与条件版 `logger <? "..."`（0.10.0）；Bytes 插值 `b"...\{x}"`（0.10.4）。
- `Iter` 显式字面量 `[| 1, 2, 3 |]` 与条件展开 `..if cond { expr }`、or-pattern 默认值 `Some(x) | None with x = 0`（均 0.10.4）。
- **稳定 regex**：`s =~ re"..."` 匹配表达式、`re"..."` 字面量可 const 复用（0.9.0）；实验性 `lexmatch` → 升级为 `lexscan`（0.10.4），0.10.9 稳定并支持流式。若 mxp 需要文本扫描（如生成器模板）用这套而非自写解析。
- **`#module("path")` 导入第三方 JS 模块**（0.6.33）：`#module("path") extern "js" fn dirname(p: String) -> String = "dirname"` 生成 ESM `import`——**mxp-vsc/mxp-crx 绑定宿主 API 与 npm 包的关键机制**。
- js 后端 `Int64`/`UInt64` 编译为 JS `BigInt`（0.9.0）——与宿主互操作时的类型对齐依据。
- 多态 trait 方法（trait 方法可带自己的类型参数，0.10.0）；可扩展枚举 `extenum` + `+=`（0.9.2）。
- `declare` 关键字声明待实现签名/类型，缺实现仅告警（0.8.0，取代 0.7.1 的 `#declaration_only`）——适合模板生成占位。
- 标记扩散改进：`for .. in` 支持状态变量默认更新（0.10.0）；管线 `|>` lambda 简写与反向管线 `<|`（0.7.1/0.9.0/0.9.2）。
- `core/argparse`（0.8.3；0.10.4 增加子命令拼写建议与默认子命令分发）——mxp CLI 参数解析候选。

## 不相关但留档

- 形式化验证 `proof_ensure` / `moon prove`（0.9.0、0.10.9）；`V128` 内建类型与 bitstring `v128le`（0.10.0、0.10.9）；新 native 后端（0.10.0 起，本机无 C 编译器不适用）；`moon runwasm` 与 skills 市场（0.10.0）。
- `moonbitlang/async` 0.21.0 breaking 变更（0.10.9）：`@http.Headers` 大小写不敏感、`@fs.open` 的 `create/truncate` 参数改为 `create_mode/permission`——仅当引入 async 时需注意。

## 查证路径

- 语言/工具链问题第一入口：`moonbit-orientation` skill。
- 逐版本细节：updates 目录各期原文（见上表）；`moonbit-evolution` 仓库有各特性 proposal。
