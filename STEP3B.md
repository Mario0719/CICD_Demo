# Step 3B：GitHub 分支保护 + PR 合并门禁

目标：在 GitHub 上实现 **「CI 测试不过 → 不能合并；全绿 → 才能 Merge」**。

---

## 前置：代码已在 GitHub 上

### 1. 本地初始化并首次推送（若还没做过）

```bash
cd /Users/mario/Downloads/HSBC/CICD_Demo

# 可选：用脚本初始化
./scripts/git-init.sh

# 或手动：
git init
git add .
git commit -m "CICD Demo: login MVVM + fastlane CI + GitHub Actions"

# 在 GitHub 网页新建仓库（不要勾选 README，避免冲突）
# 名称示例：CICD_Demo

git branch -M main
git remote add origin git@github.com:YOUR_USERNAME/CICD_Demo.git
git push -u origin main
```

### 2. 确认 Actions 已跑通

1. 打开 `https://github.com/YOUR_USERNAME/CICD_Demo/actions`
2. 点进 **iOS CI** 工作流
3. 第一次 push 到 `main` 后应出现 **绿色勾**
4. 若失败：看日志里模拟器名，改 `.github/workflows/ios-ci.yml` 的 `CI_SIMULATOR`

> **重要**：分支保护里要选的状态检查，必须 **至少成功跑过一次** 才会出现在列表里。所以先 push `main` 并等 Actions 绿，再开保护规则。

---

## 一、开启分支保护（Branch protection）

路径：**仓库 → Settings → Branches → Add branch protection rule**

| 配置项 | 建议 |
|--------|------|
| Branch name pattern | `main` |
| Require a pull request before merging | ✅ 勾选 |
| Require approvals | 可选（个人练习可关） |
| Require status checks to pass before merging | ✅ **必勾** |
| Require branches to be up to date before merging | ✅ 建议勾（PR 需基于最新 main） |
| Status checks that are required | 勾选 **`test`** 或 **`iOS CI / test`**（以你仓库里显示的为准） |
| Do not allow bypassing the above settings | 个人仓库可选 |

保存：**Create** / **Save changes**。

### 在界面上长什么样

- PR 页面右侧：**Merging is blocked** — 检查未通过时
- PR 下方 **Checks** 区域：
  - ❌ `test` 失败 → 红色，Merge 按钮灰色
  - ✅ `test` 成功 → 绿色，可以 Merge

状态检查名称来自 workflow：

```yaml
# .github/workflows/ios-ci.yml
name: iOS CI        # 工作流名
jobs:
  test:             # Job 名 → 检查常显示为 "test" 或 "iOS CI / test"
```

---

## 二、实验 A：测试失败 → 禁止合并

### 1. 从 main 拉分支

```bash
git checkout main
git pull
git checkout -b experiment/ci-should-fail
```

### 2. 故意弄失败测试

编辑 `CICD_DemoTests/JSONParsingTests.swift`：

```swift
XCTAssertEqual(response.token, "abc2")  // 故意错误
```

### 3. 提交并开 PR

```bash
git add .
git commit -m "test: intentionally fail CI"
git push -u origin experiment/ci-should-fail
```

在 GitHub：**Compare & pull request** → 创建 PR。

### 4. 观察结果（应看到）

| 位置 | 预期 |
|------|------|
| Actions | **iOS CI** 红叉 |
| PR Checks | `test` ❌ Failed |
| Merge 按钮 | **灰色 / Merge blocked** |
| 提示文案 | 类似 *Required status check "test" is expected* 或 *Merging is blocked* |

**不要合并这个 PR。** 实验完可关闭 PR 或删分支。

---

## 三、实验 B：测试通过 → 允许合并

### 1. 在同一分支改回正确断言

```swift
XCTAssertEqual(response.token, "abc")
```

### 2. 再 push

```bash
git add .
git commit -m "test: fix CI"
git push
```

### 3. 观察结果（应看到）

- Actions 重新跑，**绿色**
- PR Checks ✅
- **Merge pull request** 可点击
- 合并后代码进入 `main`

```bash
# 本地同步
git checkout main
git pull
```

---

## 四、和前三步的对应关系

```text
Step 2  fastlane test 失败 → exit ≠ 0
          ↓
Step 3B  GitHub Actions 跑同一条命令
          ↓
         Job 失败 → PR Check ❌
          ↓
分支保护  Require status checks → Merge 被挡
```

| 环节 | 谁执行 | 拦合并？ |
|------|--------|----------|
| Cmd+U | 你本地 | 否 |
| fastlane test | 本地/服务器 | 否（仅退出码） |
| GitHub Actions | GitHub 服务器 | 产生 Check 结果 |
| Branch protection | GitHub 规则 | **是** |

---

## 五、常见问题

### Q: Status checks 列表里没有 `test`？

先让 `main` 上 Actions **成功跑完至少一次**，再回到 Branch protection 里选。

### Q: Actions 在 GitHub 上模拟器失败？

改 workflow：

```yaml
CI_SIMULATOR: iPhone 16   # 或 Actions 日志里有的型号，如 iPhone 15
```

本地 `Fastfile` 仍可用 `iPhone 17 Pro`，互不影响。

### Q: 个人免费仓库能开分支保护吗？

可以。Settings → Branches 对个人公开/私有仓库均可用。

### Q: 合并后测试报告在哪？

Actions → 某次 run → **Artifacts** → 下载 `test-reports-xxx`（含 `report.html`）。

---

## 六、面试一句话

> 我们在 PR 上通过 GitHub Actions 跑 Fastlane 单测，main 分支开启 branch protection，要求 `test` job 通过才能合并；测试失败时 Check 变红，Merge 被阻断。

---

Step 3B 完成后，整个「开发 → CI 门禁 → 合并」闭环在 GitHub 上就打通了。
