//
//  PlayerViewController.swift
//  ImageMemoS
//
//  Created by 中山浩樹 on 2017/12/26.
//  Copyright © 2017年 中山浩樹. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos

class PlayerViewController: AVPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 再生動画取得
        let assets = PHAsset.fetchAssets(in: PhotoCollection.getCorrection(), options: nil)
        let asset = assets.object(at: PhotoCollection.getSelectNum())
        
        // 動画パスの要求
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: {
            (avAsset, audioMix, info) in
            
            if let asset = avAsset {
                // メインスレッドで再生開始
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        self.player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
                        self.player!.play()
                    }
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
