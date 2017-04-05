//
//  SetTimeViewController.swift
//  CaddyConnect
//
//  Created by Dan Emery on 4/2/17.
//  Copyright © 2017 OneStopAthletics. All rights reserved.
//

import UIKit

class SetTimeViewController: UIViewController {
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    var time: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setApptTime(_ sender: Any) {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        time = dateFormatter.string(from: datePicker.date)
        performSegue(withIdentifier: "setTimeSegue", sender: sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "setTimeSegue") {
            let viewController:CaddyViewController = segue.destination as! CaddyViewController
            viewController.timeAppt = time

        }
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
