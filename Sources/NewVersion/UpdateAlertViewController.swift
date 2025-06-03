//
//  UpdateAlertViewController.swift
//  NewVersion
//
//  Created by 郁旭辉 on 2025/6/3.
//

import SnapKit
import UIKit

@MainActor
public class UpdateAlertViewController: UIViewController {
    // MARK: - UI属性

    private let alertView = UIView() // 弹窗的主视图
    private let titleLabel = UILabel() // 标题标签
    private let contentScrollView = UIScrollView() // 内容滚动视图
    private let contentLabel = UILabel() // 内容标签
    private let laterButton = UIButton(type: .system) // "稍后"按钮
    private let updateButton = UIButton(type: .system) // "更新"按钮
    private let buttonsStackView = UIStackView() // 按钮容器

    // MARK: - 回调闭包

    public var onLater: (() -> Void)? // 点击"稍后"按钮的回调
    public var onUpdate: (() -> Void)? // 点击"更新"按钮的回调

    // MARK: - 配置实例

    private let config: Configuration // 弹窗配置

    // MARK: - 配置结构体

    public struct Configuration {
        let title: String // 标题文字
        let content: String // 内容文字 (通常来自服务器，动态)
        let forceUpdate: Bool // 是否强制更新

        let updateButtonTitle: String // 更新按钮的标题
        let laterButtonTitle: String // 稍后按钮的标题

        let titleColor: UIColor // 标题颜色
        let contentColor: UIColor // 内容颜色
        let updateButtonBackgroundColor: UIColor // 更新按钮背景色
        let updateButtonTitleColor: UIColor // 更新按钮标题颜色
        let laterButtonBackgroundColor: UIColor // 稍后按钮背景色
        let laterButtonTitleColor: UIColor // 稍后按钮标题颜色
        let alertBackgroundColor: UIColor // 整个视图控制器背景色 (例如：遮罩层)
        let alertViewBackgroundColor: UIColor // 弹窗主视图背景色

        let titleFont: UIFont // 标题字体
        let contentFont: UIFont // 内容字体
        let buttonFont: UIFont // 按钮字体

        let cornerRadius: CGFloat // 圆角半径
        let alertWidth: CGFloat // 弹窗宽度
        let maxContentHeight: CGFloat // 内容区域最大高度

        // 本地化键名常量
        // 确保 LocalizationKeys 及其内部的静态属性都是 public
        public struct LocalizationKeys {
            public static let defaultTitle = "update_alert_title"
            public static let defaultUpdateButton = "update_alert_update_button"
            public static let defaultLaterButton = "update_alert_later_button"

            // 新增：公共的静态本地化辅助方法
            public static func localized(_ key: String, comment: String = "") -> String {
                return NSLocalizedString(key, bundle: Bundle.module, comment: comment)
            }
        }

        public init(
            // 使用新的辅助方法
            title: String = LocalizationKeys.localized(LocalizationKeys.defaultTitle, comment: "Update alert title"),
            content: String,
            forceUpdate: Bool,
            updateButtonTitle: String = LocalizationKeys.localized(LocalizationKeys.defaultUpdateButton, comment: "Update alert: Update Now button title"),
            laterButtonTitle: String = LocalizationKeys.localized(LocalizationKeys.defaultLaterButton, comment: "Update alert: Later button title"),
            titleColor: UIColor = .black,
            contentColor: UIColor = UIColor.darkGray,
            updateButtonBackgroundColor: UIColor = UIColor.black,
            updateButtonTitleColor: UIColor = .white,
            laterButtonBackgroundColor: UIColor = UIColor.systemGray3,
            laterButtonTitleColor: UIColor = UIColor.darkGray,
            alertBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5),
            alertViewBackgroundColor: UIColor = .white,
            titleFont: UIFont = .boldSystemFont(ofSize: 18),
            contentFont: UIFont = .systemFont(ofSize: 16),
            buttonFont: UIFont = .boldSystemFont(ofSize: 16),
            cornerRadius: CGFloat = 12.0,
            alertWidth: CGFloat = 300.0,
            maxContentHeight: CGFloat = 200.0
        ) {
            self.title = title
            self.content = content
            self.forceUpdate = forceUpdate
            self.updateButtonTitle = updateButtonTitle
            self.laterButtonTitle = laterButtonTitle
            self.titleColor = titleColor
            self.contentColor = contentColor
            self.updateButtonBackgroundColor = updateButtonBackgroundColor
            self.updateButtonTitleColor = updateButtonTitleColor
            self.laterButtonBackgroundColor = laterButtonBackgroundColor
            self.laterButtonTitleColor = laterButtonTitleColor
            self.alertBackgroundColor = alertBackgroundColor
            self.alertViewBackgroundColor = alertViewBackgroundColor
            self.titleFont = titleFont
            self.contentFont = contentFont
            self.buttonFont = buttonFont
            self.cornerRadius = cornerRadius
            self.alertWidth = alertWidth
            self.maxContentHeight = maxContentHeight
        }
    }

    // MARK: - 初始化

    public init(configuration: Configuration) {
        config = configuration
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen // 模态显示风格：覆盖全屏
        modalTransitionStyle = .crossDissolve // 模态过渡风格：交叉溶解
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) 未实现")
    }

    // MARK: - 生命周期方法

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupView() // 设置主视图
        setupAlertElements() // 设置弹窗内的元素
        setupConstraints() // 设置约束
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 用于调试内容可见性的打印语句
        debugPrint("--- DEBUG UpdateAlertViewController --- 开始调试输出 ---")
        debugPrint("配置中的内容 (前50字符): \(config.content.prefix(50))")
        debugPrint("contentLabel的文本 (前50字符): \(contentLabel.text?.prefix(50) ?? "空")")
        debugPrint("contentLabel的字体: \(contentLabel.font!)")
        debugPrint("contentLabel的文本颜色: \(contentLabel.textColor!)")
        debugPrint("contentLabel的frame: \(contentLabel.frame)")
        debugPrint("contentLabel的bounds: \(contentLabel.bounds)")
        debugPrint("contentLabel的intrinsicContentSize: \(contentLabel.intrinsicContentSize)")
        debugPrint("contentScrollView的frame: \(contentScrollView.frame)")
        debugPrint("contentScrollView的bounds: \(contentScrollView.bounds)")
        debugPrint("contentScrollView的contentSize: \(contentScrollView.contentSize)")
        debugPrint("alertView的frame: \(alertView.frame)")
        debugPrint("--- DEBUG UpdateAlertViewController --- 结束调试输出 ---")
    }

    // MARK: - 视图设置

    private func setupView() {
        view.backgroundColor = config.alertBackgroundColor // 设置视图控制器主视图的背景色（遮罩层）

        alertView.backgroundColor = config.alertViewBackgroundColor // 设置弹窗卡片的背景色
        alertView.layer.cornerRadius = config.cornerRadius // 设置圆角
        alertView.layer.masksToBounds = true // 超出圆角部分裁剪
        view.addSubview(alertView) // 将弹窗卡片添加到视图控制器主视图
    }

    private func setupAlertElements() {
        // 标题标签设置
        titleLabel.text = config.title
        titleLabel.font = config.titleFont
        titleLabel.textColor = config.titleColor
        titleLabel.textAlignment = .center
        alertView.addSubview(titleLabel)

        // 内容滚动视图和内容标签设置
        contentScrollView.showsVerticalScrollIndicator = true // 显示垂直滚动条
        contentScrollView.showsHorizontalScrollIndicator = false // 不显示水平滚动条
        // 调试用: 设置背景色以观察frame
        // contentScrollView.backgroundColor = .red.withAlphaComponent(0.3)
        alertView.addSubview(contentScrollView)

        contentLabel.text = config.content
        contentLabel.font = config.contentFont
        contentLabel.textColor = config.contentColor
        contentLabel.numberOfLines = 0 // 允许多行显示
        contentLabel.textAlignment = .left
        // 调试用: 设置背景色以观察frame
        // contentLabel.backgroundColor = .green.withAlphaComponent(0.3)
        contentScrollView.addSubview(contentLabel)

        // 按钮堆栈视图设置
        buttonsStackView.axis = .horizontal // 水平排列
        buttonsStackView.spacing = 10 // 按钮间距
        buttonsStackView.distribution = .fillEqually // 等宽分布
        alertView.addSubview(buttonsStackView)

        // "稍后"按钮设置 (如果不是强制更新)
        if !config.forceUpdate {
            laterButton.setTitle(config.laterButtonTitle, for: .normal)
            laterButton.titleLabel?.font = config.buttonFont
            laterButton.backgroundColor = config.laterButtonBackgroundColor
            laterButton.setTitleColor(config.laterButtonTitleColor, for: .normal)
            laterButton.layer.cornerRadius = config.cornerRadius > 4 ? (config.cornerRadius / 2) : 6 // 根据弹窗圆角调整按钮圆角
            laterButton.addTarget(self, action: #selector(laterTapped), for: .touchUpInside)
            buttonsStackView.addArrangedSubview(laterButton)
        }

        // "更新"按钮设置
        updateButton.setTitle(config.updateButtonTitle, for: .normal)
        updateButton.titleLabel?.font = config.buttonFont
        updateButton.backgroundColor = config.updateButtonBackgroundColor
        updateButton.setTitleColor(config.updateButtonTitleColor, for: .normal)
        updateButton.layer.cornerRadius = config.cornerRadius > 4 ? (config.cornerRadius / 2) : 6 // 根据弹窗圆角调整按钮圆角
        updateButton.addTarget(self, action: #selector(updateTapped), for: .touchUpInside)
        buttonsStackView.addArrangedSubview(updateButton)
    }

    // MARK: - 约束设置

    private func setupConstraints() {
        alertView.snp.makeConstraints { make in
            make.center.equalToSuperview() // 居中显示
            make.width.equalTo(config.alertWidth) // 设置宽度
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20) // 顶部间距
            make.left.right.equalToSuperview().inset(20) // 左右间距
        }

        contentScrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15) // 位于标题下方，间距15
            make.left.right.equalToSuperview().inset(20) // 左右间距

            // 尝试让滚动视图初始时包裹其内容，然后由maxContentHeight限制其最大高度
            // 同时确保它具有一定的抗压缩能力，防止在内容为空时完全折叠
            let estimatedContentHeight = contentLabel.systemLayoutSizeFitting(CGSize(width: config.alertWidth - 40, height: UIView.layoutFittingCompressedSize.height)).height
            let scrollViewHeight = min(estimatedContentHeight, config.maxContentHeight)
            make.height.equalTo(scrollViewHeight).priority(.high) // 以高优先级设置计算出的高度
            make.height.lessThanOrEqualTo(config.maxContentHeight).priority(.required) // 确保不超过最大高度（必要约束）
            make.height.greaterThanOrEqualTo(20).priority(.low) // 防止在内容为空时折叠为零（低优先级）
        }

        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 内容标签的边缘贴紧滚动视图的边缘
            make.width.equalToSuperview() // 内容标签的宽度与滚动视图相同，以实现垂直滚动
            // contentLabel的高度将决定contentScrollView的contentSize.height
        }

        buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(contentScrollView.snp.bottom).offset(20) // 位于内容滚动视图下方，间距20
            make.left.right.equalToSuperview().inset(20) // 左右间距
            make.height.equalTo(44) // 固定高度
            make.bottom.equalToSuperview().offset(-20) // 底部间距，这将决定alertView的整体高度
        }
    }

    // MARK: - 按钮事件处理

    @objc private func laterTapped() {
        dismiss(animated: true) { [weak self] in // 关闭视图控制器
            self?.onLater?() // 执行回调
        }
    }

    @objc private func updateTapped() {
        onUpdate?() // 执行回调，具体的关闭逻辑由AppUpdateManager处理（如果是非强制更新）
    }
}
