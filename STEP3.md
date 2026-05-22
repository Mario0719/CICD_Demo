# Step 3：本地 CI 脚本 + GitHub Actions（云端 CI）

Step 3 把 Step 2 的 `fastlane test` 包成 **「一条命令的完整 CI」**，并可选接到 **GitHub**（代替 Jenkins）。

---

## Part A：本地 CI（必做）

### 一条命令

```bash
cd /Users/mario/Downloads/HSBC/CICD_Demo
chmod +x scripts/ci-local.sh   # 只需第一次
./scripts/ci-local.sh
```

### 它会做什么

| 步骤 | 说明 |
|------|------|
| 1 | 创建本次运行目录 `fastlane/test_output/runs/YYYYMMDD-HHMMSS/` |
| 2 | 终端输出 **同时写入** `run.log`（执行记录） |
| 3 | 执行 `fastlane test`（与 Step 2 相同门禁） |
| 4 | 复制 `report.html`、`report.junit`、`xcresult` 到本次目录 |
| 5 | 写 `summary.txt`（退出码、耗时、报告路径） |
| 6 | 用 **退出码** 表示成功/失败（0=绿，非0=红） |

### 成功标志

- 终端最后：`Exit code: 0 (SUCCESS)`
- 打开本次报告：

```bash
# 把下面的 RUN_ID 换成 summary.txt 里那一串时间
open fastlane/test_output/runs/20260522-150000/report.html
cat fastlane/test_output/runs/20260522-150000/summary.txt
```

### 和 Step 2 的关系

```text
Step 2:  fastlane test          →  能跑、能门禁、有报告
Step 3:  ./scripts/ci-local.sh  →  同上 + 每次运行归档 + 日志 + summary（像 Jenkins 留档）
```

---

## Part B：GitHub Actions（可选）

没有 Jenkins 时，用 GitHub 免费 macOS 跑同一套测试。

### 1. 初始化 Git 并推送

```bash
cd /Users/mario/Downloads/HSBC/CICD_Demo
git init
git add .
git commit -m "CICD Demo: login MVVM + fastlane CI"
```

在 GitHub 网页新建空仓库，然后：

```bash
git remote add origin git@github.com:YOUR_USER/CICD_Demo.git
git branch -M main
git push -u origin main
```

### 2. 查看 CI 结果

- 仓库 → **Actions** → 工作流 **iOS CI**
- 绿勾 = 测试通过；红叉 = 与本地 `fastlane test` 失败一样
- 每次运行可下载 **Artifacts**（`report.html`、`report.junit`）

### 3. 模拟器名不一致

Actions 日志若报找不到模拟器，改 `.github/workflows/ios-ci.yml` 里的：

```yaml
CI_SIMULATOR: iPhone 16
```

与 `fastlane/Fastfile` 的 `ENV["CI_SIMULATOR"]` 配合使用。

---

## 三层 CI 对照（面试用）

| 层级 | 命令 | 场景 |
|------|------|------|
| 开发 | Xcode Cmd+U | 写代码时自测 |
| 本地 CI | `./scripts/ci-local.sh` | 提交前 / 模拟 Jenkins |
| 云端 CI | GitHub Actions `ios-ci.yml` | PR 自动跑、团队共享 |

同一套 **`fastlane test`**，三层都用，避免「我机器行、服务器不行」。

---

## 小实验

1. 跑 `./scripts/ci-local.sh` → 看 `runs/` 下新目录  
2. 故意让测试失败 → 再跑 → `exit_code=65`（或类似非0），`summary.txt` 里可见  
3. （可选）push 到 GitHub → 在 Actions 里看同样红/绿  

---

## 全流程回顾

| Step | 内容 |
|------|------|
| 1 | 登录页 + ViewModel + Xcode 单测 |
| 2 | `fastlane test` = 命令行 CI 门禁 + HTML/JUnit 报告 |
| 3 | `ci-local.sh` = 本地完整 CI + 执行记录；Actions = 云端 CI |

---

Step 3 本地跑通后 → 继续 **STEP3B.md**（GitHub 分支保护 + PR 合并门禁）。

可选后续：**Step 4 `fastlane build` + TestFlight**。
