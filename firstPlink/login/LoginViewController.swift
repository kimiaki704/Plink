
import UIKit
import Firebase

class LoginViewController: UIViewController {
  
  var dataBase: DatabaseReference?
  
  
  @IBOutlet weak var plinkView: UIView!
  @IBOutlet weak var plinkLabel: UILabel!
  @IBOutlet weak var bringsLabel: UILabel!
  @IBOutlet weak var mailMark: UIImageView!
  @IBOutlet weak var mailTextField: UITextField!
  @IBOutlet weak var mailUnderLine: UIView!
  @IBOutlet weak var passwordMark: UIImageView!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var passwordUnderLine: UIView!
  @IBOutlet weak var loginButtonSetting: UIButton!
  @IBOutlet weak var newAccountViewButtonSetting: UIButton!
  
  @IBOutlet weak var registerPlinkLabel: UILabel!
  @IBOutlet weak var registerBringsLabel: UILabel!
  @IBOutlet weak var registerMailMark: UIImageView!
  @IBOutlet weak var registerMailTextField: UITextField!
  @IBOutlet weak var registerMailUnderLine: UIView!
  @IBOutlet weak var registerAccountMark: UIImageView!
  @IBOutlet weak var registerAccountTextField: UITextField!
  @IBOutlet weak var registerAccountUnderLine: UIView!
  @IBOutlet weak var registerPasswordMark: UIImageView!
  @IBOutlet weak var registerPasswordTextField: UITextField!
  @IBOutlet weak var registerPasswordUnderLine: UIView!
  @IBOutlet weak var registerButtonSetting: UIButton!
  @IBOutlet weak var loginViewButtonSetting: UIButton!
  
  
  
  @IBAction func textField(_ sender: Any) {
  }
  
  
  
  @IBAction func tapAction(_ sender: Any) {
    
    self.view.endEditing(true)
    
  }
  
  
  
  
  //インジケーター
  let indicatorLabel = UILabel()
  let indicator = UIActivityIndicatorView()
  func showIndicator() {
    let sendView = UIView()
    sendView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    sendView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
    sendView.tag = 10
    
    
    // UIActivityIndicatorView のスタイルをテンプレートから選択
    indicator.activityIndicatorViewStyle = .whiteLarge
    
    // 表示位置
    indicator.center = self.view.center
    
    // 色の設定
    indicator.color = UIColor.green
    
    //textLabel表示
    indicatorLabel.text = "ログイン中"
    indicatorLabel.textColor = UIColor.white
    indicatorLabel.font = UIFont.systemFont(ofSize: 10)
    indicatorLabel.sizeToFit()
    indicatorLabel.center = CGPoint(x: self.view.center.x, y: self.view.center.y + CGFloat(30))
    indicatorLabel.tag = 20
    sendView.addSubview(indicatorLabel)
    
    // アニメーション停止と同時に隠す設定
    indicator.hidesWhenStopped = true
    
    // 画面に追加
    sendView.addSubview(indicator)
    
    // 最前面に移動
    self.view.bringSubview(toFront: indicator)
    
    // アニメーション開始
    indicator.startAnimating()
    
    self.view.addSubview(sendView)
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
    
    
    plinkViewLoad()
    
    secondViewLoad()
    
    dataBase = Database.database().reference()
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
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
  
  
  
  
  func plinkViewLoad() {
    
    plinkView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    
    plinkLabel.frame = CGRect(x: 0, y: (50/667) * self.view.frame.size.height, width: self.view.frame.size.width, height: (200/667) * self.view.frame.size.height)
    
    bringsLabel.frame = CGRect(x: (60/375) * self.view.frame.size.width, y: (200/667) * self.view.frame.size.height, width: (277/375) * self.view.frame.size.width, height: (36/667) * self.view.frame.size.height)
    
    mailMark.frame = CGRect(x: (50/375) * self.view.frame.size.width, y: (295/667) * self.view.frame.size.height, width: (30/375) * self.view.frame.size.width, height: (25/667) * self.view.frame.size.height)
    
    mailTextField.frame = CGRect(x: (95/375) * self.view.frame.size.width, y: (292/667) * self.view.frame.size.height, width: (230/375) * self.view.frame.size.width, height: (30/667) * self.view.frame.size.height)
    
    mailUnderLine.frame = CGRect(x: (40/375) * self.view.frame.size.width, y: (330/667) * self.view.frame.size.height, width: (295/375) * self.view.frame.size.width, height: 1)
    
    passwordMark.frame = CGRect(x: (50/375) * self.view.frame.size.width, y: (362/667) * self.view.frame.size.height, width: (30/375) * self.view.frame.size.width, height: (25/667) * self.view.frame.size.height)
    
    passwordTextField.frame = CGRect(x: (95/375) * self.view.frame.size.width, y: (362/667) * self.view.frame.size.height, width: (230/375) * self.view.frame.size.width, height: (30/667) * self.view.frame.size.height)
    
    passwordUnderLine.frame = CGRect(x: (40/375) * self.view.frame.size.width, y: (400/667) * self.view.frame.size.height, width: (295/375) * self.view.frame.size.width, height: 1)
    
    loginButtonSetting.frame = CGRect(x: (40/375) * self.view.frame.size.width, y: (470/667) * self.view.frame.size.height, width: (295/375) * self.view.frame.size.width, height: (55/667) * self.view.frame.size.height)
    loginButtonSetting.layer.borderWidth = 2
    loginButtonSetting.layer.borderColor = UIColor(displayP3Red: 240/255, green: 179/255, blue: 84/255, alpha: 1.0).cgColor
    loginButtonSetting.layer.cornerRadius = 15
    loginButtonSetting.layer.masksToBounds = true
    
    
    
    newAccountViewButtonSetting.frame = CGRect(x: (170/375) * self.view.frame.size.width, y: (525/667) * self.view.frame.size.height, width: (170/375) * self.view.frame.size.width, height: (45/667) * self.view.frame.size.height)
    
    
  }
  
  
  func secondViewLoad() {
    registerPlinkLabel.frame = CGRect(x: 0, y: (50/667) * self.view.frame.size.height, width: self.view.frame.size.width, height: (200/667) * self.view.frame.size.height)
    
    registerBringsLabel.frame = CGRect(x: (60/375) * self.view.frame.size.width, y: (200/667) * self.view.frame.size.height, width: (277/375) * self.view.frame.size.width, height: (36/667) * self.view.frame.size.height)
    
    registerMailMark.frame = CGRect(x: (50/375) * self.view.frame.size.width, y: (295/667) * self.view.frame.size.height, width: (30/375) * self.view.frame.size.width, height: (25/667) * self.view.frame.size.height)
    
    registerMailTextField.frame = CGRect(x: (95/375) * self.view.frame.size.width, y: (292/667) * self.view.frame.size.height, width: (230/375) * self.view.frame.size.width, height: (30/667) * self.view.frame.size.height)
    
    registerMailUnderLine.frame = CGRect(x: (40/375) * self.view.frame.size.width, y: (330/667) * self.view.frame.size.height, width: (295/375) * self.view.frame.size.width, height: 1)
    
    registerAccountMark.frame = CGRect(x: (50/375) * self.view.frame.size.width, y: (365/667) * self.view.frame.size.height, width: (30/375) * self.view.frame.size.width, height: (25/667) * self.view.frame.size.height)
    
    registerAccountTextField.frame = CGRect(x: (95/375) * self.view.frame.size.width, y: (362/667) * self.view.frame.size.height, width: (230/375) * self.view.frame.size.width, height: (30/667) * self.view.frame.size.height)
    
    registerAccountUnderLine.frame = CGRect(x: (40/375) * self.view.frame.size.width, y: (400/667) * self.view.frame.size.height, width: (295/375) * self.view.frame.size.width, height: 1)
    
    registerPasswordMark.frame = CGRect(x: (50/375) * self.view.frame.size.width, y: (432/667) * self.view.frame.size.height, width: (30/375) * self.view.frame.size.width, height: (25/667) * self.view.frame.size.height)
    
    registerPasswordTextField.frame = CGRect(x: (95/375) * self.view.frame.size.width, y: (432/667) * self.view.frame.size.height, width: (230/375) * self.view.frame.size.width, height: (30/667) * self.view.frame.size.height)
    
    registerPasswordUnderLine.frame = CGRect(x: (40/375) * self.view.frame.size.width, y: (470/667) * self.view.frame.size.height, width: (295/375) * self.view.frame.size.width, height: 1)
    
    registerButtonSetting.frame = CGRect(x: (40/375) * self.view.frame.size.width, y: (520/667) * self.view.frame.size.height, width: (295/375) * self.view.frame.size.width, height: (55/667) * self.view.frame.size.height)
    
    loginViewButtonSetting.frame = CGRect(x: (256/375) * self.view.frame.size.width, y: (575/667) * self.view.frame.size.height, width: (120/375) * self.view.frame.size.width, height: (45/667) * self.view.frame.size.height)
  }
  
  @IBAction func newAccountViewButton(_ sender: Any) {
    
    plinkView.isHidden = true
    
  }
  
  
  @IBAction func loginViewButton(_ sender: Any) {
    
    plinkView.isHidden = false
    
  }
  
  
  @IBAction func registerButton(_ sender: Any) {
    
    if registerMailTextField.text == nil || registerAccountTextField.text == nil || registerPasswordTextField.text == nil || registerMailTextField.text == "" || registerAccountTextField.text == "" || registerPasswordTextField.text == ""{
      let alertViewController = UIAlertController(title: "おっと。", message: "入力欄が空の状態だよ〜ん", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertViewController.addAction(okAction)
      self.view.viewWithTag(10)?.removeFromSuperview()
      self.view.viewWithTag(20)?.removeFromSuperview()
      present(alertViewController, animated: true, completion: nil)
      
    } else {
      self.showIndicator()
      if registerAccountTextField.text!.isAlphanumeric() {
        
        var checkUserId = [String]()
        self.dataBase = Database.database().reference(fromURL: "https://plinkdatabase.firebaseio.com/").child("allUserID")
        self.dataBase?.observe(DataEventType.value, with: { (snapshot) in
          if (snapshot.value as! NSObject != NSNull()) {
            var snap = snapshot.value as! [String:String]
            checkUserId = [String](snap.values)
            
            if checkUserId.index(of: "@\(self.registerAccountTextField.text!)") == nil {
              
              //新規ユーザー
              Auth.auth().createUser(withEmail: self.registerMailTextField.text!, password: self.registerPasswordTextField.text!, completion: { (user, error) in
                if error == nil {
                  UserDefaults.standard.set("check", forKey: "check")
                  
                  userID = self.registerAccountTextField.text!
                  
                  UserDefaults.standard.set(userID, forKey: "userID")
                  
                  let firUser = Auth.auth().currentUser
                  if let firUser = firUser {
                    uidData = firUser.uid
                  }
                  UserDefaults.standard.set(uidData, forKey: "uidData")
                  
                  self.dataBase = Database.database().reference().child("allUidData")
                  let updateUidData: NSDictionary = [uidData : uidData]
                  self.dataBase?.updateChildValues(updateUidData as! [AnyHashable : Any])
                  
                  self.dataBase = Database.database().reference().child("allUserID")
                  let updateUserID: NSDictionary = [uidData : "@\(userID)"]
                  self.dataBase?.updateChildValues(updateUserID as! [AnyHashable : Any])
                  
                  self.dataBase = Database.database().reference().child("allUserName")
                  let updateUserName: NSDictionary = [uidData : "名前なしさん"]
                  self.dataBase?.updateChildValues(updateUserName as! [AnyHashable : Any])
                  
                  self.dataBase = Database.database().reference().child("users/\(uidData)")
                  let updateMyUserID: NSDictionary = ["userID": userID]
                  self.dataBase?.updateChildValues(updateMyUserID as! [AnyHashable : Any])
                  
                  
                  
                  self.loadUserData()
                  
                  
                  let putNewUid = Database.database().reference()
                  putNewUid.child("users/\(uidData)/newUserSignal").setValue(false)
                  
                  self.uploadingMember(img: UIImage(named: "userImage")!, completion: { (url) in
                    
                    let urlData: NSDictionary = [uidData: url as Any]
                    let profileData:NSDictionary = ["profileImage":url as Any, "userName":"名前なしさん", "spotName":"", "sexName":"", "birthdayName":"", "linkName":"", "commentName":""]
                    
                    let postUserImage = Database.database().reference()
                    postUserImage.child("allUserImage").updateChildValues(urlData as! [AnyHashable : Any])
                    
                    self.dataBase = Database.database().reference().child("users/\(uidData)/profile")
                    
                    self.dataBase?.updateChildValues(profileData as! [AnyHashable : Any])
                    profileList = profileData as! [String : String]
                    UserDefaults.standard.set(profileList["profileImage"], forKey: "profileImage")
                    UserDefaults.standard.set(profileList["userName"], forKey: "userName")
                    UserDefaults.standard.set(profileList["commentName"], forKey: "commentName")
                    
                    self.performSegue(withIdentifier: "ToTimeLine", sender: nil)
                    
                  })
                  
                  //ログインOK
                  
                  
                  
                } else {
                  //失敗
                  let alertViewController = UIAlertController(title: "だめだね！", message: error?.localizedDescription, preferredStyle: .alert)
                  let okAction = UIAlertAction(title: "は〜い", style: .cancel, handler: nil)
                  alertViewController.addAction(okAction)
                  self.view.viewWithTag(10)?.removeFromSuperview()
                  self.present(alertViewController, animated: true, completion: nil)
                }
              })
            }
            
          } else {
            let alertViewController = UIAlertController(title: "残念！", message: "そのID使われてるから違うのにして", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "は〜い", style: .default, handler: nil)
            alertViewController.addAction(okAction)
            self.view.viewWithTag(10)?.removeFromSuperview()
            self.present(alertViewController, animated: true, completion: nil)
          }//ユーザーIDチェック
          
        })
      } else {
        
        //半角英数じゃない
        let alertViewController = UIAlertController(title: "おっと。", message: "userIDは半角英数使えよ〜！「-」「_」もいいぞ", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "は〜い", style: .default, handler: nil)
        alertViewController.addAction(okAction)
        self.view.viewWithTag(10)?.removeFromSuperview()
        self.present(alertViewController, animated: true, completion: nil)
      }//半角英数
      
    }//入力欄から
  }//新規登録ボタン
  
  //最初のユーザー写真を投稿
  func uploadingMember( img : UIImage, completion: @escaping ((String) -> Void)) {
    let storageRef = Storage.storage().reference()
    let storeImage = storageRef.child("allUserImage").child("\(uidData).jpeg")
    
    if let uploadImageData = UIImageJPEGRepresentation(img, 0.1) {
      storeImage.putData(uploadImageData, metadata: nil, completion: { (metaData, error) in
        storeImage.downloadURL(completion: { (url, error) in
          if let urlText = url?.absoluteString {
            
            completion(urlText)
          }
        })
      })
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
      
      let putNewUid = Database.database().reference()
      for users in allUserUid {
        putNewUid.child("users/\(users)/newUserSignal").setValue(true)
      }
      
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
        //UserDefaults.standard.set(allUserImageDict, forKey: "allUserImageDict")
        
        for key in allUserUid {
          /*let decodeData: Any = (base64Encoded: snap[key]!)
           let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
           let decodedImage = UIImage(data: decodedData! as Data)*/
          allUserImage.append(snap[key]!)
        }
        
        //UserDefaults.standard.set(allUserImage, forKey: "allUserImage")
      })
    })
  }
        
      
  //ログイン
  @IBAction func loginButton(_ sender: Any) {
    self.showIndicator()
    Auth.auth().signIn(withEmail: mailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
      if error == nil {
        
        UserDefaults.standard.set("check", forKey: "check")
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        
        
        let firUser = Auth.auth().currentUser
        if let firUser = firUser {
          uidData = firUser.uid
          UserDefaults.standard.set(uidData, forKey: "uidData")
        }
        
        self.dataBase = Database.database().reference(fromURL: "https://plinkdatabase.firebaseio.com/").child("users/\(uidData)/userID")
        self.dataBase?.observe(DataEventType.value, with: { (snapshot) in
          
          let snap = snapshot.value as! String
          
          userID = snap
          UserDefaults.standard.set(userID, forKey: "userID")
        })

        self.dataBase = Database.database().reference(fromURL: "https://plinkdatabase.firebaseio.com/").child("users/\(uidData)/profile")
        self.dataBase?.observe(DataEventType.value, with: { (snapshot) in
          
          let snap = snapshot.value as! [String:String]
          
          profileList = snap
          UserDefaults.standard.set(profileList["profileImage"], forKey: "profileImage")
          UserDefaults.standard.set(profileList["userName"], forKey: "userName")
          UserDefaults.standard.set(profileList["commentName"], forKey: "commentName")
          
          self.loadUserData()
          
          self.performSegue(withIdentifier: "ToTimeLine", sender: nil)
        })
        
      } else {
        //失敗
        self.view.viewWithTag(10)?.removeFromSuperview()
        let alertViewController = UIAlertController(title: "だめだね!", message: error?.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "は〜い", style: .cancel, handler: nil)
        alertViewController.addAction(okAction)
        
        self.present(alertViewController, animated: true, completion: nil)
      }
    })
  }
  
  @IBAction func keyTapAction(_ sender: Any) {
    self.view.endEditing(true)
  }
  
}


  

