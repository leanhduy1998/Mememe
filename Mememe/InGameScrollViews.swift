//
//  InGameExtensionUI.swift
//  Meme with Me
//
//  Created by Duy Le on 9/21/17.
//  Copyright © 2017 Duy Le. All rights reserved.
//

import Foundation
import UIKit

extension InGameViewController {
    func reloadCurrentPlayersIcon(){
        for v in currentPlayersScrollView.subviews {
            v.removeFromSuperview()
        }
        borderForUserIconIV.removeFromSuperview()
        
        var contentWidth = CGFloat(0)
        // never use currentPlayersScrollView.frame.height, because it uses the height of its storyboard
        iconSize = currentPlayerScrollHeight - space/2
        
        var counter = 0
        for player in playersInGame{
            var userCoreData: Player!
            
            let lastestRound = GetGameCoreDataData.getLatestRound(game: game)
            
            for pCore in (lastestRound.players?.allObjects as? [Player])! {
                if(pCore.playerId == player.userId){
                    userCoreData = pCore
                    break
                }
            }
            
            let newX = (self.space * CGFloat(counter+1))  + CGFloat(counter) * self.iconSize
            var userIconIV = UIImageView()
            userIconIV.frame = CGRect(x: newX, y: self.space/4, width: self.iconSize, height: self.iconSize)
            let image = userImagesDic[player.userId]
            
            userIconIV.image = image
            userIconIV = UIImageViewHelper.roundImageView(imageview: userIconIV, radius: 20)
            
            contentWidth += self.space + self.iconSize
    
            counter = counter + 1
            
            let redDotSize = iconSize/4
            let redDotIV = UIImageView(image: #imageLiteral(resourceName: "redCircle"))
            redDotIV.frame = CGRect(x: newX + iconSize*3/4, y: 0, width: redDotSize, height: redDotSize)
            let whiteLabel = UILabel()
            
            var timesWon: Int!
            
            for c in (game.wincounter?.allObjects as? [WinCounter])!{
                if(c.playerId == player.userId){
                    timesWon = Int(c.won)
                    break
                }
            }
            if(timesWon == nil){
                timesWon = 0
            }
            
            whiteLabel.text = "\(timesWon!)"
            whiteLabel.frame = CGRect(x: 0, y: 0, width: redDotSize, height: redDotSize)
            whiteLabel.textAlignment = .center
            whiteLabel.textColor = UIColor.white
            redDotIV.addSubview(whiteLabel)
            
            currentPlayersScrollView.addSubview(redDotIV)
            
            currentPlayersScrollView.addSubview(userIconIV)
            currentPlayersScrollView.sendSubview(toBack: userIconIV)
            
            if userCoreData.playerId == userWhoWon {
                borderForUserIconIV = getBorderIVForIcon(iconSize: iconSize, newX: newX)
                currentPlayersScrollView.addSubview(borderForUserIconIV)
                currentPlayersScrollView.bringSubview(toFront: borderForUserIconIV)
            }
            
            //currentPlayersScrollView.bringSubview(toFront: borderForUserIconIV)
            currentPlayersScrollView.bringSubview(toFront: redDotIV)
        }
        
        currentPlayersScrollView.contentSize = CGSize(width: contentWidth, height: iconSize)
    }

    func clearPreviewCardsData(){
        for v in previewScrollView.subviews {
            v.removeFromSuperview()
        }
    }
    
    func reloadPreviewCards(){
        var contentWidth = 0 + space
        
        let latestRound = GetGameCoreDataData.getLatestRound(game: game)
        
        if(latestRound == nil){
            return
        }
        
        var currentPlayersCards = latestRound.cardnormal?.allObjects as? [CardNormal]
            
        let haveWinner = checkIfWinnerExist(cards: (latestRound.cardnormal?.allObjects as? [CardNormal])!)
        let myCardExist = checkIfMyCardExist(cards: (latestRound.cardnormal?.allObjects as? [CardNormal])!)
        
        
        
        let image = FileManagerHelper.getImageFromMemory(imagePath: (latestRound.cardceasar?.imageStorageLocation!)!)
        thisRoundImage = image
            
        if !haveWinner {
            let ceasarCard = latestRound.cardceasar
            setAddEditJudgeMemeBtnUI(ceasarId: (ceasarCard?.playerId)!, haveWinner: haveWinner)
                
            if (currentPlayersCards?.count)! == 0 {
                // -40 is for animation
                let emptyCardUIView = CardView(frame: CGRect(x: space, y: space/2 - cardInitialYBeforeAnimation, width: cardWidth, height: cardHeight))
                var emptyIV = UIImageView(frame: CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight))
                emptyIV = UIImageViewHelper.roundImageView(imageview: emptyIV, radius: 15)
                
                emptyIV.image = image
                emptyCardUIView.addSubview(emptyIV)
                emptyCardUIView.sendSubview(toBack: emptyIV)
                
                previewScrollView.addSubview(emptyCardUIView)
                
                emptyCardUIView.alpha = 0.5
                UIView.animate(withDuration: 1, animations: {
                    emptyCardUIView.frame = CGRect(x: emptyCardUIView.frame.origin.x, y: emptyCardUIView.frame.origin.y + self.cardInitialYBeforeAnimation, width: self.cardWidth, height: self.cardHeight)
                    emptyCardUIView.alpha = 1
                })
                
                return
            }
            else if(cardDictionary.count) == 0 {
                self.clearPreviewCardsData()
            }
            
            
            var cardNormalDictionary = [String:CardNormal]()
            var checkIfCardNoLongerExist = [String:Bool]()
            
            for x in 0...(((currentPlayersCards?.count)! - 1)) {
                let card = cardDictionary[(currentPlayersCards?[x].playerId)!]
                
                if(card == nil){
                    cardOrder.append((currentPlayersCards?[x].playerId)!)
                }
        
                checkIfCardNoLongerExist[(currentPlayersCards?[x].playerId)!] = true
                cardNormalDictionary[(currentPlayersCards?[x].playerId)!] = currentPlayersCards?[x]
            }
            
            if (currentPlayersCards?.count)! < cardDictionary.count {
                for (playerId,_) in cardDictionary {
                    if checkIfCardNoLongerExist[playerId] == nil || checkIfCardNoLongerExist[playerId] == false {
                         cardDictionary.removeValue(forKey: playerId)
                    }
                }
            }
            
            var x = 0
            for playerId in cardOrder {
                let card = cardDictionary[playerId]
                let cardNormal = cardNormalDictionary[playerId]
                
                contentWidth += space + cardWidth
                
                if card != nil && card?.bottomLabel.text == cardNormal?.bottomText && card?.topLabel.text == cardNormal?.topText {
                    previewScrollView.addSubview(card!)
                    previewScrollView.bringSubview(toFront: card!)
                }
                else {
                    let newX = getNewXForPreviewScroll(x: x, haveWinner: haveWinner)
                    
                    let upLabel = getTopLabel(text: (cardNormal?.topText)!)
                    let downLabel = getBottomLabel(text: (cardNormal?.bottomText)!)
                    
                    // -40 is for animation
                    let cardUIView = CardView(frame: CGRect(x: newX, y: space/2-cardInitialYBeforeAnimation, width: cardWidth, height: cardHeight))
                    
                    var memeImageView = getMemeIV(image: image)
                    memeImageView = UIImageViewHelper.roundImageView(imageview: memeImageView, radius: 15)
                    
                    cardUIView.initCardView(topLabel: upLabel, bottomLabel: downLabel, playerId: playerId, memeIV: memeImageView)
                    
                    let tap = UILongPressGestureRecognizer(target: self, action: #selector(showPictureDetailTap))
                    
                    tap.delegate = self
                    cardUIView.addGestureRecognizer(tap)
                    
                    if playerId != MyPlayerData.id{
                        if !cardUIView.haveHeartView{
                            cardUIView.haveHeartView = true
                            let heartView = getHeartView(frame: memeImageView.frame, playerCard: cardNormal!)
                            cardUIView.addSubview(heartView)
                            cardUIView.bringSubview(toFront: heartView)
                        }
                    }
                    previewScrollView.addSubview(cardUIView)
                    previewScrollView.bringSubview(toFront: cardUIView)
                    
                    cardUIView.alpha = 0.5
                    
                    UIView.animate(withDuration: 1, animations: {
                        cardUIView.frame = CGRect(x: cardUIView.frame.origin.x, y: cardUIView.frame.origin.y + self.cardInitialYBeforeAnimation, width: self.cardWidth, height: self.cardHeight)
                        cardUIView.alpha = 1
                    })
                    
                    cardDictionary[playerId] = cardUIView
                }
                x = x + 1
            }
            
            
            
        }
        else {
            clearPreviewCardsData()
            cardOrder.removeAll()
            cardDictionary.removeAll()
            
            contentWidth = screenWidth
            let newX = getNewXForPreviewScroll(x: 0, haveWinner: haveWinner)
            let memeImageView = getMemeIV(image: image)
            for card in currentPlayersCards! {
                if !card.didWin {
                    continue
                }
                let cardUIView = CardView(frame: CGRect(x: newX, y: space/2 - cardInitialYBeforeAnimation, width:cardWidth, height: cardHeight))
                let upLabel = getTopLabel(text: card.topText!)
                let downLabel = getBottomLabel(text: card.bottomText!)
                cardUIView.initCardView(topLabel: upLabel, bottomLabel: downLabel,playerId: card.playerId!, memeIV: memeImageView)
                    
                let borderIV = getBorderForWinningCard()
                cardUIView.addSubview(borderIV)
                    
                getUserIconView(frame: memeImageView.frame, playerCard: card,completeHandler: { (IV) in
                    cardUIView.addSubview(IV)
                    cardUIView.bringSubview(toFront: IV)
                })
                    
                previewScrollView.addSubview(cardUIView)
                
                cardUIView.alpha = 0.5
                
                UIView.animate(withDuration: 1, animations: {
                    cardUIView.frame = CGRect(x: cardUIView.frame.origin.x, y: cardUIView.frame.origin.y + self.cardInitialYBeforeAnimation, width: self.cardWidth, height: self.cardHeight)
                    cardUIView.alpha = 1
                })
                
                break
        }
    }
        previewScrollView.contentSize = CGSize(width: contentWidth, height: cardHeight)
    }
    
    func showPictureDetailTap(sender: UILongPressGestureRecognizer) {
        let cardView = sender.view as? CardView
        topTextSegue = cardView?.topText
        bottomTextSegue = cardView?.bottomText
        if !detailPictureSegueSent{
            detailPictureSegueSent = true
            performSegue(withIdentifier: "PictureDetailViewControllerSegue", sender: self)
        }
    }
    
    func isTextEmpty(string: String)->Bool{
        if (string == " " || string == "" || string.isEmpty) {
            return true
        }
        return false
    }
}
