//
//  MemoSelectViewController.swift
//  ImageMemoS
//
//  Created by 中山浩樹 on 2017/12/26.
//  Copyright © 2017年 中山浩樹. All rights reserved.
//

import UIKit
import Photos

class MemoEditViewController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var selectImageBorder: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var memoBackView: UILabel!
    @IBOutlet weak var inputCompButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var photoImageMovieMark: UIImageView!
    @IBOutlet weak var createDateView: UITextView!
    
    private let MAX_HEADER_IMAGE_COUNT: Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // 選択中の画像囲みボーダー設定
        selectImageBorder.layer.borderColor = UIColor.green.cgColor
        selectImageBorder.layer.borderWidth = 2.0
        
        inputCompButton.isHidden = true
        shareButton.isHidden = false
        
        // 画像タップイベント設定
        photoImage.isUserInteractionEnabled = true
        let singleTap = UITapGestureRecognizer(
            target: self, action: #selector(imageViewTap(_:)))
        photoImage.addGestureRecognizer(singleTap)
        
        // キーボード表示イベント設定
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWasShown), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillBeHidden), name: .UIKeyboardWillHide, object: nil)
        
        // スワイプイベント設定
        let rightSwipe = UISwipeGestureRecognizer(
            target: self, action: #selector(rightSwipeGesture))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(
            target: self, action: #selector(leftSwipeGesture))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        load(select: PhotoCollection.getSelectNum())
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
        var count = assets.count
        // 最大５画像表示
        if count > MAX_HEADER_IMAGE_COUNT {
            count = MAX_HEADER_IMAGE_COUNT
        }
        return count
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
        
        imageView.image = nil
        checkView.isHidden = true
        movieView.isHidden = true
        
        // 表示位置計算
        let index = (PhotoCollection.getSelectNum() - ((MAX_HEADER_IMAGE_COUNT - 1) / 2)) + indexPath.row
        
        let assets = PHAsset.fetchAssets(in: PhotoCollection.getCorrection(), options: nil)
        if 0 <= index && index < assets.count {
            // 画像が存在したら表示
            let asset = assets.object(at: index)
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            PHImageManager().requestImage(for: asset,
                                          targetSize: cell.frame.size,
                                          contentMode: .aspectFit,
                                          options: options,
                                          resultHandler: { (image, info) in
                                            if image != nil {
                                                imageView.image = image
                                            }
            })
            // メモ済みマーク設定
            if PhotoCollection.isMemoEnable(asset: asset) {
                checkView.isHidden = false
            }
            // 動画マーク設定
            if asset.mediaType == .video {
                movieView.isHidden = false
            }
        }
        return cell
    }
    
    /**
     * (delegate) CollectionView Cell タップ
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if photoImage.frame.origin.y == memoBackView.frame.origin.y {
            // キーボード入力中はタップ不可
            return
        }
        
        let select = (PhotoCollection.getSelectNum() - ((MAX_HEADER_IMAGE_COUNT - 1) / 2)) + indexPath.row
        if 0 <= select {
            load(select: select)
        }
    }
    
    /**
     * (delegate) 入力完了ボタンタップ
     */
    @IBAction func inputCompTouchUpInside(_ sender: Any) {
        let assets = PHAsset.fetchAssets(in: PhotoCollection.getCorrection(), options: nil)
        let asset = assets.object(at: PhotoCollection.getSelectNum())
        CoreDataManager.save(fileName: asset.value(forKey: "filename") as! String, memo: memoTextView.text)
        
        // キーボードを閉じる
        memoTextView.resignFirstResponder()
        
        // チェックマーク更新のためリロード
        collectionView.reloadData()
    }
    
    /**
     * (delegate) シェアボタンタップ
     */
    @IBAction func shareTouchUpInside(_ sender: Any) {
        
        var shareItems: NSArray?
        var shareText: String?
        
        if memoTextView.text.utf16.count > 0 {
            shareText = memoTextView.text
        }
        // 共有する項目
        if let text = shareText {
            shareItems = [text, photoImage.image as Any]
        } else {
            shareItems = [photoImage.image as Any]
        }
        
        let activityView = UIActivityViewController(activityItems: shareItems as! [Any], applicationActivities: nil)
        
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
        
        present(activityView, animated: true, completion: nil)
    }
    
    /**
     * (delegate) 戻るボタンタップ
     */
    @IBAction func exitTouchUpInside(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    /**
     * 右方向にスワイプ
     */
    @objc private func rightSwipeGesture() {
        if photoImage.frame.origin.y == memoBackView.frame.origin.y {
            // キーボード入力中は不可
            return
        }
        load(select:PhotoCollection.getSelectNum() - 1)
    }
    
    /**
     * 左方向にスワイプ
     */
    @objc private func leftSwipeGesture() {
        if photoImage.frame.origin.y == memoBackView.frame.origin.y {
            // キーボード入力中は不可
            return
        }
        load(select:PhotoCollection.getSelectNum() + 1)
    }
    
    /**
     * イメージタップ
     */
    @objc func imageViewTap(_ sender: UITapGestureRecognizer) {
        if sender.view!.tag == 2 {
            performSegue(withIdentifier: "toImageViewController", sender: self)
        }
    }
    
    /**
     * キーボード表示イベント
     */
    @objc private func keyboardWasShown() {
        // メモ関連ViewをphotoImageのtopまで移動
        memoTextView.frame = CGRect(
            x: memoTextView.frame.origin.x,
            y: photoImage.frame.origin.y + 10,
            width: memoTextView.frame.size.width,
            height: memoTextView.frame.size.height)
        
        memoBackView.frame = CGRect(
            x: memoBackView.frame.origin.x,
            y: photoImage.frame.origin.y,
            width: memoBackView.frame.size.width,
            height: memoBackView.frame.size.height)
        
        inputCompButton.isHidden = false
        shareButton.isHidden = true
    }
    
    /**
     * キーボード非表示イベント
     */
    @objc private func keyboardWillBeHidden() {
        
        // メモ関連Viewを元の位置に戻す
        memoTextView.frame = CGRect(
            x: memoTextView.frame.origin.x,
            y: photoImage.frame.origin.y + photoImage.frame.size.height + 20,
            width: memoTextView.frame.size.width,
            height: memoTextView.frame.size.height)
        
        memoBackView.frame = CGRect(
            x: memoBackView.frame.origin.x,
            y: photoImage.frame.origin.y + photoImage.frame.size.height + 10,
            width: memoBackView.frame.size.width,
            height: memoBackView.frame.size.height)
        
        inputCompButton.isHidden = true
        shareButton.isHidden = false
    }
    
    /**
     * CollectionView 操作時のロード処理
     */
    private func load(select: NSInteger) {
        
        let assets = PHAsset.fetchAssets(in: PhotoCollection.getCorrection(), options: nil)
        if 0 <= select && select < assets.count {
            // 選択位置の更新
            PhotoCollection.setSelectNum(num: select)
            
            // 表示画像取得
            let asset = assets.object(at: PhotoCollection.getSelectNum())
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            PHImageManager().requestImage(for: asset,
                                          targetSize: photoImage.frame.size,
                                          contentMode: .aspectFit,
                                          options: options,
                                          resultHandler: { (image, info) in
                                            self.photoImage.image = image
            })
            // メモデータの更新
            memoTextView.text = CoreDataManager.getMemo(
                fileName: PhotoCollection.getFileName(asset: asset))
            
            // 動画マーク設定
            if asset.mediaType == .video {
                photoImageMovieMark.isHidden = false
            } else {
                photoImageMovieMark.isHidden = true
            }
            // ファイル生成日表示
            if asset.creationDate != nil {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                self.createDateView.text = formatter.string(from: asset.creationDate!)
            }
            
            collectionView.reloadData()
        }
    }
}
