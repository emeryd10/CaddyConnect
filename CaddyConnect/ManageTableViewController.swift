//
//  ManageTableViewController.swift
//  CaddyConnect
//
//  Created by Dan Emery on 4/4/17.
//  Copyright © 2017 OneStopAthletics. All rights reserved.
//

import UIKit
import Firebase

class ManageTableViewController: UITableViewController {
    
    var appts: [String] = ["YOU CURRENTLY HAVE NO APPOINTMENTS SETUP"]
    var dbRef: FIRDatabaseReference = FIRDatabase.database().reference().child("Caddy_Request").child((FIRAuth.auth()?.currentUser?.uid)!)
    static var count: String = "0"

    override func viewDidLoad() {
        super.viewDidLoad()

        getCount()
        startObservingDB()
        tableView.delegate = self
        tableView.dataSource = self


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCount() {
        dbRef.observe(.value, with: { (snapshot:FIRDataSnapshot) in
            let temp = snapshot.childrenCount
            ManageTableViewController.count = String(temp)
        })
    }

    func startObservingDB () {
        var temp = [String]()
        let num = Int(ManageTableViewController.count)!
        for i in 0..<num {
            let tempRef = dbRef.child("\(i)")
            tempRef.observe(.value, with: { (snapshot:FIRDataSnapshot) in
                print(i)
                if let data = snapshot.value as? NSDictionary {
                    print("mark2")

                    if let time = data[Constants.TIME] {
                        print("mark3")

                        temp.append(time as! String)
                        print(time)
                    }
                    
                }
                self.appts = temp
                self.tableView.reloadData()
            })
        }

        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return appts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        cell.backgroundColor = self.view.backgroundColor
        cell.textLabel?.text = "Place \(indexPath.row + 1)"
        cell.detailTextLabel?.text = appts[indexPath.row]
        
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // remove the item from the data model
            appts.remove(at: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            //CaddyViewController.canCallCaddy = false
            dbRef.child("\(indexPath.row)").removeValue()
            startObservingDB()
            
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
