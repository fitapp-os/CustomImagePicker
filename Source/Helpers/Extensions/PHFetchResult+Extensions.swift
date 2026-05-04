//
//  PHFetchResult + IndexPath.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 26/01/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import Foundation
import Photos

internal extension PHFetchResult where ObjectType == PHAsset {
    func assetsAtIndexPaths(_ indexPaths: [IndexPath]) -> [PHAsset] {
        if indexPaths.isEmpty { return [] }
        let fetchCount = self.count

        let validIndexPaths = indexPaths.filter { indexPath in
            indexPath.item >= 0 && indexPath.item < fetchCount
        }

        if validIndexPaths.isEmpty { return [] }

        var assets: [PHAsset] = []
        assets.reserveCapacity(validIndexPaths.count)
        for indexPath in validIndexPaths {
            let asset = self[indexPath.item]
            assets.append(asset)
        }
        return assets
    }
}
