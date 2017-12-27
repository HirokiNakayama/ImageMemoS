//
//  ViewController.swift
//  ImageMemoS
//
//  Created by 中山浩樹 on 2017/12/21.
//  Copyright © 2017年 中山浩樹. All rights reserved.
//

import UIKit
import Photos

class AlbumListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var albumList: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // アルバム表示テーブルにカスタムセルを設定
        let nib = UINib(nibName: "AlbumTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        albumList = NSMutableArray()
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        // システム設定アルバム情報取得
        var assetCollections = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum, subtype: .any, options: options)
        
        for i in 0 ..< assetCollections.count {
            let collection = assetCollections.object(at: i)
            
            if PhotoCollection.isAllPhotos(collection: collection) {
                albumList.add(collection)
            }
        }
        
        // ユーザ設定アルバム情報取得
        assetCollections = PHAssetCollection.fetchAssetCollections(
            with: .album, subtype: .any, options: options)
        
        for i in 0 ..< assetCollections.count {
            albumList.add(assetCollections.object(at: i))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumList.count
    }
    
    /**
     * （delegate）tebleのcell描画
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AlbumTableViewCell
        
        let collection = albumList.object(at: indexPath.row) as! PHAssetCollection
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        
        cell.titleLabel.text = String.localizedStringWithFormat(
            "%@　(%lu)", PhotoCollection.getTitle(collection: collection), assets.count)
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true;
        
        PHImageManager().requestImage(for: assets.firstObject!,
            targetSize: cell.frame.size,
            contentMode: .aspectFill,
            options: options,
            resultHandler: { (image, info) in
                cell.thumbnailView.image = image
            })
        
        // 選択された背景色を白に設定
        let cellSelectedBgView = UIView();
        cellSelectedBgView.backgroundColor = UIColor.white;
        cell.selectedBackgroundView = cellSelectedBgView;
        
        return cell
    }
    
    /**
     *（delegate）tebleのcellタップ
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {

        PhotoCollection.setCollection(
            collection: albumList.object(at: indexPath.row) as! PHAssetCollection)
        
        self.performSegue(withIdentifier: "toPhotosViewController", sender: self)
    }
    
}

