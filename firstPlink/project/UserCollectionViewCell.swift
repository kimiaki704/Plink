
import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    
  @IBOutlet weak var userImage: UIImageView!
  
  func setUserImage(_ cellNumber: Int) {
    
    let urldata = userImages[cellNumber] 
    let strURL = URL(string: urldata)
    
    userImage.sd_setImage(with: strURL, placeholderImage: nil)
    
    //userImage.image = userImages[cellNumber]
    userImage.layer.cornerRadius = 30
    userImage.layer.masksToBounds = true
  }
}
