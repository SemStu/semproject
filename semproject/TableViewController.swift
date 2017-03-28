//
//  TableViewController.swift
//  semproject
//
//  Created by Sem Sturkenboom on 21-03-17.
//  Copyright © 2017 Sem Sturkenboom. All rights reserved.
//

import UIKit
import Firebase

class TableViewController: UITableViewController {

    var data : NSDictionary? = [:]
    var rows : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestTable()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! cell

        // configure the cell
        let keys = self.data?.allKeys
        let key = self.data?[keys![indexPath.row]] as! NSDictionary
        
        cell.symbol.text = String(describing: key["symbol"]!)
        cell.companyName.text = String(describing: key["name"]!)

        return cell
    }

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


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? SymbolViewController {
            
            URLSession.shared.dataTask(with: apiRequestFromTable()) { (data, response, error) in
                if error != nil {
                    print(error!)
                } else {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                        let dataset = json["query"] as? [String: Any]
                        let results = dataset?["results"] as? [String: Any]
                        let quote = results?["quote"] as! [String: Any]

                        // assign values to placeholders
                        DispatchQueue.main.async {
                            if let lastPrice = quote["LastTradePriceOnly"] as? String {
                            viewController.price.text = lastPrice
                            }
                            if let volume = quote["Volume"] as? String {
                            viewController.volume.text = "Volume: " + volume
                            }
                            if let lastTradeDate = quote["LastTradeDate"] as? String {
                            viewController.lastTradingDate.text = "Last Trade Date: " + lastTradeDate
                            }
                            if let marketCap = quote["MarketCapitalization"] as? String {
                            viewController.marketCap.text = "Market Cap.: " + marketCap
                            }
                            if let dividendPayDate = quote["DividendPayDate"] as? String {
                            viewController.dividendPayDate.text = "Div. Paydate: " + dividendPayDate
                            }
                            if let dividendYield = quote["DividendYield"] as? String {
                            viewController.dividendYield.text = "Div. Yield: " + dividendYield
                            }
                            if let previousClose = quote["PreviousClose"] as? String {
                            viewController.previousClose.text = "Prev. Close: " + previousClose
                            }
                        }
                        
                    } catch let error as NSError {
                        print(error)
                    }
                }
                }.resume()
        }
    }
    
    func apiRequestFromTable() -> URL {
        // get symbol of selected row
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)
        let string = currentCell?.detailTextLabel?.text
        
        //request data from yahoo
        let url = URL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22" + string! + "%22)&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=")
        
        return url!
    }
    
    func requestTable() {
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        // create snapshot of database for use in tableview
        ref.child("users").child(userID!).child("symbols").observeSingleEvent(of: .value, with: { (snapshot) in
                self.data = (snapshot.value as? NSDictionary)
                self.rows = Int(snapshot.childrenCount)
                self.tableView.reloadData()
            }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}
