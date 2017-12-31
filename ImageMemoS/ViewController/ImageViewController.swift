//
//  ImageViewController.swift
//  ImageMemoS
//
//  Created by 中山浩樹 on 2017/12/26.
//  Copyright © 2017年 中山浩樹. All rights reserved.
//

import UIKit
import Photos

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    private var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        
        // 画像タップイベント設定
        photoImage.isUserInteractionEnabled = true
        let singleTap = UITapGestureRecognizer(
            target: self, action: #selector(imageViewTap))
        photoImage.addGestureRecognizer(singleTap)
        
        // スワイプイベント設定
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(bottomSwipeGesture))
        downSwipe.direction = .down
        view.addGestureRecognizer(downSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeGesture))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeGesture))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        load(select: PhotoCollection.getSelectNum())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     * 画像タップ
     */
    @objc private func imageViewTap() {
        // タイマー設定
        if timer != nil && timer.isValid {
            timer.invalidate()
        }
        timer = Timer(timeInterval: 5.0, target: self,
                      selector: #selector(timerComplete), userInfo: nil, repeats: false)
        
        let assets = PHAsset.fetchAssets(in: PhotoCollection.getCorrection(), options: nil)
        let asset = assets.object(at: PhotoCollection.getSelectNum())
        if asset.mediaType == .video {
            playButton.isHidden = true
        }
        closeButton.isHidden = false
    }
    
    /**
     * 下方向にスワイプ
     */
    @objc private func bottomSwipeGesture() {
        
        dismiss(animated: true, completion: nil)
    }
    
    /**
     * 右方向にスワイプ
     */
    @objc private func rightSwipeGesture() {
        
        load(select: PhotoCollection.getSelectNum() - 1)
    }
    
    /**
     * 左方向にスワイプ
     */
    @objc private func leftSwipeGesture() {
        
        load(select: PhotoCollection.getSelectNum() + 1)
    }
    
    /**
     * タイマー完了イベント
     */
    @objc private func timerComplete() {
        closeButton.isHidden = true
        
        let assets = PHAsset.fetchAssets(in: PhotoCollection.getCorrection(), options: nil)
        let asset = assets.object(at: PhotoCollection.getSelectNum())
        if asset.mediaType == .video {
            playButton.isHidden = true
        }
    }
    
    /**
     * (delegate) ズームイン用
     */
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return photoImage
    }

    /**
     * (delegate) 再生ボタンボタンタップ
     */
    @IBAction func playTouchUpInside(_ sender: Any) {
        
        performSegue(withIdentifier: "toPlayerViewController", sender: self)
    }
    
    /**
     * (delegate) 戻るボタンタップ
     */
    @IBAction func exitTouchUpInside(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    /**
     * 表示切り替え
     */
    private func load(select: NSInteger) {
        closeButton.isHidden = false
        playButton.isHidden = true
        
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
            // 動画マーク設定
            if asset.mediaType == .video {
                playButton.isHidden = false
            }
            // タイマー設定
            if timer != nil && timer.isValid {
                timer.invalidate()
            }
            timer = Timer(timeInterval: 5.0, target: self,
                          selector: #selector(timerComplete), userInfo: nil, repeats: false)
        }
    }
}
