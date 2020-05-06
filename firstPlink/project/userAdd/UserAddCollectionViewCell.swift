
import UIKit


class UserAddCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var userImageView: UIImageView!
  
  func setUserImage(_ cellNumber: Int) {
    
    let urldata = userImages[cellNumber]
    let strURL = URL(string: urldata)
    
    userImageView.sd_setImage(with: strURL, placeholderImage: nil)
    
    //userImageView.image = userImages[cellNumber]
    userImageView.layer.cornerRadius = 27.5
    userImageView.layer.masksToBounds = true
  }
    
}
