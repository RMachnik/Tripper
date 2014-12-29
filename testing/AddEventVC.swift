

import UIKit
import Photos
import MapKit


class AddTaskVC: UIViewController ,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    var geocoder = CLGeocoder()
    var lastLocation: String = ""
    
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtDescription: UITextView!
    @IBOutlet var txtSubmitted: UITextField!
    @IBOutlet var btnSelectImage: UIButton!
    @IBOutlet var selectedImage: UIImageView!
    @IBOutlet weak var location: UITextField!
    @IBOutlet var mapView: MKMapView!
    
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
    @IBAction func locationEditingEnd(sender: AnyObject) {
        if(lastLocation != location.text){
            runGeocoding(location.text)
            println("Location txt changed, geocoding fired!")
        }
        lastLocation = location.text
        

    }
    func runGeocoding(address: String){
        geocoder.geocodeAddressString(address, {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                var mkPlacemark  = MKPlacemark(placemark: placemark)
                var coordinates = mkPlacemark.location.coordinate
                println(coordinates.latitude)
                println(coordinates.longitude)
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: placemark.location.coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                self.mapView.addAnnotation(mkPlacemark)
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField!) ->Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
    
    @IBAction func btnAddTask(){
        
        var name: String = txtName.text
        var description: String = txtDescription.text
        var submitted: String = txtSubmitted.text
        var locationName: String  = location.text
        eventMgr.addEvent(name, desc: description, subm: submitted,location: "locationName-tmp")
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
    
    @IBAction func btnCancel(){
        
        navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: {})
        
        //todo check locationService
        //var locationManager =  LocationService()
        //locationManager.getCurrentLocation();
        
    }
    
    func cleanTextForm(){
        txtName.text = ""
        txtDescription.text = ""
        txtSubmitted.text = ""
        location.text = ""
    }
    
}