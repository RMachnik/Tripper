
import UIKit
import Photos

let reuseIdentifier = "PhotoCell"
//let albumName = "App Folder"

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var albumFound : Bool = false
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    var assetThumbnailSize:CGSize!
    @IBOutlet var collectionView : UICollectionView!
    var albumName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("Getting event for current id \(eventMgr.currentID)")
        var event : Event = eventMgr.events[eventMgr.currentID]
        self.albumName = event.name
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if let first_Obj:AnyObject = collection.firstObject{
            self.albumFound = true
            self.assetCollection = collection.firstObject as PHAssetCollection
        }else{
            requestForPhotoAuthAndInitAlbum(albumName)
        }
        self.title = albumName
    }
    
    func requestForPhotoAuthAndInitAlbum(album: String){
        PHPhotoLibrary.requestAuthorization
            { (PHAuthorizationStatus status) -> Void in
                switch (status)
                {
                case .Authorized:
                    println("Write your code here")
                    self.initializeNewPhotoAlbum(album)
                case .Denied:
                    println("User denied")
                default:
                    println("Restricted")
                }
        }
    }
    
    func initializeNewPhotoAlbum(album: String){
        var albumPlaceholder:PHObjectPlaceholder!
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
    
    @IBAction func btnCamera(sender : AnyObject) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            var picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        }else{
            var alert = UIAlertController(title: "Error", message: "There is no camera available!", preferredStyle: .Alert)
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
        let scale:CGFloat = UIScreen.mainScreen().scale
        let cellSize = (self.collectionView.collectionViewLayout as UICollectionViewFlowLayout).itemSize
        self.assetThumbnailSize = CGSizeMake(cellSize.width, cellSize.height)
        
        self.navigationController?.hidesBarsOnTap = false
        self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
        
        checkIfEmpty()
        
        self.collectionView.reloadData()
    }
    
    
    func checkIfEmpty(){
        if(self.photosAsset != nil && self.photosAsset.count == 0){
            println("Album is empty!")
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
        let asset: PHAsset = self.photosAsset[indexPath.item] as PHAsset

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

