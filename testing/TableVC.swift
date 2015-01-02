import UIKit

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: UIImage(named: "orangecarbon"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        table.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventMgr.events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell { let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "TableView")

        cell.textLabel?.text = eventMgr.events[indexPath.row].name
        cell.detailTextLabel?.text = eventMgr.events[indexPath.row].description
        cell.textLabel?.textColor = UIColor .grayColor()
        cell.detailTextLabel?.textColor = UIColor .orangeColor()
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var detail:DetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DetailVC") as DetailVC
        detail.eventId = indexPath.row
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    
    func tableView(tableView:UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath:NSIndexPath!){
        if(editingStyle == UITableViewCellEditingStyle.Delete){
            eventMgr.removeTask(indexPath.row)
            table.reloadData()
        }
    }
    
}