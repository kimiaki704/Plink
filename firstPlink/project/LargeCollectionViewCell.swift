
import UIKit

class LargeCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var largeImage: UIImageView!
  
  func setLargeImage (_ cellNumber: Int) {
    //largeImage.image = projectImage[cellNumber]
    if UserDefaults.standard.object(forKey: "projectImage\(cellNumber)") != nil {
      let str = UserDefaults.standard.object(forKey: "projectImage\(cellNumber)") as! String
      let decodeData: Any = (base64Encoded: str)
      let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
      let decodedImage = UIImage(data: decodedData! as Data)
      
      largeImage.image = decodedImage!
    }
    
    
    largeImage.contentMode = UIViewContentMode.scaleAspectFill
  }
}
