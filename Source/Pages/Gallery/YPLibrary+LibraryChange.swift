//
//  YPLibrary+LibraryChange.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 26/01/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit
import Photos

extension YPLibraryVC: PHPhotoLibraryChangeObserver {
    func registerForLibraryChanges() {
        PHPhotoLibrary.shared().register(self)
    }
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            guard let fetchResult = self.mediaManager.fetchResult,
                  let collectionChanges = changeInstance.changeDetails(for: fetchResult) else {
                ypLog("Some problems there.")
                return
            }

            let collectionView = self.v.collectionView
            self.mediaManager.fetchResult = collectionChanges.fetchResultAfterChanges
            collectionView.reloadData()

            self.updateAssetSelection()
            self.mediaManager.resetCachedAssets()
            self.updateEmptyState()
        }
    }

    fileprivate func updateAssetSelection() {
        // If no items selected in assetView, but there are already photos
        // after photoLibraryDidChange, than select first item in library.
        // It can be when user add photos from limited permission.
        if self.mediaManager.hasResultItems,
           selectedItems.isEmpty,
           let newAsset = self.mediaManager.getAsset(at: 0) {
            self.changeAsset(newAsset)
        }

        // If user decided to forbid all photos with limited permission
        // while using the lib we need to remove asset from assets view.
        if selectedItems.isEmpty == false,
           self.mediaManager.hasResultItems == false {
            self.v.assetZoomableView.clearAsset()
            self.selectedItems.removeAll()
            self.delegate?.libraryViewFinishedLoading()
        }
    }
}
