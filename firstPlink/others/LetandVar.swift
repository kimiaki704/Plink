
import Foundation
import UIKit
import Photos
import Firebase

var projectImage: Array! = [UIImage]()
//var projectImageInfo: Array = [Bool]()
var projectEditMember: Dictionary = [String:String]()
var projectEditNumber: Array = [Int]()
var updateProjectImage: Array = [Int]()
var userImages: Array! = [String]()
var dataDraftingTime:Array = [String]()
var dataImage:Array = [UIImage]()
var cellNumbers : Int = 1
var colorChange = 0

var indexPathInfo = Int()
var nowEditImageInfo = UIImage()

var groupUserCount: Int = 0

var projectList: [String:String] = ["Team":"", "Title":"", "Spot":"", "HashTag":""]
var profileList: [String:String] = ["userName":"", "spotName":"", "sexName":"", "birthdayName":"", "linkName":"", "commentName":""]
var moreDetailImage:Array = [UIImage]()

var allUserId: Array = [String]()
var allUserName: Array = [String]()
var allUserUid:Array = [String]()
var allUserImage:Array = [String]()

var allUserIdDict: Dictionary = [String:String]()
var allUserNameDict: Dictionary = [String:String]()
var allUserUidDict:Dictionary = [String:String]()
var allUserImageDict:Dictionary = [String:String]()

var stringUserImage:Array = [String]()


var userID: String = ""
var userPassword: String = ""
var userName: String = ""
var roomMemberImages = [String]()
var dataTLTime:Array = [String]()

var uidData = ""
var groupID = ""
var projectDataKey: Array = [String]()

var stampInfomation = [String:String]()
var tlInfo = [String]()

