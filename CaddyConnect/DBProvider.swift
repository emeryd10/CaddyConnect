//
//  DBProvider.swift
//  CaddyConnect
//
//  Created by Dan Emery on 4/1/17.
//  Copyright © 2017 OneStopAthletics. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    private static let _instance = DBProvider();
    
    static var Instance: DBProvider {
        return _instance;
    }
    
    var dbRef: FIRDatabaseReference {
        return FIRDatabase.database().reference();
    }
    
    var ridersRef: FIRDatabaseReference {
        return dbRef.child(Constants.GOLFERS);
    }
    
    var requestRef: FIRDatabaseReference {
        return dbRef.child(Constants.CADDY_REQUEST);
    }
    
    var requestAcceptedRef: FIRDatabaseReference {
        return dbRef.child(Constants.CADDY_ACCEPTED);
    }
    
    func saveUser(withID: String, email: String, password: String) {
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.isGolfer: true];
        ridersRef.child(withID).child(Constants.DATA).setValue(data);
    }
    
} // class
