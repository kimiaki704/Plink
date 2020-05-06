
import UIKit
import Firebase

class ProfileEditingViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  var dataBase: DatabaseReference?

  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var accountText: UITextField!
  @IBOutlet weak var commentTextView: UITextView!
  
  @IBOutlet weak var view3: UIView!
  @IBOutlet weak var changeImageSetting: UIButton!
  @IBOutlet weak var commentView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    accountText.delegate = self
    commentTextView.delegate = self
    
    if UserDefaults.standard.object(forKey: "profileImage") != nil {
      let decodeData = (base64Encoded:UserDefaults.standard.object(forKey: "profileImage"))
      let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
      let decodedImage = UIImage(data: decodedData! as Data)
      profileImage.image = decodedImage
      profileImage.layer.cornerRadius = 62.5
      profileImage.layer.masksToBounds = true
      
      accountText.text = (UserDefaults.standard.object(forKey: "userName") as! String)
      commentTextView.text = UserDefaults.standard.object(forKey: "commentName") as! String
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
  
  
  
  @IBAction func changeImage(_ sender: Any) {
    
    let alertViewController = UIAlertController(title: "選んで", message: "", preferredStyle: .actionSheet)
    let cameraAction = UIAlertAction(title: "カメラ", style: .default, handler: { (action:UIAlertAction!) -> Void in
        
        self.openCamera()
        
    })
    
    let photoAction = UIAlertAction(title: "ライブラリー", style: .default, handler: { (action:UIAlertAction!) -> Void in
        
        self.openLibrary()
        
    })
    
    let cancelAction = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
    
    alertViewController.addAction(cameraAction)
    alertViewController.addAction(photoAction)
    alertViewController.addAction(cancelAction)
    
    present(alertViewController, animated: true, completion: nil)
    
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      
      var image = UIImage()
      
      if pickedImage.size.width > pickedImage.size.height {
        let pickedX = (pickedImage.size.width / 2) - (pickedImage.size.height / 2)
        
        image = pickedImage.cropping(to: CGRect(x: pickedX, y: 0, width: pickedImage.size.height, height: pickedImage.size.height))!
        
      } else if pickedImage.size.width < pickedImage.size.height {
        let pickedY = (pickedImage.size.height / 2) - (pickedImage.size.width / 2)
        
        image = pickedImage.cropping(to: CGRect(x: 0, y: pickedY, width: pickedImage.size.width, height: pickedImage.size.width))!
        
      } else {
        image = pickedImage
      }
      profileImage.image = image
      profileImage.layer.cornerRadius = 62.5
      profileImage.layer.masksToBounds = true
      
    }
    
    picker.dismiss(animated: true, completion: nil)
    
  }
  
  //戻るボタン
  @IBAction func returnButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  //決定ボタン
  @IBAction func profileSave(_ sender: Any) {
    
    var data: NSData = NSData()
    if let image = profileImage.image {
      data = UIImageJPEGRepresentation(image, 0.9)! as NSData
      
      let accountName = accountText.text
      let commentName = commentTextView.text
      let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as String
      
      //アプリ内へ保存
      UserDefaults.standard.set(base64String, forKey: "profileImage")
      UserDefaults.standard.set(accountName, forKey: "userName")
      UserDefaults.standard.set(commentName, forKey: "commentName")
      
      let profileVC = presentingViewController as! ProfileViewController
      profileVC.viewLoadMethod()
      postProfileData()
      self.dismiss(animated: true, completion: nil)
      
    } else {
      let alertViewController = UIAlertController(title: "おいおい", message: "変更する気ないだろ", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "は〜い", style: .default, handler: nil)
      alertViewController.addAction(okAction)
      self.present(alertViewController, animated: true, completion: nil)
    }
  }
  
  func postProfileData() {
    
    dataBase = Database.database().reference()
    
    let accountName = accountText.text
    let commentName = commentTextView.text
    
    var data: NSData = NSData()
    if let image = profileImage.image {
      data = UIImageJPEGRepresentation(image, 0.9)! as NSData
    }
    let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as String
    
    let sendData:NSDictionary = ["profileImage":base64String, "userName":accountName as Any, "spotName":"", "sexName":"", "birthdayName":"", "linkName":"", "commentName":commentName as Any]
    
    dataBase?.child("users/\(uidData)/profile").updateChildValues(sendData as! [AnyHashable : Any])
    dataBase?.child("allUserName").updateChildValues([uidData:accountName as Any])
    dataBase?.child("allUserImage").updateChildValues([uidData:base64String])
    
    
    self.navigationController?.popToRootViewController(animated: true)
  }
  
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    UIView.animate(withDuration: 0.3,
                   animations: {
                    self.commentView.frame.origin = CGPoint(x: 0, y: self.changeImageSetting.frame.origin.y)
    })
    
    return true
  }
  
  
  func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    UIView.animate(withDuration: 0.3,
                   animations: {
                    self.commentView.frame.origin = CGPoint(x: 0, y: self.view3.frame.origin.y + 0.5)
    })
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    accountText.resignFirstResponder()
    return true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if (accountText.isFirstResponder) {
      accountText.resignFirstResponder()
    } else if (commentTextView.isFirstResponder) {
      commentTextView.resignFirstResponder()
    }
  }
}
