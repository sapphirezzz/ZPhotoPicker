//
//  ZVideoPhotoMutilPickerController.swift
//
//  Created by zackzheng on 2019/8/9.
//

import UIKit
import Photos

class ZVideoPhotoMutilPickerController: UINavigationController {
    
    private var imagesPickedHandler: ((_ images: [UIImage]) -> Void)? = nil
    private var videosPickedHandler: ((_ videos: [AVURLAsset]) -> Void)? = nil
    private var selectionDurationForbidHandler: ((_ duration: TimeInterval) -> Void)? = nil
    private var cancelledHandler: (() -> Void)?
    private var maxCount: Int = 0
    private var canMutilSelectVideo: Bool = false
    private var selectedAssets: [PHAsset] = []
    
    deinit {
        print("\(self) \(#function)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(maxCount: Int, canMutilSelectVideo: Bool = false, maxVideoDurationInSecond: Int?, minVideoDurationInSecond: Int?, imagesPickedHandler: ((_ images: [UIImage]) -> Void)? = nil, videosPickedHandler: ((_ videos: [AVURLAsset]) -> Void)? = nil, cancelledHandler: (() -> Void)? = nil) {
        
        let vc = ZPhotoAlbumListController()
        self.init(rootViewController: vc)
        self.maxCount = maxCount
        self.canMutilSelectVideo = canMutilSelectVideo
        self.imagesPickedHandler = imagesPickedHandler
        self.videosPickedHandler = videosPickedHandler
        self.cancelledHandler = cancelledHandler
        vc.albumListdelegate = self
        let secondVC = ZVideoPhotoMutilPickerHostController(collectionViewLayout: UICollectionViewFlowLayout())
        secondVC.maxVideoDurationInSecond = maxVideoDurationInSecond
        secondVC.minVideoDurationInSecond = minVideoDurationInSecond
        secondVC.delegate = self
        secondVC.dataSource = self
        self.pushViewController(secondVC, animated: false)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
}

extension ZVideoPhotoMutilPickerController {
    
    class func pickPhotoes(onPresentingViewController controller: UIViewController, maxCount: Int, canMultiSelectVideo: Bool, maxVideoDurationInSecond: Int?, minVideoDurationInSecond: Int?, imagesPickedHandler: ((_ images: [UIImage]) -> Void)? = nil, videosPickedHandler: ((_ videos: [AVURLAsset]) -> Void)? = nil, cancelledHandler: (() -> Void)? = nil, selectionDurationForbidHandler: ((_ duration: TimeInterval) -> Void)? = nil) {

        let vc = ZVideoPhotoMutilPickerController(maxCount: maxCount, canMutilSelectVideo: canMultiSelectVideo, maxVideoDurationInSecond: maxVideoDurationInSecond, minVideoDurationInSecond: minVideoDurationInSecond, imagesPickedHandler: imagesPickedHandler, videosPickedHandler: videosPickedHandler, cancelledHandler: cancelledHandler)
        vc.selectionDurationForbidHandler = selectionDurationForbidHandler
        controller.present(vc, animated: true, completion: nil)
    }
}

extension ZVideoPhotoMutilPickerController: ZVideoPhotoMutilPickerHostControllerDelegate {
    func photoMutilPickerHostController(_ controller: ZVideoPhotoMutilPickerHostController, didForbidSelectionDuration videoDuration: TimeInterval) {
        selectionDurationForbidHandler?(videoDuration)
    }
    
    
    func photoMutilPickerHostController(_ controller: ZVideoPhotoMutilPickerHostController, didFinishPickingImages images: [UIImage]) {
        
        self.dismiss(animated: true, completion: { [weak self] in
            self?.imagesPickedHandler?(images)
        })
    }

    func photoMutilPickerHostController(_ controller: ZVideoPhotoMutilPickerHostController, didFinishPickingVideos videos: [AVURLAsset]) {

        self.dismiss(animated: true, completion: { [weak self] in
            self?.videosPickedHandler?(videos)
        })
    }
    
    func photoMutilPickerHostControllerDidCancel(_ controller: ZVideoPhotoMutilPickerHostController) {
        
        self.dismiss(animated: true, completion: { [weak self] in
            self?.cancelledHandler?()
        })
    }
    
    func photoMutilPickerHostController(_ controller: ZVideoPhotoMutilPickerHostController, didSelectAsset asset: PHAsset) {
        selectedAssets.append(asset)
        controller.collectionView.reloadData()
    }
    
    func photoMutilPickerHostController(_ controller: ZVideoPhotoMutilPickerHostController, didDeselectAsset asset: PHAsset) {

        if let index = selectedAssets.firstIndex(of: asset) {
            selectedAssets.remove(at: index)
        }
        controller.collectionView.reloadData()
    }
    
    func photoMutilPickerHostControllerDidFetchFailed(_ controller: ZVideoPhotoMutilPickerHostController) {

    }
}

extension ZVideoPhotoMutilPickerController: ZVideoPhotoMutilPickerHostControllerDataSource {
    
    func numberOfItemsSelected(_ controller: ZVideoPhotoMutilPickerHostController) -> Int {
        return selectedAssets.count
    }
    
    func maxSelectedCount(_ controller: ZVideoPhotoMutilPickerHostController) -> Int {
        return selectedAssets.first?.mediaType == .video && !canMutilSelectVideo ? 1 : maxCount
    }
    
    func selectedItems(_ controller: ZVideoPhotoMutilPickerHostController) -> [PHAsset] {
        return selectedAssets
    }
    
    func assetsTypeSelecting(_ controller: ZVideoPhotoMutilPickerHostController) -> PHAssetMediaType? {
        return selectedAssets.first?.mediaType
    }
}

extension ZVideoPhotoMutilPickerController: ZPhotoAlbumListControllerDelegate {
    
    func photoAlbumListController(_ controller: ZPhotoAlbumListController, didSelectAlbum album: AlbumItem) {
        
        let vc = ZVideoPhotoMutilPickerHostController(collectionViewLayout: UICollectionViewFlowLayout())
        vc.delegate = self
        vc.dataSource = self
        vc.selectedAlbum = album
        pushViewController(vc, animated: true)
    }
    
    func photoAlbumListControllerDidCancel(_ controller: ZPhotoAlbumListController) {
        
        self.dismiss(animated: true) { [weak self] in
            self?.cancelledHandler?()
        }
    }
}
