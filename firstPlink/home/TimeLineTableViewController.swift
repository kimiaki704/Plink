
import UIKit


class TimeLineTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let returnCGFloat = self.view.frame.size.width * (125/375) * (60/125)
    return 50 + returnCGFloat + self.view.frame.size.width
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableItems.count
  }
  var tableViewCount = 0
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "TLTableCell", for: indexPath) as! TLTableViewCell
    
    //サイズ指定
    
    
    cell.userScrollView.frame = CGRect(x: 10, y: 5, width: (self.view.frame.size.width * (125/375)), height: (self.view.frame.size.width * (125/375)) * (60/125))
    
    let otherButtonSettingX1 = self.view.frame.size.width * (125/375)
    let otherButtonSettingX2 = self.view.frame.size.width * (185/375)
    let otherButtonSettingX3 = (self.view.frame.size.width * (7.5/375)) * 2
    cell.otherButtonSetting.frame = CGRect(x: 10 + otherButtonSettingX1 + otherButtonSettingX2 + otherButtonSettingX3 , y: 5, width: self.view.frame.size.width * (50/375), height: self.view.frame.size.width * (125/375) * (60/125))
    
    cell.scrollView.frame = CGRect(x: 0, y: 10 + self.view.frame.size.width * (125/375) * (60/125), width: self.view.frame.size.width, height: self.view.frame.size.width)
    
    
    let timeLabelY = self.view.frame.size.width * (125/375) * (60/125)
    cell.timeLabel.frame = CGRect(x: self.view.frame.size.width - 135, y: 25 + timeLabelY + self.view.frame.size.width, width: 135, height: 20)
    
    //どのセルのボタンかを判定
    cell.otherButtonSetting.tag = indexPath.row
    cell.delegate = self
    
    
    cell.selectionStyle = UITableViewCellSelectionStyle.none
    
    let dict = tableItems[(indexPath as NSIndexPath).row]
    //let dictUser = itemsUser[(indexPath as NSIndexPath).row]
    
    cell.teamLabel.text! = dict["Team"] as! String
    cell.teamLabel.sizeToFit()
    
    let teamLabelX1 = self.view.frame.size.width * (125/375)
    let teamLabelX2 = self.view.frame.size.width * (7.5/375)
    cell.teamLabel.frame = CGRect(x: 10 + teamLabelX1 + teamLabelX2, y: 5, width: cell.teamLabel.frame.size.width, height: self.view.frame.size.width * (125/375) * (60/125))
    
    
    cell.titleLabel.text! = dict["Title"] as! String
    cell.titleLabel.sizeToFit()
    let titleLabelY = self.view.frame.size.width * (125/375) * (60/125)
    cell.titleLabel.frame = CGRect(x: 15, y: 10 + titleLabelY + 10 + self.view.frame.size.width, width: cell.titleLabel.frame.size.width, height: 20)
    
    
    cell.timeLabel.text! = dict["Time"] as! String
    let imageCount = dict["Count"] as! String
    
    let dataCount = dict.count - 7
    for count in 0..<dataCount {
      
      if count < Int(imageCount)! {
        let decodeData = (base64Encoded:dict[String(count)])
        let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        let decodedImage = UIImage(data: decodedData! as Data)
        
        let image = UIImageView()
        
        image.image = decodedImage
        image.contentMode = UIViewContentMode.scaleAspectFill
        
        image.frame = CGRect(x: view.frame.size.width * CGFloat(count), y: 0, width: view.frame.size.width, height: view.frame.size.width)
        
        cell.scrollView.addSubview(image)
      } else if count >= Int(imageCount)! {
        let decodeData = (base64Encoded:dict[String(count)])
        let decodedData = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        let decodedImage = UIImage(data: decodedData! as Data)
        
        let image = UIImageView()
        
        image.image = decodedImage
        
        image.frame = CGRect(x: (50 * CGFloat(count - Int(imageCount)!)) + 10 * CGFloat(count - Int(imageCount)!), y: 10, width: 50, height: 50)
        image.layer.cornerRadius = 25
        image.layer.masksToBounds = true
        
        cell.userScrollView.alwaysBounceVertical = true
        
        cell.userScrollView.addSubview(image)
        
        
      }
    }
    
    cell.scrollView.contentSize = CGSize(width: view.frame.size.width * CGFloat(Int(imageCount)!), height: view.frame.size.width)
    cell.userScrollView.contentSize = CGSize(width: 50 * CGFloat(dataCount - Int(imageCount)!), height: 50)
    
    if dataCount - Int(imageCount)! == 1 {
      cell.userScrollView.frame = CGRect(x: 10, y: 5, width: (self.view.frame.size.width * (50/375)), height: (self.view.frame.size.width * (125/375)) * (60/125))
    }
    
    //if tlInfo.index(of: dict["Info"] as! String) == nil {
      //tlInfo.append(dict["Info"] as! String)
    //}
    
    return cell
  }
}
