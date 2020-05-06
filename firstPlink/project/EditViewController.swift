
import UIKit
import Firebase


var stampCount = 0
var firstTimeGesture = [String:Bool]()

class EditViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
  
  var stampTapedIn = [String:Bool]()
  var stampTapedOut = [String:Bool]()
  var tapStampNumber = Int()
  
  let indicatorLabel = UILabel()
  let indicator = UIActivityIndicatorView()
  
  
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
    indicatorLabel.tag = -10
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
  
  
  var updateStampSignal = Bool()
  var updateCGPointSignal = Bool()
  var updateCGAffineTransformSignal = Bool()
  var updateRemoveSignal = Bool()
  var noUpdateSignal = Bool()
  
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      
      stampCount = 0
      firstTimeGesture = [String:Bool]()
      stampInfomation = [String:String]()
      stampTapedIn = [String:Bool]()
      stampTapedOut = [String:Bool]()
      
      textWhite.isHidden = true
      stampWhite.isHidden = true
      
      
      collectionCellLayout()
      editImage.image = nowEditImageInfo
      editImage.contentMode = UIViewContentMode.scaleAspectFill
      editImage.clipsToBounds = true
      
      viewLoad()
      viewSizeLoad()
      
      updateStampTaped()
      tapedInChanged()
       // Do any additional setup after loading the view.
      
    }

  
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  var checkLoad = false
  
  
  func viewLoad() {
    
    /*let label = UILabel()
     label.text = "ラベル"
     label.sizeToFit()
     label.center = self.view.center
     self.view.addSubview(label)*/
    
    
    
    let database = Database.database().reference()
    
    let postRef = database
    
    
    postRef.child("rooms/\(groupID)/stamps/\(indexPathInfo)/").observe(.childAdded, with: { (snapshot) -> Void in
      /*label.text = "Added"
      label.backgroundColor = .green*/
      
      if self.updateStampSignal == false {
        self.updateStamp()
      } else {
        self.updateStampSignal = false
      }
    })
    
    
    postRef.child("rooms/\(groupID)/stampTaped/\(indexPathInfo)").observe(.childAdded, with: { (snapshot) -> Void in
      
      self.updateStampTaped()
      
    })
    
    
    postRef.child("rooms/\(groupID)/CGPoint/\(indexPathInfo)").observe(.childChanged, with: { (snapshot) -> Void in
      /*label.text = "Edited"
      label.backgroundColor = .yellow
      */
      if self.updateCGPointSignal == false {
        if self.noUpdateSignal != true {
          self.updateCGpoint()
        }
      }  else {
        self.updateCGPointSignal = false
      }
    })
    
    
    postRef.child("rooms/\(groupID)/CGAffineTransform/\(indexPathInfo)").observe(.childChanged, with: { (snapshot) -> Void in
     /* label.text = "Edited"
      label.backgroundColor = .yellow*/
      
      if self.updateCGAffineTransformSignal == false {
        if self.noUpdateSignal == false {
          self.updateCGAffineTransform()
        }
      }  else {
        self.updateCGAffineTransformSignal = false
      }
    })
    
    
    
    postRef.child("rooms/\(groupID)/stampTaped/\(indexPathInfo)").observe(.childChanged, with: { (snapshot) -> Void in
      /* label.text = "Edited"
       label.backgroundColor = .yellow*/
      
      if self.stampTapedIn["\(self.tapStampNumber)"] == false {
        self.updateStampTaped()
      }
      
    })
    
    
    
    postRef.child("rooms/\(groupID)/stamps/\(indexPathInfo)").observe(.childRemoved, with: { (snapshot) -> Void in
      /*label.text = "Removed"
       label.backgroundColor = .red*/
      
      if self.updateRemoveSignal == false {
        self.removeStamp()
        
      }  else {
        self.updateRemoveSignal = false
      }
    })
  }
  
  
  var tempItems = [NSDictionary]()
  func updateStamp() {
    
    let dataBase = Database.database().reference()
    
    dataBase.child("rooms/\(groupID)/stamps/\(indexPathInfo)").observe(.value) { (snapshot, error) in
      
      if (snapshot.value as! NSObject != NSNull()) {
        
        
        for item in(snapshot.children) {
          
          let child = item as! DataSnapshot
          let dict = child.value
          self.tempItems.append(dict as! NSDictionary)
          
        }
        
        var stampCountData = String()
        var stampInfoData = String()
        var CGPointData = String()
        var CGAffineTransformData = String()
        
        if self.tempItems.last!["stampInfo"] != nil {
          stampCountData = self.tempItems.last!["stampCount"] as! String
          stampInfoData = self.tempItems.last!["stampInfo"] as! String
          CGPointData = self.tempItems.last!["CGPoint"] as! String
          CGAffineTransformData = self.tempItems.last!["CGAffineTransform"] as! String
        
          //後から追加された時
          if stampCount == Int(stampCountData)! && stampCount != 0 || self.zeroCheck == true {
            
            self.zeroCheck = false
            
            if self.tempItems.last!["stampName"] != nil {
              
              self.stampImage = UIImage(named: self.tempItems.last!["stampName"] as! String)!
              
              let stampSize = self.stampImage.size
              let stampImageView = UIImageView()
              
              stampImageView.frame.size = stampSize
              
              //stampImageView.center = CGPoint(x: self.editImage.frame.size.width / 2, y: self.editImage.frame.size.height / 2)
              stampImageView.center = CGPoint(x: self.stampImageView.frame.size.width / 2, y: self.stampImageView.frame.size.height / 2)
              
              stampImageView.image = self.stampImage
              
              stampImageView.isUserInteractionEnabled = true
              
              let panGesture = UIPanGestureRecognizer(target:self, action: #selector(self.handlePanGesture))
              panGesture.delegate = self
              stampImageView.addGestureRecognizer(panGesture)
              
              let rotationGesture = UIRotationGestureRecognizer(target:self, action: #selector(self.rotateLabel))
              rotationGesture.delegate = self
              stampImageView.addGestureRecognizer(rotationGesture)
              
              let pinchGesture = UIPinchGestureRecognizer(target:self, action: #selector(self.pinchStamp))
              pinchGesture.delegate = self
              stampImageView.addGestureRecognizer(pinchGesture)
              
              
              //self.stampCount = Int(stampCountData)!
              stampImageView.tag = Int(stampCountData)!
              stampCount = Int(stampCountData)! + 1
              //self.firstTimeGesture.append(false)
              self.stampImageView.addSubview(stampImageView)
              //self.editImage.addSubview(stampImageView)
              
              if firstTimeGesture.count < stampCount {
                //self.firstTimeGesture.append(false)
                firstTimeGesture[stampCountData] = false
              }
              
              let stampInfomationValues = [String](stampInfomation.values)
              if stampInfomationValues.contains(stampInfoData) != true {
              
                stampInfomation[stampCountData] = stampInfoData
                self.stampTapedIn[stampCountData] = false
                //self.stampTapedIn.append(false)
                
                stampImageView.center = CGPointFromString(CGPointData)
                stampImageView.transform = CGAffineTransformFromString(CGAffineTransformData)
                
                
              }
              
            } else {
              
              let stampLabel = UILabel()
              
              stampLabel.numberOfLines = 0
              
              stampLabel.text = (self.tempItems.last!["labelText"] as! String)
              stampLabel.font = UIFont.systemFont(ofSize: 50)
              stampLabel.sizeToFit()
              stampLabel.isUserInteractionEnabled = true
              
              let panGesture = UIPanGestureRecognizer(target:self, action: #selector(self.handlePanGesture))
              panGesture.delegate = self
              stampLabel.addGestureRecognizer(panGesture)
              
              let rotationGesture = UIRotationGestureRecognizer(target:self, action: #selector(self.rotateLabel))
              rotationGesture.delegate = self
              stampLabel.addGestureRecognizer(rotationGesture)
              
              let pinchGesture = UIPinchGestureRecognizer(target:self, action: #selector(self.pinchStamp))
              pinchGesture.delegate = self
              stampLabel.addGestureRecognizer(pinchGesture)
              
              
              stampLabel.backgroundColor = UIColor.clear
              let labelColorNumber = self.colorAssetName.index(of: (self.tempItems.last!["colorInfo"] as! String))
              stampLabel.textColor = self.colorAsset[labelColorNumber!]
              
              let stampLabelCenterX = self.editImage.frame.size.width / 2
              let stampLabelCenterY = self.editImage.frame.size.height / 2
              stampLabel.center = CGPoint(x: stampLabelCenterX, y: stampLabelCenterY)
              
              //self.stampCount = Int(stampCountData)!
              stampLabel.tag = Int(stampCountData)!
              stampCount = Int(stampCountData)! + 1
              //self.firstTimeGesture.append(false)
              self.stampImageView.addSubview(stampLabel)
              //self.editImage.addSubview(stampLabel)
              
              if firstTimeGesture.count < stampCount {
                //self.firstTimeGesture.append(false)
                firstTimeGesture[stampCountData] = false
              }
              
              let stampInfomationValues = [String](stampInfomation.values)
              if stampInfomationValues.contains(stampInfoData) != true {
                stampInfomation[stampCountData] = stampInfoData
                self.stampTapedIn[stampCountData] = false
                //self.stampTapedIn.append(false)
                
                
                stampLabel.center = CGPointFromString(CGPointData)
                stampLabel.transform = CGAffineTransformFromString(CGAffineTransformData)
                
              }
            }
            
            
            //最初に開いた時
          } else if stampCount == 0 && self.zeroCheck == false {
            //self.showIndicator()
            
            for items in self.tempItems {
              
              let stampCountData2 = items["stampCount"] as! String
              let stampInfoData2 = items["stampInfo"] as! String            //取得できなかったらスタンプ消すほうが安全
              let CGPointData2 = items["CGPoint"] as! String
              let CGAffineTransformData2 = items["CGAffineTransform"] as! String
              
              if items["stampName"] != nil {
                
                self.stampImage = UIImage(named: items["stampName"] as! String)!
                
                let stampSize = self.stampImage.size
                let stampImageView = UIImageView()
                
                stampImageView.frame.size = stampSize
                
                //stampImageView.center = CGPoint(x: self.editImage.frame.size.width / 2, y: self.editImage.frame.size.height / 2)
                stampImageView.center = CGPoint(x: self.stampImageView.frame.size.width / 2, y: self.stampImageView.frame.size.height / 2)
                
                stampImageView.image = self.stampImage
                
                stampImageView.isUserInteractionEnabled = true
                
                let panGesture = UIPanGestureRecognizer(target:self, action: #selector(self.handlePanGesture))
                panGesture.delegate = self
                stampImageView.addGestureRecognizer(panGesture)
                
                let rotationGesture = UIRotationGestureRecognizer(target:self, action: #selector(self.rotateLabel))
                rotationGesture.delegate = self
                stampImageView.addGestureRecognizer(rotationGesture)
                
                let pinchGesture = UIPinchGestureRecognizer(target:self, action: #selector(self.pinchStamp))
                pinchGesture.delegate = self
                stampImageView.addGestureRecognizer(pinchGesture)
                
                //self.stampCount = Int(stampCountData2)!
                stampImageView.tag = Int(stampCountData2)!
                stampCount = Int(stampCountData)! + 1
                //self.firstTimeGesture.append(false)
                self.stampImageView.addSubview(stampImageView)
                //self.editImage.addSubview(stampImageView)
                
                if firstTimeGesture.count < stampCount {
                  //self.firstTimeGesture.append(false)
                  firstTimeGesture[stampCountData2] = false
                }
                
                //print(stampInfomation)
                let stampInfomationValues = [String](stampInfomation.values)
                if stampInfomationValues.contains(stampInfoData2) != true {
                  stampInfomation[stampCountData2] = stampInfoData2
                  //self.stampTapedIn.append(false)
                  self.stampTapedIn[stampCountData2] = false
                  
                  stampImageView.center = CGPointFromString(CGPointData2)
                  stampImageView.transform = CGAffineTransformFromString(CGAffineTransformData2)
                  
                }
                
              } else {
                let stampLabel = UILabel()
                
                stampLabel.numberOfLines = 0
                
                stampLabel.text = (items["labelText"] as! String)
                stampLabel.font = UIFont.systemFont(ofSize: 50)
                stampLabel.sizeToFit()
                stampLabel.isUserInteractionEnabled = true
                
                let panGesture = UIPanGestureRecognizer(target:self, action: #selector(self.handlePanGesture))
                panGesture.delegate = self
                stampLabel.addGestureRecognizer(panGesture)
                
                let rotationGesture = UIRotationGestureRecognizer(target:self, action: #selector(self.rotateLabel))
                rotationGesture.delegate = self
                stampLabel.addGestureRecognizer(rotationGesture)
                
                let pinchGesture = UIPinchGestureRecognizer(target:self, action: #selector(self.pinchStamp))
                pinchGesture.delegate = self
                stampLabel.addGestureRecognizer(pinchGesture)
                
                
                stampLabel.backgroundColor = UIColor.clear
                let labelColorNumber = self.colorAssetName.index(of: (items["colorInfo"] as! String))
                stampLabel.textColor = self.colorAsset[labelColorNumber!]
                
                let stampLabelCenterX = self.editImage.frame.size.width / 2
                let stampLabelCenterY = self.editImage.frame.size.height / 2
                
                stampLabel.center = CGPoint(x: stampLabelCenterX, y: stampLabelCenterY)
                
                //self.stampCount = Int(stampCountData2)!
                stampLabel.tag = Int(stampCountData2)!
                stampCount = Int(stampCountData)! + 1
                //self.firstTimeGesture.append(false)
                self.stampImageView.addSubview(stampLabel)
                //self.editImage.addSubview(stampLabel)
                
                if firstTimeGesture.count < stampCount {
                  //self.firstTimeGesture.append(false)
                  firstTimeGesture[stampCountData2] = false
                  //self.stampTapedIn.append(false)
                  self.stampTapedIn[stampCountData2] = false
                }
                
                let stampInfomationValues = [String](stampInfomation.values)
                if stampInfomationValues.contains(stampInfoData2) != true {
                  stampInfomation[stampCountData2] = stampInfoData2
                  //self.stampTapedIn.append(false)
                  self.stampTapedIn[stampCountData2] = false
                  
                  stampLabel.center = CGPointFromString(CGPointData2)
                  stampLabel.transform = CGAffineTransformFromString(CGAffineTransformData2)
                  
                
                }
              }
            }
          }
        }
      }
    }
  }
  
  
  var zeroCheck = false
  
  func removeStamp() {
    var removeKeys = String()
    
    let removeDatabase = Database.database().reference()
    removeDatabase.child("rooms/\(groupID)/removeKey/\(indexPathInfo)").observe(.value, with: { (snapshot) in
      if (snapshot.value as! NSObject != NSNull()) {
        
        removeKeys = snapshot.value as! String
        
      }
    })
    
    //let stamps = editImage.viewWithTag(stampCount - 1)
    let stamps = stampImageView.viewWithTag(Int(removeKeys)!)
    stamps?.removeFromSuperview()
    
    //stampCount -= 1
    
    
    if stampCount == 0 {
      zeroCheck = true
      
      firstTimeGesture = [String:Bool]()
      stampInfomation = [String:String]()
    }
    
    //print(firstTimeGesture)
    if firstTimeGesture.isEmpty != true {
      firstTimeGesture.removeValue(forKey: removeKeys)
    }
    
    if stampInfomation.isEmpty != true {
      //let stampInfomationKey = [String](stampInfomation.keys)
      //print(removeKey)
      stampInfomation.removeValue(forKey: removeKeys)
    }
    
    if stampTapedIn.isEmpty != true {
      //stampTapedIn.removeLast()
      stampTapedIn.removeValue(forKey: removeKeys)
    }
    
    if stampTapedOut.isEmpty != true {
      stampTapedOut.removeValue(forKey: removeKeys)
    }
    
    if self.tempItems.isEmpty != true {
      self.tempItems.removeLast()
    }
  }
  
  
  
  func updateCGpoint() {
    
    let dataBase = Database.database().reference()
    
    dataBase.child("rooms/\(groupID)/CGPoint/\(indexPathInfo)")/*.queryLimited(toLast: UInt(stampCount))*/.observe(DataEventType.value, with: { (snapshot) in
      if (snapshot.value as! NSObject != NSNull()) {
        
        let snap = snapshot.value as! [String:String]
        if snap.count == stampInfomation.count {
          
          let stampInfomationValues = [String](stampInfomation.values)
          
        for points in 0..<snap.count {
            //let stampViews = self.editImage.viewWithTag(points)
          let stampViews = self.stampImageView.viewWithTag(points)
          
            let receptionRatio = CGPoint.receptionScreenRatioCalculation(CGPointFromString(snap[stampInfomationValues[points]]!).x, CGPointFromString(snap[stampInfomationValues[points]]!).y)
          
            stampViews?.center = receptionRatio
          }
        }
      }
    })
  }
  
  
  func updateCGAffineTransform() {
    
    let dataBase = Database.database().reference()
    
    dataBase.child("rooms/\(groupID)/CGAffineTransform/\(indexPathInfo)")/*.queryLimited(toLast: UInt(stampCount))*/.observe(DataEventType.value, with: { (snapshot) in
      if (snapshot.value as! NSObject != NSNull()) {
        
        let snap = snapshot.value as! [String:String]
        if snap.count == stampInfomation.count {
          
          let stampInfomationValues = [String](stampInfomation.values)
          
        for points in 0..<snap.count {
            //let stampViews = self.editImage.viewWithTag(points)
          let stampViews = self.stampImageView.viewWithTag(points)
          
          
            stampViews?.transform = CGAffineTransformFromString(snap[stampInfomationValues[points]]!)
          }
        }
      }
    })
  }
  
  
  func updateStampTaped() {
    let dataBase = Database.database().reference()
    
    dataBase.child("rooms/\(groupID)/stampTaped/\(indexPathInfo)").observe(DataEventType.value, with: { (snapshot) in
      if (snapshot.value as! NSObject != NSNull()) {
        
        let snap = snapshot.value as! [String:Bool]
        
        //let snapValue = [Bool](snap.values)
        self.stampTapedOut = snap
        self.stampTapedIn = snap
        
        let stampTapedOutValues = [Bool](self.stampTapedOut.values)
        
        /*if stampTapedOutValues.index(of: false) != nil {
          self.stampReturnSetting.isEnabled = false
        } else if stampTapedOutValues.index(of: true) != nil {
          self.stampReturnSetting.isEnabled = true
        }*/
        for num in 0..<stampInfomation.count
        {
          //let stampViews = self.editImage.viewWithTag(num)
          let stampViews = self.stampImageView.viewWithTag(num)
          
          stampViews?.isUserInteractionEnabled = stampTapedOutValues[num]
          
        }
      }
    })
  }
  
  
  func tapedInChanged() {
    
    for num in 0..<self.stampTapedIn.count {
      
      if self.stampTapedIn["\(num)"] != false {
        
        self.stampTapedIn["\(num)"] = false
        
      }
      
    }
    
  }
  
  
  func viewSizeLoad() {
    editImage.frame = CGRect(x: 0, y: (115/667) * self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.width)
    stampImageView.frame = CGRect(x: 0, y: (115/667) * self.view.frame.size.height, width: self.view.frame.size.width, height: (557/667) * self.view.frame.size.height)
    
    stapmActionSetting.frame = CGRect(x: (205/375) * self.view.frame.size.width, y: (75/667) * self.view.frame.size.height, width: 30, height: 30)
    drawStampSetting.frame = CGRect(x: (270/375) * self.view.frame.size.width, y: (75/667) * self.view.frame.size.height, width: 30, height: 30)
    textStampSetting.frame = CGRect(x: (325/375) * self.view.frame.size.width, y: (75/667) * self.view.frame.size.height, width: 30, height: 30)
    imageSaveSetting.frame = CGRect(x: (10/375) * self.view.frame.size.width, y: (75/667) * self.view.frame.size.height, width: 30, height: 30)
    //editButtonSetting.frame = CGRect(x: (324/375) * self.view.frame.size.width, y: 20/*(20/667) * self.view.frame.size.height*/, width: 31, height: 30)
    backViewButtonSetting.frame = CGRect(x: 20/*(20/375) * self.view.frame.size.width*/, y: 25/*(25/667) * self.view.frame.size.height*/, width: 15, height: 15)
    backViewButtonSetting2.frame = CGRect(x: (15/375) * self.view.frame.size.width, y: (20/667) * self.view.frame.size.height, width: 30, height: 30)
    //view1.frame = CGRect(x: 0, y: 58/*(58/667) * self.view.frame.size.height*/, width: self.view.frame.size.width, height: 0.5)
    titleLabel.frame = CGRect(x: self.view.frame.size.width / 2, y: 13/*(13/667) * self.view.frame.size.height*/, width: 69, height: 39)
    titleLabel.text = projectList["Title"]
    titleLabel.sizeToFit()
    titleLabel.frame = CGRect(x: (self.view.frame.size.width / 2) - (titleLabel.frame.size.width / 2), y: 13/*(13/667) * self.view.frame.size.height*/, width: titleLabel.frame.size.width, height: 39)
    
    deleteImage.frame = CGRect(x: (45/375) * self.view.frame.size.width, y: (520/667) * self.view.frame.size.height, width: (285/375) * self.view.frame.size.width, height: (100/667) * self.view.frame.size.height)
    stampWhite.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    stampCollection.frame = CGRect(x: 0, y: (58.5/667) * self.view.frame.size.height, width: self.view.frame.size.width, height: (609/667) * self.view.frame.size.height)
    stampWhiteBackSetting.frame = CGRect(x: 20/*(20/375) * self.view.frame.size.width*/, y: 25/*(25/667) * self.view.frame.size.height*/, width: 15, height: 15)
    stampWhiteBackSetting2.frame = CGRect(x: (15/375) * self.view.frame.size.width, y: (20/667) * self.view.frame.size.height, width: 30, height: 30)
    
    textWhite.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    textColorCollection.frame = CGRect(x: 0, y: (450/667) * self.view.frame.size.height, width: self.view.frame.size.width, height: 30)
    textDoneSetting.frame = CGRect(x: (324/375) * self.view.frame.size.width, y: 20/*(20/667) * self.view.frame.size.height*/, width: 31, height: 30)
    textField.frame = CGRect(x: 0, y: (277/667) * self.view.frame.size.height, width: self.view.frame.size.width, height: 300)
    topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 58)
    textWhiteBackSetting.frame = CGRect(x: 20/*(20/375) * self.view.frame.size.width*/, y: 25/*(25/667) * self.view.frame.size.height*/, width: 15, height: 15)
    textWhiteBackSetting2.frame = CGRect(x: (15/375) * self.view.frame.size.width, y: (20/667) * self.view.frame.size.height, width: 30, height: 30)

  }

  
  
  
  //画像編集
  @IBOutlet weak var editImage: UIImageView!
  
  
  @IBOutlet weak var stampImageView: UIImageView!
  
  @IBOutlet weak var deleteImage: UIImageView!
  
  @IBOutlet weak var imageSaveSetting: UIButton!
  
  
  
  @IBOutlet weak var stapmActionSetting: UIButton!
  @IBOutlet weak var textStampSetting: UIButton!
  @IBOutlet weak var drawStampSetting: UIButton!
  
  @IBOutlet weak var backViewButtonSetting: UIButton!
  @IBOutlet weak var backViewButtonSetting2: UIButton!
  
  @IBOutlet weak var titleLabel: UILabel!
  
  
  
  
  @IBAction func backViewButton(_ sender: Any) {
    let imagesInfoDatabase = Database.database().reference()
    /*let imageInfo: NSDictionary = ["\(indexPathInfo)": false]
    imagesInfoDatabase.child("rooms/\(groupID)/imagesInfo").updateChildValues(imageInfo as! [AnyHashable : Any])
    projectImageInfo[indexPathInfo] = false*/
    
    
    imagesInfoDatabase.child("rooms/\(groupID)/editMember/\(uidData)").setValue("100")
    
    /*if projectEditMember[indexPathInfo].index(of: uidData) != nil {
      projectEditMember[indexPathInfo].remove(at: projectEditMember[indexPathInfo].index(of: uidData)!)
    }*/
    
    for _ in 0..<stampCount {
      //let stamps = editImage.subviews
      let stamps = stampImageView.subviews
      
      stamps.last?.removeFromSuperview()
    }
    
    /*stampCount = 0
    firstTimeGesture = [Bool]()
    stampInfomation = [String]()*/
    
    
    self.dismiss(animated: true, completion: nil)
  }
  
  
  
  
  @IBAction func stampAction(_ sender: Any) {
    stampWhite.isHidden = false
    textWhite.isHidden = true
    stampCollection.isHidden = false
  }
  
  
  @IBAction func drawStampAction(_ sender: Any) {
    
    stampImageView.isHidden = true
    
    deleteImage.isHidden = true
    
    imageSaveSetting.isHidden = true
    
    stapmActionSetting.isHidden = true
    textStampSetting.isHidden = true
    drawStampSetting.isHidden = true
    
    backViewButtonSetting.isHidden = true
    backViewButtonSetting2.isHidden = true
    //view1.isHidden = true
    titleLabel.isHidden = true
    
  }
  
  
  @IBAction func drawReturnAction(_ sender: Any) {
    
    stampImageView.isHidden = false
    
    deleteImage.isHidden = false
    
    imageSaveSetting.isHidden = false
    
    stapmActionSetting.isHidden = false
    textStampSetting.isHidden = false
    drawStampSetting.isHidden = false
    
    backViewButtonSetting.isHidden = false
    backViewButtonSetting2.isHidden = false
    //view1.isHidden = false
    titleLabel.isHidden = false
    
    editImage.isUserInteractionEnabled = false
  }
  
  
  @IBAction func drawDoneAction(_ sender: Any) {
    
    stampImageView.isHidden = false
    
    deleteImage.isHidden = false
    
    imageSaveSetting.isHidden = false
    
    
    
    stapmActionSetting.isHidden = false
    textStampSetting.isHidden = false
    drawStampSetting.isHidden = false
    
    backViewButtonSetting.isHidden = false
    backViewButtonSetting2.isHidden = false
    //view1.isHidden = false
    titleLabel.isHidden = false
    
    editImage.isUserInteractionEnabled = false
  }
  
  
  @IBAction func imageSave(_ sender: Any) {
    
    saveImageWithStamps()
    
  }
  
  
  private func displayAlert(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    
    alertController.addAction(action)
    
    present(alertController, animated: true, completion: nil)
  }
  
  
  private func saveImageWithStamps() {
    
    //editImage.gestureRecognizers?.removeAll()
    let dataBase = Database.database().reference()
    dataBase.child("rooms/\(groupID)/stamps/\(indexPathInfo)").observe(.value) { (snapshot, error) in
      
      if (snapshot.value as! NSObject != NSNull()) {
        
        self.tempItems = [NSDictionary]()
        for item in(snapshot.children) {
          
          let child = item as! DataSnapshot
          let dict = child.value
          self.tempItems.append(dict as! NSDictionary)
          
        }
        
        let saveImageView = UIImageView()
        saveImageView.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)
        saveImageView.image = projectImage[indexPathInfo]
        
        //test
        for items in self.tempItems {
          
          
          //let stampCountData = items["stampCount"] as! String
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
            
            //stampImageView.tag = Int(stampCountData)!
            //self.editImage.addSubview(stampImageView)
            saveImageView.addSubview(stampImageView)
            
            
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
            
            //stampLabel.tag = Int(stampCountData)!
            
            //self.editImage.addSubview(stampLabel)
            saveImageView.addSubview(stampLabel)
          }
        }
        
        //UIGraphicsBeginImageContextWithOptions(self.editImage.frame.size, false, 0.0)
        UIGraphicsBeginImageContextWithOptions(saveImageView.frame.size, false, 0.0)
        
        /*let fakeImage = UIGraphicsGetImageFromCurrentImageContext()!
         UIImageWriteToSavedPhotosAlbum(fakeImage, self, #selector(self.showResultOfSaveImage(_:didFinishSavingWithError:contextInfo:)), nil)
         UIGraphicsEndImageContext()*/
        guard let context = UIGraphicsGetCurrentContext() else {
          self.displayAlert(title: "エラー", message: "画像の保存に失敗しました")
          return
        }
        
        self.editImage.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
          self.displayAlert(title: "エラー", message: "画像の保存に失敗しました")
          return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.imageError(image:didFinishSaveImageWithError:contextInfo:)), nil)
        UIGraphicsEndImageContext()
        
      }
    }
  }
  
  
    @objc func imageError(image: UIImage, didFinishSaveImageWithError error: NSError?, contextInfo: UnsafeMutableRawPointer) {
      if error != nil {
        print(error?.code as Any)
      }
      switch error {
      case let .some(error):
        displayAlert(title: "エラー", message: error.localizedDescription)
        
      case .none:
        displayAlert(title: "成功", message: "画像が保存されました！")
      }
    }
  
  
  @IBAction func textStamp(_ sender: Any) {
    textField.text = ""
    stampWhite.isHidden = true
    textWhite.isHidden = false
    textField.becomeFirstResponder()
    textField.textColor = UIColor.white
    colorInfo = UIColor.white
    textField.center = CGPoint(x:self.view.frame.size.width/2, y:((170/667) * self.view.frame.size.height) + (self.view.frame.size.width/2))
  }
  
  
  
  @IBAction func textFieldAction(_ sender: Any) {
    textField.sizeToFit()
    textField.center = CGPoint(x:self.view.frame.size.width/2, y:((170/667) * self.view.frame.size.height) + (self.view.frame.size.width/2))
  }
  
  
  @IBAction func editButton(_ sender: Any) {
    
    let imagesInfoDatabase = Database.database().reference()
    /*let imageInfo: NSDictionary = ["\(indexPathInfo)": false]
    imagesInfoDatabase.child("rooms/\(groupID)/imagesInfo").updateChildValues(imageInfo as! [AnyHashable : Any])*/
    //projectImageInfo[indexPathInfo] = false
    
    imagesInfoDatabase.child("rooms/\(groupID)/editMember/\(uidData)").setValue("100")
    if projectEditMember[uidData] != nil {
      projectEditMember[uidData] = "100"
    }
    
    
    //画質を維持するためにUIGraphicsBeginImageContextではなくUIGraphicsBeginImageContextWithOptionsを使う
    UIGraphicsBeginImageContextWithOptions(editImage.frame.size, false, 0.0)
    editImage.layer.render(in: UIGraphicsGetCurrentContext()!)
    
    //editした画像をに表示されている画像をに格納
    projectImage[indexPathInfo] = UIGraphicsGetImageFromCurrentImageContext()!
    
    UIGraphicsEndImageContext()
    
    let projectVC = presentingViewController as! ProjectViewController
    
    projectVC.slideCollection.reloadData()
    projectVC.largeCollection.reloadData()
    
    let dataBase = Database.database().reference()
    
    var data: NSData = NSData()
    let images = projectImage[indexPathInfo]
    
    data = UIImageJPEGRepresentation(images, 1.0)! as NSData
    let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as String
    let imageData: NSDictionary = ["\(indexPathInfo)": base64String]
    dataBase.child("rooms/\(groupID)/images").updateChildValues(imageData as! [AnyHashable : Any])
    
    
    for _ in 0..<stampCount {
      let stamps = stampImageView.subviews
      //let stamps = editImage.subviews
      
      stamps.last?.removeFromSuperview()
    }
    
    
    
    self.dismiss(animated: true, completion: nil)
  }
  
  
  @IBOutlet weak var stampWhite: UIView!
  @IBOutlet weak var stampCollection: UICollectionView!
  @IBOutlet weak var stampWhiteBackSetting: UIButton!
  @IBOutlet weak var stampWhiteBackSetting2: UIButton!
  
  
  @IBAction func stampWhiteBack(_ sender: Any) {
    stampWhite.isHidden = true
  }
  
  
  var stampImage = UIImage()
  
  let stampArray = [UIImage(named: "star1"), UIImage(named: "star2"), UIImage(named: "starSet2"), UIImage(named: "heart1"), UIImage(named: "heart2"), UIImage(named: "heart3"), UIImage(named: "heart5"), UIImage(named: "p"), UIImage(named: "いい日"), UIImage(named: "いい日白"), UIImage(named: "ふわふわ白"), UIImage(named: "ふわふわ白_1"), UIImage(named: "ふわふわ黒"), UIImage(named: "ふわふわ黒_1"), UIImage(named: "よき日"), UIImage(named: "素材"), UIImage(named: "綺麗"), UIImage(named: "綺麗黒"), UIImage(named: "boom"), UIImage(named: "bang"), UIImage(named: "fusaiyou"), UIImage(named: "goukaku"), UIImage(named: "hi"), UIImage(named: "hugoukaku"), UIImage(named: "ka"), UIImage(named: "kakunin"), UIImage(named: "saiyou"), UIImage(named: "sikyu"), UIImage(named: "sumi")]
  let stampArrayName = ["star1", "star2", "starSet2", "heart1", "heart2", "heart3", "heart5", "p", "いい日", "いい日白", "ふわふわ白", "ふわふわ白_1", "ふわふわ黒", "ふわふわ黒_1", "よき日", "素材", "綺麗", "綺麗黒", "boom", "bang", "fusaiyou", "goukaku", "hi", "hugoukaku", "ka", "kakunin", "saiyou", "sikyu", "sumi"]
  var colorInfoData = "white"
  
  
  @IBOutlet weak var textWhite: UIView!
  @IBOutlet weak var textColorCollection: UICollectionView!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var textDoneSetting: UIButton!
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var textWhiteBackSetting: UIButton!
  @IBOutlet weak var textWhiteBackSetting2: UIButton!
  
  
  var colorInfo = UIColor()
  let colorAsset = [UIColor.white, UIColor.black, UIColor.darkGray, UIColor.lightGray, UIColor.gray, UIColor.brown, UIColor.red, UIColor.magenta, UIColor.green, UIColor.blue, UIColor.cyan, UIColor.yellow, UIColor.orange, UIColor.purple]
  let colorAssetName = ["white", "black", "darkGray", "lightGray", "gray", "brown", "red", "magenta", "green", "blue", "cyan", "yellow", "orange", "purple"]
  
  
  @IBAction func textWhiteBack(_ sender: Any) {
    textWhite.isHidden = true
    textWhite.resignFirstResponder()
  }
  
  
  @IBAction func textDone(_ sender: Any) {
    
    //updateStampSignal = true
    
    textWhite.isHidden = true
    
    let stampLabel = UILabel()
    
    //stampLabel.numberOfLines = 0
    
    stampLabel.text = textField.text
    stampLabel.font = UIFont.systemFont(ofSize: 50)
    stampLabel.sizeToFit()
    
    
    let stampLabelCenterX = self.editImage.frame.size.width / 2
    let stampLabelCenterY = self.editImage.frame.size.height / 2
    
    stampLabel.center = CGPoint(x: stampLabelCenterX, y: stampLabelCenterY)
    /*tapCount += 1
    stampLabel.tag = tapCount - 1
    firstTimeGesture.append(false)
    self.editImage.addSubview(stampLabel)*/
    
    let stampInfoDatabase = Database.database().reference()
    let autoId = stampInfoDatabase.child("rooms/\(groupID)/stamps/\(indexPathInfo)/").childByAutoId().key
    //stampInfomation.append(autoId)
    
    let stampLabelCenterData = NSStringFromCGPoint(CGPoint.screenRatioCalculation(stampLabelCenterX, stampLabelCenterY))
    let stampLabelTransformData = NSStringFromCGAffineTransform(CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0))
    
    
    let allData: NSDictionary = ["labelText":stampLabel.text as Any, "colorInfo": colorInfoData, "stampCount": "\(stampCount)", "stampInfo": autoId, "CGPoint": stampLabelCenterData as Any, "CGAffineTransform": stampLabelTransformData as Any]
    let CGPointData: NSDictionary = [autoId: stampLabelCenterData as Any]
    let CGAffineTransformData: NSDictionary = [autoId: stampLabelTransformData as Any]
    //let stampReloadSignal: NSDictionary = [autoId: false]
    
    stampInfoDatabase.child("rooms/\(groupID)/stamps/\(indexPathInfo)/\(autoId)").setValue(allData)
    stampInfoDatabase.child("rooms/\(groupID)/CGPoint/\(indexPathInfo)").updateChildValues(CGPointData as! [AnyHashable : Any])
    stampInfoDatabase.child("rooms/\(groupID)/CGAffineTransform/\(indexPathInfo)").updateChildValues(CGAffineTransformData as! [AnyHashable : Any])
    
    let tapDatabase = Database.database().reference()
    let stampTapedData = ["\(autoId)" : true]
    tapDatabase.child("rooms/\(groupID)/stampTaped/\(indexPathInfo)").updateChildValues(stampTapedData)
    
    //self.stampTapedIn.append(false)
    self.stampTapedIn["\(stampCount)"] = false
    /*stampInfoDatabase.child("rooms/\(groupID)/stampCGPointReloadSignal\(indexPathInfo)").updateChildValues(stampReloadSignal as! [AnyHashable : Any])
    stampInfoDatabase.child("rooms/\(groupID)/stampCGTransReloadSignal\(indexPathInfo)").updateChildValues(stampReloadSignal as! [AnyHashable : Any])*/
    
  }
  
  
  var removeKey = Int()
  // タッチ開始時のUIViewのorigin
  var orgOrigin: CGPoint!
  // タッチ開始時の親ビュー上のタッチ位置
  var orgParentPoint : CGPoint!
  @objc func handlePanGesture(_ sender: UIPanGestureRecognizer){
    
    switch sender.state {
    case UIGestureRecognizerState.began:
      // タッチ開始:タッチされたビューのoriginと親ビュー上のタッチ位置を記録しておく
      orgOrigin = sender.view?.center
      orgParentPoint = sender.translation(in: self.view)
      
      
      stampTapedIn["\((sender.view?.tag)!)"] = true
      tapStampNumber = (sender.view?.tag)!
      let tapDatabase = Database.database().reference()
      //print(stampInfomation)
      let stampTapedData = ["\(stampInfomation["\((sender.view?.tag)!)"]!)" : false]
      tapDatabase.child("rooms/\(groupID)/stampTaped/\(indexPathInfo)").updateChildValues(stampTapedData)
      
      
      break
      
    case UIGestureRecognizerState.changed:
      // 現在の親ビュー上でのタッチ位置を求める
      let newParentPoint = sender.translation(in: self.stampImageView)
      // パンジャスチャの継続:タッチ開始時のビューのoriginにタッチ開始からの移動量を加算する
      sender.view?.center = orgOrigin + newParentPoint - orgParentPoint
      
      
      
      let stampInfoDatabase = Database.database().reference()
      
      let stampCenterData = NSStringFromCGPoint(CGPoint.screenRatioCalculation((sender.view?.center.x)!, (sender.view?.center.y)!))
      
      if stampInfomation.isEmpty != true {
        let data: NSDictionary = ["\(stampInfomation[String((sender.view?.tag)!)]!)": stampCenterData as Any]
        stampInfoDatabase.child("rooms/\(groupID)/CGPoint/\(indexPathInfo)").updateChildValues(data as! [AnyHashable : Any])
      }
      
      updateCGPointSignal = true
      
      
      if (sender.view?.center.y)! >= self.stampImageView.frame.size.height - 177 {
        deleteImage.image = UIImage(named: "削除赤")
      } else {
        deleteImage.image = UIImage(named: "削除白")
      }
      /*let signal: NSDictionary = ["\(stampInfomation[(sender.view?.tag)!])": true]
      stampInfoDatabase.child("rooms/\(groupID)/stampCGPointReloadSignal/\(indexPathInfo)").updateChildValues(signal as! [AnyHashable : Any])*/
      
      break
      
    case UIGestureRecognizerState.ended:
      
      if (sender.view?.center.y)! >= self.stampImageView.frame.size.height - 177 {
        
        if stampCount != 0 {
          
          
          
          let stampDatabase = Database.database().reference()
          
          
          if stampInfomation.isEmpty != true {
            stampDatabase.child("rooms/\(groupID)/stamps/\(indexPathInfo)/\(stampInfomation[String((sender.view?.tag)!)]!)").removeValue()
            stampDatabase.child("rooms/\(groupID)/CGPoint/\(indexPathInfo)/\(stampInfomation[String((sender.view?.tag)!)]!)").removeValue()
            stampDatabase.child("rooms/\(groupID)/CGAffineTransform//\(indexPathInfo)/\(stampInfomation[String((sender.view?.tag)!)]!)").removeValue()
            stampDatabase.child("rooms/\(groupID)/stampTaped/\(indexPathInfo)/\(stampInfomation[String((sender.view?.tag)!)]!)").removeValue()
            
            removeKey = (sender.view?.tag)!
            
            let removeData = Database.database().reference()

            removeData.child("rooms/\(groupID)removeKey/\(indexPathInfo)").setValue("\(removeKey)")
            
            deleteImage.image = UIImage(named: "削除白")
            
          }
          
        }
        
      } else {
        
        let stampInfoDatabase = Database.database().reference()
        let stampCenterData = NSStringFromCGPoint(CGPoint.screenRatioCalculation((sender.view?.center.x)!, (sender.view?.center.y)!))
        let data: NSDictionary = ["CGPoint": stampCenterData as Any]
        stampInfoDatabase.child("rooms/\(groupID)/stamps/\(indexPathInfo)/\(stampInfomation[String((sender.view?.tag)!)]!)").updateChildValues(data as! [AnyHashable : Any])
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150)) {
          let tapDatabase = Database.database().reference()
          let stampTapedData = ["\(stampInfomation[String((sender.view?.tag)!)]!)" : true]
          tapDatabase.child("rooms/\(groupID)/stampTaped/\(indexPathInfo)").updateChildValues(stampTapedData)
          
          self.stampTapedIn["\(self.tapStampNumber)"] = false
        }
        
      }
      
      break
      
    default:
      break
    }
  }
  
  
  var saveAngle = CGAffineTransform()
  var saveAngleReal = CGAffineTransform()
  //回転時の呼び出しメソッド
  @objc func rotateLabel(_ sender: UIRotationGestureRecognizer) {
    
    
    if sender.state == UIGestureRecognizerState.began {
      stampTapedIn["\((sender.view?.tag)!)"] = true
      tapStampNumber = (sender.view?.tag)!
      let tapDatabase = Database.database().reference()
      let stampTapedData = ["\(stampInfomation[String((sender.view?.tag)!)]!)" : false]
      tapDatabase.child("rooms/\(groupID)/stampTaped/\(indexPathInfo)").updateChildValues(stampTapedData)
      
    }
    
    
    if firstTimeGesture["\((sender.view?.tag)!)"] == false {
      
     saveScale = (sender.view?.transform)!
     saveScaleReal = (sender.view?.transform)!
     
     saveAngle = (sender.view?.transform)!
     saveAngleReal = (sender.view?.transform)!
     
     firstTimeGesture["\((sender.view?.tag)!)"] = true
      
    } else {
      
      let nowRotate = saveAngle.rotated(by: sender.rotation)
      
      sender.view?.transform = saveScaleReal.concatenating(nowRotate)
      
      saveAngleReal = nowRotate
      
      
      if sender.state == UIGestureRecognizerState.ended {
        saveAngle = nowRotate
        
        let stampInfoDatabase = Database.database().reference()
        
        let stampTransformData = NSStringFromCGAffineTransform((sender.view?.transform)!)
        
        
        let data: NSDictionary = ["\(stampInfomation[String((sender.view?.tag)!)]!)": stampTransformData as Any]
        stampInfoDatabase.child("rooms/\(groupID)/CGAffineTransform/\(indexPathInfo)").updateChildValues(data as! [AnyHashable : Any])
        
        let data2: NSDictionary = ["CGAffineTransform": stampTransformData as Any]
        stampInfoDatabase.child("rooms/\(groupID)/stamps/\(indexPathInfo)/\(stampInfomation[String((sender.view?.tag)!)]!)").updateChildValues(data2 as! [AnyHashable : Any])
        
        updateCGAffineTransformSignal = true
        
        
        
        /*let signal: NSDictionary = ["\(stampInfomation[(sender.view?.tag)!])": true]
        stampInfoDatabase.child("rooms/\(groupID)/stampCGTransReloadSignal/\(indexPathInfo)").updateChildValues(signal as! [AnyHashable : Any])*/
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150)) {
          let tapDatabase = Database.database().reference()
          let stampTapedData = ["\(stampInfomation[String((sender.view?.tag)!)]!)" : true]
          tapDatabase.child("rooms/\(groupID)/stampTaped/\(indexPathInfo)").updateChildValues(stampTapedData)
          
          self.stampTapedIn["\(self.tapStampNumber)"] = false
        }
        
      }
    }
  }
  
  
  var saveScale = CGAffineTransform()
  var saveScaleReal = CGAffineTransform()
  @objc func pinchStamp(_ sender: UIPinchGestureRecognizer){
    
    
    if sender.state == UIGestureRecognizerState.began {
      stampTapedIn["\((sender.view?.tag)!)"] = true
      tapStampNumber = (sender.view?.tag)!
      let tapDatabase = Database.database().reference()
      
      let stampTapedData = ["\(stampInfomation[String((sender.view?.tag)!)]!)" : false]
      tapDatabase.child("rooms/\(groupID)/stampTaped/\(indexPathInfo)").updateChildValues(stampTapedData)
      
    }
    
    
    if firstTimeGesture["\((sender.view?.tag)!)"] == false {
      
      saveScale = (sender.view?.transform)!
      saveScaleReal = (sender.view?.transform)!
      
      saveAngle = (sender.view?.transform)!
      saveAngleReal = (sender.view?.transform)!
      
      firstTimeGesture["\((sender.view?.tag)!)"] = true
      
    } else {
      
      let nowPinch = saveScale.scaledBy(x: sender.scale, y: sender.scale)
      
      sender.view?.transform = saveAngleReal.concatenating(nowPinch)
      
      saveScaleReal = nowPinch
      
      
      
      if sender.state == UIGestureRecognizerState.ended {
        saveScale = nowPinch
        
        
        let stampInfoDatabase = Database.database().reference()
        
        let stampTransformData = NSStringFromCGAffineTransform((sender.view?.transform)!)
        
        let data: NSDictionary = ["\(stampInfomation[String((sender.view?.tag)!)]!)": stampTransformData as Any]
        stampInfoDatabase.child("rooms/\(groupID)/CGAffineTransform/\(indexPathInfo)").updateChildValues(data as! [AnyHashable : Any])
        
        let data2: NSDictionary = ["CGAffineTransform": stampTransformData as Any]
        stampInfoDatabase.child("rooms/\(groupID)/stamps/\(indexPathInfo)/\(stampInfomation[String((sender.view?.tag)!)]!)").updateChildValues(data2 as! [AnyHashable : Any])
        
        updateCGAffineTransformSignal = true
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150)) {
          let tapDatabase = Database.database().reference()
          let stampTapedData = ["\(stampInfomation[String((sender.view?.tag)!)]!)" : true]
          tapDatabase.child("rooms/\(groupID)/stampTaped/\(indexPathInfo)").updateChildValues(stampTapedData)
          
          self.stampTapedIn["\(self.tapStampNumber)"] = false
        }
        
      }
      
    }
  }
  
  
  //リコグナイザーの同時検知を許可するメソッド
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  
  func collectionCellLayout() {
    
    let layout2 = UICollectionViewFlowLayout()
    layout2.itemSize = CGSize(width: ((self.view.frame.size.width / 2) - 10), height: ((self.view.frame.size.width / 2) - 10))//Cellの大きさ
    layout2.minimumInteritemSpacing = 10 //アイテム同士の余白
    layout2.minimumLineSpacing = 10 //セクションとアイテムの余白
    
    stampCollection.collectionViewLayout = layout2 //layoutの更新
  }
  
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView.tag == 3 {
      return stampArray.count
    } else {
      return colorAsset.count
    }
  }
  
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch collectionView.tag {
    case 3:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StampCell", for: indexPath) as! StampCollectionViewCell
      cell.stampImages.image = stampArray[indexPath.row]
      return cell
      
    default:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! StampCollectionViewCell
      cell.textColorImages.backgroundColor = colorAsset[indexPath.row]
      return cell
    }
  }
  
  
  func collectionView(_ collectionView : UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch collectionView.tag {
    case 3:
      
      //updateStampSignal = true
      
      //stampImage = stampArray[indexPath.row]!
      let stampName = stampArrayName[indexPath.row]
      
      
      let stampSize = stampImage.size
      let stampImageView = UIImageView()
      
      stampImageView.frame.size = stampSize
      
      //let stampImageCenterX = self.editImage.frame.size.width / 2
      //let stampImageCenterY = self.editImage.frame.size.height / 2
      let stampImageCenterX = self.stampImageView.frame.size.width / 2
      let stampImageCenterY = self.stampImageView.frame.size.height / 2
      
      //stampImageView.center = CGPoint(x: self.editImage.frame.size.width / 2, y: self.editImage.frame.size.height / 2)
      stampImageView.center = CGPoint(x: self.stampImageView.frame.size.width / 2, y: self.stampImageView.frame.size.height / 2)
      
      
      
      let stampInfoDatabase = Database.database().reference()
      let autoId = stampInfoDatabase.child("rooms/\(groupID)/stamps/\(indexPathInfo)/").childByAutoId().key
      //stampInfomation.append(autoId)
      
      
      let stampImageCenterData = NSStringFromCGPoint(CGPoint.screenRatioCalculation(stampImageCenterX, stampImageCenterY))
      let stampImageTransformData = NSStringFromCGAffineTransform(CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0))
      
      
      let allData: NSDictionary = ["stampName":stampName as Any, "stampCount": "\(stampCount)", "stampInfo": autoId, "CGPoint": stampImageCenterData as Any, "CGAffineTransform": stampImageTransformData as Any]
      let CGPointData: NSDictionary = [autoId: stampImageCenterData as Any]
      let CGAffineTransformData: NSDictionary = [autoId: stampImageTransformData as Any]
      //let stampReloadSignal: NSDictionary = [autoId: false]
      
      stampInfoDatabase.child("rooms/\(groupID)/stamps/\(indexPathInfo)/\(autoId)").setValue(allData)
      stampInfoDatabase.child("rooms/\(groupID)/CGPoint/\(indexPathInfo)").updateChildValues(CGPointData as! [AnyHashable : Any])
      stampInfoDatabase.child("rooms/\(groupID)/CGAffineTransform/\(indexPathInfo)").updateChildValues(CGAffineTransformData as! [AnyHashable : Any])
      
      let tapDatabase = Database.database().reference()
      let stampTapedData = ["\(autoId)" : true]
      tapDatabase.child("rooms/\(groupID)/stampTaped/\(indexPathInfo)").updateChildValues(stampTapedData)
      //self.stampTapedIn.append(false)
      self.stampTapedIn["\(stampCount)"] = false
      /*stampInfoDatabase.child("rooms/\(groupID)/stampCGPointReloadSignal\(indexPathInfo)").updateChildValues(stampReloadSignal as! [AnyHashable : Any])
      stampInfoDatabase.child("rooms/\(groupID)/stampCGTransReloadSignal\(indexPathInfo)").updateChildValues(stampReloadSignal as! [AnyHashable : Any])*/
      
      
      stampWhite.isHidden = true
      
      
    case 4:
      colorInfo = colorAsset[indexPath.row]
      textField.textColor = colorAsset[indexPath.row]
      colorInfoData = colorAssetName[indexPath.row]
      
    default:
      break
    }
  }
}


extension Dictionary where Value: Equatable {
  func allKeysForValue(value: Value) -> [Key] {
    return self.filter({ $0.1 == value }).map({ $0.0 })
    // return self.flatMap({ $0.1 == value ? $0.0 : nil }) // こっちでもok
  }
  func keyForValue(value: Value) -> Key? {
    return allKeysForValue(value: value).first
  }
}
