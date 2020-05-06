
import Foundation
import UIKit
import Firebase

func baseUserImageCreator() -> UIImage {
  let userImage: UIImage = #imageLiteral(resourceName: "user.png")
  return userImage
}

class Functions {
  class func nowTimeGet() -> String {
    // 現在時刻を取得
    let now = NSDate()
    let formatter = DateFormatter()
    // 好きなフォーマットを設定する
    formatter.dateFormat = "yyyy_MM_dd HH:mm:ss"
    let str = formatter.string(from: now as Date)
    return str
  }
}

func wait(_ waitContinuation: @escaping (()->Bool), compleation: @escaping (()->Void)) {
  var wait = waitContinuation()
  // 0.01秒周期で待機条件をクリアするまで待ちます。
  let semaphore = DispatchSemaphore(value: 0)
  DispatchQueue.global().async {
    while wait {
      DispatchQueue.main.async {
        wait = waitContinuation()
        semaphore.signal()
      }
      semaphore.wait()
      Thread.sleep(forTimeInterval: 0.01)
    }
    // 待機条件をクリアしたので通過後の処理を行います。
    DispatchQueue.main.async {
      compleation()
    }
  }
}
//乱数を生成
func generate(length: Int) -> String {
  let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  var randomString: String = ""
  
  
  for _ in 0..<length {
    let randomValue = arc4random_uniform(62)
    randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))..<base.index(base.startIndex, offsetBy: Int(randomValue) + 1)])"
  }
  return randomString
}

//UIImageのサイズ変更
extension UIImage {
  func cropping(to: CGRect) -> UIImage? {
    var opaque = false
    if let cgImage = cgImage {
      switch cgImage.alphaInfo {
      case .noneSkipLast, .noneSkipFirst:
        opaque = true
      default:
        break
      }
    }
    
    UIGraphicsBeginImageContextWithOptions(to.size, opaque, scale)
    draw(at: CGPoint(x: -to.origin.x, y: -to.origin.y))
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result
  }
}

extension UIImage {
  func resize(size _size: CGSize) -> UIImage? {
    let widthRatio = _size.width / size.width
    let heightRatio = _size.height / size.height
    let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
    
    let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)
    
    UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0) // 変更
    draw(in: CGRect(origin: .zero, size: resizedSize))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return resizedImage
  }
}

//半角英数判定
extension String {
  func isAlphanumeric() -> Bool {
    return NSPredicate(format: "SELF MATCHES %@", "[a-zA-Z0-9_-]+").evaluate(with: self)
  }
}

extension CGPoint {
  
  static func screenRatioCalculation(_ x:CGFloat, _ y:CGFloat) -> CGPoint {
    
    switch UIScreen.main.bounds.size {
    case CGSize(width: 320.0, height: 480.0): return CGPoint(x: CGFloat((x/320)*375), y: CGFloat((y/320)*375)) //iPhone4S
    case CGSize(width: 320.0, height: 568.0): return CGPoint(x: CGFloat((x/320)*375), y: CGFloat((y/320)*375)) //iPhone5,iPhone5S,iPodTouch5
    case CGSize(width: 375.0, height: 667.0): return CGPoint(x: x, y: y) //iPhone6
    case CGSize(width: 414.0, height: 736.0): return CGPoint(x: CGFloat((x/414)*375), y: CGFloat((y/414)*375)) //iPhone6Plus
    default:
      return CGPoint(x: 0, y: 0)
    }
  }
  
  static func receptionScreenRatioCalculation(_ x:CGFloat, _ y:CGFloat) -> CGPoint {
    
    switch UIScreen.main.bounds.size {
    case CGSize(width: 320.0, height: 480.0): return CGPoint(x: CGFloat((x/375)*320), y: CGFloat((y/375)*320)) //iPhone4S
    case CGSize(width: 320.0, height: 568.0): return CGPoint(x: CGFloat((x/375)*320), y: CGFloat((y/375)*320)) //iPhone5,iPhone5S,iPodTouch5
    case CGSize(width: 375.0, height: 667.0): return CGPoint(x: x, y: y) //iPhone6
    case CGSize(width: 414.0, height: 736.0): return CGPoint(x: CGFloat((x/375)*414), y: CGFloat((y/375)*414)) //iPhone6Plus
    default:
      return CGPoint(x: 0, y: 0)
    }
  }
  
}

