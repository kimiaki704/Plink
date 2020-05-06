
import UIKit
import Photos
import Firebase
import SDWebImage



func -(_ left: CGPoint, _ right: CGPoint) -> CGPoint {
  return CGPoint(x:left.x - right.x, y:left.y - right.y)
}

func +(_ left: CGPoint, _ right: CGPoint) -> CGPoint {
  return CGPoint(x:left.x + right.x, y:left.y + right.y)
}


class ProjectViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  
  @IBAction func unwindToProjectView(segue: UIStoryboardSegue) {
  }

  @IBOutlet weak var slideCollection: UICollectionView!
  @IBOutlet weak var userCollection: UICollectionView!
  @IBOutlet weak var largeCollection: UICollectionView!
  @IBOutlet weak var projectTableView: UITableView!
  
  @IBOutlet weak var sendButtonSetting: UIButton!
  @IBOutlet weak var sendSwitch: UISwitch!
  
  @IBOutlet weak var line3: UIView!
  @IBOutlet weak var line4: UIView!
  
  @IBOutlet weak var blackView: UIView!
  
  @IBOutlet weak var newProjectSetting: UIButton!
  @IBOutlet weak var invitationListSetting: UIButton!
  
  
  
  var largeCollectionOriginalPosition: CGPoint?
  var slideCollectionOriginalPosition: CGPoint?
  var line3OriginalPosition: CGPoint?
  var line4OriginalPosition: CGPoint?
  
  
  override func viewDidLoad() {
    blackView.isHidden = true
    super.viewDidLoad()
    if UserDefaults.standard.object(forKey: "groupID") != nil {
      blackView.isHidden = true
      sendSwitch.isHidden = false
      groupID = UserDefaults.standard.object(forKey: "groupID") as! String
      
      

      let getDatabase = Database.database().reference().child("rooms/\(groupID)")
      getDatabase.child("membersUid").observe(DataEventType.value, with: { (snapshot) in
        if (snapshot.value as! NSObject != NSNull()) {
          roomMemberImages = [String]()
          let snap = snapshot.value as! [String:String]
          let snaps = [String](snap.values)
          
          for key in snaps {
            /*let decodeData: Any = (base64Encoded: allUserImageDict["\(key)"])
            let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            let decodedImage = UIImage(data: decodedData! as Data)*/
            
            
            
            roomMemberImages.append(allUserImageDict["\(key)"]!)
          }
          self.userCollection.reloadData()
        }
      })
        
      /*let getImageDatabase = Database.database().reference().child("rooms/\(groupID)")
      getImageDatabase.child("images").observe(DataEventType.value, with: { (snapshot) in
        if (snapshot.value as! NSObject != NSNull()) {
          let snap = snapshot.value as! [String]
          
          for key in snap {
            let decodeData: Any = (base64Encoded: key)
            let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            let decodedImage = UIImage(data: decodedData! as Data)
            projectImage.append(decodedImage!)
          }
          self.slideCollection.reloadData()
          self.largeCollection.reloadData()
        }
      })*/
      
      
      viewLoad()
      viewSizeLoad()
      collectionCellLayout()
      
      
      //UIパーツの位置保存
      largeCollectionOriginalPosition = self.largeCollection.layer.position
      slideCollectionOriginalPosition = self.slideCollection.layer.position
      line3OriginalPosition = self.line3.layer.position
      line4OriginalPosition = self.line4.layer.position
      
      
      projectTableView.isScrollEnabled = false
      
      sendSwitch.isOn = false
      sendSwitch.addTarget(self, action: #selector(ProjectViewController.onSendSwitch(sender:)), for: UIControlEvents.valueChanged)
      sendButtonSetting.isEnabled = false
      
      //largeCollection.reloadData()
      //slideCollection.reloadData()
      
      animationStart()
      openORclose = 1
      
      
    } else {
      
      
      blackView.isHidden = false
      
      sendSwitch.isHidden = true
      
      viewLoad()
      viewSizeLoad()
      collectionCellLayout()
      
      
      //UIパーツの位置保存
      largeCollectionOriginalPosition = self.largeCollection.layer.position
      slideCollectionOriginalPosition = self.slideCollection.layer.position
      line3OriginalPosition = self.line3.layer.position
      line4OriginalPosition = self.line4.layer.position
      
      
      projectTableView.isScrollEnabled = false
      
      sendSwitch.isOn = false
      sendSwitch.addTarget(self, action: #selector(ProjectViewController.onSendSwitch(sender:)), for: UIControlEvents.valueChanged)
      sendButtonSetting.isEnabled = false
      
      largeCollection.reloadData()
      slideCollection.reloadData()
      userCollection.reloadData()
      
      animationStart()
      openORclose = 1
      
      
    }
  }

  
  func viewLoad() {
    
    /*let label = UILabel()
    label.text = "ラベル"
    label.sizeToFit()
    label.center = self.view.center
    self.view.addSubview(label)*/
    
    self.updateEditCount()
    
    
    let database = Database.database().reference()
    
    let postRef = database
    postRef.child("rooms/\(groupID)/images").observe(.childChanged, with: { (snapshot) -> Void in
      /*label.text = "Edited\(self.indexPathInfo)"
      label.backgroundColor = .yellow*/
      self.updateStampEdit()
    })
    
    postRef.child("rooms/\(groupID)/editMember").observe(.childChanged, with: { (snapshot) -> Void in
      /*label.text = "EditedInfo"
      label.sizeToFit()
      label.backgroundColor = .yellow*/
      //self.updateEditCheck()
      self.updateEditCount()
    })
    
    postRef.child("rooms/\(groupID)/images").observe(.childAdded, with: { (snapshot) -> Void in
      /*label.text = "Added"
      label.backgroundColor = .green*/
      
      self.updateFirebase()
    })
    
    /*postRef.child("rooms/\(groupID)/membersUid").observe(.childAdded, with: { (snapshot) -> Void in
      label.text = "Added"
      label.backgroundColor = .green
      self.updateMember()
    })*/
    
    postRef.child("rooms/\(groupID)/images").observe(.childRemoved, with: { (snapshot) -> Void in
      self.showIndicator()
      /*label.text = "Removed"
      label.backgroundColor = .red*/
      self.dismiss(animated: true, completion: nil)
      
      groupID = ""
      projectImage = [UIImage]()
      projectEditMember = [String:String]()
      projectEditNumber = [Int]()
      updateProjectImage = [Int]()
      userImages = [String]()
      roomMemberImages = [String]()
      projectList = ["Team":"", "Title":"", "Spot":"", "HashTag":""]
      UserDefaults.standard.removeObject(forKey: "groupID")
    })
    
    postRef.child("rooms/\(groupID)/Labels").observe(.childChanged, with: { (snapshot) -> Void in
      /*label.text = "Labels"
      label.backgroundColor = .yellow*/
      self.updateLabels()
    })
  }
  
  
  func viewSizeLoad() {
    line3.frame = CGRect(x: 0, y: 118, width: self.view.frame.size.width, height: 0.5)
    line4.frame = CGRect(x: 0, y: 258, width: self.view.frame.size.width, height: 0.5)
    slideCollection.frame = CGRect(x: 0, y: 124, width: self.view.frame.size.width, height: 128)
    largeCollection.frame = CGRect(x: 0, y: 258, width: self.view.frame.size.width, height: self.view.frame.size.height - 258)
    
    /*backgroundImage.frame = CGRect(x: (self.view.frame.size.width/2) - 152.5, y: (132/667) * self.view.frame.size.height, width: 305, height: 305)*/
    newProjectSetting.frame = CGRect(x: 57, y: 70, width: 184, height: 36)
    
  }
  
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
  
  //Firebaseの更新監視
  func updateFirebase() {
    
    let dataBase = Database.database().reference()
    
    dataBase.child("rooms/\(groupID)/images").observe(.value, with: { (snapshot) -> Void in
      if (snapshot.value as! NSObject != NSNull()) {
        let snap = snapshot.value as! [String]
        //var item = [Int]()
        
        projectImage = [UIImage]()
        for image in snap {
          let decodeData: Any = (base64Encoded: image)
          let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
          let decodedImage = UIImage(data: decodedData! as Data)
          
          projectImage.append(decodedImage!)
          //item.append(0)
          
          UserDefaults.standard.set(image, forKey: "projectImage\(projectImage.count - 1)")
          //この処理だと重くなる
          /*let urldata = image
          let fakeImageView = UIImageView()
          let strURL = URL(string: urldata)
          
          if let data = try? Data(contentsOf: strURL!)
          {
            let imageTest: UIImage = UIImage(data: data)!
            projectImage.append(imageTest)
          }*/
          
          
        }
        
        //projectEditNumber = item
      }
      self.slideCollection.reloadData()
      self.largeCollection.reloadData()
    })
  }
  
  //stamp編集の更新
  func updateStampEdit() {
    
    let dataBase = Database.database().reference()
    
    dataBase.child("rooms/\(groupID)/images").observe(.value, with: { (snapshot) -> Void in
      if (snapshot.value as! NSObject != NSNull()) {
        let snap = snapshot.value as! [String]
        
        let decodeData: Any = (base64Encoded: snap[indexPathInfo])
        let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        let decodedImage = UIImage(data: decodedData! as Data)
        projectImage[indexPathInfo] = decodedImage!
        
        self.slideCollection.reloadData()
        self.largeCollection.reloadData()
        
      }
    })
  }
  
  //編集の可否の更新
  /*func updateEditCheck() {
    
    let dataBase = Database.database().reference()
    
    dataBase.child("rooms/\(groupID)/imagesInfo").observe(.value, with: { (snapshot) -> Void in
      if (snapshot.value as! NSObject != NSNull()) {
        let snap = snapshot.value as! [Bool]
        
        //projectImageInfo = snap
      }
    })
  }*/
  
  //編集人数の更新
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
        self.slideCollection.reloadData()
        self.largeCollection.reloadData()
        projectEditNumber = item
        
       }
      
      
    })
  }
  
  //labelの更新
  func updateLabels() {
    
    let dataBase = Database.database().reference()
    
    dataBase.child("rooms/\(groupID)/Labels").observe(.value, with: { (snapshot) -> Void in
      if (snapshot.value as! NSObject != NSNull()) {
        let snap = snapshot.value as! [String]
        
        projectList["Team"] = snap[0]
        projectList["Title"] = snap[1]
        
        self.projectTableView.reloadData()
      }
    })
  }
  
  
  //新しいプロジェクトをタップ
  @IBAction func newProject(_ sender: Any) {
    
    let dataBase = Database.database().reference()
    
    sendSwitch.isHidden = false
    blackView.alpha = 1.0
    UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseIn], animations: {
      self.blackView.alpha = 0.0
    }, completion: nil)
    
    let autoGroupId = dataBase.child("rooms").childByAutoId().key
    
    self.userCollection.reloadData()
    
    roomMemberImages.append(profileList["profileImage"]!)
    
    self.userCollection.reloadData()
    
    let roomUidData: NSDictionary = [uidData: uidData]
    dataBase.child("rooms/\(autoGroupId)/membersUid").updateChildValues(roomUidData as! [AnyHashable : Any])
    
    let imagesInfoDatabase = Database.database().reference()
    let editMember: NSDictionary = [uidData: "100"]
    imagesInfoDatabase.child("rooms/\(autoGroupId)/editMember").updateChildValues(editMember as! [AnyHashable : Any])
    
    let teamData = ["0":""]
    let titleData = ["1":""]
    
    dataBase.child("rooms/\(autoGroupId)/Labels").updateChildValues(teamData)
    dataBase.child("rooms/\(autoGroupId)/Labels").updateChildValues(titleData)
    
    allUserUidDict.removeValue(forKey: "\(uidData)")
    groupID = autoGroupId
    UserDefaults.standard.set(autoGroupId, forKey: "groupID")
    viewLoad()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if UserDefaults.standard.object(forKey: "groupID") != nil {
      blackView.isHidden = true
      sendSwitch.isHidden = false
    }
    viewLoad()
    
    /*userCollection.reloadData()
    slideCollection.reloadData()
    largeCollection.reloadData()*/
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    
    userCollection.reloadData()
    slideCollection.reloadData()
    largeCollection.reloadData()
    
  }
  
  
  func collectionCellLayout() {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)//Cellの大きさ
    layout.minimumInteritemSpacing = 0 //アイテム同士の余白
    layout.minimumLineSpacing = 0 //セクションとアイテムの余白
    
    largeCollection.collectionViewLayout = layout //layoutの更新
    
  }
 
  //cellの数を設定する
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    if collectionView.tag == 1 {
      return projectImage.count + 1
    } else if collectionView.tag == 2 {
      return projectImage.count
    } else {
    return roomMemberImages.count
    }
  }
  
  //cellにUIImageをセットする
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    switch collectionView.tag {
    case 1:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlideCell", for: indexPath) as! SlideCollectionViewCell
      if indexPath.row == projectImage.count {
        cell.slideImage.image = UIImage(named: "pictureAdd")
        return cell
      } else {
        cell.setImage(indexPath.row)
        
        //print(projectEditNumber)
        if projectEditNumber.isEmpty == false {
          if projectEditNumber[indexPath.row] > 0 {
            
           
            if cell.subviews.isEmpty != true {
              
              let blackTags = cell.viewWithTag(20)
              
              blackTags?.removeFromSuperview()
              
            }
            
            
            let blackImage = UIView()
            blackImage.frame = CGRect(x: 20, y: 0, width: 128, height: 128)
            blackImage.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.4)
            blackImage.tag = 20
            
            let whiteLabelOver = UILabel()
            whiteLabelOver.textColor = UIColor.white
            whiteLabelOver.text = "\(projectEditNumber[indexPath.row])人が"
            whiteLabelOver.font = UIFont.systemFont(ofSize: 25)
            whiteLabelOver.sizeToFit()
            whiteLabelOver.center = CGPoint(x: 64, y: 44)
            
            let whiteLabelUnder = UILabel()
            whiteLabelUnder.textColor = UIColor.white
            whiteLabelUnder.text = "編集中"
            whiteLabelUnder.font = UIFont.systemFont(ofSize: 25)
            whiteLabelUnder.sizeToFit()
            whiteLabelUnder.center = CGPoint(x: 64, y: 84)
            
            
            blackImage.addSubview(whiteLabelOver)
            blackImage.addSubview(whiteLabelUnder)
            cell.addSubview(blackImage)
            
            
            updateProjectImage = projectEditNumber
            //print(projectEditNumber)
            //print(updateProjectImage)
            
          } else {
            
            let blackTags = cell.viewWithTag(20)
            
            blackTags?.removeFromSuperview()
            
            updateRealTimeEdit()
            
            
          }
        }
        
        
        return cell
      }
      
      
    case 2:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LargeCell", for: indexPath) as! LargeCollectionViewCell
      cell.setLargeImage(indexPath.row)
      return cell
      
    default:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCollectionViewCell
      
      
      let urldata = roomMemberImages[indexPath.row]
      let strURL = URL(string: urldata)
      
      cell.userImage.sd_setImage(with: strURL, placeholderImage: nil)
      
      //cell.userImage.image = roomMemberImages[indexPath.row]
      cell.userImage.layer.cornerRadius = 27.5
      cell.userImage.layer.masksToBounds = true
      return cell
      
    }
  }
  
  var newImageCheck = Bool()
  func collectionView(_ collectionView : UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch collectionView.tag {
      
    case 1:
      
      
      
      if indexPath.row == projectImage.count {
        
        self.newImageSet()
        
        let alertViewController = UIAlertController(title: "選んで", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "カメラ", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction!) -> Void in
          
          
          if self.newImageCheck != true {
            
            let newPictureSignal = Database.database().reference()
            newPictureSignal.child("rooms/\(groupID)/newPictureSignal").setValue(true)
            self.openCamera()
            
          } else {
            
            let alertViewController = UIAlertController(title: "すとっぷ", message: "誰かが追加してるから待って", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "は〜い", style: .default, handler: nil)
            alertViewController.addAction(okAction)
            
            self.present(alertViewController, animated: true, completion: nil)
            
          }
        
          
        })
        
        let photoAction = UIAlertAction(title: "ライブラリー", style: .default, handler: { (action:UIAlertAction!) -> Void in
          
          if self.newImageCheck != true {
            
            let newPictureSignal = Database.database().reference()
            newPictureSignal.child("rooms/\(groupID)/newPictureSignal").setValue(true)
            self.openLibrary()
            
          } else {
            
            let alertViewController = UIAlertController(title: "すとっぷ", message: "誰かが追加してるから待って", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "は〜い", style: .default, handler: nil)
            alertViewController.addAction(okAction)
            
            self.present(alertViewController, animated: true, completion: nil)
            
          }
          
          
        })
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
        
        cameraAction.setValue(UIColor.black, forKey: "titleTextColor")
        photoAction.setValue(UIColor.black, forKey: "titleTextColor")
        cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
        
        alertViewController.addAction(cameraAction)
        alertViewController.addAction(photoAction)
        alertViewController.addAction(cancelAction)
        
        
        
        present(alertViewController, animated: true, completion: nil)
      }
      
    case 2:
      let imagesInfoDatabase = Database.database().reference()
      let editMember: NSDictionary = [uidData: "\(indexPath.row)"]
      imagesInfoDatabase.child("rooms/\(groupID)/editMember").updateChildValues(editMember as! [AnyHashable : Any])
      
      //projectImageInfo[indexPath.row] = true
      
      nowEditImageInfo = projectImage[indexPath.row]
      indexPathInfo = indexPath.row
      self.performSegue(withIdentifier: "ToEditView", sender: nil)
      /*if projectImageInfo[indexPath.row] != true {
        let imagesInfoDatabase = Database.database().reference()
        let imageInfo: NSDictionary = ["\(indexPath.row)": true]
        let editMember: NSDictionary = [uidData: "\(indexPath.row)"]
        imagesInfoDatabase.child("rooms/\(groupID)/imagesInfo").updateChildValues(imageInfo as! [AnyHashable : Any])
        imagesInfoDatabase.child("rooms/\(groupID)/editMember").updateChildValues(editMember as! [AnyHashable : Any])
        
        //projectImageInfo[indexPath.row] = true
        
        nowEditImageInfo = projectImage[indexPath.row]
        indexPathInfo = indexPath.row
        self.performSegue(withIdentifier: "ToEditView", sender: nil)
        
      } else {
        /*let alertViewController = UIAlertController(title: "あ〜", message: "誰かが編集中だわ", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "は〜い", style: .default, handler: nil)
        alertViewController.addAction(okAction)
        
        self.present(alertViewController, animated: true, completion: nil)*/
        
        let imagesInfoDatabase = Database.database().reference()
        let imageInfo: NSDictionary = ["\(indexPath.row)": true]
        let editMember: NSDictionary = [uidData: "\(indexPath.row)"]
        imagesInfoDatabase.child("rooms/\(groupID)/imagesInfo").updateChildValues(imageInfo as! [AnyHashable : Any])
        imagesInfoDatabase.child("rooms/\(groupID)/editMember").updateChildValues(editMember as! [AnyHashable : Any])
        
        //projectImageInfo[indexPath.row] = true
        
        nowEditImageInfo = projectImage[indexPath.row]
        indexPathInfo = indexPath.row
        self.performSegue(withIdentifier: "ToEditView", sender: nil)
      }*/
      break
      
    default:
      break
    }
  }
  
  
  func newImageSet() {
    let newPictureSignal = Database.database().reference()
    
    newPictureSignal.child("rooms/\(groupID)/newPictureSignal").observe(.value, with: { (snapshot) -> Void in
      if (snapshot.value as! NSObject != NSNull()) {
        let snap = snapshot.value as! Bool
        
        if snap != true {
          
          self.newImageCheck = false
          
        } else {
          
          
          self.newImageCheck = true
          
        }
        
      }
    })
    
  }
  
  
  let colorAsset = [UIColor.white, UIColor.black, UIColor.darkGray, UIColor.lightGray, UIColor.gray, UIColor.brown, UIColor.red, UIColor.magenta, UIColor.green, UIColor.blue, UIColor.cyan, UIColor.yellow, UIColor.orange, UIColor.purple]
  let colorAssetName = ["white", "black", "darkGray", "lightGray", "gray", "brown", "red", "magenta", "green", "blue", "cyan", "yellow", "orange", "purple"]
  
  
  func updateRealTimeEdit() {
    
    if updateProjectImage.isEmpty != true {
      for count in 0..<projectEditNumber.count {
        
        
        if updateProjectImage[count] - 1 == projectEditNumber[count] && projectEditNumber[count] == 0 {
          var tempItems = [NSDictionary]()
          //print("ここに処理書くよ！\(count)")
          let stampDatabase = Database.database().reference()
          stampDatabase.child("rooms/\(groupID)/stamps/\(count)").observe(.value) { (snapshot, error) in
            
            if (snapshot.value as! NSObject != NSNull()) {
              
              let updateImageView = UIImageView()
              
              updateImageView.frame.size = CGSize(width:self.view.frame.size.width, height: self.view.frame.size.width)
              
              updateImageView.image = projectImage[count]
              
              updateImageView.contentMode = UIViewContentMode.scaleAspectFill
              
              for item in(snapshot.children) {
                
                let child = item as! DataSnapshot
                let dict = child.value
                tempItems.append(dict as! NSDictionary)
                
              }
              
              for items in tempItems {
                
                //print(items)
                
                let stampCountData = items["stampCount"] as! String
                let CGPointData = items["CGPoint"] as! String
                let CGAffineTransformData = items["CGAffineTransform"] as! String
                
                
                if items["stampName"] != nil {
                  
                  let stampImage = UIImage(named: items["stampName"] as! String)!
                  
                  let stampSize = stampImage.size
                  let stampImageView = UIImageView()
                  
                  stampImageView.frame.size = stampSize
                  
                  stampImageView.center = CGPointFromString(CGPointData)
                  
                  stampImageView.image = stampImage
                  
                  stampImageView.transform = CGAffineTransformFromString(CGAffineTransformData)
                  
                  stampImageView.isUserInteractionEnabled = true
                  
                  stampImageView.tag = Int(stampCountData)!
                  updateImageView.addSubview(stampImageView)
                  
                  
                } else {
                  let stampLabel = UILabel()
                  
                  stampLabel.numberOfLines = 0
                  
                  stampLabel.text = (items["labelText"] as! String)
                  stampLabel.font = UIFont.systemFont(ofSize: 50)
                  stampLabel.sizeToFit()
                  stampLabel.isUserInteractionEnabled = true
                  stampLabel.backgroundColor = UIColor.clear
                  
                  let labelColorNumber = self.colorAssetName.index(of: (items["colorInfo"] as! String))
                  stampLabel.textColor = self.colorAsset[labelColorNumber!]
                  
                  stampLabel.center = CGPointFromString(CGPointData)
                  
                  stampLabel.transform = CGAffineTransformFromString(CGAffineTransformData)
                  
                  stampLabel.tag = Int(stampCountData)!
                  
                  updateImageView.addSubview(stampLabel)
                  
                }
              }
              
              UIGraphicsBeginImageContextWithOptions(updateImageView.frame.size, false, 0.0)
              updateImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
              
              //editした画像をに表示されている画像をに格納
              let image = UIGraphicsGetImageFromCurrentImageContext()!
              
              /*let testImageView = UIImageView()
              testImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
              testImageView.image = image
              self.view.addSubview(testImageView)*/
              
              var data: NSData = NSData()
              data = UIImageJPEGRepresentation(image, 0.9)! as NSData
              let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as String
              
              
              UserDefaults.standard.set(base64String, forKey: "projectImage\(count)")
              
              UIGraphicsEndImageContext()
              
              self.reloadProjectImage()
            }
          }
        }
      }
    }
  }
  
  
  func reloadProjectImage() {
    //UserDefaultsから
  }
  
  
  func openCamera() {
    
    let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
      let cameraPicker = UIImagePickerController()
      cameraPicker.sourceType = sourceType
      cameraPicker.delegate = self
      self.present(cameraPicker, animated: true, completion: nil)
    }
  }
  
  func openLibrary() {
    
    let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.photoLibrary
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
      let photoPicker = UIImagePickerController()
      photoPicker.sourceType = sourceType
      photoPicker.delegate = self
      self.present(photoPicker, animated: true, completion: nil)
    }
  }
  
  // 写真を選んだ後に呼ばれる処理
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    // 選択した写真を取得する
    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    
    //test -> start
    /*let roomsDatabase = Database.database().reference()
    
    uploadingRealtimeImage(img: image, completion: { (url) in
      let urlData: NSDictionary = ["\(projectImage.count)": url as Any]
      let imageInfo: NSDictionary = ["\(projectImage.count)": false]
      roomsDatabase.child("rooms/\(groupID)/images").updateChildValues(urlData as! [AnyHashable : Any])
      roomsDatabase.child("rooms/\(groupID)/imagesInfo").updateChildValues(imageInfo as! [AnyHashable : Any])
      
      projectImage.append(image)
      projectImageInfo.append(false)
    })
    //test -> end*/
    
    var data: NSData = NSData()
    let images = image
    data = UIImageJPEGRepresentation(images, 0.9)! as NSData
    let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as String
    let imageData: NSDictionary = ["\(projectImage.count)": base64String]
    let imageInfo: NSDictionary = ["\(projectImage.count)": false]
    
    let roomsDatabase = Database.database().reference()
    roomsDatabase.child("rooms/\(groupID)/images").updateChildValues(imageData as! [AnyHashable : Any])
    roomsDatabase.child("rooms/\(groupID)/imagesInfo").updateChildValues(imageInfo as! [AnyHashable : Any])
    
    //projectEditNumber.append(0)
    
    slideCollection.reloadData()
    largeCollection.reloadData()
    // 写真を選ぶビューを引っ込める
    //projectImage.append(image)
    //projectImageInfo.append(false)
    self.dismiss(animated: true, completion: nil)
    
    let newPictureSignal = Database.database().reference()
    newPictureSignal.child("rooms/\(groupID)/newPictureSignal").setValue(false)
  }
  
  
  
  //Accordionもどき
  var openORclose: Int = 0
  @IBAction func openTableview(_ sender: Any) {
    if openORclose == 0 {
      (sender as AnyObject).setImage(UIImage(named: "accordionButton"), for: .normal)
      animationStart()
      openORclose = 1
    } else {
      //(sender as AnyObject).setImage(UIImage(named: "open.png"), for: .normal)
      animationEnd()
      openORclose = 0
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
    
    let newPictureSignal = Database.database().reference()
    newPictureSignal.child("rooms/\(groupID)/newPictureSignal").setValue(false)
    
  }
  
  //送信許可スイッチ設定
  @objc func onSendSwitch(sender: UISwitch) {
    if sender.isOn {
      sendButtonSetting.isEnabled = true
    } else {
      sendButtonSetting.isEnabled = false
    }
  }
  

  func animationStart() {
    UIView.animate(withDuration: 0.5,
                   animations: {
                    self.largeCollection.layer.position = CGPoint(x: (self.largeCollectionOriginalPosition!.x), y: (self.largeCollectionOriginalPosition!.y + 100))
                    self.largeCollection.frame.size.height = self.view.frame.size.height - CGFloat(358)
                    self.slideCollection.layer.position = CGPoint(x: (self.slideCollectionOriginalPosition!.x), y: (self.slideCollectionOriginalPosition!.y + 100))
                    self.line3.layer.position = CGPoint(x: (self.line3OriginalPosition!.x), y: (self.line3OriginalPosition!.y + 100))
                    self.line4.layer.position = CGPoint(x: (self.line4OriginalPosition!.x), y: (self.line4OriginalPosition!.y + 100))
                  })
  }
  func animationEnd() {
    UIView.animate(withDuration: 0.5,
                   animations: {
                    self.largeCollection.layer.position = CGPoint(x: (self.largeCollectionOriginalPosition!.x), y: (self.largeCollectionOriginalPosition!.y - 50))
                    self.largeCollection.frame.size.height = self.view.frame.size.height - CGFloat(258)
                    self.slideCollection.layer.position = self.slideCollectionOriginalPosition!
                    self.line3.layer.position = self.line3OriginalPosition!
                    self.line4.layer.position = self.line4OriginalPosition!
                  })
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
    return 2
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.row {
    case 3:
      return 76
    default:
      return 50
    }
  }
  
  var tableViewCellName: String = ""
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    switch indexPath.row {
    case 0:
      tableViewCellName = "Cell1"
    case 1:
      tableViewCellName = "Cell2"
    case 2:
      tableViewCellName = "Cell3"
    default:
      tableViewCellName = "Cell4"
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellName, for: indexPath) as! ProjectTableViewCell
    cell.selectionStyle = UITableViewCellSelectionStyle.none
    
    switch indexPath.row {
    case 0:
      let cellLabel = cell.viewWithTag(11) as! UILabel
      let cellText = cell.viewWithTag(21) as! UITextField
      cellLabel.text! = "チーム名:"
      cellText.text! = projectList["Team"]!
      
      cellLabel.frame = CGRect(x: 31, y: 10, width: 67, height: 30)
      cellText.frame = CGRect(x: 101, y: 10, width: 302, height: 30)
      
    case 1:
      let cellLabel = cell.viewWithTag(12) as! UILabel
      let cellText = cell.viewWithTag(22) as! UITextField
      cellLabel.text! = "タイトル:"
      cellText.text! = projectList["Title"]!
      
      cellLabel.frame = CGRect(x: 31, y: 10, width: 67, height: 30)
      cellText.frame = CGRect(x: 101, y: 10, width: 302, height: 30)
      
    case 2:
      let cellLabel = cell.viewWithTag(13) as! UILabel
      let cellText = cell.viewWithTag(23) as! UITextField
      cellLabel.text! = "スポット:"
      cellText.text! = projectList["Spot"]!
    default:
      let cellLabel = cell.viewWithTag(14) as! UILabel
      let cellText = cell.viewWithTag(24) as! UITextField
      cellLabel.text! = "ハッシュタグ:"
      cellText.text! = projectList["HashTag"]!
    }
    
    return cell
  }
  
  //戻る
  @IBAction func backToTimeLine(_ sender: Any) {
    roomMemberImages = [String]()
    projectImage = [UIImage]()
    
    self.dismiss(animated: true, completion: nil)
  }
  
  //インジケーター
  let indicatorLabel = UILabel()
  let indicator = UIActivityIndicatorView()
  func showIndicator() {
    let sendView = UIView()
    sendView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    sendView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
    self.view.addSubview(sendView)
    
    // UIActivityIndicatorView のスタイルをテンプレートから選択
    indicator.activityIndicatorViewStyle = .whiteLarge
    
    // 表示位置
    indicator.center = self.view.center
    
    // 色の設定
    indicator.color = UIColor.green
    
    //textLabel表示
    indicatorLabel.text = "送信中"
    indicatorLabel.textColor = UIColor.white
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
    self.view.bringSubview(toFront: indicator)
    
    // アニメーション開始
    indicator.startAnimating()
    
  }
  

  //送信ボタン
  @IBAction func sendButton(_ sender: Any) {
    if projectImage.count != 0 {
      let newProjectEditNumber = projectEditNumber.filter{ $0 == 0 }
      if projectImage.count != newProjectEditNumber.count {
        let alertViewController = UIAlertController(title: "すとっぷ", message: "まだ誰かが編集してるみたい", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "は〜い", style: .default, handler: nil)
        alertViewController.addAction(okAction)
        
        self.present(alertViewController, animated: true, completion: nil)
        
      } else {
        showIndicator()
        
        
        postData()
        
        
        UserDefaults.standard.removeObject(forKey: "groupID")
        UserDefaults.standard.removeObject(forKey: "\(groupID)")
      }
      
    } else {
      let alertViewController = UIAlertController(title: "だめだよ〜！", message: "1枚くらい写真選べよ！", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "は〜い", style: .default, handler: nil)
      alertViewController.addAction(okAction)
      
      self.present(alertViewController, animated: true, completion: nil)
    }
    
  }
  
  
  func postData() {
    
    var postCheck = [Bool]()
    for _ in 0..<projectImage.count {
      postCheck.append(false)
    }
    
    let postDataBase = Database.database().reference()
   
    let autoid = postDataBase.child("TL").childByAutoId().key
    
    let allData: NSDictionary = ["Team":projectList["Team"] as Any, "Title":projectList["Title"] as Any, "Spot":projectList["Spot"] as Any, "HashTag":projectList["HashTag"] as Any, "Time":Functions.nowTimeGet(), "Count": "\(projectImage.count)", "Info": "\(autoid)"]
    
    postDataBase.child("TL/\(autoid)").setValue(allData)
    
    
    for count in 0..<projectImage.count + roomMemberImages.count{
      if count < projectImage.count {
        //let image = projectImage[count]
        
        let image = UserDefaults.standard.object(forKey: "projectImage\(count)")
        let decodeData: Any = (base64Encoded: image)
        let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        let decodedImage = UIImage(data: decodedData! as Data)
        
        
        //data = UIImageJPEGRepresentation(image, 0.9)! as NSData
        //let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as String
        //let imageData: NSDictionary = [String(count): base64String]
        
        
        //ここからテスト
        uploadingProject(img: decodedImage!, count: count, autoID: autoid, completion: { (url) in
          
          let urlData: NSDictionary = [String(count): url as Any]
          postDataBase.child("TL/\(autoid)").updateChildValues(urlData as! [AnyHashable : Any])
          
          for set in 0..<projectImage.count {
            if url.contains("\(set).jpeg") == true && postCheck[set] == false {
              postCheck[set] = true
            }
          }
          
          
          if postCheck.contains(false) != true {
            let newPostSignal = Database.database().reference()
            let postSignalUid = [String](allUserUidDict.values)
            
            newPostSignal.child("users/\(uidData)/newPostCount").childByAutoId().setValue("Post")
            
            for uid in postSignalUid {
              newPostSignal.child("users/\(uid)/newPostCount").childByAutoId().setValue("Post")
              
            }
            
            
            
            
            for data in 0..<projectImage.count {
              
              UserDefaults.standard.removeObject(forKey: "projectImage\(data)")
              
            }
            
            groupID = ""
            projectImage = [UIImage]()
            //projectImageInfo = [Bool]()
            roomMemberImages = [String]()
            projectList = ["Team":"", "Title":"", "Spot":"", "HashTag":""]
            
            
            let dataBase = Database.database().reference().child("rooms/\(groupID)")
            dataBase.removeValue()
            
          }
          
        })
        //ここまで
        
        //postDataBase.child("TL/\(autoid)").updateChildValues(imageData as! [AnyHashable : Any])
      } else {
        //let images = roomMemberImages[count - projectImage.count]
        //data = UIImageJPEGRepresentation(image, 0.1)! as NSData
        //let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as String
        //let imageData: NSDictionary = [String(count): base64String]
        let url = URL(string: roomMemberImages[count - projectImage.count])!
        
        //セット
        let imageData = try? Data(contentsOf: url)
        let image = UIImage(data:imageData!)
        
        
        //ここからテスト
        uploadingMember(img: image!, count: count, autoID: autoid, completion: { (url) in
          
          let urlData: NSDictionary = [String(count): url as Any]
          postDataBase.child("TL/\(autoid)").updateChildValues(urlData as! [AnyHashable : Any])
          
        })
        //ここまで
        
        //postDataBase.child("TL/\(autoid)").updateChildValues(imageData as! [AnyHashable : Any])
      }
    }
    
    
  }
  
  func uploadingMember( img : UIImage, count : Int, autoID : String, completion: @escaping ((String) -> Void)) {
    let storageRef = Storage.storage().reference()
    let storeImage = storageRef.child("TL/\(autoID)").child("\(count).jpeg")
    
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
  
  func uploadingProject( img : UIImage, count : Int, autoID : String,  completion: @escaping ((String) -> Void)) {
    let storageRef = Storage.storage().reference()
    let storeImage = storageRef.child("TL/\(autoID)").child("\(count).jpeg")
    
    if let uploadImageData = UIImageJPEGRepresentation(img, 1.0) {
      storeImage.putData(uploadImageData, metadata: nil, completion: { (metaData, error) in
        storeImage.downloadURL(completion: { (url, error) in
          if let urlText = url?.absoluteString {
            
            completion(urlText)
          }
        })
      })
    }
  }
  
  func uploadingRealtimeImage( img : UIImage, completion: @escaping ((String) -> Void)) {
    let storageRef = Storage.storage().reference()
    let storeImage = storageRef.child("rooms/\(groupID)").child("\(projectImage.count).jpeg")
    
    if let uploadImageData = UIImageJPEGRepresentation(img, 1.0) {
      storeImage.putData(uploadImageData, metadata: nil, completion: { (metaData, error) in
        storeImage.downloadURL(completion: { (url, error) in
          if let urlText = url?.absoluteString {
            
            completion(urlText)
          }
        })
      })
    }
  }
  
}



extension UIImagePickerController {
  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    self.navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor.black
    self.navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
  }
}
