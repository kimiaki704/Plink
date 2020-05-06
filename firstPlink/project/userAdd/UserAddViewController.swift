
import UIKit
import Firebase
import SDWebImage

class UserAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UICollectionViewDelegate, UICollectionViewDataSource {
  
  var dataBase : DatabaseReference?
  var fakeAllUserName: Array = [String]()
  var fakeAllUserId: Array = [String]()
  var fakeAllUserUid: Array = [String]()
  var fakeAllUserImage: Array = [UIImage]()
  
  var fakeUidDict = [String:String]()
  var postInvitationInfo: Array = [String]()

  @IBOutlet weak var addUserCollection: UICollectionView!
  @IBOutlet weak var userAddTableView: UITableView!
  @IBOutlet weak var userSearch: UISearchBar!
  
  var uidValue = [String]()
  override func viewDidLoad() {
        super.viewDidLoad()
    dataBase = Database.database().reference()
    
    dataBase = Database.database().reference(fromURL: "https://plinkdatabase.firebaseio.com/").child("rooms/\(groupID)/mambersUid")
    dataBase?.observe(DataEventType.value, with: { (snapshot) in
      if (snapshot.value as! NSObject != NSNull()) {
        var snap = snapshot.value as! [String:String]
        let snaps = [String](snap.values)
        
        for uid in snaps {
          let removeCheck = allUserUidDict.removeValue(forKey: "\(uid)")
          if removeCheck == nil {
            print("uid削除データ無し")
          } else {
            print("uid削除実施 \(removeCheck!)")
          }
        }
      }
      
      
      self.dataBase = Database.database().reference(fromURL: "https://plinkdatabase.firebaseio.com/").child("rooms/\(groupID)/nowInvitation")
      self.dataBase?.observe(DataEventType.value, with: { (snapshot) in
        if (snapshot.value as! NSObject != NSNull()) {
          var snap = snapshot.value as! [String:String]
          let snaps = [String](snap.values)
          
          for uid in snaps {
            let removeCheck = allUserUidDict.removeValue(forKey: "\(uid)")
            if removeCheck == nil {
              print("uid削除データ無し")
            } else {
              print("uid削除実施 \(removeCheck!)")
            }
          }
        }
        self.fakeUidDict = allUserUidDict
        self.uidValue = [String](self.fakeUidDict.values)
        self.userAddTableView.reloadData()
      })
    })
    
    userAddTableView.reloadData()
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return uidValue.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserAddCell", for: indexPath)
    let nameLabel = cell.viewWithTag(1) as! UILabel
    let idLabel = cell.viewWithTag(2) as! UILabel
    let imageView = cell.viewWithTag(3) as! UIImageView
    
    nameLabel.text = allUserNameDict["\(uidValue[indexPath.row])"]
    idLabel.text = allUserIdDict["\(uidValue[indexPath.row])"]
    
    nameLabel.frame = CGRect(x: 62, y: 16, width: 229, height: 27)
    nameLabel.sizeToFit()
    
    idLabel.frame = CGRect(x: 280, y: 17, width: 11, height: 27)
    idLabel.sizeToFit()
    
    imageView.frame = CGRect(x: 11, y: 5, width: 40, height: 40)
    /*let decodeData: Any = (base64Encoded:allUserImageDict["\(uidValue[indexPath.row])"])
    let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
    let decodedImage = UIImage(data: decodedData! as Data)*/
    
    //テスト
    
    let urldata = allUserImageDict["\(uidValue[indexPath.row])"] as! String
    let strURL = URL(string: urldata)
    imageView.sd_setImage(with: strURL, placeholderImage: nil)
    
    //imageView.image = decodedImage!
    imageView.layer.cornerRadius = 20
    imageView.layer.masksToBounds = true
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    /*let decodeData: Any = (base64Encoded:allUserImageDict["\(uidValue[indexPath.row])"])
    let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
    let decodedImage = UIImage(data: decodedData! as Data)*/
    
    
    userImages.append(allUserImageDict["\(uidValue[indexPath.row])"]!)
    postInvitationInfo.append(uidValue[indexPath.row])
    uidValue.remove(at: indexPath.row)
    
    addUserCollection.reloadData()
    userAddTableView.reloadData()
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return userImages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCell", for: indexPath) as! UserAddCollectionViewCell
    cell.setUserImage(indexPath.row)
    return cell
  }
  

  
  @IBAction func cancel(_ sender: Any) {
    userImages = [String]()
    self.dismiss(animated: true, completion: nil)
  }
  
  
  
  @IBAction func done(_ sender: Any) {
    let PVController = presentingViewController as! ProjectViewController
    PVController.userCollection.reloadData()
    userImages = [String]()
    
    for count in 0..<postInvitationInfo.count {
      let data = ["groupId":groupID, "time":Functions.nowTimeGet(), "userID":userID, "userName":profileList["userName"]]
      let usersDataBase = Database.database().reference().child("users/\(postInvitationInfo[count])/invitationInfo/\(groupID)")
      usersDataBase.setValue(data)

      /*let roomsInvitationInfo = [postInvitationInfo[count]:postInvitationInfo[count]]
      let roomsDataBase = Database.database().reference().child("rooms/\(groupID)/nowInvitation")
      roomsDataBase.updateChildValues(roomsInvitationInfo)*/
      let roomsInvitationInfo = [postInvitationInfo[count]:postInvitationInfo[count]]
      let roomsDataBase = Database.database().reference().child("rooms/\(groupID)/membersUid")
      roomsDataBase.updateChildValues(roomsInvitationInfo)
      
      /*let decodeData: Any = (base64Encoded:allUserImageDict["\(postInvitationInfo[count])"])
      let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
      let decodedImage = UIImage(data: decodedData! as Data)*/
      roomMemberImages.append(allUserImageDict["\(postInvitationInfo[count])"]!)
    }
    
    dismiss(animated: true, completion: nil)
  }
}
