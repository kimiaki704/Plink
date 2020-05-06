

import UIKit
import Photos
import Firebase


class PictureSelectViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  var imageArray = [UIImage]()
  var photoAssets = [PHAsset]()

  @IBOutlet weak var albumCollection: UICollectionView!
  
  var dataBase : DatabaseReference?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //updateFirebase()
    grabPhotos()
    collectionCellLayout()
    self.albumCollection.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
  
  func updateFirebase() {
    
    dataBase = Database.database().reference()
    dataBase?.child("rooms/\(groupID)/images").observe(.value, with: { (snapshot) -> Void in
      if (snapshot.value as! NSObject != NSNull()) {
        var snap = snapshot.value as! [String]
        //let snaps = [String](snap.values)
       // projectDataKey = [String](snap.keys)
        
        if projectImage.count < snap.count {
          projectImage = [UIImage]()
          for num in 0..<snap.count {
            let decodeData: Any = (base64Encoded: snap[num])
            let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            let decodedImage = UIImage(data: decodedData! as Data)
            projectImage.append(decodedImage!)
          }
        }
      }
    })
  }
  
  func grabPhotos(){
    imageArray = []
    
    DispatchQueue.global(qos: .background).async {
      print("This is run on the background queue")
      let imgManager=PHImageManager.default()
      
      let requestOptions=PHImageRequestOptions()
      requestOptions.isSynchronous=true
      requestOptions.deliveryMode = .highQualityFormat
      
      let fetchOptions=PHFetchOptions()
      fetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
      
      let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
      if fetchResult.count > 0 {
        for i in 0..<fetchResult.count{
          imgManager.requestImage(for: fetchResult.object(at: i) as PHAsset, targetSize: CGSize(width:200, height: 200),contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
            self.imageArray.append(image!)
          })
        }
      } else {
        print("You got no photos.")
      }
      print("imageArray count: \(self.imageArray.count)")
      
      DispatchQueue.main.async {
        print("This is run on the main queue, after the previous code in outer block")
        self.albumCollection.reloadData()
      }
      
    }
  }
  
  
  func collectionCellLayout() {
    let layout = UICollectionViewFlowLayout()
    let selfSize = self.view.frame.size.width
    layout.itemSize = CGSize(width: selfSize * (124/375), height: selfSize * (124/375))//Cellの大きさ
    layout.minimumInteritemSpacing = (self.view.frame.size.width - ((selfSize * (124/375)) * 3)) / 2 //アイテム同士の余白
    layout.minimumLineSpacing = (self.view.frame.size.width - ((selfSize * (124/375)) * 3)) / 2 //セクションとアイテムの余白
    
    albumCollection.collectionViewLayout = layout //layoutの更新
    albumCollection.reloadData()  //これはいらないかもしれません
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imageArray.count + 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCollectionViewCell
    
    switch indexPath.row {
    case 0:
      cell.albumImage.image = UIImage(named: "cameraButton")
      return cell
    default:
      cell.albumImage.image = imageArray[indexPath.row - 1]
      return cell
    }
    
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    switch indexPath.row {
    case 0:
      self.openCamera()
      
    default:
      dataBase = Database.database().reference()
      
      let beforeClassImage = self.presentingViewController as! ProjectViewController
      beforeClassImage.slideCollection.reloadData()
      beforeClassImage.largeCollection.reloadData()
      
      var data: NSData = NSData()
      let images = imageArray[indexPath.row - 1]
      data = UIImageJPEGRepresentation(images, 0.1)! as NSData
      let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as String
      let imageData: NSDictionary = ["\(projectImage.count)": base64String]
      self.dataBase?.child("rooms/\(groupID)/images").updateChildValues(imageData as! [AnyHashable : Any])
      projectImage.append(images)
      self.dismiss(animated: true, completion: nil)
      
    }
    
    
  }
  
  @IBAction func libraryButton(_ sender: Any) {
    // カメラロールが利用可能か？
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      // 写真を選ぶビュー
      let pickerView = UIImagePickerController()
      // 写真の選択元をカメラロールにする
      // 「.camera」にすればカメラを起動できる
      pickerView.sourceType = .photoLibrary
      // デリゲート
      pickerView.delegate = self
      // ビューに表示
      self.present(pickerView, animated: true)
    }
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
  
  
  // 写真を選んだ後に呼ばれる処理
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    // 選択した写真を取得する
    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    
    var data: NSData = NSData()
    let images = image
    data = UIImageJPEGRepresentation(images, 0.1)! as NSData
    let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as String
    let imageData: NSDictionary = ["\(projectImage.count)": base64String]
    self.dataBase?.child("rooms/\(groupID)/images").updateChildValues(imageData as! [AnyHashable : Any])
    
    let beforeClassImage = self.presentingViewController as! ProjectViewController
    beforeClassImage.slideCollection.reloadData()
    beforeClassImage.largeCollection.reloadData()
    // 写真を選ぶビューを引っ込める
    projectImage.append(image)
    self.presentingViewController?.dismiss(animated: true, completion: nil)
  }
}
