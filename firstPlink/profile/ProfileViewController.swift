
import UIKit
import Firebase

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  
  
  @IBOutlet weak var userIDLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var commentLabel: UILabel!
  
  @IBOutlet weak var profileImage: UIImageView!
  
  @IBOutlet weak var TLCollection: UICollectionView!
  
  

  var dataBase : DatabaseReference?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewLoadMethod()
    collectionCellLayout()
    
    dataBase = Database.database().reference()
    let id = dataBase?.child("users/\(uidData)/userID")
    id?.observe(.value) { (snap: DataSnapshot) in self.userIDLabel.text = (snap.value! as AnyObject).description
      
    }
    
    TLCollection.reloadData()
  }
  
  func viewLoadMethod() {
    
    if UserDefaults.standard.object(forKey: "ProfileTLData") != nil {
      tableItems = UserDefaults.standard.object(forKey: "ProfileTLData") as! [NSDictionary]
    }
    
    
    if UserDefaults.standard.object(forKey: "profileImage") != nil {
      
      /*let decodeData = UserDefaults.standard.object(forKey: "profileImage")
      
      let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
      let decodedImage = UIImage(data: decodedData! as Data)
      profileImage.image = decodedImage*/
      
      let urldata = UserDefaults.standard.object(forKey: "profileImage") as! String
      let strURL = URL(string: urldata)
      
      profileImage.sd_setImage(with: strURL, placeholderImage: nil)
      
      profileImage.layer.cornerRadius = 35
      profileImage.layer.masksToBounds = true
    } else {
      profileImage.image = UIImage(named: "userImage")
    }
    
    nameLabel.text = (UserDefaults.standard.object(forKey: "userName") as! String)
    commentLabel.text = (UserDefaults.standard.object(forKey: "commentName") as! String)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }

  //ログアウト
  @IBAction func logout(_ sender: Any) {
    try! Auth.auth().signOut()
    UserDefaults.standard.removeObject(forKey: "check")
    UserDefaults.standard.removeObject(forKey: "profileImage")
    UserDefaults.standard.removeObject(forKey: "userID")
    UserDefaults.standard.removeObject(forKey: "uidData")
    UserDefaults.standard.removeObject(forKey: "groupID")
    UserDefaults.standard.removeObject(forKey: "userName")
    UserDefaults.standard.removeObject(forKey: "commentName")
    UserDefaults.standard.removeObject(forKey: "TLData")
    UserDefaults.standard.removeObject(forKey: "ProfileTLData")
    
    self.dismiss(animated: true, completion: nil)
    
  }
  
  func collectionCellLayout() {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: self.view.frame.size.width/3, height: self.view.frame.size.width/3)//Cellの大きさ
    layout.minimumInteritemSpacing = 0 //アイテム同士の余白
    layout.minimumLineSpacing = 0 //セクションとアイテムの余白
    
    TLCollection.collectionViewLayout = layout //layoutの更新
    
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return tableItems.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TLList", for: indexPath) as! TLListCollectionViewCell
    
    let dict = tableItems[(indexPath as NSIndexPath).row]
    
    /*let decodeData = (base64Encoded:dict["0"])
    let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
    let decodedImage = UIImage(data: decodedData! as Data)*/
    
    let urldata = dict["0"] as! String
    let strURL = URL(string: urldata)
    
    cell.tlImage.sd_setImage(with: strURL, placeholderImage: nil)
    
    
    cell.tlImage.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width/3, height: self.view.frame.size.width/3)
    cell.tlImage.contentMode = UIViewContentMode.scaleAspectFill
    //cell.tlImage.image = decodedImage
    
    
    return cell
  }
  
}
