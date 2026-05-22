# Step 2：Fastlane 跑测试（CI 门禁）

Step 2 只做一件事：**用命令行自动跑单元测试**，等价于 Jenkins 里 PR 触发的 CI job。

---

## 一次性安装

在终端执行（项目根目录 `CICD_Demo/`）：

```bash
cd /Users/mario/Downloads/HSBC/CICD_Demo

# 若没有 bundler
gem install bundler

bundle config set --local path 'vendor/bundle'
bundle install
```

**若 `bundle install` 失败（例如代理 127.0.0.1:1081 连不上）**：

- 可暂时关掉终端代理后再 `bundle install`  
- 或你本机已装过 fastlane 时，直接用：`fastlane test`（与 `bundle exec fastlane test` 效果相同）

---

## 核心命令（必练）

```bash
bundle exec fastlane test
# 或（已全局安装 fastlane 时）
fastlane test
```

等价于 Xcode **Cmd + U**，但适合：

- 终端 / 脚本一键执行
- 以后接到 Jenkins、GitHub Actions（同一命令）

### 成功标志

- 终端最后出现 **`fastlane.tools finished successfully`**
- 3 个测试通过（与 Step 1 相同）
- 产物目录：`fastlane/test_output/`（含测试报告、覆盖率）

---

## 可选命令

```bash
# 仅当你想练 CD 打包（需 Signing 正常）
bundle exec fastlane build

# 测试 + 打包一条龙
bundle exec fastlane ci_local
```

Step 2 **只需跑通 `fastlane test`**。`build` 可留到 Step 3。

---

## 模拟器名称不对？

报错类似 `Unable to find a device matching iPhone 17 Pro` 时：

1. Xcode → **Window → Devices and Simulators** 看名称  
2. 修改 `fastlane/Fastfile` 顶部的 `SIMULATOR = "..."`  
3. 再执行 `bundle exec fastlane test`

---

## 和工程化的对应关系

| Xcode | Fastlane | 含义 |
|-------|----------|------|
| Cmd + U | `fastlane test` | CI：质量门禁 |
| Archive | `fastlane build` | CD：出包（Step 3） |

面试可这样说：

> PR 合入前用 Fastlane scan 跑单测，失败不能合并；和本地、CI 服务器用同一套 Fastfile，避免环境差异。

---

## 小实验（建议）

1. 在 `JSONParsingTests` 里故意写一个失败断言  
2. 再跑 `bundle exec fastlane test` → 应失败退出（非 0）  
3. 改回通过后重跑 → 成功  

体会 **CI 门禁**：测试红 = 流水线红。

---

Step 2 已完成 → 见 **STEP3.md**。
