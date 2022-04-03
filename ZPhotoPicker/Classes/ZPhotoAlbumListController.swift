//
//  ZPhotoAlbumListController.swift
//
//  Created by Zack･Zheng on 2018/4/9.
//

import UIKit
import Photos

class ZPhotoAlbumListController: UITableViewController {
    
    var items: [AlbumItem] = []
    weak var albumListdelegate: ZPhotoAlbumListControllerDelegate?
    var mediaType: PHAssetMediaType = .unknown

    override func viewDidLoad() {

        super.viewDidLoad()
        
        title = "albumList".locale
        let cancelButton = UIBarButtonItem(title: "cancel".locale, style: .plain, target: self, action: #selector(ZPhotoAlbumListController.clickCancelButton(sender:)))
        cancelButton.tintColor = ZPhotoPicker.themeColor
        navigationItem.setRightBarButton(cancelButton, animated: false)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AlumTableViewCell")
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let `self` = self else {return}
            switch status {
            case .authorized:
                self.getAlbums()
            default:
                break
            }
        }
    }
}

private extension ZPhotoAlbumListController {

    @objc private func clickCancelButton(sender: Any) {
        albumListdelegate?.photoAlbumListControllerDidCancel(self)
    }

    private func getAlbums() {

        // 所有用户创建的相册
        let userCollections = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                  subtype: .albumRegular,
                                                                  options: nil)
        convertCollection(collection: userCollections)
        
        // 智能相册（系统提供的特定的一系列相册，例如：最近删除，视频列表，收藏等等）
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                  subtype: .smartAlbumUserLibrary,
                                                                  options: nil)
        convertCollection(collection: smartAlbums)

        DispatchQueue.main.sync {
            self.tableView.reloadData()
        }
    }
    
    private func convertCollection(collection: PHFetchResult<PHAssetCollection>) {

        let resultsOptions = PHFetchOptions()
        resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        (0..<collection.count).forEach { (index) in
            let collection = collection[index]
            let assetsFetchResult = PHAsset.fetchAssets(in: collection, options: resultsOptions)
            if assetsFetchResult.count > 0, let localizedTitle = collection.localizedTitle {
                
                let title = convertTitle(fromEnglish: localizedTitle)
                let totalAssets = assetsFetchResult.objects(at: IndexSet(integersIn: 0...assetsFetchResult.count - 1))
                let assets = mediaType == .unknown ? totalAssets : totalAssets.filter({ $0.mediaType == mediaType})
                if assets.count > 0 {
                    let album = AlbumItem(title: title, count: assets.count, assets: assets)
                    items.append(album)
                }
            }
        }
    }
    
    private func convertTitle(fromEnglish title: String) -> String {
        
        switch title {
            
        case "Favorites":
            return "favorites".locale
        case "Panoramas":
            return "panoramas".locale
        case "Camera Roll":
            return "cameraRoll".locale
        case "Slo-mo":
            return "sloMo".locale
        case "Screenshots":
            return "screenshots".locale
        case "Bursts":
            return "bursts".locale
//        case "Videos":
//            return "视频"
        case "Selfies":
            return "selfies".locale
        case "Hidden":
            return "hidden".locale
//        case "Time-lapse":
//            return "延时视频"
        case "Recently Added":
            return "recentlyAdded".locale
//        case "Long Exposure":
//        case "Animated":
//        case "Live Photos":
//        case "Portrait":
        case "Recently Deleted":
            return "recentlyDeleted".locale
        case "All Photos":
            return "allPhotos".locale
        case "Recents":
            return "recents".locale
        default:
            return title
        }
    }
}

extension ZPhotoAlbumListController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlumTableViewCell")!
        cell.textLabel?.text = "\(items[indexPath.row].title)（\(items[indexPath.row].count)）"
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let album = items[indexPath.row]
        albumListdelegate?.photoAlbumListController(self, didSelectAlbum: album)
    }
}

protocol ZPhotoAlbumListControllerDelegate: class {

    func photoAlbumListController(_ controller: ZPhotoAlbumListController, didSelectAlbum album: AlbumItem)
    func photoAlbumListControllerDidCancel(_ controller: ZPhotoAlbumListController)
}

struct AlbumItem {

    var title: String
    var count: Int
    var assets: [PHAsset]
}
