

import UIKit

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //This is your tableView
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "orangecarbon"))
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        table.reloadData()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return eventMgr.events.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell { let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "TableView")
        
        //Assign the contents of our var "items" to the textLabel of each cell
        cell.textLabel?.text = eventMgr.events[indexPath.row].name
        cell.detailTextLabel?.text = eventMgr.events[indexPath.row].description
        cell.textLabel?.textColor = UIColor .grayColor()
        cell.detailTextLabel?.textColor = UIColor .orangeColor()
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Create instance of DetailVC
        var detail:DetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DetailVC") as DetailVC
        
        //Reference DetailVC's var "cellName" and assign it to DetailVC's var "items"
        detail.txtCellName = eventMgr.events[indexPath.row].name
        detail.txtCellDesc = eventMgr.events[indexPath.row].description
        detail.txtCellSubm = eventMgr.events[indexPath.row].submitted
        detail.txtCellLocation = eventMgr.events[indexPath.row].location
        
        //Programmatically push to associated VC (DetailVC)
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    
    func tableView(tableView:UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath:NSIndexPath!){
        
        if(editingStyle == UITableViewCellEditingStyle.Delete){
            eventMgr.removeTask(indexPath.row)
            table.reloadData()
        }
        
    }
    
}