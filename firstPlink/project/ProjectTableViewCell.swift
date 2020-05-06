
import UIKit
import Firebase

class ProjectTableViewCell: UITableViewCell, UITextFieldDelegate {
  
  
  @IBOutlet weak var cell1TextField: UITextField!
  @IBOutlet weak var cell2TextField: UITextField!
  @IBOutlet weak var cell3TextField: UITextField!
  @IBOutlet weak var cell4TextField: UITextField!
  
  @IBAction func catchText1(_ sender: Any) {
    
    if projectList["Team"] != (sender as AnyObject).text {
      let teamDatabase = Database.database().reference()
      let teamData = ["0":String((sender as AnyObject).text)]
      teamDatabase.child("rooms/\(groupID)/Labels").updateChildValues(teamData)
    }
    projectList["Team"] = (sender as AnyObject).text
  }
  
  @IBAction func catchText2(_ sender: Any) {
    
    if projectList["Title"] != (sender as AnyObject).text {
      let titleDatabase = Database.database().reference()
      let titleData = ["1":String((sender as AnyObject).text)]
      titleDatabase.child("rooms/\(groupID)/Labels").updateChildValues(titleData)
    }
    projectList["Title"] = (sender as AnyObject).text
  }
  
  @IBAction func catchText3(_ sender: Any) {
    projectList["Spot"] = (sender as AnyObject).text
  }
  @IBAction func catchText4(_ sender: Any) {
    projectList["HashTag"] = (sender as AnyObject).text
  }
  
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
 
}
