//
//  AvailableRoomHelper.swift
//  Mememe
//
//  Created by Duy Le on 9/13/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import FirebaseDatabase

class AvailableRoomHelper {
    //private static let ref = Database.database().reference()
    private static let availableRoomRef = Database.database().reference().child("availableRoom")
    
    static func uploadEmptyRoomToFirB(roomType: String){
        var onlyYouPlayerInRoom = [String:Any]()
        onlyYouPlayerInRoom[MyPlayerData.id] = MyPlayerData.name
        
        let room = AvailableRoomFirBModel(leaderName: MyPlayerData.name, leaderId: MyPlayerData.id, playerInRoom: onlyYouPlayerInRoom, roomType: roomType, roomImageUrl: "noURL", roomIsOpen: "true")
        
        let value = getMapStringValueFromRoom(room: room)
        
        availableRoomRef.child(room.leaderId!).setValue(value) { (err, reference) in
            if err == nil {
            }
        }
    }
    
    
    @objc static func updateRoomTimeTimer(timer:Timer){
        updateRoomTime(leaderId: timer.userInfo as! String)
    }
    
    static func makeMyRoomStatusClosed(){
        availableRoomRef.child(MyPlayerData.id).child("roomIsOpen").setValue("false")
    }
    
    static func getAllRoom(completionHandler: @escaping (_ roomArr: [AvailableRoomFirBModel]) -> Void){
        var roomArr = [AvailableRoomFirBModel]()

        availableRoomRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            for (leaderId,value) in postDict {
                let room = transferValueFromMapToRoom(leaderId: leaderId, map: value as! [String : AnyObject])
                roomArr.append(room)
            }
            
            completionHandler(roomArr)
        })
    }
    
    private static func getMapStringValueFromRoom(room: AvailableRoomFirBModel) -> [String:Any]{
        var map = [String:Any]()
        map["playerInRoom"] = room.playerInRoom
        map["roomType"] = room.roomType
        map["roomImageUrl"] = room.roomImageUrl
        map["roomIsOpen"] = room.roomIsOpen
        map["leaderName"] = room.leaderName
        return map
    }
    
    static func transferValueFromMapToRoom(leaderId: String, map: [String : AnyObject]) -> AvailableRoomFirBModel{
        let room = AvailableRoomFirBModel(leaderName: "", leaderId: leaderId, playerInRoom: [:], roomType: "", roomImageUrl: "", roomIsOpen: "false")
        
        for (key,value) in map {
            switch(key){
                case "roomType":
                    room.roomType = value as? String
                    break
                case "playerInRoom":
                    room.playerInRoom = value as? [String:Any]
                    break
                case "roomImageUrl":
                    room.roomImageUrl = value as? String
                    break
                case "roomIsOpen":
                    room.roomIsOpen = (value as! String)
                case "leaderName":
                    room.leaderName = (value as! String)
                break
                default:
                    fatalError()
                break
            }
        }
        return room
    }
    static func updateRoomTime(leaderId:String){
        GetGameData.getCurrentTimeInt { (timeInt) in
            let key = "/\(leaderId)/"
            let childUpdates = ["\(key)/lastActive": timeInt]
            availableRoomRef.updateChildValues(childUpdates)
        }
    }
    static func deleteMyAvailableRoom(completeHandler: @escaping ()-> Void){
        availableRoomRef.child(MyPlayerData.id).removeValue { (error, reference) in
            completeHandler()
        }
    }
    static func insertYourselfIntoSomeoneRoom(leaderId: String){        
        availableRoomRef.child(leaderId).child("playerInRoom").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            var playerInRoom = snapshot.value as? [String:Any]
            playerInRoom?[MyPlayerData.id] = MyPlayerData.name
            
            DispatchQueue.main.async {
                let key = "/\(leaderId)"
                let childUpdates = ["\(key)/playerInRoom": playerInRoom]
                availableRoomRef.updateChildValues(childUpdates)
            }
        })
    }
    static func removeYourselfIntoSomeoneRoom(leaderId: String, completeHandler: @escaping ()-> Void){
        availableRoomRef.child(leaderId).child("playerInRoom").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            var playerInRoom = snapshot.value as? [String:Any]
            playerInRoom?.removeValue(forKey: MyPlayerData.id)
            
            DispatchQueue.main.async {
                let key = "/\(leaderId)"
                let childUpdates = ["\(key)/playerInRoom": playerInRoom]
                availableRoomRef.updateChildValues(childUpdates, withCompletionBlock: { (error, reference) in
                    completeHandler()
                })
            }
        })
    }
    
    static func getMyRoom(completionHandler: @escaping (_ room: AvailableRoomFirBModel)->Void){
        availableRoomRef.child(MyPlayerData.id).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let room = transferValueFromMapToRoom(leaderId: MyPlayerData.id, map: postDict)
            completionHandler(room)
        })
    }
}
