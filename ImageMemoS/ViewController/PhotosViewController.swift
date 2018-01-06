//
//  PhotosViewController.swift
//  ImageMemoS
//
//  Created by 中山浩樹 on 2017/12/26.
//  Copyright © 2017年 中山浩樹. All rights reserved.
//

import UIKit
import Photos

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var selectCancelButton: UIButton!
    @IBOutlet weak var menuView: UIView!
    
    private var selectingMode: Bool!
    private var selectingCell: Bool!
    private var selectArray: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let collection = PhotoCollection.getCorrection()
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        
        titleLabel.text = PhotoCollection.getTitle(
            collection: collection) + " （" + String(assets.count) + "）"
        
        selectingMode = false
        selectingCell = false
        selectArray = nil
                
        changeSelectMode(selectMode: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // メモ有りチェック振り直しのためリロード
        collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * (delegate) CollectionView Cell 最大数
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let assets = PHAsset.fetchAssets(in: PhotoCollection.getCorrection(), options: nil)
        return assets.count
    }
    
    /**
     * (delegate) CollectionView Cell 描画
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        // セルの出力先View生成
        let imageView = cell.viewWithTag(1) as! UIImageView
        let checkView = cell.viewWithTag(2) as! UIImageView
        let movieView = cell.viewWithTag(3) as! UIImageView
        let selectView = cell.viewWithTag(4) as! UIImageView
        
        // 表示画像取得
        let assets = PHAsset.fetchAssets(in: PhotoCollection.getCorrection(), options: nil)
        let asset = assets.object(at: indexPath.row)
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        PHImageManager().requestImage(for: asset,
                                      targetSize: cell.frame.size,
                                      contentMode: .aspectFill,
                                      options: options,
                                      resultHandler: { (image, info) in
                                        imageView.image = image
        })
        
        checkView.isHidden = true
        movieView.isHidden = true
        
        // 動画マーク設定
        if asset.mediaType == .video {
            movieView.isHidden = false
        }
        // モード毎に表示設定
        if !selectingMode {
            selectView.isHidden = true
            // メモ済みマーク設定
            if PhotoCollection.isMemoEnable(asset: asset) {
                checkView.isHidden = false
            }
        } else {
            // 画像選択マーク設定
            if selectArray.contains(indexPath) {
                selectView.isHidden = false
            } else {
                selectView.isHidden = true
            }
            selectingCell = false
        }
        return cell
    }
    
    /**
     * (delegate) CollectionView Cell タップ
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !selectingMode {
            // 画像の保存
            PhotoCollection.setSelectNum(num: indexPath.row)
            
            performSegue(withIdentifier: "toImageViewController", sender: self)
        } else {
            if selectArray.contains(indexPath) {
                selectArray.remove(indexPath)
            } else {
                selectArray.add(indexPath)
            }
        }
        // 選択画像のcellを更新
        collectionView.reloadItems(at: [indexPath])
    }
    
    /**
     * (delegate) 設定ボタンタップ
     */
    @IBAction func settingTouchUpInside(_ sender: Any) {
        
        // メニュー出力
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "画像選択", style: .default) { (action:UIAlertAction) in
            self.changeSelectMode(selectMode: true)
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: .default) { (action:UIAlertAction) in
            self.changeSelectMode(selectMode: false)
        })
        present(alert, animated: true, completion: nil)
    }
    
    /**
     * (delegate) シェアボタンタップ
     */
    @IBAction func shareTouchUpInside(_ sender: Any) {
        
        if selectArray.count == 0 {
            return
        }
        
        let imageArray = NSMutableArray()
        let deleteArray = NSMutableArray()
        
        let assets = PHAsset.fetchAssets(in: PhotoCollection.getCorrection(), options: nil)
        
        selectArray.forEach { obj in
            // 選択画像取得
            let indexPath = obj as! IndexPath
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.isSynchronous = true
            PHImageManager().requestImageData(for: assets.object(at: indexPath.row),
                                              options: options,
                                              resultHandler: { (imageData, dataUTI, orientation, info) in
                                                let image = UIImage(data: imageData!)!
                                                imageArray.add(image)
                                                deleteArray.add(assets.object(at: indexPath.row))
            })
        }
        
        let activityView = UIActivityViewController(activityItems: imageArray as! [Any], applicationActivities: nil)
        
        // 使用しないアクティビティタイプ
        activityView.excludedActivityTypes = [
            .postToFacebook,
            .postToTwitter,
            .postToWeibo,
            .message,
            .mail,
            .print,
            .assignToContact,
            .copyToPasteboard,
            .saveToCameraRoll,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo,
            .postToTencentWeibo,
            .airDrop,
            .openInIBooks]
        
        activityView.completionWithItemsHandler = {
            (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in
            
            guard completed else {
                return
            }
            
            if let type = activityType, type.rawValue == "com.google.Drive.ShareExtension" {
                deleteArray.forEach { obj in
                    self.deleteImage(asset: obj as! PHAsset)
                }
            }
            // 投稿後は選択モード解除
            self.changeSelectMode(selectMode: false)
        }
        present(activityView, animated: true, completion: nil)
    }
    
    /**
     * (delegate) 戻るボタンタップ
     */
    @IBAction func exitTouchUpInside(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    /**
     * (delegate) 画像選択キャンセルボタンタップ
     */
    @IBAction func selectCancelTouchUpInside(_ sender: Any) {
        
        changeSelectMode(selectMode: false)
    }
    
    /**
     * イメージの削除
     */
    private func deleteImage(asset: PHAsset) {
        
        PHPhotoLibrary.shared().performChanges( { () -> Void in
            // 削除などの変更はこのblocks内でリクエストする
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            
        }, completionHandler: { (success, error) -> Void in
            if success {
                // main thread で実行
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        })
    }
    
    /**
     * 選択モード切り替え
     */
    private func changeSelectMode(selectMode: Bool) {
        if selectMode {
            // 選択モード
            if selectArray != nil {
                selectArray.removeAllObjects()
            } else {
                selectArray = NSMutableArray()
            }
            selectingMode = true
            menuView.isHidden = false
            settingButton.isHidden = true
        } else {
            // 通常モード
            selectingMode = false
            menuView.isHidden = true
            settingButton.isHidden = false
            
            if selectArray != nil {
                selectArray.removeAllObjects()
                selectArray = nil
            }
        }
        collectionView.reloadData()
    }
}
