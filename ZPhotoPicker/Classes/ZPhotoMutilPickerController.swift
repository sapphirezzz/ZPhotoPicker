//
//  ZPhotoMutilPickerController.swift
//
//  Created by Zack･Zheng on 2018/1/30.
//

import UIKit
import Photos

class ZPhotoMutilPickerController: UINavigationController {
    
    private var imagesPickedHandler: ((_ image: [UIImage]) -> Void)?
    private var cancelledHandler: (() -> Void)?
    private var maxCount: Int = 0
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

    convenience init(maxCount: Int, imagesPickedHandler: ((_ image: [UIImage]) -> Void)? = nil, cancelledHandler: (() -> Void)? = nil) {

        let vc = ZPhotoAlbumListController()
        self.init(rootViewController: vc)
        self.maxCount = maxCount
        self.imagesPickedHandler = imagesPickedHandler
        self.cancelledHandler = cancelledHandler
        vc.albumListdelegate = self
        vc.mediaType = .image
        pushZPhotoMutilPickerHostController()
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
}

extension ZPhotoMutilPickerController {
    
    class func pickPhotoes(onPresentingViewController controller: UIViewController, maxCount: Int, imagesPickedHandler: @escaping (_ image: [UIImage]) -> Void, cancelledHandler: (() -> Void)? = nil) {

        let vc = ZPhotoMutilPickerController(maxCount: maxCount, imagesPickedHandler: imagesPickedHandler, cancelledHandler: cancelledHandler)
        vc.modalPresentationStyle = .fullScreen
        controller.present(vc, animated: true, completion: nil)
    }
    
    @available(iOS 12.0, *)
    class func pickPhotoes(onPresentingViewController controller: UIViewController, maxCount: Int, imagesPickedHandler: @escaping (_ image: [UIImage]) -> Void, cancelledHandler: (() -> Void)? = nil, userInterfaceStyle: UIUserInterfaceStyle = .unspecified) {

        let vc = ZPhotoMutilPickerController(maxCount: maxCount, imagesPickedHandler: imagesPickedHandler, cancelledHandler: cancelledHandler)
        if #available(iOS 13.0, *) {
            vc.overrideUserInterfaceStyle = userInterfaceStyle
        }
        vc.modalPresentationStyle = .fullScreen
        controller.present(vc, animated: true, completion: nil)
    }
}

extension ZPhotoMutilPickerController: ZPhotoMutilPickerHostControllerDelegate {
    
    func photoMutilPickerHostController(_ controller: ZPhotoMutilPickerHostController, didFinishPickingImages images: [UIImage]) {

        self.dismiss(animated: true, completion: { [weak self] in
            self?.imagesPickedHandler?(images)
        })
    }
    
    func photoMutilPickerHostControllerDidCancel(_ controller: ZPhotoMutilPickerHostController) {
        
        self.dismiss(animated: true, completion: { [weak self] in
            self?.cancelledHandler?()
        })
    }
    
    func photoMutilPickerHostController(_ controller: ZPhotoMutilPickerHostController, didSelectAsset asset: PHAsset) {
        selectedAssets.append(asset)
        controller.collectionView.reloadData()
    }
    
    func photoMutilPickerHostController(_ controller: ZPhotoMutilPickerHostController, didDeselectAsset asset: PHAsset) {
        
        if let index = selectedAssets.firstIndex(of: asset) {
            selectedAssets.remove(at: index)
        }
        controller.collectionView.reloadData()
    }
}

extension ZPhotoMutilPickerController: ZPhotoMutilPickerHostControllerDataSource {

    func numberOfItemsSelected(_ controller: ZPhotoMutilPickerHostController) -> Int {
        return selectedAssets.count
    }
    
    func maxSelectedCount(_ controller: ZPhotoMutilPickerHostController) -> Int {
        return maxCount
    }
    
    func selectedItems(_ controller: ZPhotoMutilPickerHostController) -> [PHAsset] {
        return selectedAssets
    }
}

extension ZPhotoMutilPickerController: ZPhotoAlbumListControllerDelegate {
    
    func photoAlbumListController(_ controller: ZPhotoAlbumListController, didSelectAlbum album: AlbumItem) {
        
        pushZPhotoMutilPickerHostController(with: album)
    }
    
    func photoAlbumListControllerDidCancel(_ controller: ZPhotoAlbumListController) {
        
        self.dismiss(animated: true) { [weak self] in
            self?.cancelledHandler?()
        }
    }
}

private extension ZPhotoMutilPickerController {

    func pushZPhotoMutilPickerHostController(with album: AlbumItem? = nil) {

        let vc = ZPhotoMutilPickerHostController(collectionViewLayout: UICollectionViewFlowLayout())
        vc.delegate = self
        vc.dataSource = self
        if let album = album {
            vc.selectedAlbum = album
        }
        pushViewController(vc, animated: true)
    }
}
