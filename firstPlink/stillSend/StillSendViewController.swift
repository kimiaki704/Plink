
import UIKit
import Firebase

class StillSendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var stillLabel: UILabel!
  @IBOutlet weak var stillTableView: UITableView!
  
  var DBRef:DatabaseReference!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      stillTableView.delegate = self
      stillTableView.dataSource = self
      
      stillLabel.text = "未送信\(dataDraftingTime.count)件"
      
      DBRef = Database.database().reference()
      
  }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
  //tableViewCellの数
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
    stillLabel.text = "未送信\(dataDraftingTime.count)件"
    return dataDraftingTime.count
  }
  //tableViewの高さ
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  //Cellの中身
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = stillTableView.dequeueReusableCell(withIdentifier: "StillCell", for: indexPath)
    let dataImageView = cell .viewWithTag(1) as! UIImageView
    let dataTitleName = cell.viewWithTag(2) as! UILabel
    let dateLabel = cell.viewWithTag(3) as! UILabel
    
    if dataImage.count != 0{
      dataImageView.image = dataImage[indexPath.row]
    } else {
      
    }
    dataTitleName.text = projectList["Title"]!
    dateLabel.text = dataDraftingTime[indexPath.row]
    return cell
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
      self.DBRef.child("users/@\(userID)/draftBox/\(dataDraftingTime[indexPath.row])").removeValue()
      dataDraftingTime.remove(at: indexPath.row)
      if dataImage.count != 0 {
        dataImage.remove(at: indexPath.row)
      }
      self.stillTableView.reloadData()
    }
    deleteButton.backgroundColor = UIColor.red
    return [deleteButton]
  }
 
  @IBAction func projectButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func backButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func returnButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
}
