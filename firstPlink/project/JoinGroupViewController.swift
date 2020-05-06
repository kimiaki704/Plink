
import UIKit
import Firebase

var invitationItems = [NSDictionary]()

class JoinGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

  @IBOutlet weak var invitationTable: UITableView!
  override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return invitationItems.count
  }
  
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 65
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "InvitationCell", for: indexPath)
    
    let dict = invitationItems[(indexPath as NSIndexPath).row]
    
    
    let nameCell = cell.viewWithTag(1) as! UILabel
    let idCell = cell.viewWithTag(2) as! UILabel
    let timeCell = cell.viewWithTag(3) as! UILabel
    
    nameCell.text = (dict["userName"] as! String)
    idCell.text = (dict["userID"] as! String)
    timeCell.text = (dict["time"] as! String)
    
    nameCell.frame = CGRect(x: (15/375) * self.view.frame.size.width, y: 5, width: 166, height: 32)
    idCell.frame = CGRect(x: (189/375) * self.view.frame.size.width, y: 5, width: 177, height: 32)
    timeCell.frame = CGRect(x: (160/375) * self.view.frame.size.width, y: 38, width: 200, height: 21)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //let dataBase = Database.database().reference()
    
    updateEditCount()
    
    let dict = invitationItems[(indexPath as NSIndexPath).row]
    groupID = (dict["groupId"] as! String)
    UserDefaults.standard.set(groupID, forKey: "groupID")
    /*let userData: NSDictionary = [uidData: uidData]
    dataBase.child("rooms/\(groupID)/membersUid").updateChildValues(userData as! [AnyHashable : Any])*/
    
    let getDatabase = Database.database().reference().child("rooms/\(groupID)")
    getDatabase.child("membersUid").observe(DataEventType.value, with: { (snapshot) in
      if (snapshot.value as! NSObject != NSNull()) {
        let snap = snapshot.value as! [String:String]
        let snaps = [String](snap.values)
        
        for key in snaps {
          /*let decodeData: Any = (base64Encoded: allUserImageDict["\(key)"])
          let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
          let decodedImage = UIImage(data: decodedData! as Data)*/
          
          
          roomMemberImages.append(allUserImageDict["\(key)"]!)
          
        }
        /*let PVController = self.presentingViewController as! ProjectViewController
        PVController.blackView.isHidden = true
        PVController.viewLoad()
        
        PVController.userCollection.reloadData()*/
      }
    })
    
    let dataBaseRemove = Database.database().reference().child("users/\(uidData)/invitationInfo/\(groupID)")
    dataBaseRemove.removeValue()
    
    /*let dataBaseRemoveRooms = Database.database().reference().child("rooms/\(groupID)/nowInvitation/\(uidData)")
    dataBaseRemoveRooms.removeValue()*/
    
    let imagesInfoDatabase = Database.database().reference()
    let editMember: NSDictionary = [uidData: "100"]
    imagesInfoDatabase.child("rooms/\(groupID)/editMember").updateChildValues(editMember as! [AnyHashable : Any])
    
    
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func returnAction(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  func updateEditCount() {
    
    
    let dataBase = Database.database().reference()
    
    dataBase.child("rooms/\(groupID)/editMember").observe(.value, with: { (snapshot) -> Void in
      if (snapshot.value as! NSObject != NSNull()) {
        
        var item = [Int]()
        
        let snap = snapshot.value as! [String:String]
        
        projectEditMember = snap
        
        for count in 0..<projectImage.count {
          let values = [String](projectEditMember.values)
          let intValues: [Int] = values.map( { Int($0)!})
          let appendValue: Int = intValues.filter({$0 == count}).count
          item.append(appendValue)
          
        }
        projectEditNumber = item
        
      }
      
      
    })
  }
  

}
