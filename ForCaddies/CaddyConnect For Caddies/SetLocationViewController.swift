//
//  SetLocationViewController.swift
//  CaddyConnect For Caddies
//
//  Created by Dan Emery on 4/6/17.
//  Copyright © 2017 OneStopAthletics. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class SetLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var myMap: MKMapView!
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var caddyLocation: CLLocationCoordinate2D?
    
    var timeAppt: String!
    static var apptLocation: CLLocationCoordinate2D?
    
    private var timer = Timer()
    
    private var canCallCaddy = true
    private var golferCanceledRequest = false
    
    private var appStartedForTheFirstTime = true
    
    var resultSearchController: UISearchController? = nil
    
    var selectedPin: MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        CaddyHandler.Instance.observeMessagesForGolfer()
        //CaddyHandler.Instance.delegate = self
        
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = myMap
        
        locationSearchTable.handleMapSearchDelegate = self
        instructions()
        
        
        
    }

    
    private func instructions() {
        let instructionAlert = UIAlertController(title: "Setting Location", message: "Search for the golf course you wish to play on. Once selected, a marker will be place on the golf course you chose. If this is the correct location, select the 'Set Location' button.", preferredStyle: .alert)
        
        
        instructionAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
        }))
        
        self.present(instructionAlert, animated:true, completion: nil)
        
    }
    
    
    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // if we have the coordinates from the manager
        if let location = locationManager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            
            //myMap.setRegion(region, animated: true);
            
            //myMap.removeAnnotations(myMap.annotations);
            
            
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!;
            annotation.title = "My Location";
            myMap.addAnnotation(annotation);
        }
        
    }
    
    func updateCaddyLocation(lat: Double, long: Double) {
        CaddyHandler.Instance.updateCaddyLocation(lat: userLocation!.latitude, long: userLocation!.longitude);
    }
    
    
    func canCallCaddy(delegateCalled: Bool) {
        if delegateCalled {
            //callCaddy.setTitle("Cancel Uber", for: UIControlState.normal);
            canCallCaddy = true;
        } else {
            //callCaddy.setTitle("Call Uber", for: UIControlState.normal);
            canCallCaddy = true;
        }
    }
    func caddyAcceptedRequest(requestAccepted: Bool, caddyName: String) {
        
        if !golferCanceledRequest {
            if requestAccepted {
                alertTheUser(title: "Request Accepted", message: "\(caddyName) Accepted Your Request For A Caddy")
            } else {
                CaddyHandler.Instance.cancelCaddy();
                timer.invalidate();
                alertTheUser(title: "Caddy Canceled", message: "\(caddyName) Canceled Request")
            }
        }
        golferCanceledRequest = false;
    }
    private func alertTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }
    
    @IBAction func setLoc(_ sender: Any) {
        if SetLocationViewController.apptLocation != nil {
            if canCallCaddy {
                //CaddyHandler.Instance.requestCaddy(latitude: Double(SetLocationViewController.apptLocation!.latitude), longitude: Double(SetLocationViewController.apptLocation!.longitude), user: (FIRAuth.auth()?.currentUser?.uid)!)
                CaddyHandler.Instance.setCaddyLocation(latitude: Double(SetLocationViewController.apptLocation!.latitude), longitude: Double(SetLocationViewController.apptLocation!.longitude), user: "Dan Emery")
                
                //timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(CaddyViewController.updateCaddyLocation), userInfo: nil, repeats: true);
                
            } else {
                golferCanceledRequest = true;
                CaddyHandler.Instance.cancelCaddy();
                timer.invalidate();
            }
        } else {
            let setAlert = UIAlertController(title: "Please Choose Location", message: "Search for the golf course you wish to play on. Once selected, a marker will be place on the golf course you chose. If this is the correct location, select the 'Set Location' button.", preferredStyle: .alert)
            
            
            setAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
            }))
            
            self.present(setAlert, animated:true, completion: nil)
            
        }
    }
    @IBAction func set(_ sender: Any) {
        if SetLocationViewController.apptLocation != nil {
            if canCallCaddy {
                
                CaddyHandler.Instance.requestCaddy(latitude: Double(SetLocationViewController.apptLocation!.latitude), longitude: Double(SetLocationViewController.apptLocation!.longitude), user: (FIRAuth.auth()?.currentUser?.uid)!)
               
                
                //timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(CaddyViewController.updateCaddyLocation), userInfo: nil, repeats: true);
                
            } else {
                golferCanceledRequest = true;
                CaddyHandler.Instance.cancelCaddy();
                timer.invalidate();
            }
        } else {
            let setAlert = UIAlertController(title: "Please Choose Location", message: "Search for the golf course you wish to play on. Once selected, a marker will be place on the golf course you chose. If this is the correct location, select the 'Set Location' button.", preferredStyle: .alert)
            
            
            setAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
            }))
            
            self.present(setAlert, animated:true, completion: nil)
            
        }
        //performSegue(withIdentifier: "confirmSegue", sender: sender)
        
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
}

extension SetLocationViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        myMap.removeAnnotations(myMap.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        SetLocationViewController.apptLocation = annotation.coordinate
        print("MARK")
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        myMap.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        myMap.setRegion(region, animated: true)
    }
}
