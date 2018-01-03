//
//  PhotoCollerction.swift
//  ImageMemoS
//
//  Created by 中山浩樹 on 2017/12/24.
//  Copyright © 2017年 中山浩樹. All rights reserved.
//

import Photos

class PhotoCollection {
    
    private static var collection: PHAssetCollection!
    private static var selectNum: NSInteger!
    
    public static func getCorrection() -> PHAssetCollection {
        return self.collection
    }
    
    public static func setCollection(collection: PHAssetCollection) {
        self.collection = collection
    }
    
    public static func getSelectNum() -> NSInteger {
        return self.selectNum
    }
    
    public static func setSelectNum(num: NSInteger) {
        self.selectNum = num
    }
    
    public static func getTitle(collection: PHAssetCollection) -> String {
        var title = collection.localizedTitle! as String
        
        if isAllPhotos(collection: collection) {
            title = "すべての写真"
        }
        return title
    }
    
    public static func isAllPhotos(collection: PHAssetCollection) -> Bool {
        let title: NSString = collection.localizedTitle! as NSString
        
        if title.isEqual(to: "All Photos") || title.isEqual(to: "Camera Roll") {
            return true
        }
        return false
    }
    
    public static func getFileName(asset: PHAsset) -> String {

        return asset.value(forKey: "filename") as! String
    }
    
    public static func isMemoEnable(asset: PHAsset) -> Bool {
        if (CoreDataManager.getMemo(
            fileName: asset.value(forKey: "filename") as! String)).utf16.count > 0 {
            return true
        }
        return false
    }
}
