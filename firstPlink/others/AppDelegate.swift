
import UIKit
import Firebase
import Photos
import Crashlytics
import Fabric
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    FirebaseApp.configure()
    
    
    Fabric.sharedSDK().debug = true
    
    
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: {_, _ in })
    
    // UNUserNotificationCenterDelegateの設定
    UNUserNotificationCenter.current().delegate = self
    // FCMのMessagingDelegateの設定
    Messaging.messaging().delegate = self
    
    // リモートプッシュの設定
    application.registerForRemoteNotifications()
    // Firebase初期設定
    //FirebaseApp.configure()
    
    // アプリ起動時にFCMのトークンを取得し、表示する
    let token = Messaging.messaging().fcmToken
    print("FCM token: \(token ?? "")")

    
    
    return true
  }
  

  func applicationWillResignActive(_ application: UIApplication) {
    print("バックグラウンド入りまぁす")
    UserDefaults.standard.set("true", forKey: "backgroundSignal")
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    print("バックグラウンドなーう")
    
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    print("バックグラウンド終わりまぁす")
    UserDefaults.standard.removeObject(forKey: "backgroundSignal")
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    print("つけました")
    
    if UserDefaults.standard.object(forKey: "backgroundSignal") != nil {
      print("消しマーース")
      for num in 0..<projectImage.count {
        UserDefaults.standard.removeObject(forKey: "projectImage\(num)")
      }
      groupID = ""
      projectImage = [UIImage]()
      roomMemberImages = [String]()
      projectList = ["Team":"", "Title":"", "Spot":"", "HashTag":""]
      UserDefaults.standard.removeObject(forKey: "groupID")
      UserDefaults.standard.removeObject(forKey: "\(groupID)")
      UserDefaults.standard.removeObject(forKey: "backgroundSignal")
    }
  }

  func applicationWillTerminate(_ application: UIApplication) {
    
    if UserDefaults.standard.object(forKey: "groupID") == nil {
      print("non")
    } else {
      /*let unsentDataBase = Database.database().reference().child("users/\(uidData)")
      let unsentData = ["groupID": groupID, "Team": projectList["Team"], "Title": projectList["Title"], "Time": Functions.nowTimeGet()]
      unsentDataBase.child("unsent/\(groupID)").setValue(unsentData)
      
      var data: NSData = NSData()
      for count in 0..<projectImage.count + roomMemberImages.count{
        if count < projectImage.count {
          let image = projectImage[count]
          data = UIImageJPEGRepresentation(image, 0.1)! as NSData
          let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as String
          let imageData: NSDictionary = [String(count): base64String]
          let unsentDataBase2 = Database.database().reference().child("users/\(uidData)")
          unsentDataBase2.child("unsent/\(groupID)").updateChildValues(imageData as! [AnyHashable : Any])
        } else {
          let image = roomMemberImages[count - projectImage.count]
          data = UIImageJPEGRepresentation(image, 0.1)! as NSData
          let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as String
          let imageData: NSDictionary = [String(count): base64String]
          let unsentDataBase2 = Database.database().reference().child("users/\(uidData)")
          unsentDataBase2.child("unsent/\(groupID)").updateChildValues(imageData as! [AnyHashable : Any])
        }
      }*/
      print("消しマーース")
      groupID = ""
      projectImage = [UIImage]()
      roomMemberImages = [String]()
      projectList = ["Team":"", "Title":"", "Spot":"", "HashTag":""]
      UserDefaults.standard.removeObject(forKey: "groupID")
      UserDefaults.standard.removeObject(forKey: "backgroundSignal")
      
    }
  }
  
  private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    DeployGateSDK
      .sharedInstance()
      .launchApplication(withAuthor: "USERNAME", key: "API_KEY")
    return true
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("フロントでプッシュ通知受け取ったよ")
  }
  
  func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
    print("Firebase registration token: \(fcmToken)")
  }
 
}

