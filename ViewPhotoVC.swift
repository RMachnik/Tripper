//
//  ViewPhoto.swift
//  Photos Gallery App
//
//  Created by Tony on 7/7/14.
//  Copyright (c) 2014 Abbouds Corner. All rights reserved.
//
//  Updated for Xcode 6.0.1 GM

import UIKit
import Photos
import MessageUI

class ViewPhoto: UIViewController, MFMailComposeViewControllerDelegate {
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
        println("Export")
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
    }
    
    @IBAction func btnTrash(sender : AnyObject) {
        let alert = UIAlertController(
            title: "Delete Image",
            message: "Are you sure you want to delete this image?",
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

    func displayPhoto(){
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
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.addAttachmentData(imgView.image?.imageAsset as NSData, mimeType: "image/jpeg", fileName: "EventName")
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["someone@somewhere.com"])
        mailComposerVC.setSubject("Event Name")
        mailComposerVC.setMessageBody("Even description!", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
