//
//  PreviewInGameViewController.swift
//  Mememe
//
//  Created by Duy Le on 10/12/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class PreviewInGameViewController: UIViewController {
    @IBOutlet weak var previewScrollView: UIScrollView!
    @IBOutlet weak var currentPlayersScrollView: UIScrollView!
    @IBOutlet weak var previousRoundBtn: UIBarButtonItem!
    @IBOutlet weak var nextRoundBtn: UIBarButtonItem!
    @IBOutlet weak var floorBackground: UIImageView!
    
    var game:Game!
    // ui
    var screenWidth : CGFloat!
    var space = CGFloat(5)
    var cardWidth : CGFloat!
    var cardHeight: CGFloat!
    var iconSize: CGFloat!
    
    var cardInitialYBeforeAnimation: CGFloat!
    var borderForUserIconIV = UIImageView()
    
    var currentRound = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFloorBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDimensions()
        reloadPreviewCards()
        reloadCurrentPlayersIcon()
        checkSwitchingRoundCondition()
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func previousBtnPressed(_ sender: Any) {
        currentRound = currentRound - 1
        checkSwitchingRoundCondition()
        clearPreviewCardsData()
        reloadPreviewCards()
        reloadCurrentPlayersIcon()
    }
    @IBAction func nextBtnPressed(_ sender: Any) {
        currentRound = currentRound + 1
        checkSwitchingRoundCondition()
        clearPreviewCardsData()
        reloadPreviewCards()
        reloadCurrentPlayersIcon()
    }
    
    func checkSwitchingRoundCondition(){
        if(currentRound == 0){
            previousRoundBtn.isEnabled = false
            nextRoundBtn.isEnabled = true
        }
        if(currentRound == ((game.rounds?.count)!-1)){
            if(currentRound == 0){
                previousRoundBtn.isEnabled = false
            }
            else{
                previousRoundBtn.isEnabled = true
            }
            nextRoundBtn.isEnabled = false
        }
        if(currentRound > 0 && currentRound < ((game.rounds?.count)!-1)){
            previousRoundBtn.isEnabled = true
            nextRoundBtn.isEnabled = true
        }
    }
    
    func clearPreviewCardsData(){
        for v in previewScrollView.subviews {
            v.removeFromSuperview()
        }
    }
    
    func reloadPreviewCards(){
        let round = GetGameCoreDataData.getRound(game: game, roundNum: currentRound)
        
        if(round == nil){
            return
        }
        
        var image = FileManagerHelper.getImageFromMemory(imagePath: (round.cardceasar?.imageStorageLocation)!)
        
        if(image == nil){
            let helper = UserFilesHelper()
            helper.getMemeData(memeUrl: (round.cardceasar?.cardDBUrl)!, completeHandler: { (memeImageData) in
                DispatchQueue.main.async {
                    image = UIImage(data: memeImageData)!
                    self.loadPreviewScrollView(image: image, round: round)
                }
            })
            
        }
        else{
            loadPreviewScrollView(image: image, round: round)
        }
        
        
    }
    
    func loadPreviewScrollView(image:UIImage,round:Round){
        var contentWidth = 0 + space*2
        
        var currentPlayersCards = round.cardnormal?.allObjects as? [CardNormal]
        
        if(currentPlayersCards?.count == 0){
            contentWidth = contentWidth + cardWidth
            
            let newX = getNewXForPreviewScroll(x: 0)
            let memeImageView = getMemeIV(image: image)
            let cardUIView = CardView(frame: CGRect(x: newX, y: space/2-cardInitialYBeforeAnimation, width: cardWidth, height: cardHeight))
            
            cardUIView.memeIV = memeImageView
            cardUIView.addSubview(memeImageView)
            cardUIView.bringSubview(toFront: memeImageView)
            
            previewScrollView.addSubview(cardUIView)
            previewScrollView.bringSubview(toFront: cardUIView)
            
            cardUIView.alpha = 0.5
            
            UIView.animate(withDuration: 1, animations: {
                cardUIView.frame = CGRect(x: newX, y: cardUIView.frame.origin.y + self.cardInitialYBeforeAnimation, width: self.cardWidth, height: self.cardHeight)
                cardUIView.alpha = 1
            })
            previewScrollView.contentSize = CGSize(width: contentWidth, height: cardHeight)
            return
        }
        
        for x in 0...(((currentPlayersCards?.count)! - 1)) {
            let memeImageView = getMemeIV(image: image)
            memeImageView.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
            
            contentWidth += space*2 + cardWidth
            
            let newX = getNewXForPreviewScroll(x: x)
            
            let upLabel = getTopLabel(text: (currentPlayersCards?[x].topText)!)
            let downLabel = getBottomLabel(text: (currentPlayersCards?[x].bottomText)!)
            
            // -40 is for animation
            let cardUIView = CardView(frame: CGRect(x: newX, y: space/2-cardInitialYBeforeAnimation, width: cardWidth, height: cardHeight))
            cardUIView.initCardView(topLabel: upLabel, bottomLabel: downLabel, playerId: (currentPlayersCards?[x].playerId)!, memeIV: memeImageView)
            
            var round: Round!
            
            for r in (game.rounds?.allObjects as? [Round])!{
                if Int(r.roundNum) == currentRound {
                    round = r
                    break
                }
            }
            
            getUserIconView(round: round, frame: memeImageView.frame, playerCard: currentPlayersCards![x], completeHandler: { (iv) in
                DispatchQueue.main.async {
                    cardUIView.addSubview(iv)
                    cardUIView.bringSubview(toFront: iv)
                }
            })
            
       
            if(currentPlayersCards![x].didWin){
                let borderForCard = self.getBorderForWinningCard()
                cardUIView.addSubview(borderForCard)
                cardUIView.bringSubview(toFront: borderForCard)
            }
            
            
            
            let playerLoves = currentPlayersCards?[x].playerlove?.allObjects as? [PlayerLove]
            
            for love in playerLoves!{
                if(love.playerId == MyPlayerData.id){
                    let heartView = getHeartView(frame: memeImageView.frame, playerCard: (currentPlayersCards?[x])!)
                    
                    heartView.alpha = 0
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat], animations: {
                        heartView.alpha = 1
                        heartView.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
                    }, completion: nil)
                    
                    
                    cardUIView.addSubview(heartView)
                    cardUIView.bringSubview(toFront: heartView)
                    break
                }
            }
            
            previewScrollView.addSubview(cardUIView)
            previewScrollView.bringSubview(toFront: cardUIView)
            
            cardUIView.alpha = 0.5
            
            UIView.animate(withDuration: 1, animations: {
                cardUIView.frame = CGRect(x: cardUIView.frame.origin.x, y: cardUIView.frame.origin.y + self.cardInitialYBeforeAnimation, width: self.cardWidth, height: self.cardHeight)
                cardUIView.alpha = 1
            })
        }
        previewScrollView.contentSize = CGSize(width: contentWidth, height: cardHeight)
    }
    
    func reloadCurrentPlayersIcon(){
        for v in currentPlayersScrollView.subviews {
            v.removeFromSuperview()
        }
        borderForUserIconIV.removeFromSuperview()
        
        var contentWidth = CGFloat(0)
        iconSize = currentPlayersScrollView.frame.height - space
        
        var counter = 0
        
        var round: Round!
        
        for r in (game.rounds?.allObjects as? [Round])!{
            if Int(r.roundNum) == currentRound {
                round = r
                break
            }
        }
        
        for player in (round.players?.allObjects as? [Player])!{
            let newX = (self.space * CGFloat(counter+1))  + CGFloat(counter) * self.iconSize
            var userIconIV = UIImageView()
            userIconIV.frame = CGRect(x: newX, y: self.space/4, width: self.iconSize, height: self.iconSize)
            contentWidth += self.space + self.iconSize
            
            counter = counter + 1
            
            let redDotSize = iconSize/4
            let redDotIV = UIImageView(image: #imageLiteral(resourceName: "redCircle"))
            redDotIV.frame = CGRect(x: iconSize/2 - (redDotSize)/2, y: 0, width: redDotSize, height: redDotSize)
            let whiteLabel = UILabel()
            
            var timesWon: Int!
            for c in (game.wincounter?.allObjects as? [WinCounter])!{
                if(c.playerId == player.playerId){
                    timesWon = Int(c.won)
                    break
                }
            }
            
            whiteLabel.text = "\(timesWon!)"
            whiteLabel.frame = CGRect(x: 0, y: 0, width: redDotSize, height: redDotSize)
            whiteLabel.textAlignment = .center
            whiteLabel.textColor = UIColor.white
            redDotIV.addSubview(whiteLabel)
            
            userIconIV.addSubview(redDotIV)
            userIconIV.bringSubview(toFront: redDotIV)
            
            
            let image = FileManagerHelper.getImageFromMemory(imagePath: player.imageStorageLocation!)
            userIconIV.image = image
            userIconIV = CircleImageCutter.roundImageView(imageview: userIconIV, radius: 5)
            
            self.currentPlayersScrollView.addSubview(userIconIV)
            self.currentPlayersScrollView.sendSubview(toBack: userIconIV)
            
            for card in (round.cardnormal?.allObjects as? [CardNormal])!{
                if(card.didWin && card.playerId == player.playerId){
                    self.borderForUserIconIV = self.getBorderIVForIcon(iconSize: self.iconSize)
                    userIconIV.addSubview(self.borderForUserIconIV)
                    userIconIV.bringSubview(toFront: self.borderForUserIconIV)
                }
            }
            
            currentPlayersScrollView.bringSubview(toFront: borderForUserIconIV)
        }
        
        currentPlayersScrollView.contentSize = CGSize(width: contentWidth, height: iconSize)
    }


}
