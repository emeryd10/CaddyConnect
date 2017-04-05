//
//  CaddyHandler.swift
//  CaddyConnect
//
//  Created by Dan Emery on 4/1/17.
//  Copyright © 2017 OneStopAthletics. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol CaddyController: class {
    func canCallCaddy(delegateCalled: Bool)
    func caddyAcceptedRequest(requestAccepted: Bool, caddyName: String)
    func updateCaddyLocation(lat: Double, long: Double)
}

class CaddyHandler {
    private static let _instance = CaddyHandler();
    
    weak var delegate: CaddyController?
    var golfer = ""
    var caddy = ""
    var golfer_id = ""
    
    static var Instance: CaddyHandler {
        return _instance
    }
    
    func observeMessagesForGolfer() {
        //Caddy requested
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded) { (snapshot:FIRDataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.golfer {
                        self.golfer_id = snapshot.key
                        self.delegate?.canCallCaddy(delegateCalled: true)
                    }
                }
            }
        }
        //Golfer Cancelled Caddy
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childRemoved) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.golfer {
                        self.delegate?.canCallCaddy(delegateCalled: false);
                    }
                }
            }
        }
        // Caddy Accepted Request
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if self.caddy == "" {
                        self.caddy = name;
                        self.delegate?.caddyAcceptedRequest(requestAccepted: true, caddyName: self.caddy)
                    }
                }
            }
        }
        
        // Caddy Cancelled Request
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childRemoved) { (snapshot:FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.caddy {
                        self.caddy = "";
                        self.delegate?.caddyAcceptedRequest(requestAccepted: false, caddyName: name);
                    }
                }
            }
        }
        
    }
    func requestCaddy(latitude: Double, longitude: Double, time: String, user: String) {
        let data: Dictionary<String, Any> = [Constants.NAME: golfer, Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude, Constants.TIME: time]
        DBProvider.Instance.requestRef.child(user).child(ManageTableViewController.count).setValue(data)
    }
    func cancelCaddy() {
        DBProvider.Instance.requestRef.child(golfer_id).removeValue()
    }
    func updateCaddyLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestRef.child(golfer_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long]);
    }
    
}
