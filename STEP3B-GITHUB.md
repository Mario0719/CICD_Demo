# Step 3B 操作清单（仓库：Mario0719/CICD_Demo）

仓库地址：https://github.com/Mario0719/CICD_Demo

---

## 第 0 步：先让 main 上 CI 变绿（必做）

你第一次 push 后 Actions **红了**，需要先修 CI 再开分支保护。

本地已调整：部署目标改为 iOS 16.0、CI 自动选模拟器。请执行：

```bash
cd /Users/mario/Downloads/HSBC/CICD_Demo
git add .
git commit -m "fix: CI deployment target + auto pick simulator on GitHub Actions"
git push
```

然后打开：https://github.com/Mario0719/CICD_Demo/actions  
等待最新 **iOS CI** 显示 **绿色勾**。

---

## 第 1 步：开启分支保护

1. 打开 https://github.com/Mario0719/CICD_Demo/settings/branches  
2. **Add branch protection rule**  
3. 填写：

| 项 | 设置 |
|----|------|
| Branch name pattern | `main` |
| Require a pull request before merging | ✅ |
| Require status checks to pass before merging | ✅ |
| Require branches to be up to date before merging | ✅ 建议 |
| Status checks that are required | 勾选 **`test`**（或 **iOS CI / test**） |

4. **Save changes**

> 若列表里没有 `test`：等 main 上 Actions **成功跑过一次** 再回来勾选。

---

## 第 2 步：实验 — 失败 PR 不能合并

```bash
cd /Users/mario/Downloads/HSBC/CICD_Demo
git checkout main && git pull
git checkout -b experiment/ci-should-fail
```

编辑 `CICD_DemoTests/JSONParsingTests.swift` 第 16 行：

```swift
XCTAssertEqual(response.token, "abc2")  // 故意错
```

```bash
git add .
git commit -m "test: intentionally fail CI"
git push -u origin experiment/ci-should-fail
```

在 GitHub 开 PR → 应看到 **test ❌**、**Merge 被挡**。

---

## 第 3 步：实验 — 修复后可以合并

改回：

```swift
XCTAssertEqual(response.token, "abc")
```

```bash
git add .
git commit -m "test: fix CI"
git push
```

PR 上 **test ✅** → 点击 **Merge pull request**。

```bash
git checkout main
git pull
```

---

## 合并门禁体现在哪

| 现象 | 含义 |
|------|------|
| PR 下方 Checks `test` 红 | fastlane 测试失败 |
| **Merge blocked** | 分支保护生效，不能合 |
| Checks `test` 绿 | 允许 Merge |

---

完成 Step 3B 后，整个 GitHub CI/CD 闭环打通。
