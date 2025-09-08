//
//  YPAssetViewContainer.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 15/11/2016.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import UIKit
import Stevia
import AVFoundation

/// The container for asset (video or image). It containts the YPGridView and YPAssetZoomableView.
final class YPAssetViewContainer: UIView {
    public let curtain = UIView()
    public let spinnerView = UIView()
    public let squareCropButton = UIButton()
    public let rotateButton = UIButton()
    public let multipleSelectionButton: UIButton = {
        let v = UIButton()
        v.setImage(YPConfig.icons.multipleSelectionOffIcon, for: .normal)
        return v
    }()
    
    public var zoomableView: YPAssetZoomableView
    public var itemOverlay: UIView?
    public var onlySquare = YPConfig.library.onlySquare
    public var isShown = true
    public var spinnerIsShown = false
    public var itemOverlayType = YPConfig.library.itemOverlayType
    public var rotationAngle = YPConfig.library.rotationAngle
    
    public private(set) var currentRotationAngle: CGFloat = 0
    
    private let spinner = UIActivityIndicatorView(style: .medium)
    private var shouldCropToSquare = YPConfig.library.isSquareByDefault
    private var isMultipleSelectionEnabled = false

    init(frame: CGRect, zoomableView: YPAssetZoomableView) {
        self.zoomableView = zoomableView
        super.init(frame: frame)

        self.zoomableView.zoomableViewDelegate = self

        switch itemOverlayType {
        case .grid:
            itemOverlay = YPGridView()
        default:
            break
        }

        if let itemOverlay = itemOverlay {
            addSubview(itemOverlay)
            itemOverlay.frame = frame
            clipsToBounds = true

            itemOverlay.alpha = 0
        }

        let touchDownGR = UILongPressGestureRecognizer(target: self,
                                                       action: #selector(handleTouchDown))
        touchDownGR.minimumPressDuration = 0
        touchDownGR.delegate = self
        addGestureRecognizer(touchDownGR)

        // TODO: Add tap gesture to play/pause. Add double tap gesture to square/unsquare

        subviews(
            spinnerView.subviews(
                spinner
            ),
            curtain
        )

        spinner.centerInContainer()
        spinnerView.fillContainer()
        curtain.fillContainer()

        spinner.startAnimating()
        spinnerView.backgroundColor = UIColor.ypLabel.withAlphaComponent(0.3)
        curtain.backgroundColor = UIColor.ypLabel.withAlphaComponent(0.7)
        curtain.alpha = 0

        if !onlySquare {
            // Crop Button
            squareCropButton.setImage(YPConfig.icons.cropIcon, for: .normal)
            
            if let backgroundColor = YPConfig.library.buttonBackgroundColor {
                squareCropButton.layer.masksToBounds = true
                squareCropButton.layer.cornerRadius = YPConfig.library.buttonSize / 2
                squareCropButton.backgroundColor = backgroundColor
            }
            
            subviews(squareCropButton)
            squareCropButton.size(YPConfig.library.buttonSize)
            |-15-squareCropButton
            squareCropButton.Bottom == self.Bottom - 15
        }
        
        if YPConfig.library.rotationAngle != nil {
            // Rotate button
            rotateButton.setImage(YPConfig.icons.rotateIcon, for: .normal)
            if let backgroundColor = YPConfig.library.buttonBackgroundColor {
                rotateButton.layer.masksToBounds = true
                rotateButton.layer.cornerRadius = YPConfig.library.buttonSize / 2
                rotateButton.backgroundColor = backgroundColor
            }
            
            subviews(rotateButton)
            rotateButton.size(YPConfig.library.buttonSize)
            rotateButton-15-|
            rotateButton.Bottom == self.Bottom - 15
        }

        // Multiple selection button
        subviews(multipleSelectionButton)
        multipleSelectionButton.size(YPConfig.library.buttonSize).trailing(15)
        multipleSelectionButton.Bottom == zoomableView.Bottom - (15 + (rotationAngle != nil ? YPConfig.library.buttonSize + 10 : 0))
    }

    required init?(coder: NSCoder) {
        zoomableView = YPAssetZoomableView()
        super.init(coder: coder)
        fatalError("Only code layout.")
    }

    // MARK: - Square button

    @objc public func squareCropButtonTapped() {
        let z = zoomableView.zoomScale
        shouldCropToSquare = (z >= 1 && z < zoomableView.squaredZoomScale)
        squareCropButton.setImage(z <= 1 ? YPConfig.icons.shrinkIcon : YPConfig.icons.cropIcon, for: .normal)
        zoomableView.fitImage(shouldCropToSquare, animated: true)
    }

    /// Update only UI of square crop button.
    public func updateSquareCropButtonState() {
        guard !isMultipleSelectionEnabled else {
            // If multiple selection enabled, the squareCropButton is not visible
            squareCropButton.isHidden = true
            return
        }
        guard !onlySquare else {
            // If only square enabled, than the squareCropButton is not visible
            squareCropButton.isHidden = true
            return
        }
        guard let selectedAssetImage = zoomableView.assetImageView.image else {
            // If no selected asset, than the squareCropButton is not visible
            squareCropButton.isHidden = true
            return
        }

        let isImageASquare = selectedAssetImage.size.width == selectedAssetImage.size.height
        squareCropButton.isHidden = isImageASquare
    }
    
    // MARK: - Rotate button
    
    @objc public func rotateButtonTapped() {
        guard let rotationAngle = YPConfig.library.rotationAngle else { return }
           currentRotationAngle += rotationAngle * .pi / 180
           zoomableView.transform = CGAffineTransform(rotationAngle: currentRotationAngle)
       }
    
    // MARK: - Multiple selection

    /// Use this to update the multiple selection mode UI state for the YPAssetViewContainer
    public func setMultipleSelectionMode(on: Bool) {
        isMultipleSelectionEnabled = on
        let image = on ? YPConfig.icons.multipleSelectionOnIcon : YPConfig.icons.multipleSelectionOffIcon
        multipleSelectionButton.setImage(image, for: .normal)
        updateSquareCropButtonState()
    }
}

// MARK: - ZoomableViewDelegate
extension YPAssetViewContainer: YPAssetZoomableViewDelegate {
    public func ypAssetZoomableViewDidLayoutSubviews(_ zoomableView: YPAssetZoomableView) {
        let newFrame = zoomableView.assetImageView.convert(zoomableView.assetImageView.bounds, to: self)
        
        if let itemOverlay = itemOverlay {
            // update grid position
            itemOverlay.frame = frame.intersection(newFrame)
            itemOverlay.layoutIfNeeded()
        }
        
        // Update play imageView position - bringing the playImageView from the videoView to assetViewContainer,
        // but the controll for appearing it still in videoView.
        if zoomableView.videoView.playImageView.isDescendant(of: self) == false {
            self.addSubview(zoomableView.videoView.playImageView)
            zoomableView.videoView.playImageView.centerInContainer()
        }
        
        squareCropButton.setImage(zoomableView.zoomScale <= 1 ? YPConfig.icons.shrinkIcon : YPConfig.icons.cropIcon, for: .normal)
    }
    
    public func ypAssetZoomableViewScrollViewDidZoom() {
        guard let itemOverlay = itemOverlay else {
            return
        }
        if isShown {
            UIView.animate(withDuration: 0.1) {
                itemOverlay.alpha = 1
            }
        }
    }
    
    public func ypAssetZoomableViewScrollViewDidEndZooming() {
        guard let itemOverlay = itemOverlay else {
            return
        }
        UIView.animate(withDuration: 0.3) {
            itemOverlay.alpha = 0
        }
    }
}

// MARK: - Gesture recognizer Delegate
extension YPAssetViewContainer: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !spinnerIsShown && !(touch.view is UIButton)
    }
    
    @objc
    private func handleTouchDown(sender: UILongPressGestureRecognizer) {
        guard let itemOverlay = itemOverlay else {
            return
        }
        switch sender.state {
        case .began:
            if isShown {
                UIView.animate(withDuration: 0.1) {
                    itemOverlay.alpha = 1
                }
            }
        case .ended:
            UIView.animate(withDuration: 0.3) {
                itemOverlay.alpha = 0
            }
        default: ()
        }
    }
}
