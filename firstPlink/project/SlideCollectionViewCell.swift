
import UIKit

class SlideCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var slideImage: UIImageView!
  
  func setImage (_ cellNumber: Int) {
    //slideImage.image = projectImage[cellNumber]
    
    if UserDefaults.standard.object(forKey: "projectImage\(cellNumber)") != nil {
      let str = UserDefaults.standard.object(forKey: "projectImage\(cellNumber)") as! String
      let decodeData: Any = (base64Encoded: str)
      let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
      let decodedImage = UIImage(data: decodedData! as Data)
      
      slideImage.image = decodedImage!
    }
    
    slideImage.layer.borderWidth = 5
    slideImage.layer.borderColor = UIColor.black.cgColor
    slideImage.contentMode = UIViewContentMode.scaleAspectFill
    //slideImage.layer.borderColor = UIColor(displayP3Red: 135/255, green: 226/255, blue: 163/255, alpha: 1).cgColor
  }
  
  
  func deleteEditCounter() {
    slideImage.removeFromSuperview()
  }

}
