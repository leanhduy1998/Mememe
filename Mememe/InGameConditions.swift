//
//  File.swift
//  Mememe
//
//  Created by Duy Le on 10/7/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

extension InGameViewController{
    func checkIfYourAreJudge(){
        if playerJudging == MyPlayerData.id {
            checkIfAllPlayersHaveInsertCard()
            AddEditJudgeMemeBtn.title = "Judge Your People!"
        }
            
        else if myCardInserted {
            AddEditJudgeMemeBtn.isEnabled = true
            AddEditJudgeMemeBtn.title = "Edit Your Meme"
        }
        else {
     //       AddEditJudgeMemeBtn.title = "Please Wait"
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self.AddEditJudgeMemeBtn.isEnabled = true
                self.AddEditJudgeMemeBtn.title = "Add Your Meme!"
            })
            
        }
    }
    func checkIfWinnerExist(cards: [CardNormal]) -> Bool{
        var haveWinner = false
        for card in cards {
            if card.didWin {
                haveWinner = true
                break
            }
        }
        return haveWinner
    }
    func checkIfMyCardExist(cards: [CardNormal]) -> Bool{
        var myCardExist = false
        for card in cards {
            if card.playerId == MyPlayerData.id {
                myCardExist = true
                break
            }
        }
        return myCardExist
    }
}
