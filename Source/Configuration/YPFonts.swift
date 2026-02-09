//
//  YPFonts.swift
//  YPImagePicker
//
//  Created by Sebastiaan Seegers on 28/02/2020.
//  Copyright © 2020 Yummypets. All rights reserved.
//

import UIKit

public struct YPFonts {

    /// The font used in the picker title
    public var pickerTitleFont: UIFont = .rubikFont(ofSize: 17, weight: .bold)

    /// The font used in the warning label of the LibraryView
    public var libaryWarningFont: UIFont = UIFont(name: "Helvetica Neue", size: 14)!

    /// The font used to show the duration in the LibraryViewCell
    public var durationFont: UIFont = .rubikFont(ofSize: 12)

    public var multipleSelectionIndicatorFont: UIFont = .rubikFont(ofSize: 12)

    public var albumCellTitleFont: UIFont = .rubikFont(ofSize: 16)

    public var albumCellNumberOfItemsFont: UIFont = .rubikFont(ofSize: 12)

    public var menuItemFontSelected: UIFont = .rubikFont(ofSize: 17, weight: .bold)
    public var menuItemFontUnselected: UIFont = .rubikFont(ofSize: 17, weight: .medium)

    public var filterNameFont: UIFont = .rubikFont(ofSize: 11)
    public var filterSelectionSelectedFont: UIFont = .rubikFont(ofSize: 11, weight: .semibold)
    public var filterSelectionUnSelectedFont: UIFont = .rubikFont(ofSize: 11)

    public var cameraTimeElapsedFont: UIFont = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)

    public var navigationBarTitleFont: UIFont = .rubikFont(ofSize: 17, weight: .bold)

    /// The font used in the UINavigationBar rightBarButtonItem
    public var rightBarButtonFont: UIFont?

    /// The font used in the UINavigationBar leftBarButtonItem
    public var leftBarButtonFont: UIFont?
}

extension UIFont {
    class func rubikFont(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let fontName = switch weight {
            case .bold: "Rubik-Bold"
            case .semibold: "Rubik-Semibold"
            case .medium: "Rubik-Medium"
            case .light: "Rubik-Light"
            default: "Rubik-Regular"
        }

        return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
    }
}
