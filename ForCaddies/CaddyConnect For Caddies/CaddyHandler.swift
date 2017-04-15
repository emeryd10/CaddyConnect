//
//  CaddyHandler.swift
//  CaddyConnect For Caddies
//
//  Created by Dan Emery on 4/6/17.
//  Copyright © 2017 OneStopAthletics. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol CaddyController: class {
    func acceptRequest(lat: Double, long: Double);
    func golferCanceledRequest();
    func requestCanceled();
    func updateGolfersLocation(lat: Double, long: Double);
}

class CaddyHandler {
    private static let _instance = CaddyHandler();
    
    weak var delegate: CaddyController?
    var golfer = ""
    var caddy = ""
    var caddy_id = ""
    
    static var Instance: CaddyHandler {
        return _instance
    }
    
    func observeMessagesForGolfer() {
        // GOLFER REQUESTED A REQUEST
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        self.delegate?.acceptRequest(lat: latitude, long: longitude);
                    }
                }
                
                if let name = data[Constants.NAME] as? String {
                    self.golfer = name;
                }
                
            }
            
            // GOLFER CANCELED REQEUST
            DBProvider.Instance.requestRef.observe(FIRDataEventType.childRemoved, with: { (snapshot: FIRDataSnapshot) in
                
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.golfer {
                            self.golfer = "";
                            self.delegate?.golferCanceledRequest();
                        }
                    }
                }
                
            });
            
        }
        
        // GOLFER UPDATING LOCATION
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childChanged) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let lat = data[Constants.LATITUDE] as? Double {
                    if let long = data[Constants.LONGITUDE] as? Double {
                        self.delegate?.updateGolfersLocation(lat: lat, long: long);
                    }
                }
            }
            
        }
        
        // CADDY ACCEPTS REQUEST
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.caddy {
                        self.caddy_id = snapshot.key;
                    }
                }
            }
            
        }
        
        // DRIVER CANCELED UBER
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childRemoved) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.caddy {
                        self.delegate?.requestCanceled();
                    }
                }
            }
            
        }
        
    } // observeMessagesForDriver
    func requestCaddy(latitude: Double, longitude: Double, user: String) {
        let data: Dictionary<String, Any> = [Constants.NAME: golfer, Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude]
        DBProvider.Instance.requestRef.child(user).setValue(data)
    }
    func cancelCaddy() {
        DBProvider.Instance.requestRef.child(caddy_id).removeValue()
    }
    func updateCaddyLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestRef.child(caddy_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long]);
    }
    func setCaddyLocation(latitude: Double, longitude: Double, user: String) {
        let data: Dictionary<String, Any> = [Constants.NAME: golfer, Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude]
        DBProvider.Instance.requestRef.child("Caddies").child(user).setValue(data)
    }
    
}
