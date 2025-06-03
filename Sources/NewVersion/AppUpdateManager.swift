//
//  AppUpdateManager.swift
//  NewVersion
//
//  Created by 郁旭辉 on 2025/6/3.
//

import UIKit
import SnapKit

/// 应用更新管理器
@MainActor
public class AppUpdateManager {

    /// 单例实例
    public static let shared = AppUpdateManager()

    /// 当前显示的模态视图控制器
    private var updateModalVC: UpdateAlertViewController?
    /// App Store 链接
    private var currentAppStoreURL: URL?

    // 新增：用于存储上次提示过的版本号的 UserDefaults key
    private let lastPromptedVersionKey = "appUpdateManager_lastPromptedVersion"

    private init() {}

    /// 显示更新提示视图
    /// - Parameters:
    ///   - latestVersion: 最新版本号（例如 "2.3.1"）
    ///   - updateText: 更新内容描述
    ///   - forceUpdate: 是否强制更新
    ///   - appStoreURL: App Store 链接
    ///   - inViewController: 当前视图控制器，用于 present UpdateAlertViewController
    ///   - customConfiguration: 可选的自定义弹窗配置 (UpdateAlertViewController.Configuration)
    ///   - promptStrategy: (当前未使用，为未来扩展保留) 弹出策略
    public func showUpdatePrompt(
        latestVersion: String,
        updateText: String,
        forceUpdate: Bool,
        appStoreURL: URL,
        inViewController: UIViewController,
        customConfiguration: UpdateAlertViewController.Configuration? = nil,
        promptStrategy: PromptStrategy = .default // 默认为 .default
    ) {

        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            debugPrint("错误: 无法获取当前应用版本。")
            return
        }

        // 版本比较：如果当前版本 >= 最新版本，则不提示
        if currentVersion.compare(latestVersion, options: .numeric) != .orderedAscending {
            debugPrint("应用已是最新版本 (当前: \(currentVersion), 最新: \(latestVersion))")
            return
        }

        // 避免重复显示同一个弹窗实例
        if updateModalVC != nil {
            debugPrint("更新提示已在显示中。")
            return
        }

        // --- 新的弹出逻辑控制 ---
        let defaults = UserDefaults.standard
        let lastPromptedVersion = defaults.string(forKey: lastPromptedVersionKey)

        // 策略：如果这个最新版本之前已经提示过，并且不是强制更新，则不再提示
        if promptStrategy == .oncePerVersionNonForced && !forceUpdate && lastPromptedVersion == latestVersion {
            debugPrint("版本 \(latestVersion) 已在本会话或之前提示过（策略：oncePerVersionNonForced），非强制更新，本次不再显示。")
            return
        }
        // --- 结束新的弹出逻辑控制 ---
        
        self.currentAppStoreURL = appStoreURL

        let alertConfig = customConfiguration ?? UpdateAlertViewController.Configuration(
            content: updateText,
            forceUpdate: forceUpdate
        )

        let alertVC = UpdateAlertViewController(configuration: alertConfig)
        
        alertVC.onLater = { [weak self] in
            guard let self = self else { return }
            self.updateModalVC = nil // 清除引用，因为弹窗已自行关闭
            if !forceUpdate {
                // 用户选择了稍后，根据策略记录这个版本为已提示 (针对非强制更新)
                if promptStrategy == .oncePerVersionNonForced || promptStrategy == .default { // .default 也视为提示过一次
                    defaults.set(latestVersion, forKey: self.lastPromptedVersionKey)
                    debugPrint("用户选择稍后更新版本 \(latestVersion)。已记录为已提示。")
                }
            }
        }
        
        alertVC.onUpdate = { [weak self] in
            guard let self = self else { return }
            self.openAppStore()
            if !forceUpdate {
                self.dismissUpdatePrompt() // 管理器在非强制更新后关闭弹窗
                // 用户已行动（即使只是去商店），根据策略记录这个版本为已提示
                 if promptStrategy == .oncePerVersionNonForced || promptStrategy == .default {
                    defaults.set(latestVersion, forKey: self.lastPromptedVersionKey)
                     debugPrint("用户选择更新版本 \(latestVersion)。已记录为已提示。")
                }
            }
            // 对于强制更新，弹窗会保留
        }

        self.updateModalVC = alertVC
        inViewController.present(alertVC, animated: true, completion: nil)
    }

    /// 关闭更新提示 (主要用于非强制更新时，从 AppUpdateManager 主动关闭)
    private func dismissUpdatePrompt() {
        updateModalVC?.dismiss(animated: true, completion: { [weak self] in
            self?.updateModalVC = nil
        })
    }

    /// 打开 App Store
    private func openAppStore() {
        guard let url = currentAppStoreURL else {
            debugPrint("错误: App Store URL 未设置。")
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            debugPrint("错误: 无法打开 App Store URL: \(url.absoluteString)")
        }
    }

    // 定义弹出策略枚举
    public enum PromptStrategy {
        case `default` // 默认行为：符合条件就弹（除非正在显示），用户操作后视为该版本已提示一次
        case oncePerVersionNonForced // 每个新版本（非强制）只提示一次，直到用户更新或新版本出现
        // case remindNextLaunchIfNotUpdated // (未来扩展) 如果用户选"稍后"，下次启动再提醒
    }
    
    // 可选：清除记录的函数，例如当用户成功更新应用后，或者希望重置测试时
    public func clearLastPromptedVersion() {
       UserDefaults.standard.removeObject(forKey: lastPromptedVersionKey)
        debugPrint("已清除上次提示的版本记录。")
    }
}

