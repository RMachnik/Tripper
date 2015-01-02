

import UIKit

class DetailVC: UIViewController {
    
    //Our label for displaying var "items/cellName"
    @IBOutlet var cellNameLabel: UILabel!
    @IBOutlet var cellSubmittedLabel: UILabel!
    @IBOutlet var cellLocation: UILabel!
    @IBOutlet var cellDescription: UITextView!
    //Receiving variable assigned to MainVC's var "items"
    var eventId:Int = 0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign your UILabel text to your String
        var event:Event = eventMgr.events[eventId]
        cellNameLabel.text = event.name
        cellDescription.text = event.description
        cellSubmittedLabel.text = event.submitted
        cellLocation.text = event.location
        
        //Assign String var to NavBar title
        self.title = event.name
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
