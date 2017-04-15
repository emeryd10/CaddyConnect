//
//  CaddyVC.swift
//  CaddyConnect For Caddies
//
//  Created by Dan Emery on 4/6/17.
//  Copyright © 2017 OneStopAthletics. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class CaddyVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, CaddyController {
    
    
    @IBOutlet weak var myMap: MKMapView!
    
    
    @IBOutlet weak var acceptRequestBtn: UIButton!
    
    
    private var locationManager = CLLocationManager();
    private var userLocation: CLLocationCoordinate2D?;
    private var golferLocation: CLLocationCoordinate2D?;
    
    private var timer = Timer();
    
    private var acceptedRequest = false;
    private var caddyCanceledRequest = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLocationManager();
        
        CaddyHandler.Instance.delegate = self;
        CaddyHandler.Instance.observeMessagesForGolfer();
        
    }
    
    private func initializeLocationManager() {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // if we have the coordinates from the manager
        if let location = locationManager.location?.coordinate {
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            
            myMap.setRegion(region, animated: true);
            
            myMap.removeAnnotations(myMap.annotations);
            
            if golferLocation != nil {
                if acceptedRequest {
                    let riderAnnotation = MKPointAnnotation();
                    riderAnnotation.coordinate = golferLocation!;
                    riderAnnotation.title = "Golfer's Location";
                    myMap.addAnnotation(riderAnnotation);
                }
            }
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!;
            annotation.title = "Caddy's Location";
            myMap.addAnnotation(annotation);
            
        }
        
    }

    
    func acceptRequest(lat: Double, long: Double) {
        if !acceptedRequest {
            caddyRequest(title: "Caddy Request", message: "You have a caddy request at this location Lat: \(lat), Long: \(long)", requestAlive: true);
        }
    }
    
    func golferCanceledRequest() {
        if !caddyCanceledRequest {
            CaddyHandler.Instance.cancelCaddy();
            self.acceptedRequest = false;
            self.acceptRequestBtn.isHidden = true;
            caddyRequest(title: "Caddy Request Canceled", message: "The Rider Has Canceled The Request For A Caddy", requestAlive: false);
        }
    }
    
    func requestCanceled() {
        acceptedRequest = false;
        acceptRequestBtn.isHidden = true;
        timer.invalidate();
    }
    
    func updateGolfersLocation(lat: Double, long: Double) {
        golferLocation = CLLocationCoordinate2D(latitude: lat, longitude: long);
    }
    
    func updateCaddyLocation() {
        CaddyHandler.Instance.updateCaddyLocation(lat: userLocation!.latitude, long: userLocation!.longitude);
    }
    
    @IBAction func cancelRequest(_ sender: AnyObject) {
        if acceptedRequest {
            caddyCanceledRequest = true;
            acceptRequestBtn.isHidden = true;
            CaddyHandler.Instance.cancelCaddy();
            timer.invalidate();
        }
    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        if logOut() {
            
            if acceptedRequest {
                acceptRequestBtn.isHidden = true;
                CaddyHandler.Instance.cancelCaddy();
                timer.invalidate();
            }
            
            dismiss(animated: true, completion: nil);
            
        } else {
            // problem with loging out
            caddyRequest(title: "Could Not Logout", message: "We could not logout at the moment, please try again later", requestAlive: false)
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
    
    private func caddyRequest(title: String, message: String, requestAlive: Bool) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        
        if requestAlive {
            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction: UIAlertAction) in
                
                self.acceptedRequest = true;
                self.acceptRequestBtn.isHidden = false;
                
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(CaddyVC.updateCaddyLocation), userInfo: nil, repeats: true);
                
                CaddyHandler.Instance.requestCaddy(latitude: Double(self.userLocation!.latitude), longitude: Double(self.userLocation!.longitude), user: (FIRAuth.auth()?.currentUser?.uid)!);
                
            });
            
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil);
            
            alert.addAction(accept);
            alert.addAction(cancel);
            
        } else {
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
            alert.addAction(ok);
        }
        
        present(alert, animated: true, completion: nil);
    }

    
} // class
