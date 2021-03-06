//
//  InGameSwitchingRound.swift
//  Mememe
//
//  Created by Duy Le on 10/7/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import Firebase

extension InGameViewController{
    func savePeopleWhoLikedYou(){
        inGameRef.child(game.gameId!).child("normalCards").child(MyPlayerData.id).child("peopleLiked").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            DispatchQueue.main.async {
                let postDict = snapshot.value as? [String:Any]
                if(postDict == nil){
                    return
                }
                let cardNormals = GetGameCoreDataData.getLatestRound(game: self.game).cardnormal?.allObjects as? [CardNormal]
                
                for card in cardNormals! {
                    if(card.playerId == MyPlayerData.id){
                        var count = 0
                        for(id,_) in postDict!{
                            card.addToPlayerlove(PlayerLove(playerId: id, context: GameStack.sharedInstance.stack.context))
                            count = count + 1
                        }
                        PlayerDataDynamoDB.updateLaughes(laughes: count, completionHandler: { (error) in
                            if(error != nil){
                                print(error?.description)
                            }
                        })
                        break
                    }
                }
                GameStack.sharedInstance.saveContext {}
            }
        })
    }
    func updateNumberOfTimesYouAreCeasar(){
        PlayerDataDynamoDB.updateMadeCeasar(madeCeasar: 1) { (error) in
            if(error != nil){
                print(error?.description)
            }
        }
    }
    func getNextRoundDataLeader(completeHandler: @escaping (_ roundJudgeId:String, _ roundNumber: Int)-> Void){
        // create next Round data
        let currentRoundNumber = Int(GetGameCoreDataData.getLatestRound(game: self.game).roundNum)
        let nextRoundNumber = currentRoundNumber + 1
        
        var nextRoundJudgingId: String!
        
        for x in 0...(playersInGame.count - 1){
            if(playersInGame[x].userId == playerJudging){
                if(x == playersInGame.count-1){
                    nextRoundJudgingId = playersInGame[0].userId
                    break
                }
                else{
                    nextRoundJudgingId = playersInGame[x+1].userId
                    break
                }
            }
        }
        
        if(playersInGame.count == 1){
            completeHandler(MyPlayerData.id, nextRoundNumber)
        }
        else if(nextRoundJudgingId == nil){
            nextRoundJudgingId = playersInGame[0].userId
        }
        else{
            completeHandler(nextRoundJudgingId!, nextRoundNumber)
        }
        
    }
    func leaderCreateNewRoundBeforeNextRoundBegin(){
        if(MyPlayerData.id != leaderId){
            return
        }
        getNextRoundDataLeader { (nextRoundJudgeId, nextRoundNumber) in
            DispatchQueue.main.async {
                let helper = UserFilesHelper()
                helper.getRandomMemeData(completeHandler: { (memeData, memeUrl) in
                    DispatchQueue.main.async {
                        InGameHelper.updateGameToNextRound(nextRoundJudgeId: nextRoundJudgeId, gameId: self.game.gameId!, nextRound: nextRoundNumber, nextRoundImageUrl: memeUrl)
                        
                        let currentPlayersCore = GetGameCoreDataData.getLatestRound(game: self.game).players?.allObjects as? [Player]
                        
                        let nextRound = Round(roundNum: nextRoundNumber, context: GameStack.sharedInstance.stack.context)
                        
                        for player in currentPlayersCore!{
                            let copy = Player(playerName: player.name!, playerId: player.playerId!, userImageLocation: player.imageStorageLocation!, context: GameStack.sharedInstance.stack.context)
                            nextRound.addToPlayers(copy)
                        }
                        
                        let gameIdForStorage = FileManagerHelper.getPlayerIdForStorage(playerId: self.game.gameId!)
                        
                        let directory: [String] = ["Game","\(gameIdForStorage)"]
                        
                        let filePath = FileManagerHelper.insertImageIntoMemory(imageName: "round\(nextRoundNumber)", directory: directory, image: UIImage(data: memeData)!)
                        
                        nextRound.cardceasar = CardCeasar(playerId: nextRoundJudgeId, round: nextRoundNumber, cardDBurl: memeUrl, imageStorageLocation: filePath, context: GameStack.sharedInstance.stack.context)
                        
                        self.game.addToRounds(nextRound)
                    }
                })
            }
        }
    }
    func loadNextRound(){
        myCardInserted = false
        self.currentRoundFinished = false
        clearPreviewCardsData()
        cardOrder.removeAll()
        cardDictionary.removeAll()
        
        removeMemeThatAlreadyBeenPuttedOnTopPic()
        removeMemeThatAlreadyBeenPuttedOnBottomPic()
        
        let oldTopMemesCount = memeModel.topMemes.count
        let oldBottomMemesCount = memeModel.bottomMemes.count
        let oldFullMemesCount = memeModel.fullMemes.count
        
        memeModel = MemeHelper.refillCards(model: memeModel)
        memesArrangement.removeAll()
        memesArrangement.append(contentsOf: memeModel.topMemes)
        memesArrangement.append(contentsOf: memeModel.bottomMemes)
        memesArrangement.append(contentsOf: memeModel.fullMemes)
        
        for x in (oldTopMemesCount-1)...(memeModel.topMemes.count-1){
            memesRelatedPos[memeModel.topMemes[x]] = "top"
        }
        for x in (oldBottomMemesCount-1)...(memeModel.bottomMemes.count-1){
            memesRelatedPos[memeModel.bottomMemes[x]] = "bot"
        }
        for x in (oldFullMemesCount-1)...(memeModel.fullMemes.count-1){
            memesRelatedPos[memeModel.fullMemes[x]] = "full"
        }
        memesArrangement.shuffle()
        
        if MyPlayerData.id == self.leaderId {
            MememeDynamoDB.updateGame(itemToUpdate: gameDBModel!, game: game) { (error) in
                if(error != nil){
                    print(error.debugDescription)
                    return
                }
                self.reloadPreviewCards()
                self.reloadCurrentPlayersIcon()
                self.checkIfYourAreJudge()
            }
        }
        else {
            setupNextRoundForNonLeader {
                DispatchQueue.main.async {
                    MememeDynamoDB.updateGame(itemToUpdate: self.gameDBModel!, game: self.game) { (error) in
                        if(error != nil){
                            print(error.debugDescription)
                            return
                        }
                        DispatchQueue.main.async {
                            self.reloadPreviewCards()
                            self.reloadCurrentPlayersIcon()
                            self.checkIfYourAreJudge()
                            self.nextRoundStarting = false
                        }
                    }
                }
            }
        }
    }
    private func setupNextRoundForNonLeader(completeHandler: @escaping ()-> Void){
        let nextRoundNumber = Int(GetGameCoreDataData.getLatestRound(game: game).roundNum) + 1
        
        InGameHelper.getRoundImage( gameId: self.game.gameId!, completionHandler: { (memeData, memeUrl) in
            DispatchQueue.main.async {
                let nextRound = Round(roundNum: nextRoundNumber, context: GameStack.sharedInstance.stack.context)
                
                let currentPlayers = GetGameCoreDataData.getLatestRound(game: self.game).players?.allObjects as? [Player]
                
                for player in currentPlayers! {
                    let copy = Player(playerName: player.name!, playerId: player.playerId!, userImageLocation: player.imageStorageLocation!, context: GameStack.sharedInstance.stack.context)
                    nextRound.addToPlayers(copy)
                }
                
                let gameIdForStorage = FileManagerHelper.getPlayerIdForStorage(playerId: self.game.gameId!)
                
                let directory: [String] = ["Game","\(gameIdForStorage)"]
                
                let filePath = FileManagerHelper.insertImageIntoMemory(imageName: "round\(nextRoundNumber)", directory: directory, image: UIImage(data: memeData)!)
                
                nextRound.cardceasar = CardCeasar(playerId: self.playerJudging, round: nextRoundNumber, cardDBurl: memeUrl, imageStorageLocation: filePath, context: GameStack.sharedInstance.stack.context)
                
                self.game.addToRounds(nextRound)
                
                GameStack.sharedInstance.saveContext(completeHandler: {
                    completeHandler()
                })
            }
        })
    }
    
    func removeMemeThatAlreadyBeenPuttedOnTopPic(){
        if memesRelatedPos[myTopText] == "top" {
            var count = 0
            for meme in memeModel.topMemes {
                if meme == myTopText{
                    memeModel.topMemes.remove(at: count)
                    return
                }
                count = count + 1
            }
        }
        else if memesRelatedPos[myTopText] == "bot" {
            var count = 0
            for meme in memeModel.bottomMemes {
                if meme == myTopText{
                    memeModel.bottomMemes.remove(at: count)
                    return
                }
                count = count + 1
            }
        }
        else if memesRelatedPos[myTopText] == "full" {
            var count = 0
            for meme in memeModel.fullMemes {
                if meme == myTopText{
                    memeModel.fullMemes.remove(at: count)
                    return
                }
                count = count + 1
            }
        }
    }
    
    func removeMemeThatAlreadyBeenPuttedOnBottomPic(){
        if memesRelatedPos[myBottomText] == "top" {
            var count = 0
            for meme in memeModel.topMemes {
                if meme == myBottomText{
                    memeModel.topMemes.remove(at: count)
                    return
                }
                count = count + 1
            }
        }
        else if memesRelatedPos[myBottomText] == "bot" {
            var count = 0
            for meme in memeModel.bottomMemes {
                if meme == myBottomText{
                    memeModel.bottomMemes.remove(at: count)
                    return
                }
                count = count + 1
            }
        }
        else if memesRelatedPos[myBottomText] == "full" {
            var count = 0
            for meme in memeModel.fullMemes {
                if meme == myBottomText{
                    memeModel.fullMemes.remove(at: count)
                    return
                }
                count = count + 1
            }
        }
    }
}
