//
//  DrawViewController.swift
//  firstPlink
//
//  Created by 鈴木公章 on 2018/04/20.
//  Copyright © 2018年 kimio. All rights reserved.
//

import UIKit
import Firebase

class DrawViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  
  
  
  //@IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var canvasView: UIImageView!
  @IBOutlet weak var stampView: UIImageView!
  @IBOutlet weak var editImage: UIImageView!
  @IBOutlet weak var sliderValue: UISlider!
  
  @IBOutlet weak var backViewSetting: UIButton!
  @IBOutlet weak var doneButtonSetting: UIButton!
  
  @IBOutlet weak var colorCollection: UICollectionView!
  
  var lastPoint: CGPoint?                 //直前のタッチ座標の保存用
  var lineWidth: CGFloat?                 //描画用の線の太さの保存用
  //var bezierPath = UIBezierPath()         //お絵描きに使用
  var bezierPath: UIBezierPath?           //お絵描きに使用
  var drawColor = UIColor.black               //描画色の保存用
  var currentDrawNumber = 0               //現在の表示しているは何回めのタッチか
  var saveImageArray = [UIImage]()        //Undo/Redo用にUIImageを保存
  
  //let defaultLineWidth: CGFloat = 10.0    //デフォルトの線の太さ
  let scale = CGFloat(30)                   //線の太さに変換するためにSlider値にかける係数
  
  override func viewDidLoad() {
    super.viewDidLoad()
    stampCount = 0
    zeroCheck = false
    
    //updateEdit()
    viewLoad()
    
    editImage.image = projectImage[indexPathInfo]
    self.canvasView.isUserInteractionEnabled = true
    
    //scrollView.delegate = self
    //scrollView.minimumZoomScale = 1.0                   // 最小拡大率
    //scrollView.maximumZoomScale = 4.0                   // 最大拡大率
    //scrollView.zoomScale = 1.0                          // 表示時の拡大率(初期値)
    
    prepareDrawing()                                    //お絵描き準備
    
    //self.scrollView.isUserInteractionEnabled = false
  }
  
  
  
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
      self.updateStamp()
    })
    
    
    postRef.child("rooms/\(groupID)/CGPoint/\(indexPathInfo)").observe(.childChanged, with: { (snapshot) -> Void in
      /*label.text = "Edited"
       label.backgroundColor = .yellow
       */
      self.updateCGpoint()
    })
    
    
    postRef.child("rooms/\(groupID)/CGAffineTransform/\(indexPathInfo)").observe(.childChanged, with: { (snapshot) -> Void in
      /* label.text = "Edited"
       label.backgroundColor = .yellow*/
      self.updateCGAffineTransform()
    })
    
    
    postRef.child("rooms/\(groupID)/stamps/\(indexPathInfo)").observe(.childRemoved, with: { (snapshot) -> Void in
      /*label.text = "Removed"
       label.backgroundColor = .red*/
      
      self.removeStamp()
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
          if stampCount != 0 && self.zeroCheck == true {
            
            self.zeroCheck = false
            
            if self.tempItems.last!["stampName"] != nil {
              
              let stampImage = UIImage(named: self.tempItems.last!["stampName"] as! String)!
              
              let stampSize = stampImage.size
              let stampImageView = UIImageView()
              
              stampImageView.frame.size = stampSize
              
              //stampImageView.center = CGPoint(x: self.editImage.frame.size.width / 2, y: self.editImage.frame.size.height / 2)
              stampImageView.center = CGPoint(x: self.stampView.frame.size.width / 2, y: self.stampView.frame.size.height / 2)
              
              stampImageView.image = stampImage
              
              stampImageView.isUserInteractionEnabled = true
              
              //self.stampCount = Int(stampCountData)!
              stampImageView.tag = Int(stampCountData)!
              stampCount = Int(stampCountData)! + 1
              //self.firstTimeGesture.append(false)
              self.stampView.addSubview(stampImageView)
              //self.editImage.addSubview(stampImageView)
              
              
              let stampInfomationValues = [String](stampInfomation.values)
              if stampInfomationValues.contains(stampInfoData) != true {
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
              self.stampView.addSubview(stampLabel)
              //self.editImage.addSubview(stampLabel)
              
              
              let stampInfomationValues = [String](stampInfomation.values)
              if stampInfomationValues.contains(stampInfoData) != true {
                
                
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
                
                let stampImage = UIImage(named: items["stampName"] as! String)!
                
                let stampSize = stampImage.size
                let stampImageView = UIImageView()
                
                stampImageView.frame.size = stampSize
                
                //stampImageView.center = CGPoint(x: self.editImage.frame.size.width / 2, y: self.editImage.frame.size.height / 2)
                stampImageView.center = CGPoint(x: self.stampView.frame.size.width / 2, y: self.stampView.frame.size.height / 2)
                
                stampImageView.image = stampImage
                
                stampImageView.isUserInteractionEnabled = true
                
                
                //self.stampCount = Int(stampCountData2)!
                stampImageView.tag = Int(stampCountData2)!
                stampCount = Int(stampCountData)! + 1
                //self.firstTimeGesture.append(false)
                self.stampView.addSubview(stampImageView)
                //self.editImage.addSubview(stampImageView)
                
                let stampInfomationValues = [String](stampInfomation.values)
                if stampInfomationValues.contains(stampInfoData2) != true {
                  
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
                self.stampView.addSubview(stampLabel)
                //self.editImage.addSubview(stampLabel)
                
                
                let stampInfomationValues = [String](stampInfomation.values)
                if stampInfomationValues.contains(stampInfoData2) != true {
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
    let stamps = stampView.viewWithTag(Int(removeKeys)!)
    stamps?.removeFromSuperview()
    
    //stampCount -= 1
    
    
    if stampCount == 0 {
      zeroCheck = true
      
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
            let stampViews = self.stampView.viewWithTag(points)
            
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
            let stampViews = self.stampView.viewWithTag(points)
            
            
            stampViews?.transform = CGAffineTransformFromString(snap[stampInfomationValues[points]]!)
          }
        }
      }
    })
  }
  
  
  
  @IBAction func drawButton(_ sender: Any) {
    
    //self.scrollView.isUserInteractionEnabled = true
    self.canvasView.isUserInteractionEnabled = true
    //self.editImage.isUserInteractionEnabled = true
  }
  
  @IBAction func stopButton(_ sender: Any) {
    
    //self.scrollView.isUserInteractionEnabled = false
    self.canvasView.isUserInteractionEnabled = false
    //self.editImage.isUserInteractionEnabled = false
    
  }
  
  @IBAction func backView(_ sender: Any) {
    
    if currentDrawNumber <= 0 {return}
    
    self.canvasView.image = saveImageArray[currentDrawNumber - 1]   //保存している直前imageに置き換える
    //self.editImage.image = saveImageArray[currentDrawNumber - 1]
    
    currentDrawNumber -= 1
    
  }
  
  @IBAction func doneButtonButton(_ sender: Any) {
    
    self.dismiss(animated: true, completion: nil)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /**
   拡大縮小に対応
   */
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return self.canvasView
    //return self.editImage
  }
  
  /**
   UIGestureRecognizerでお絵描き対応。1本指でなぞった時のみの対応とする。
   */
  private func prepareDrawing() {
    
    //実際のお絵描きで言う描く手段(色えんぴつ？クレヨン？絵の具？など)の準備
    let myDraw = UIPanGestureRecognizer(target: self, action: #selector(self.drawGesture(_:)))
    myDraw.maximumNumberOfTouches = 1
    //self.scrollView.addGestureRecognizer(myDraw)
    self.canvasView.addGestureRecognizer(myDraw)
    //self.editImage.addGestureRecognizer(myDraw)
    
    //drawColor = colorInfo                   //draw色を黒色に決定する
    lineWidth = CGFloat(sliderValue.value) * scale      //線の太さを決定する
    
    //実際のお絵描きで言うキャンバスの準備 (=何も描かれていないUIImageの作成)
    prepareCanvas()
    
    saveImageArray.append(self.canvasView.image!)       //配列にcanvasView.imageを保存
    //saveImageArray.append(self.editImage.image!)
    
  }
  
  /**
   キャンバスの準備 (何も描かれていないUIImageの作成)
   */
  func prepareCanvas() {
    let canvasSize = CGSize(width: view.frame.width * 2, height: view.frame.width * 2)     //キャンバスのサイズの決定
    let canvasRect = CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height)      //キャンバスのRectの決定
    UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0.0)              //コンテキスト作成(キャンバスのUIImageを作成する為)
    var firstCanvasImage = UIImage()                                            //キャンバス用UIImage(まだ空っぽ)
    UIColor.clear.setFill()                                              //白色塗りつぶし作業1
    UIRectFill(canvasRect)                                                      //白色塗りつぶし作業2
    firstCanvasImage.draw(in: canvasRect)                                     //firstCanvasImageの内容を描く(真っ白)
    firstCanvasImage = UIGraphicsGetImageFromCurrentImageContext()!              //何も描かれてないUIImageを取得
    canvasView.contentMode = .scaleAspectFit                                    //contentModeの設定
    //editImage.contentMode = .scaleAspectFit
    canvasView.image = firstCanvasImage                                         //画面の表示を更新
    //editImage.image = firstCanvasImage
    UIGraphicsEndImageContext()                                                 //コンテキストを閉じる
  }
  
  
  /**
   draw動作
   */
  @objc func drawGesture(_ sender: AnyObject) {
    
    guard let drawGesture = sender as? UIPanGestureRecognizer else {
      print("drawGesture Error happened.")
      return
    }
    
    //guard let canvas = self.canvasView.image else {
    guard let canvas = self.canvasView.image else {
      fatalError("self.pictureView.image not found")
    }
    
    //lineWidth = defaultLineWidth                                    //描画用の線の太さを決定する
    //drawColor = UIColor.blackColor()                                //draw色を決定する
    let touchPoint = drawGesture.location(in: canvasView)         //タッチ座標を取得
    //let touchPoint = drawGesture.location(in: editImage)
    switch drawGesture.state {
      
    case .began:
      lastPoint = touchPoint                                      //タッチ座標をlastTouchPointとして保存する
      print("first\(touchPoint)")
      //touchPointの座標はscrollView基準なのでキャンバスの大きさに合わせた座標に変換しなければいけない
      //LastPointをキャンバスサイズ基準にConvert
      let lastPointForCanvasSize = convertPointForCanvasSize(originalPoint: lastPoint!, canvasSize: canvas.size)
      
      bezierPath = UIBezierPath()
      guard let bzrPth = bezierPath else {
        fatalError("bezierPath Error")
      }
      
      
      bzrPth.lineCapStyle = .butt                          //描画線の設定 端を丸くする
      //bzrPth.lineWidth = defaultLineWidth                //描画線の太さ
      bzrPth.lineWidth = lineWidth!                        //描画線の太さ
      bzrPth.move(to: lastPointForCanvasSize)
      
    case .changed:
      
      let newPoint = touchPoint                            //タッチポイントを最新として保存
      print("Second\(touchPoint)")
      guard let bzrPth = bezierPath else {
        fatalError("bezierPath Error")
      }
      
      //Draw実行しDraw後のimage取得
      let imageAfterDraw = drawGestureAtChanged(canvas: canvas, lastPoint: lastPoint!, newPoint: newPoint, bezierPath: bzrPth)
      
      self.canvasView.image = imageAfterDraw                      //Draw画像をCanvasに上書き
      //self.editImage.image = imageAfterDraw
      lastPoint = newPoint                                        //Point保存
      
    case .ended:
      
      //currentDrawNumberとsaveImageArray配列数が矛盾無きまでremoveLastする
      while currentDrawNumber != saveImageArray.count - 1 {
        saveImageArray.removeLast()
      }
      
      currentDrawNumber += 1
      saveImageArray.append(self.canvasView.image!)               //配列にcanvasView.imageを保存
      //saveImageArray.append(self.editImage.image!)
      var data: NSData = NSData()
      let images = self.canvasView.image!
      data = UIImageJPEGRepresentation(images, 0.1)! as NSData
      //let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as String
      print(data.length)
      
      if currentDrawNumber != saveImageArray.count - 1 {
        fatalError("index Error")
      }
      
      print("Finish dragging")
      
    default:
      ()
    }
    
  }
  
  /**
   UIGestureRecognizerのStatusが.Changedの時に実行するDraw動作
   
   - parameter canvas : キャンバス
   - parameter lastPoint : 最新のタッチから直前に保存した座標
   - parameter newPoint : 最新のタッチの座標座標
   - parameter bezierPath : 線の設定などが保管されたインスタンス
   - returns : 描画後の画像
   */
  func drawGestureAtChanged(canvas: UIImage, lastPoint: CGPoint, newPoint: CGPoint, bezierPath: UIBezierPath) -> UIImage {
    
    //最新のtouchPointとlastPointからmiddlePointを算出
    let middlePoint = CGPoint(x: (lastPoint.x + newPoint.x) / 2, y: (lastPoint.y + newPoint.y) / 2)
    
    //各ポイントの座標はscrollView基準なのでキャンバスの大きさに合わせた座標に変換しなければいけない
    //各ポイントをキャンバスサイズ基準にConvert
    let middlePointForCanvas = convertPointForCanvasSize(originalPoint: middlePoint, canvasSize: canvas.size)
    let lastPointForCanvas   = convertPointForCanvasSize(originalPoint: lastPoint, canvasSize: canvas.size)
    
    bezierPath.addQuadCurve(to: middlePointForCanvas, controlPoint: lastPointForCanvas)              //曲線を描く
    
    
    UIGraphicsBeginImageContextWithOptions(canvas.size, false, 0.0)                                  //コンテキストを作成
    let canvasRect = CGRect(x: 0, y: 0, width: canvas.size.width, height: canvas.size.height)        //コンテキストのRect
    self.canvasView.image?.draw(in: canvasRect)                                     //既存のCanvasを準備
    //self.editImage.image?.draw(in: canvasRect)
    drawColor.setStroke()                                                           //drawをセット
    bezierPath.stroke()                                                             //draw実行
    let imageAfterDraw = UIGraphicsGetImageFromCurrentImageContext()                //Draw後の画像
    UIGraphicsEndImageContext()                                                     //コンテキストを閉じる
    
    return imageAfterDraw!
  }
  
  /**
   (おまじない)座標をキャンバスのサイズに準じたものに変換する
   
   - parameter originalPoint : 座標
   - parameter canvasSize : キャンバスのサイズ
   - returns : キャンバス基準に変換した座標
   */
  func convertPointForCanvasSize(originalPoint: CGPoint, canvasSize: CGSize) -> CGPoint {
    
    //let viewSize = scrollView.frame.size
    let viewSize = canvasView.frame.size
    //let viewSize = editImage.frame.size
    var ajustContextSize = canvasSize
    var diffSize: CGSize = CGSize(width: 0, height: 0)
    let viewRatio = viewSize.width / viewSize.height
    let contextRatio = canvasSize.width / canvasSize.height
    let isWidthLong = viewRatio < contextRatio ? true : false
    
    if isWidthLong {
      
      ajustContextSize.height = ajustContextSize.width * viewSize.height / viewSize.width
      diffSize.height = (ajustContextSize.height - canvasSize.height) / 2
      
    } else {
      
      ajustContextSize.width = ajustContextSize.height * viewSize.width / viewSize.height
      diffSize.width = (ajustContextSize.width - canvasSize.width) / 2
      
    }
    
    let convertPoint = CGPoint(x: originalPoint.x * ajustContextSize.width / viewSize.width - diffSize.width, y: originalPoint.y * ajustContextSize.height / viewSize.height - diffSize.height)
    
    
    return convertPoint
    
  }
  
  
  
  /**
   スライダーを動かした時の動作
   ペンの太さを変更する
   */
  @IBAction func slideSlider(_ sender: Any) {
    
    lineWidth = CGFloat(sliderValue.value) * scale
    
  }
  
  /**
   Undoボタンを押した時の動作
   Undoを実行する
   */
  @IBAction func pressUndoButton(_ sender: Any) {
    
    if currentDrawNumber <= 0 {return}
    
    self.canvasView.image = saveImageArray[currentDrawNumber - 1]   //保存している直前imageに置き換える
    //self.editImage.image = saveImageArray[currentDrawNumber - 1]
    
    currentDrawNumber -= 1
    
  }
  
  /**
   Redoボタンを押した時の動作
   Redoを実行する
   */
  @IBAction func pressRedoButton(_ sender: Any) {
    
    if currentDrawNumber + 1 > saveImageArray.count - 1 {return}
    
    self.canvasView.image = saveImageArray[currentDrawNumber + 1]   //保存しているUndo前のimageに置き換える
    //self.editImage.image = saveImageArray[currentDrawNumber + 1]
    
    currentDrawNumber += 1
    
  }
  
  var colorInfo = UIColor.black
  let colorAsset = [UIColor.white, UIColor.black, UIColor.darkGray, UIColor.lightGray, UIColor.gray, UIColor.brown, UIColor.red, UIColor.magenta, UIColor.green, UIColor.blue, UIColor.cyan, UIColor.yellow, UIColor.orange, UIColor.purple]
  let colorAssetName = ["white", "black", "darkGray", "lightGray", "gray", "brown", "red", "magenta", "green", "blue", "cyan", "yellow", "orange", "purple"]
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return colorAsset.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! StampCollectionViewCell
    cell.textColorImages.backgroundColor = colorAsset[indexPath.row]
    return cell
  }
  
  func collectionView(_ collectionView : UICollectionView, didSelectItemAt indexPath: IndexPath) {
    drawColor = colorAsset[indexPath.row]
    
  }
  
  /*var tempItems = [NSDictionary]()
  func updateEdit() {
    
    let stampDatabase = Database.database().reference()
    stampDatabase.child("rooms/\(groupID)/stamps/\(indexPathInfo)").observe(.value) { (snapshot, error) in
      
      if (snapshot.value as! NSObject != NSNull()) {
        
        let updateImageView = UIImageView()
        
        updateImageView.frame.size = CGSize(width:self.view.frame.size.width, height: self.view.frame.size.width)
        
        updateImageView.image = projectImage[indexPathInfo]
        
        updateImageView.contentMode = UIViewContentMode.scaleAspectFill
        
        for item in(snapshot.children) {
          
          let child = item as! DataSnapshot
          let dict = child.value
          self.tempItems.append(dict as! NSDictionary)
          
        }
        
        for items in self.tempItems {
          
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
            self.editImage.addSubview(stampImageView)
            
            
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
            
            self.editImage.addSubview(stampLabel)
            
    
          }
        }
      }
    }
  }*/
  
}
