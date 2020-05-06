
import UIKit
import Firebase
import SDWebImage

var tableItems = [NSDictionary]()
var tableImages: Array = [UIImage]()

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
  
  
  

  @IBOutlet weak var plink: UILabel!
  @IBOutlet weak var topLine: UIView!
  @IBOutlet weak var underLine: UIView!
  @IBAction func unwindToHomeView(segue: UIStoryboardSegue) {
  }
  @IBOutlet weak var timeLineTableView: UITableView!
  
  var items = [NSDictionary]()              //TLの中身
  var newItems = [NSDictionary]()           //更新分の中身
  var newItemsCount = Int()                 //更新数
  let refreshcontrol = UIRefreshControl()   //引っ張って更新
  
  let indicatorLabel = UILabel()
  let indicator = UIActivityIndicatorView()
  
  
  @IBOutlet weak var homeButton: UIBarButtonItem!
  @IBOutlet weak var projectButtton: UIBarButtonItem!
  @IBOutlet weak var profileButton: UIBarButtonItem!
  
  func showIndicator() {
    
    // UIActivityIndicatorView のスタイルをテンプレートから選択
    indicator.activityIndicatorViewStyle = .whiteLarge
    
    // 表示位置
    indicator.center = self.view.center
    
    // 色の設定
    indicator.color = UIColor.green
    
    //textLabel表示
    indicatorLabel.text = "読み込み中"
    indicatorLabel.textColor = UIColor.black
    indicatorLabel.font = UIFont.systemFont(ofSize: 10)
    indicatorLabel.sizeToFit()
    indicatorLabel.center = CGPoint(x: self.view.center.x, y: self.view.center.y + CGFloat(30))
    indicatorLabel.tag = 10
    self.view.addSubview(indicatorLabel)
    
    // アニメーション停止と同時に隠す設定
    indicator.hidesWhenStopped = true
    
    // 画面に追加
    self.view.addSubview(indicator)
    
    // 最前面に移動
    self.view.bringSubview(toFront: self.logoView)
    
    // アニメーション開始
    indicator.startAnimating()
    
    homeButton.isEnabled = false
    projectButtton.isEnabled = false
    profileButton.isEnabled = false
    
  }
  
  var logoImageView = UIImageView()
  var logoView = UIView()
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      
      
      self.logoView.backgroundColor = UIColor.white
      
      self.logoView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
      
      //imageView作成
      self.logoImageView.frame = CGRect(x: 0, y: 150, width: 375, height: 265)
      
      //画面centerに
      self.logoImageView.center.x = self.view.center.x
      //logo設定
      self.logoImageView.image = UIImage(named: "logo6")
      
      self.logoImageView.contentMode = UIViewContentMode.scaleAspectFill
      //viewに追加
      self.logoView.addSubview(self.logoImageView)
      self.view.addSubview(logoView)
      
      self.view.bringSubview(toFront: self.logoView)
      
      UserDefaults.standard.removeObject(forKey: "TLData")

      
      if UserDefaults.standard.object(forKey: "check") != nil {
        if UserDefaults.standard.object(forKey: "uidData") == nil && UserDefaults.standard.object(forKey: "userID") == nil {
          
          try! Auth.auth().signOut()
          UserDefaults.standard.removeObject(forKey: "check")
          self.performSegue(withIdentifier: "ToPlinkStartView", sender: nil)
          
        } else {
          
          viewLoad()
        }
        
      } else {
        
        self.performSegue(withIdentifier: "ToPlinkStartView", sender: nil)
        
      }
    }
  
  
  //下に引っ張って更新
  @objc func refresh() {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    
    items = [NSDictionary]()
    tlInfo = [String]()
    loadAllData()
    timeLineTableView.reloadData()
    refreshcontrol.endRefreshing()
    
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
  
  
  //viewを開いた時実行(didload)
  func viewLoad() {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    self.timeLineTableView.isHidden = true
    showIndicator()
    
    uidData = UserDefaults.standard.object(forKey: "uidData") as! String
    userID = UserDefaults.standard.object(forKey: "userID") as! String
    
    profileList["profileImage"] = (UserDefaults.standard.object(forKey: "profileImage") as! String)
    profileList["userName"] = (UserDefaults.standard.object(forKey: "userName") as! String)
    profileList["commentName"] = (UserDefaults.standard.object(forKey: "commentName") as! String)
    
    self.refreshcontrol.attributedTitle = NSAttributedString(string: "引っ張って更新")
    self.refreshcontrol.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
    self.timeLineTableView.addSubview(self.refreshcontrol)
    
    self.items = [NSDictionary]()
    tlInfo = [String]()
    self.loadAllData()
    
    
    self.newUidCheck()
    
    self.invitationLoad()
    self.timeLineTableView.reloadData()
    
    let removeTL = Database.database().reference()
    removeTL.child("TL").observe(.childRemoved, with: { (snapshot) -> Void in
      
      if removeSignals != true {
        print("消えた")
      }
      
    })
    
    
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
  
  //TLの取得
  func loadAllData() {
    
    if UserDefaults.standard.object(forKey: "TLData") != nil {
      self.items = UserDefaults.standard.object(forKey: "TLData") as! [NSDictionary]
      let newPostCountDatabase = Database.database().reference()
      var newPostCount = [String]()
      
      newPostCountDatabase.child("users/\(uidData)/newPostCount").observe(DataEventType.value, with: { (snapshot) in
        if (snapshot.value as! NSObject != NSNull()) {
          let snap = snapshot.value as! [String:String]
          
          newPostCount = [String](snap.keys)
          
          let loadDataBase = Database.database().reference()
          
          loadDataBase.child("TL").queryLimited(toLast: UInt(newPostCount.count)).observe(.value) { (snapshot, error) in
            
            for item in(snapshot.children) {
              
              let child = item as! DataSnapshot
              let dict = child.value
              self.items.insert(dict as! NSDictionary, at: 0)
              UserDefaults.standard.set(self.items, forKey: "TLData")
              UserDefaults.standard.set(self.items, forKey: "ProfileTLData")
              
              let insertDict = child.value as! NSDictionary
              if tlInfo.contains(insertDict["Info"] as! String) != true {
                tlInfo.insert(insertDict["Info"] as! String, at: 0)
                
              }
              self.timeLineTableView.reloadData()
            }
          }
        }
        self.indicator.stopAnimating()
        self.homeButton.isEnabled = true
        self.projectButtton.isEnabled = true
        self.profileButton.isEnabled = true
        self.view.viewWithTag(10)?.removeFromSuperview()
        self.timeLineTableView.isHidden = false
        self.timeLineTableView.reloadData()
        newPostCountDatabase.child("users/\(uidData)/newPostCount").removeValue()
      })
      
    } else {
      let newPost = Database.database().reference()
      newPost.child("users/\(uidData)/newPostCount").removeValue()
      
      
      let loadDataBase = Database.database().reference()
      
      
      loadDataBase.child("TL").queryLimited(toLast: 10).observe(.value) { (snapshot, error) in
        //var itemsList = [NSDictionary]()
        
        var tempItems = [NSDictionary]()
        for item in(snapshot.children) {
          
          let child = item as! DataSnapshot
          let dict = child.value
          tempItems.append(dict as! NSDictionary)
          
          let insertDict = child.value as! NSDictionary
          if tlInfo.contains(insertDict["Info"] as! String) != true {
            tlInfo.insert(insertDict["Info"] as! String, at: 0)
            
          }
        }
        self.items = tempItems
        self.items = self.items.reversed()
        UserDefaults.standard.set(self.items, forKey: "TLData")
        UserDefaults.standard.set(self.items, forKey: "ProfileTLData")
        
        
        self.timeLineTableView.reloadData()
        self.indicator.stopAnimating()
        self.homeButton.isEnabled = true
        self.projectButtton.isEnabled = true
        self.profileButton.isEnabled = true
        self.view.viewWithTag(10)?.removeFromSuperview()
        self.timeLineTableView.isHidden = false
      }
    }
  }
  
  
  //投稿を監視
  func viewReload() {
    
    let label = UILabel()
    label.text = "ラベル"
    label.sizeToFit()
    label.center = self.view.center
    self.view.addSubview(label)
    
    let database = Database.database().reference()
    let database2 = Database.database().reference()
    
    
    database.child("TLCount").observe(.childAdded, with: { (snapshot) -> Void in
      label.text = "Added"
      label.backgroundColor = .green
      
    })
    
    database2.child("TL").observe(.childRemoved, with: { (snapshot) -> Void in
      label.text = "Removed"
      label.backgroundColor = .red
      
    })
  }
  
  //招待一覧を取得 ->  要修正かも
  func invitationLoad() {
    let invitationDataBase = Database.database().reference()
    
    invitationDataBase.child("users/\(uidData)/invitationInfo").queryLimited(toLast: 10).observe(.value) { (snapshot, error) in
      var tempItems = [NSDictionary]()
      for item in(snapshot.children) {
        
        let child = item as! DataSnapshot
        let dict = child.value
        tempItems.append(dict as! NSDictionary)
      }
      
      tempItems = tempItems.reversed()
      invitationItems = tempItems
      
    }
  }
  
  //他のユーザーデータを持ってくる
  func loadUserData() {
    
    let loadUserDataBase = Database.database().reference()
    
    loadUserDataBase.child("allUidData").observe(DataEventType.value, with: { (snapshot) in
      
      var snap = snapshot.value as! [String:String]
      allUserUidDict = snap
      UserDefaults.standard.set(allUserUidDict, forKey: "allUserUidDict")
      
      
      let removeCheck = snap.removeValue(forKey: "\(uidData)")
      if removeCheck == nil {
        print("削除データ無し")
      } else {
        print("削除実施 \(removeCheck!)")
      }
      let snaps = [String](snap.values)
      allUserUid = snaps
      UserDefaults.standard.set(allUserUid, forKey: "allUserUid")
      
      let userNameDataBase = Database.database().reference()
      userNameDataBase.child("allUserName").observe(DataEventType.value, with: { (snapshot) in
        
        var snap = snapshot.value as! [String:String]
        allUserNameDict = snap
        UserDefaults.standard.set(allUserNameDict, forKey: "allUserNameDict")
        
        for key in allUserUid {
          allUserName.append(snap[key]!)
        }
        UserDefaults.standard.set(allUserName, forKey: "allUserName")
      })
      
      let userIDDataBase = Database.database().reference()
      userIDDataBase.child("allUserID").observe(DataEventType.value, with: { (snapshot) in
        
        var snap = snapshot.value as! [String:String]
        allUserIdDict = snap
        UserDefaults.standard.set(allUserIdDict, forKey: "allUserIdDict")
        
        for key in allUserUid {
          allUserId.append(snap[key]!)
        }
        UserDefaults.standard.set(allUserId, forKey: "allUserId")
      })
      
      let userImageDataBase = Database.database().reference()
      userImageDataBase.child("allUserImage").observe(DataEventType.value, with: { (snapshot) in
        
        var snap = snapshot.value as! [String:String]
        allUserImageDict = snap
        UserDefaults.standard.set(allUserImageDict, forKey: "allUserImageDict")
        
        for key in allUserUid {
          /*let decodeData: Any = (base64Encoded: snap[key]!)
          let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
          let decodedImage = UIImage(data: decodedData! as Data)*/
          allUserImage.append(snap[key]!)
        }
        
        UserDefaults.standard.set(allUserImage, forKey: "allUserImage")
      })
    })
  }
  
  
  //新しいユーザーが増えているかどうかチェック
  func newUidCheck() {
    let checkNewUid = Database.database().reference()
    
    checkNewUid.child("users/\(uidData)/newUserSignal").observe(.value, with: { (snapshot) in
      if (snapshot.value as! NSObject != NSNull()) {
        let snap = snapshot.value! as! Bool
        
        
        if snap != false {
          self.loadUserData()
        } else {
          
          if UserDefaults.standard.object(forKey: "allUserUidDict") != nil {
            self.defaultsUserData()
            
          }
        }
      }
    })
  }

  //ユーザーデータを持ってくる
  func defaultsUserData() {
    
    allUserUidDict = UserDefaults.standard.object(forKey: "allUserUidDict") as! Dictionary<String, String>
    allUserUid = UserDefaults.standard.object(forKey: "allUserUid") as! Array<String>
    allUserNameDict = UserDefaults.standard.object(forKey: "allUserNameDict") as! Dictionary<String, String>
    allUserName = UserDefaults.standard.object(forKey: "allUserName") as! Array<String>
    allUserIdDict = UserDefaults.standard.object(forKey: "allUserIdDict") as! Dictionary<String, String>
    allUserId = UserDefaults.standard.object(forKey: "allUserId") as! Array<String>
//    allUserImageDict = UserDefaults.standard.object(forKey: "allUserImageDict") as! Dictionary<String, String>
//    allUserImage = UserDefaults.standard.object(forKey: "allUserImage") as! Array<String>
    
  }
  
  
  //ナビゲーションバー隠す
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.timeLineTableView.reloadData()
    
    //少し縮小するアニメーション
    UIView.animate(withDuration: 0.3,
                               delay: 1.0,
                               options: UIViewAnimationOptions.curveEaseOut,
                               animations: { () in
                                self.logoImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }, completion: { (Bool) in
      
    })
    
    //拡大させて、消えるアニメーション
    UIView.animate(withDuration: 0.2,
                               delay: 1.3,
                               options: UIViewAnimationOptions.curveEaseOut,
                               animations: { () in
                                self.logoImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                                self.logoImageView.alpha = 0
    }, completion: { (Bool) in
      self.logoView.removeFromSuperview()
    })
    
  }
  
 
    override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
    }
 
  
  
  
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    let returnCGFloat = self.view.frame.size.width * (125/375)
    
    return 50 + (returnCGFloat * (60/125)) + self.view.frame.size.width
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  var tableViewCount = 0
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "TLTableCell", for: indexPath) as! TLTableViewCell
    
    //サイズ指定
    let userScrollViewWidth:CGFloat = self.view.frame.size.width * (125/375)
    let userScrollViewHeight:CGFloat = self.view.frame.size.width * (125/375) * (60/125)
    cell.userScrollView.frame = CGRect(x: 10, y: 5, width: userScrollViewWidth, height: userScrollViewHeight)
    
    let otherButtonSettingX1:CGFloat = 10 + userScrollViewWidth + (self.view.frame.size.width * (185/375))
    let otherButtonSettingX2:CGFloat =  (self.view.frame.size.width * (7.5/375)) * 2
    let otherButtonSettingWidth:CGFloat = self.view.frame.size.width * (50/375)
    let otherButtonSettingHeight:CGFloat = self.view.frame.size.width * (125/375) * (60/125)
    cell.otherButtonSetting.frame = CGRect(x: otherButtonSettingX1 + otherButtonSettingX2, y: 5, width: otherButtonSettingWidth, height: otherButtonSettingHeight)
    
    
    let scrollViewY:CGFloat = (self.view.frame.size.width * (125/375)) * (60/125)
    cell.scrollView.frame = CGRect(x: 0, y: 10 + scrollViewY, width: self.view.frame.size.width, height: self.view.frame.size.width)
    cell.timeLabel.frame = CGRect(x: self.view.frame.size.width - 135, y: 25 + scrollViewY + self.view.frame.size.width, width: 135, height: 20)
    
    //どのセルのボタンかを判定
    cell.otherButtonSetting.tag = indexPath.row
    cell.delegate = self
    
    
    cell.selectionStyle = UITableViewCellSelectionStyle.none
    
    let dict = items[(indexPath as NSIndexPath).row]
    //let decodeDict = decodeImagesArray[(indexPath as NSIndexPath).row]
    
    cell.teamLabel.text! = dict["Team"] as! String
    cell.teamLabel.sizeToFit()
    
    let teamLabelX1 = self.view.frame.size.width * (125/375)
    let teamLabelX2 = self.view.frame.size.width * (7.5/375)
    cell.teamLabel.frame = CGRect(x: 10 + teamLabelX1 + teamLabelX2, y: 5, width: cell.teamLabel.frame.size.width, height: self.view.frame.size.width * (125/375) * (60/125))
    
    
    cell.titleLabel.text! = dict["Title"] as! String
    cell.titleLabel.sizeToFit()
    
    let titleLabelY = self.view.frame.size.width * (125/375) * (60/125)
    cell.titleLabel.frame = CGRect(x: 15, y: 20 + titleLabelY + self.view.frame.size.width, width: cell.titleLabel.frame.size.width, height: 20)
    
    
    cell.timeLabel.text! = dict["Time"] as! String
    let imageCount = dict["Count"] as! String
   
    let dataCount = dict.count - 7
    for count in 0..<dataCount {
      
      if count < Int(imageCount)! {
        //let decodeData = (base64Encoded:dict[String(count)])
        //let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        //let decodedImage = UIImage(data: decodedData! as Data)
        
        //let images = decodeDict["\(count)"]
        
        let image = UIImageView()
        //ここからテスト
        let urldata = dict[String(count)] as! String
        let strURL = URL(string: urldata)
        
        image.sd_setImage(with: strURL, placeholderImage: nil)
        
        //ここまで
       //image.image = decodedImage
        //image.image = (images as! UIImage)
        image.contentMode = UIViewContentMode.scaleAspectFill
        image.clipsToBounds = true
        
        image.frame = CGRect(x: view.frame.size.width * CGFloat(count), y: 0, width: view.frame.size.width, height: view.frame.size.width)
        
        cell.scrollView.addSubview(image)
        
      } else if count >= Int(imageCount)! {
        //let decodeData = (base64Encoded:dict[String(count)])
        //let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        //let decodedImage = UIImage(data: decodedData! as Data)
        
        //let images = decodeDict["\(count)"]
        
        let image = UIImageView()
        //ここからテスト
//        let urldata = dict[String(count)] as! String
//        let strURL = URL(string: urldata)
//        image.sd_setImage(with: strURL, placeholderImage: nil)
        
        
        //ここまで
        
        //image.image = (images as! UIImage)
        //image.image = decodedImage
        
        image.frame = CGRect(x: (50 * CGFloat(count - Int(imageCount)!)) + 10 * CGFloat(count - Int(imageCount)!), y: 10, width: 50, height: 50)
        
        image.contentMode = UIViewContentMode.scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 25
        image.layer.masksToBounds = true
        
        cell.userScrollView.alwaysBounceVertical = true
        
        cell.userScrollView.addSubview(image)
        
      }
    }
    
    cell.scrollView.contentSize = CGSize(width: view.frame.size.width * CGFloat(Int(imageCount)!), height: view.frame.size.width)
    cell.userScrollView.contentSize = CGSize(width: 50 * CGFloat(dataCount - Int(imageCount)!), height: 50)
    
    if dataCount - Int(imageCount)! == 1 {
      cell.userScrollView.frame = CGRect(x: 10, y: 5, width: (self.view.frame.size.width * (50/375)), height: (self.view.frame.size.width * (125/375)) * (60/125))
    }
    
    //if tlInfo.index(of: dict["Info"] as! String) == nil {
      //tlInfo.insert(dict["Info"] as! String, at: 0)
      //tlInfo.append(dict["Info"] as! String)
    //}
    
    return cell
  }
}

