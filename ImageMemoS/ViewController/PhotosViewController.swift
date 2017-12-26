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
    
    private var selectingMode: Bool!
    private var selectingCell: Bool!
    private var selectArray: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self;
        collectionView.dataSource = self;
        
        let collection = PhotoCollection.getCorrection()
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        
        titleLabel.text = PhotoCollection.getTitle(
            collection: collection) + " （" + String(assets.count) + "）"
        
        selectingMode = false;
        selectingCell = false;
        selectArray = nil;
        
        shareButton.isHidden = true;
        settingButton.isHidden = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /**
     * (delegate) CollectionView Cell 最大数
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    /**
     * (delegate) CollectionView Cell 描画
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //コレクションビューから識別子「CalendarCell」のセルを取得する
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)

        return cell
    }
    
    /**
     * (delegate) CollectionView Cell タップ
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
