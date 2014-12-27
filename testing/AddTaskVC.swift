

import UIKit
import Photos

class AddTaskVC: UIViewController ,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtDescription: UITextField!
    @IBOutlet var txtSubmitted: UITextField!
    @IBOutlet var btnSelectImage: UIButton!
    @IBOutlet var selectedImage: UIImageView!
    @IBOutlet weak var location: UITextField!
    
    @IBAction func btnAddTask(){
        
        var name: String = txtName.text
        var description: String = txtDescription.text
        var submitted: String = txtSubmitted.text
        var locationName: String  = location.text
        eventMgr.addEvent(name, desc: description, subm: submitted,location: "locationName-tmp",image: "imageDesc")
        cleanTextForm()
        self.view.endEditing(true)

        navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: {})
        
    }
    
    @IBAction func btnPhotoAlbum(sender : AnyObject) {
        var picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
        picker.delegate = self
        picker.allowsEditing = false
        self.presentViewController(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            println("User pressed exit from gallery!")
        })
        
        selectedImage.image = image
        
    }
    
    @IBAction func btnCancel(){
        
        navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: {})
        
        //todo check locationService
        //var locationManager =  LocationService()
        //locationManager.getCurrentLocation();
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtName.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(textField: UITextField!) ->Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
    func cleanTextForm(){
        txtName.text = ""
        txtDescription.text = ""
        txtSubmitted.text = ""
        location.text = ""
    }
    
}