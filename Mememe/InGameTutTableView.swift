//
//  InGameChatTableView.swift
//  Mememe
//
//  Created by Duy Le on 8/4/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension InGameTutController {
    func calculateHeight(inString:String) -> CGFloat {
        let messageString = inString
        let attributes : [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 25.0)]
        
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
        
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: view.frame.width - 106, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        let requredSize:CGRect = rect
        return requredSize.height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == chatTableView){
            if(calculateHeight(inString: messages[indexPath.row].text) > 40){
                return calculateHeight(inString: messages[indexPath.row].text)
            }
            else{
                return 40
            }
        }
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if(message.senderId == MyPlayerData.id){
            var cell = tableView.dequeueReusableCell(withIdentifier: "MyChatTableViewCell") as? MyChatTableViewCell
            cell = CellAnimator.add(cell: cell!)
            cell?.messageTF.text = message.text
            cell?.messageTF.numberOfLines = 0
            cell?.messageTF.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            cell?.messageTF.layer.masksToBounds = true
            cell?.messageTF.layer.cornerRadius = 5
            
            if(message.senderId == MyPlayerData.id){
                s3Helper.loadUserProfilePicture(userId: message.senderId) { (imageData) in
                    DispatchQueue.main.async {
                        cell?.userIV.image = UIImage(data: imageData)
                    }
                }
            }
            else{
                cell?.userIV.image = #imageLiteral(resourceName: "ichooseyou")
            }
            
            return cell!
        }
        else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "HerChatTableViewCell") as? HerChatTableViewCell
            cell = CellAnimator.add(cell: cell!)
            cell?.messageTF.text = message.text
            cell?.messageTF.numberOfLines = 0
            cell?.messageTF.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            cell?.messageTF.layer.masksToBounds = true
            cell?.messageTF.layer.cornerRadius = 5
            
            if(message.senderId == MyPlayerData.id){
                s3Helper.loadUserProfilePicture(userId: message.senderId) { (imageData) in
                    DispatchQueue.main.async {
                        cell?.userIV.image = UIImage(data: imageData)
                    }
                }
            }
            else{
                cell?.userIV.image = #imageLiteral(resourceName: "ichooseyou")
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(messages.count == 0){
            emptyMessageLabel.isHidden = false
        }
        else{
            emptyMessageLabel.isHidden = true
        }
        return messages.count
    }
}

