
import UIKit
import Firebase

var removeSignals = Bool()

class TLTableViewCell: UITableViewCell {
  
  var delegate: UIViewController?
  
  @IBOutlet weak var teamLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  @IBOutlet weak var scrollView: UIScrollView!
  
  @IBOutlet weak var userScrollView: UIScrollView!
  
  @IBOutlet weak var otherButtonSetting: UIButton!
  
  @IBAction func otherButton(_ sender: Any) {
    let alertViewController = UIAlertController(title: "選んで", message: "", preferredStyle: .actionSheet)
    
    let deleteAction = UIAlertAction(title: "削除", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction!) -> Void in
      
      removeSignals = true
      
      let removeSignalOther = Database.database().reference()
      removeSignalOther.child("users")
      
      
      let removeProject = Database.database().reference()
      removeProject.child("TL/\(tlInfo[(sender as AnyObject).tag])").removeValue()
      
      
      tlInfo.remove(at: (sender as AnyObject).tag)
      
      let removeSignal = Database.database().reference()
      let removeInfo: NSDictionary = ["\(tlInfo[(sender as AnyObject).tag])": "\(tlInfo[(sender as AnyObject).tag])"]
      removeSignal.child("users/\(uidData)/removeSignal").updateChildValues(removeInfo as! [AnyHashable : Any])
    })
    
    let cancelAction = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
    
    deleteAction.setValue(UIColor.black, forKey: "titleTextColor")
    cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
    
    alertViewController.addAction(deleteAction)
    alertViewController.addAction(cancelAction)
    
    delegate!.present(alertViewController, animated: true, completion: nil)
  }
  
  
  override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
    }

}
