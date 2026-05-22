# Step 1：跑通登录 Demo + 单元测试

## 新增文件

| 文件 | 作用 |
|------|------|
| `CICD_Demo/LoginViewModel.swift` | MVVM、Mock 可测、async 登录 |
| `CICD_Demo/LoginViewController.swift` | 登录 UI（代码布局） |
| `CICD_DemoTests/LoginViewModelTests.swift` | ViewModel 单测 |
| `CICD_DemoTests/JSONParsingTests.swift` | Codable 单测 |

## 修改

- `SceneDelegate.swift`：启动时显示登录页（不再用 Main.storyboard）
- `Info.plist`：去掉 Scene 的 Main storyboard 绑定
- 工程：已添加 **CICD_DemoTests** 测试 Target

## 在 Xcode 里运行

1. 打开 `CICD_Demo.xcodeproj`
2. 选模拟器（如 iPhone 17 Pro）
3. **Cmd + R** 运行 App  
   - 用户名：`demo`  
   - 密码：`pass123`
4. **Cmd + U** 运行单元测试（应 3 个全绿）

## 测试账号

- 成功：`demo` / `pass123` → `Welcome, Demo User`
- 失败：任意其他组合 → `Invalid username or password`

---

Step 1 已完成 → 见 **STEP2.md**（Fastlane）。
