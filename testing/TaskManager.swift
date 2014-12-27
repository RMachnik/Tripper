

import UIKit

var eventMgr:EventManager = EventManager()

struct Event{
    var name: String = "Name"
    var description: String = "Description"
    var submitted: String = "Submitted"
    var location: String = "Location"
    var image: String = ""
}

class EventManager: NSObject {
    
    var events = [Event]()
    var persistenceHelper: PersistenceHelper = PersistenceHelper()
    
    override init(){
        
        var tempTasks:NSArray = persistenceHelper.list("Event")
        for res:AnyObject in tempTasks{
            events.append(Event(name: res.valueForKey("name") as String,description:res.valueForKey("desc") as String, submitted:res.valueForKey("subm")as String,location: res.valueForKey("location") as String,image: res.valueForKey("image") as String))
        }
        
    }

    func addEvent(name:String, desc: String, subm: String,location: String,image : String){
 
        var dicTask: Dictionary<String, String> = Dictionary<String,String>()
        dicTask["name"] = name
        dicTask["desc"] = desc
        dicTask["subm"] = subm
        dicTask["location"] = location
        dicTask["image"] = image
        
        if(persistenceHelper.save("Event", parameters: dicTask)){
            events.append(Event(name: name, description:desc, submitted: subm,location: location,image:image))
        }
    }
    
    func removeTask(index:Int){
        
        var value:String = events[index].name
        
        if(persistenceHelper.remove("Event", key: "name", value: value)){
            events.removeAtIndex(index)
        }
    }
    
}

extension Double {
    func toString() -> String {
        return String(format: "%.1f",self)
    }
}
