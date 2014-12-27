

import UIKit

var taskMgr:TaskManager = TaskManager()

struct Task{
    var name: String = "Name"
    var description: String = "Description"
    var submitted: String = "Submitted"
    var locationName: String = "LocationName"
    var image: String = ""
}

extension Double {
    func toString() -> String {
        return String(format: "%.1f",self)
    }
}

class TaskManager: NSObject {
    
    var tasks = [Task]()
    var persistenceHelper: PersistenceHelper = PersistenceHelper()
    
    override init(){
        
        var tempTasks:NSArray = persistenceHelper.list("Task")
        for res:AnyObject in tempTasks{
            tasks.append(Task(name: res.valueForKey("name") as String,description:res.valueForKey("desc") as String, submitted:res.valueForKey("subm")as String,locationName: res.valueForKey("locationName") as String,image: res.valueForKey("image") as String))
        }
        
    }

    
    func addTask(name:String, desc: String, subm: String,locationName: String,image : String){
 
        var dicTask: Dictionary<String, String> = Dictionary<String,String>()
        dicTask["name"] = name
        dicTask["desc"] = desc
        dicTask["subm"] = subm
        dicTask["locationName"] = locationName
        dicTask["image"] = image
        
        if(persistenceHelper.save("Task", parameters: dicTask)){
            tasks.append(Task(name: name, description:desc, submitted: subm,locationName: locationName,image:image))
        }
    }
    
    func removeTask(index:Int){
        
        var value:String = tasks[index].name
        
        if(persistenceHelper.remove("Task", key: "name", value: value)){
            tasks.removeAtIndex(index)
        }
    }
    
}