# NewVersion

一个 Swift Package，用于在 iOS 应用中优雅地提示用户进行版本更新。

## 概览

`NewVersion` 提供了一个易于集成的解决方案，用于检测新版本并通过一个可高度自定义的弹窗通知用户。它支持强制更新和可选更新，并能管理提示的频率，以提供更好的用户体验。

## 特性

-   **可定制的更新弹窗**: 通过 `UpdateAlertViewController.Configuration` 可以自定义弹窗的标题、内容文本、按钮文字、颜色、字体等。
-   **强制与可选更新**: 支持标记某个更新是否为强制性。
-   **提示策略**: 内置提示策略，如 `oncePerVersionNonForced`，避免对非强制更新的同一版本重复打扰用户。
-   **本地化支持**: 默认支持英文和简体中文（通过项目中的 `en.lproj` 和 `zh-Hans.lproj` 文件）。弹窗的默认标题和按钮文本可以通过本地化字符串进行配置。
-   **易于集成**: 使用 Swift Package Manager 轻松添加到你的项目中。
-   **主要组件**:
    -   `AppUpdateManager`: 核心管理类，负责处理更新逻辑和显示提示。
    -   `UpdateAlertViewController`: 用于展示更新信息的弹窗视图控制器。

## 环境要求

-   iOS 13.0+
-   Swift 6.0+
-   依赖库:
    -   [SnapKit](https://github.com/SnapKit/SnapKit.git) (>= 5.7.1)

## 安装

通过 Swift Package Manager 将 `NewVersion` 添加到你的 Xcode 项目中：

1.  在 Xcode 中，打开你的项目。
2.  选择 `File` > `Add Packages...`
3.  在搜索框中输入你的包的 Git URL (例如: `https://your-repo-url/NewVersion.git` - **请替换为你的实际仓库URL**)。
4.  选择版本规则（例如，`Up to Next Major Version` from `1.0.0`）。
5.  点击 `Add Package`。
6.  选择要将库添加到的目标。

## 使用方法

### 1. 导入模块

在需要使用的地方导入 `NewVersion`：

```swift
import NewVersion
```

### 2. 显示更新提示

通过 `AppUpdateManager` 的单例来显示更新提示。通常你会在应用启动后或者某个合适的时机检查更新。

```swift
import NewVersion
import UIKit

class YourViewController: UIViewController {

    func checkForAppUpdate() {
        // 替换为你的 App Store 链接
        guard let appStoreURL = URL(string: "https://apps.apple.com/app/your-app-id") else {
            print("无效的 App Store URL")
            return
        }

        // 从你的服务器获取最新版本信息
        let latestVersionFromServer = "1.1.0"
        let updateNotesFromServer = "我们修复了一些已知问题，并优化了性能。建议您尽快更新！\n\n- 新增了XX功能\n- 修复了YY bug"
        let isForceUpdateFromServer = false

        AppUpdateManager.shared.showUpdatePrompt(
            latestVersion: latestVersionFromServer,
            updateText: updateNotesFromServer,
            forceUpdate: isForceUpdateFromServer,
            appStoreURL: appStoreURL,
            inViewController: self, // 当前的视图控制器，用于 present 弹窗
            // customConfiguration: nil, // 可选：自定义弹窗配置
            // promptStrategy: .default  // 可选：自定义提示策略
        )
    }
}
```

### 3. 自定义弹窗外观 (可选)

你可以通过 `UpdateAlertViewController.Configuration` 来完全自定义弹窗的外观和部分文本。

```swift
import NewVersion
import UIKit

// ...

let customConfig = UpdateAlertViewController.Configuration(
    // title: "发现新版本!", // 默认会使用本地化字符串
    content: "自定义的更新内容...",
    forceUpdate: false,
    // updateButtonTitle: "立即升级", // 默认会使用本地化字符串
    // laterButtonTitle: "残忍拒绝",   // 默认会使用本地化字符串
    titleColor: .blue,
    contentColor: .purple,
    updateButtonBackgroundColor: .green,
    updateButtonTitleColor: .white,
    // ... 更多配置项
    alertWidth: 280,
    maxContentHeight: 300
)

AppUpdateManager.shared.showUpdatePrompt(
    latestVersion: "1.1.0",
    updateText: "这是通过自定义配置显示的更新内容。", // 如果config中也设置了content, 优先使用调用时传入的
    forceUpdate: false,
    appStoreURL: appStoreURL,
    inViewController: self,
    customConfiguration: customConfig
)
```

### 4. 本地化

`NewVersion` 使用 `Bundle.module` 来加载本地化资源。默认的弹窗标题（"发现新版本"）、"立即更新"按钮和"稍后提醒"按钮的文本可以通过在你的 Swift Package 的 `Sources/NewVersion/Resources` 目录下创建或修改 `en.lproj/Localizable.strings` 和 `zh-Hans.lproj/Localizable.strings` (或其他语言) 文件来进行本地化。

`UpdateAlertViewController.Configuration.LocalizationKeys` 提供了默认的键名：
-   `defaultTitle = "update_alert_title"`
-   `defaultUpdateButton = "update_alert_update_button"`
-   `defaultLaterButton = "update_alert_later_button"`

示例 `zh-Hans.lproj/Localizable.strings` 文件内容:
```
"update_alert_title" = "发现新版本";
"update_alert_update_button" = "立即更新";
"update_alert_later_button" = "稍后提醒";
```

你可以通过 `UpdateAlertViewController.Configuration` 的初始化参数直接提供自定义的标题和按钮文本，这将覆盖默认的本地化行为。

### 5. 清除已提示版本记录 (用于测试)

如果使用了 `.oncePerVersionNonForced` 或默认策略，`AppUpdateManager` 会记录已提示过的版本（针对非强制更新）。在测试时，你可能需要清除这个记录：

```swift
AppUpdateManager.shared.clearLastPromptedVersion()
```

## 核心组件

-   **`AppUpdateManager`**:
    -   `shared`: 单例访问。
    -   `showUpdatePrompt(...)`: 显示更新提示的核心方法。
    -   `clearLastPromptedVersion()`: 清除已提示版本记录。
    -   `PromptStrategy`: 枚举，定义提示策略 (`.default`, `.oncePerVersionNonForced`)。

-   **`UpdateAlertViewController`**:
    -   用于显示更新弹窗的 `UIViewController`。
    -   `onLater`: 用户点击"稍后"按钮的回调。
    -   `onUpdate`: 用户点击"更新"按钮的回调。
    -   `Configuration`: 结构体，用于详细配置弹窗的UI和文本。
        -   `LocalizationKeys`: 结构体，包含默认本地化键名和辅助方法。

## 依赖项

-   [SnapKit](https://github.com/SnapKit/SnapKit.git): 一个强大的 Swift 自动布局 DSL。

---

希望这个 `README.md` 对您有所帮助！ 