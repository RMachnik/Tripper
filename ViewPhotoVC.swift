import UIKit
import Photos
import MessageUI

class ViewPhoto: UIViewController, MFMailComposeViewControllerDelegate {
    private let messageComposer = MessageComposer()
    private let mailComposer = MailComposer()
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    var index: Int = 0
    
    @IBOutlet var imgView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true
        self.displayPhoto()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnCancel(sender : AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func btnExport(sender : AnyObject) {
        println("Trying to send email!")
        sendEmail()
        println("Trying to send txt message!")
        sendTextMessage()
    }
    
    @IBAction func btnTrash(sender : AnyObject) {
        var deleteImageMsg = NSLocalizedString("deleteImage", comment: "")
        var deleteAssurance = NSLocalizedString("deleteImageAssurance",comment:"")
        let alert = UIAlertController(
            title: deleteImageMsg,
            message: deleteAssurance,
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(
            title: "Yes", style: .Default,
            handler: {(alertAction)in
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    let request = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                    request.removeAssets([self.photosAsset[self.index]])
                    },
                    completionHandler: {(success, error)in
                        NSLog("\nDeleted Image -> %@", (success ? "Success":"Error!"))
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        if(success){
                            dispatch_async(dispatch_get_main_queue(), {
                                self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
                                if(self.photosAsset.count == 0){
                                    println("No Images Left!!")
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                }else{
                                    if(self.index >= self.photosAsset.count){
                                        self.index = self.photosAsset.count - 1
                                    }
                                    self.displayPhoto()
                                }
                            })
                        }else{
                            println("Error: \(error)")
                        }
                })
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: {(alertAction)in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    private func displayPhoto(){
        let screenSize: CGSize = UIScreen.mainScreen().bounds.size
        let targetSize = CGSizeMake(screenSize.width, screenSize.height)
        let imageManager = PHImageManager.defaultManager()
        var ID = imageManager.requestImageForAsset(self.photosAsset[self.index] as PHAsset, targetSize: targetSize, contentMode: .AspectFit, options: nil, resultHandler: {
            (result, info)->Void in
            self.imgView.image = result
            println("Description!!!")
            println(self.imgView.image?.CIImage?.description)
        })
    }
    
    private func showSendMailErrorAlert() {
        var couldNotSendEmail = NSLocalizedString("couldNotSendEmail",comment:"")
        var couldNotSendEmailMsg = NSLocalizedString("couldNotSendEmailMsg",comment:"")
        let sendMailErrorAlert = UIAlertView(title: couldNotSendEmail, message: couldNotSendEmailMsg, delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    private func sendEmail(){
        let mailComposeViewController = mailComposer.configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    private func sendTextMessage(){
        if (messageComposer.canSendText()) {
            let messageComposeVC = messageComposer.configuredMessageComposeViewController("Content of message")
            presentViewController(messageComposeVC, animated: true, completion: nil)
        } else {
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    
    
}
