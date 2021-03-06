//
//  InGameCards.swift
//  Mememe
//
//  Created by Duy Le on 10/5/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension InGameViewController{
    func getUserIconView(frame: CGRect, playerCard: CardNormal,completeHandler: @escaping (_ IV: UIImageView)-> Void){
        s3Helper.loadUserProfilePicture(userId: playerCard.playerId!) { (imageData) in
            DispatchQueue.main.async {
                let imageview = UIImageView(image: UIImage(data: imageData))
                imageview.frame = CGRect(x: frame.maxX - self.cardHeight/20, y: frame.minY, width: self.cardHeight/10, height: self.cardHeight/10)
                completeHandler(imageview)
            }
        }
    }
    func getBorderForWinningCard() -> UIImageView{
        let borderImage = #imageLiteral(resourceName: "border")
        let borderIV = UIImageView(image: borderImage)
        borderIV.frame = CGRect(x:-75, y: -75, width: cardWidth+160, height: cardHeight+150)
        return borderIV
    }
    func getBorderIVForIcon(iconSize: CGFloat, newX: CGFloat) -> UIImageView{
        let crownImage = #imageLiteral(resourceName: "border")
        let crownIV = UIImageView(image: crownImage)
        crownIV.frame = CGRect(x: newX - 20, y: -10, width: iconSize+45, height: iconSize+25)
        return crownIV
    }
    func getMemeIV(image:UIImage) -> UIImageView {
        var memeImageView = UIImageView(image: image)
        memeImageView.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
        memeImageView = UIImageViewHelper.roundImageView(imageview: memeImageView, radius: 5)
        return memeImageView
    }
    func getHeartView(frame: CGRect, playerCard: CardNormal) -> HeartView{
        let heartView = HeartView()
        heartView.cardNormal = playerCard
        heartView.frame = frame
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.loveMemeDoubleTap(sender:)))
        
        tap.numberOfTapsRequired = 2
        tap.delegate = self
        
        heartView.addGestureRecognizer(tap)
        
        return heartView
    }
    func loveMemeDoubleTap(sender: UITapGestureRecognizer) {
        let heartView = sender.view as? HeartView
        
        InGameHelper.checkIfYouLikedSomeonesCard(gameId: game.gameId!, cardId: (heartView?.cardNormal.playerId)!) { (youLiked) in
            DispatchQueue.main.async {
                if !youLiked {
                    let heartWidth = self.cardHeight/5
                    let heartHeight = self.cardHeight*2/5
                    
                    let heartImageView = heartView?.get(heartWidth: heartWidth, heartHeight: heartHeight, x: (heartView?.frame.width)!/2 - heartWidth/2, y: 0)
                //    heartImageView?.alpha = 0
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat], animations: {
                //        heartImageView?.alpha = 1
                //        heartImageView?.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
                        heartImageView?.frame.origin.y = (heartImageView?.frame.origin.y)! + self.cardHeight/2
                    }, completion: nil)
                    self.playHeartSound()
                    
                    heartView?.liked = true
                    heartView?.addSubview(heartImageView!)
                    
                    let cardNormal = heartView?.cardNormal
                    cardNormal?.addToPlayerlove(PlayerLove(playerId: MyPlayerData.id, context: GameStack.sharedInstance.stack.context))
                    
                    GameStack.sharedInstance.saveContext(completeHandler: {
                        DispatchQueue.main.async {
                            InGameHelper.likeSomeoOneCard(gameId: self.game.gameId!, cardId: (cardNormal?.playerId)!)
                        }
                    })
                }
                else {
                    for v in (heartView?.subviews)! {
                        v.removeFromSuperview()
                    }

                    let cardNormal = heartView?.cardNormal
                    
                    InGameHelper.unlikeSomeoOneCard(gameId: self.game.gameId!, cardId: (cardNormal?.playerId)!)
                    
                    for pl in (cardNormal?.playerlove?.allObjects)! {
                        let playerLove = pl as? PlayerLove
                        if playerLove?.playerId == MyPlayerData.id {
                            cardNormal?.removeFromPlayerlove(playerLove!)
                            
                            GameStack.sharedInstance.saveContext(completeHandler: {
                            })
                        }
                    }
                }
            }
        }
    }
}
