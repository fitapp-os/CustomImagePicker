//
//  YPLibraryView.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/14.
//  Copyright © 2015 Yummypets. All rights reserved.
//

import UIKit
import Stevia
import Photos

internal final class YPLibraryView: UIView {

    // MARK: - Public vars

    internal let assetZoomableViewMinimalVisibleHeight: CGFloat  = 50
    internal var assetViewContainerConstraintTop: NSLayoutConstraint?
    internal let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.backgroundColor = YPConfig.colors.libraryScreenBackgroundColor
        v.collectionViewLayout = layout
        v.showsHorizontalScrollIndicator = false
        v.alwaysBounceVertical = true
        return v
    }()
    internal lazy var assetViewContainer: YPAssetViewContainer = {
        let v = YPAssetViewContainer(frame: .zero, zoomableView: assetZoomableView)
        v.accessibilityIdentifier = "assetViewContainer"
        return v
    }()
    internal let assetZoomableView: YPAssetZoomableView = {
        let v = YPAssetZoomableView(frame: .zero)
        v.accessibilityIdentifier = "assetZoomableView"
        return v
    }()
    /// At the bottom there is a view that is visible when selected a limit of items with multiple selection
    internal let maxNumberWarningView: UIView = {
        let v = UIView()
        v.backgroundColor = .ypSecondarySystemBackground
        v.isHidden = true
        return v
    }()
    internal let maxNumberWarningLabel: UILabel = {
        let v = UILabel()
        v.font = YPConfig.fonts.libaryWarningFont
        return v
    }()
    internal let emptyStateView: UIView = {
        let v = UIView()
        v.backgroundColor = .ypSecondarySystemBackground
        v.layer.cornerRadius = 12
        v.isHidden = true
        v.accessibilityIdentifier = "libraryEmptyStateView"
        return v
    }()
    internal let emptyStateTitleLabel: UILabel = {
        let v = UILabel()
        v.font = .rubikFont(ofSize: 17, weight: .bold)
        v.textColor = YPConfig.colors.labelColorPrimary
        v.numberOfLines = 0
        v.textAlignment = .center
        return v
    }()
    internal let emptyStateMessageLabel: UILabel = {
        let v = UILabel()
        v.font = .rubikFont(ofSize: 14, weight: .regular)
        v.textColor = YPConfig.colors.labelColorSecondary
        v.numberOfLines = 0
        v.textAlignment = .center
        return v
    }()
    internal let emptyStateActionButton: UIButton = {
        let v = UIButton(type: .system)
        v.titleLabel?.font = .rubikFont(ofSize: 15, weight: .bold)
        v.tintColor = YPConfig.colors.tintColor
        return v
    }()
    private let emptyStateStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 8
        v.alignment = .center
        return v
    }()

    // MARK: - Private vars

    private let line: UIView = {
        let v = UIView()
        v.backgroundColor = .ypSystemBackground
        return v
    }()
    /// When video is processing this bar appears
    private let progressView: UIProgressView = {
        let v = UIProgressView()
        v.progressViewStyle = .bar
        v.trackTintColor = YPConfig.colors.progressBarTrackColor
        v.progressTintColor = YPConfig.colors.progressBarCompletedColor ?? YPConfig.colors.tintColor
        v.isHidden = true
        v.isUserInteractionEnabled = false
        return v
    }()
    private let collectionContainerView: UIView = {
        let v = UIView()
        v.accessibilityIdentifier = "collectionContainerView"
        return v
    }()
    private var shouldShowLoader = false {
        didSet {
            DispatchQueue.main.async {
                self.assetViewContainer.squareCropButton.isEnabled = !self.shouldShowLoader
                self.assetViewContainer.multipleSelectionButton.isEnabled = !self.shouldShowLoader
                self.assetViewContainer.spinnerIsShown = self.shouldShowLoader
                self.shouldShowLoader ? self.hideOverlayView() : ()
            }
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Only code layout.")
    }

    // MARK: - Public Methods

    // MARK: Overlay view

    func hideOverlayView() {
        assetViewContainer.itemOverlay?.alpha = 0
    }

    // MARK: Loader and progress

    func fadeInLoader() {
        shouldShowLoader = true
        // Only show loader if full res image takes more than 0.5s to load.
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            if self.shouldShowLoader == true {
                UIView.animate(withDuration: 0.2) {
                    self.assetViewContainer.spinnerView.alpha = 1
                }
            }
        }
    }

    func hideLoader() {
        shouldShowLoader = false
        assetViewContainer.spinnerView.alpha = 0
    }

    func updateProgress(_ progress: Float) {
        progressView.isHidden = progress > 0.99 || progress == 0
        progressView.progress = progress
        UIView.animate(withDuration: 0.1, animations: progressView.layoutIfNeeded)
    }

    // MARK: Crop Rect

    func currentCropRect() -> CGRect {
        let cropView = assetZoomableView
        let normalizedX = min(1, cropView.contentOffset.x &/ cropView.contentSize.width)
        let normalizedY = min(1, cropView.contentOffset.y &/ cropView.contentSize.height)
        let normalizedWidth = min(1, cropView.frame.width / cropView.contentSize.width)
        let normalizedHeight = min(1, cropView.frame.height / cropView.contentSize.height)
        return CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
    }

    // MARK: Curtain

    func refreshImageCurtainAlpha() {
        let imageCurtainAlpha = abs(assetViewContainerConstraintTop?.constant ?? 0)
        / (assetViewContainer.frame.height - assetZoomableViewMinimalVisibleHeight)
        assetViewContainer.curtain.alpha = imageCurtainAlpha
    }

    func cellSize() -> CGSize {
        var screenWidth = window?.windowScene?.screen.bounds.width ?? 1.0
        let scale = window?.windowScene?.screen.scale ?? 1.0
        if UIDevice.current.userInterfaceIdiom == .pad && YPImagePickerConfiguration.widthOniPad > 0 {
            screenWidth =  YPImagePickerConfiguration.widthOniPad
        }
        let size = screenWidth / 4 * scale
        return CGSize(width: size, height: size)
    }

    // MARK: - Private Methods

    private func setupLayout() {
        subviews(
            collectionContainerView.subviews(
                collectionView,
                emptyStateView
            ),
            line,
            assetViewContainer.subviews(
                assetZoomableView
            ),
            progressView,
            maxNumberWarningView.subviews(
                maxNumberWarningLabel
            )
        )

        collectionContainerView.fillContainer()
        collectionView.fillHorizontally().bottom(0)

        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: collectionView.leadingAnchor,
                                                   constant: 24),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: collectionView.trailingAnchor,
                                                    constant: -24),
            emptyStateView.widthAnchor.constraint(lessThanOrEqualToConstant: 320)
        ])

        emptyStateView.subviews(
            emptyStateStack
        )
        emptyStateStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStateStack.topAnchor.constraint(equalTo: emptyStateView.topAnchor, constant: 16),
            emptyStateStack.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor, constant: -16),
            emptyStateStack.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 16),
            emptyStateStack.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -16)
        ])
        emptyStateStack.addArrangedSubview(emptyStateTitleLabel)
        emptyStateStack.addArrangedSubview(emptyStateMessageLabel)
        emptyStateStack.addArrangedSubview(emptyStateActionButton)
        collectionContainerView.bringSubviewToFront(emptyStateView)

        assetViewContainer.Bottom == line.Top
        line.height(1)
        line.fillHorizontally()

        assetViewContainer.translatesAutoresizingMaskIntoConstraints = false
        let assetViewContainerTopConstraint = assetViewContainer.topAnchor.constraint(equalTo: topAnchor)
        var assetViewContainerConstraints = [
            assetViewContainerTopConstraint,
            assetViewContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            assetViewContainer.heightAnchor.constraint(equalTo: assetViewContainer.widthAnchor)
        ]

        if let maximumPreviewWidth = YPConfig.library.maximumPreviewWidth {
            let fillAvailableWidthConstraint = assetViewContainer.widthAnchor.constraint(equalTo: widthAnchor)
            fillAvailableWidthConstraint.priority = .defaultHigh
            assetViewContainerConstraints.append(contentsOf: [
                assetViewContainer.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
                assetViewContainer.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
                assetViewContainer.widthAnchor.constraint(lessThanOrEqualToConstant: maximumPreviewWidth),
                fillAvailableWidthConstraint
            ])
        } else {
            assetViewContainerConstraints.append(contentsOf: [
                assetViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
                assetViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }

        NSLayoutConstraint.activate(assetViewContainerConstraints)
        self.assetViewContainerConstraintTop = assetViewContainerTopConstraint
        assetZoomableView.fillContainer().heightEqualsWidth()
        assetZoomableView.Bottom == collectionView.Top
        assetViewContainer.sendSubviewToBack(assetZoomableView)

        progressView.height(5).fillHorizontally()
        progressView.Bottom == line.Top

        |maxNumberWarningView|.bottom(0)
        maxNumberWarningView.Top == safeAreaLayoutGuide.Bottom - 40
        maxNumberWarningLabel.centerHorizontally().top(11)
    }

    func showEmptyState(title: String,
                        message: String,
                        actionTitle: String?) {
        emptyStateTitleLabel.text = title
        emptyStateMessageLabel.text = message
        if let actionTitle = actionTitle, !actionTitle.isEmpty {
            emptyStateActionButton.setTitle(actionTitle, for: .normal)
            emptyStateActionButton.isHidden = false
        } else {
            emptyStateActionButton.setTitle(nil, for: .normal)
            emptyStateActionButton.isHidden = true
        }
        emptyStateView.isHidden = false
    }

    func hideEmptyState() {
        emptyStateView.isHidden = true
    }
}
