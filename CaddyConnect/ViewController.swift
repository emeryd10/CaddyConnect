//
//  ViewController.swift
//  CaddyConnect
//
//  Created by Dan Emery on 4/1/17.
//  Copyright © 2017 OneStopAthletics. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Firebase



class ViewController: UIViewController {

    @IBOutlet weak var apointmentsLabel: UILabel!
    
    
    @IBAction func logout(_ sender: Any) {
        if logOut() {
            
            
            dismiss(animated: true, completion: nil);
            
        } else {
            // problem with logging out
            alertTheUser(title: "Could Not Logout", message: "We could not logout at the moment, please try again later");
        }
        
    }
    func logOut() -> Bool {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut();
                return true;
            } catch {
                return false;
            }
        }
        return true;
    }
    private func alertTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
class confirmationViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locLabel: UILabel!
    static var apptTime: String!
    static var apptLocation: String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        timeLabel.text = confirmationViewController.apptTime
        locLabel.text = confirmationViewController.apptLocation
        
    }
    @IBAction func sendRequest(_ sender: Any) {
        CaddyHandler.Instance.requestCaddy(latitude: Double(CaddyViewController.apptLocation!.latitude), longitude: Double(CaddyViewController.apptLocation!.longitude), time: timeLabel.text!, user: (FIRAuth.auth()?.currentUser?.uid)!)
        
    }
}

