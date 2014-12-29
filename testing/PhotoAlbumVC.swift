//
//  ViewController.swift
//  Photos Gallery App
//
//  Created by Tony on 7/7/14.
//  Copyright (c) 2014 Abbouds Corner. All rights reserved.
//
//  Updated to Xcode 6.0.1 GM

import UIKit
import Photos

let reuseIdentifier = "PhotoCell"
let albumName = "App Folder"            //App specific folder name


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var albumFound : Bool = false
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    var assetThumbnailSize:CGSize!
    @IBOutlet var collectionView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check if the folder exists, if not, create it
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if let first_Obj:AnyObject = collection.firstObject{
            //found the album
            self.albumFound = true
            self.assetCollection = collection.firstObject as PHAssetCollection
        }else{
            requestForPhotoAuthAndInitAlbum(albumName)
        }
    }
    
    func requestForPhotoAuthAndInitAlbum(album: String){
        PHPhotoLibrary.requestAuthorization
            { (PHAuthorizationStatus status) -> Void in
                switch (status)
                {
                case .Authorized:
                    // Permission Granted
                    println("Write your code here")
                    self.initializeNewPhotoAlbum(album)
                case .Denied:
                    // Permission Denied
                    println("User denied")
                default:
                    println("Restricted")
                }
        }

    }
    
    func initializeNewPhotoAlbum(album: String){
        //Album placeholder for the asset collection, used to reference collection in completion handler
        var albumPlaceholder:PHObjectPlaceholder!
        //create the folder
        NSLog("\nFolder \"%@\" does not exist\nCreating now...", album)
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(album)
            albumPlaceholder = request.placeholderForCreatedAssetCollection
            },
            completionHandler: {(success:Bool, error:NSError!)in
                NSLog("Creation of folder -> %@", (success ? "Success":"Error!"))
                println(error)
                self.albumFound = (success ? true:false)
                if(success){
                    let collection = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([albumPlaceholder.localIdentifier], options: nil)
                    self.assetCollection = collection?.firstObject as PHAssetCollection
                }
        })

    }
    
    //Actions & Outlets
    @IBAction func btnCamera(sender : AnyObject) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            //load the camera interface
            var picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        }else{
            //no camera available
            var alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }
    
    @IBAction func btnPhotoAlbum(sender : AnyObject) {
        var picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
        picker.delegate = self
        picker.allowsEditing = false
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier! as String == "viewLargePhoto"){
            let controller:ViewPhoto = segue.destinationViewController as ViewPhoto
            let indexPath: NSIndexPath = self.collectionView.indexPathForCell(sender as UICollectionViewCell)!
            controller.index = indexPath.item
            controller.photosAsset = self.photosAsset
            controller.assetCollection = self.assetCollection
        }
    }

    override func viewWillAppear(animated: Bool) {
        println("ViewWillAppear")
        
        // Get size of the collectionView cell for thumbnail image
        let scale:CGFloat = UIScreen.mainScreen().scale
        let cellSize = (self.collectionView.collectionViewLayout as UICollectionViewFlowLayout).itemSize
        self.assetThumbnailSize = CGSizeMake(cellSize.width, cellSize.height)
        
        //fetch the photos from collection
        self.navigationController?.hidesBarsOnTap = false   //!! Use optional chaining
        self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
        
        checkIfEmpty()
        
        self.collectionView.reloadData()
    }
    
    
    func checkIfEmpty(){
        if(self.photosAsset != nil && self.photosAsset.count == 0){
            println("album is empty")
            self.title = "No photos"
        }else{
            self.title = albumName
        }
    }
    
    //UICollectionViewDataSource Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        var count: Int = 0
        if(self.photosAsset != nil){
            count = self.photosAsset.count
        }
        return count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell: PhotoThumbnail = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as PhotoThumbnail
        
        //Modify the cell
        let asset: PHAsset = self.photosAsset[indexPath.item] as PHAsset
        
        // Create options for retrieving image (Degrades quality if using .Fast)
        //        let imageOptions = PHImageRequestOptions()
        //        imageOptions.resizeMode = PHImageRequestOptionsResizeMode.Fast
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: self.assetThumbnailSize, contentMode: .AspectFill, options: nil, resultHandler: {(result, info)in
            cell.setThumbnailImage(result)
        })
        return cell
    }
    
    //UICollectionViewDelegateFlowLayout methods
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 4
    }
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }
    
    
    
    
    
    //UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!){
        let image = info.objectForKey("UIImagePickerControllerOriginalImage") as UIImage
        
        //Implement if allowing user to edit the selected image
        //let editedImage = info.objectForKey("UIImagePickerControllerEditedImage") as UIImage
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0), {
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection, assets: self.photosAsset)
                albumChangeRequest.addAssets([assetPlaceholder])
                }, completionHandler: {(success, error)in
                    dispatch_async(dispatch_get_main_queue(), {
                        NSLog("Adding Image to Library -> %@", (success ? "Sucess":"Error!"))
                        picker.dismissViewControllerAnimated(true, completion: nil)
                    })
            })
            
        })
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController!){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

