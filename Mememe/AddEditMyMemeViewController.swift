//
//  AddEditYourMemeViewController.swift
//  Mememe
//
//  Created by Duy Le on 8/14/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class AddEditMyMemeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    
    var topUIView : UIView!
    var bottomUIView : UIView!
    var dragLabel : UILabel!
    
    var myPlayerId: String!
    var memeImage: UIImage!
    var game: Game!
    
    var leaderId:String!
    
    var imageviewHeight : CGFloat!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    @IBAction func finishBtnPressed(_ sender: Any) {
        let latestRound = GetGameCoreDataData.getLatestRound(game: game)
        let cardNormals = latestRound.cardnormal?.allObjects as? [CardNormal]
        
        var found = false
        for card in cardNormals! {
            if card.playerId == myPlayerId {
                found = true
                card.topText = topLabel.text!
                card.bottomText = bottomLabel.text!
                
                InGameHelper.insertNormalCardIntoGame(gameId: game.gameId!, card: card)
                break
            }
        }
        
        
        if !found {
            let myCard = CardNormal(bottomText: bottomLabel.text!, didWin: false, playerId: myPlayerId, round: Int((latestRound.roundNum)), topText: topLabel.text!, context: GameStack.sharedInstance.stack.context)
            latestRound.addToCardnormal(myCard)
            
            InGameHelper.insertNormalCardIntoGame(gameId: game.gameId!, card: myCard)
        }
        
                
        GameStack.sharedInstance.saveContext(completeHandler: {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "unwindToInGameViewController", sender: self)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? InGameViewController {
            destination.game = game
        }
    }
}
