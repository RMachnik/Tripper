

import UIKit

class DetailVC: UIViewController {
    
    //Our label for displaying var "items/cellName"
    @IBOutlet var cellNameLabel: UILabel!
    @IBOutlet var cellDetailLabel: UILabel!
    @IBOutlet var cellSubmittedLabel: UILabel!
    @IBOutlet var cellLocation: UILabel!

    //Receiving variable assigned to MainVC's var "items"
    var txtCellName:String = ""
    var txtCellDesc:String = ""
    var txtCellSubm:String = ""
    var txtCellLocation:String = ""
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder:aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign your UILabel text to your String
        cellNameLabel.text = txtCellName
        cellDetailLabel.text = txtCellDesc
        cellSubmittedLabel.text = txtCellSubm
        cellLocation.text = txtCellLocation
        
        //Assign String var to NavBar title
        self.title = txtCellName
        
        cellDetailLabel.numberOfLines = 0
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
