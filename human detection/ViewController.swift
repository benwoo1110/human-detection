//
//  ViewController.swift
//  human detection
//
//  Created by Ben Woo on 10/1/20.
//  Copyright © 2020 Ben Woo. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: Variables
    @IBOutlet weak var data_view: UITableView!
    
    public let ip_address = "192.168.1.181:5000"
    public var Data:[String:[String]] = ["year":[], "month":[], "day":[], "time":[], "duration":[]]
    
    
    // MARK: Recieving data
    @objc func get_data() {
        // Prepare URL
        let url = URL(string: "http://\(ip_address)/data")!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
                    let dictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String : [String]]
                    DispatchQueue.main.async {
                        self.Data = dictionary!
                        self.data_view.reloadData()
                    }
                    
                }
            }
        }
        task.resume()
    }
    
    func save_data(dictionary: [String:[String]]) {
        DispatchQueue.main.async {
            self.Data = dictionary
            }
    }
    
    // MARK: Table view for data
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = "error"
        switch section {
        case 0: title = "Video Feed"
        case 1: title = "Data"
        default: break
        }
        
        return title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 0
        switch indexPath.section {
        case 0: height = 316
        case 1: height = 88
        default: break
        }
        
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var row = 0
        switch section {
        case 0: row = 1
        case 1: row = 10
        default: break
        }
        
        return row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Video feed
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "video_cell", for: indexPath) as! VideoTableViewCell
            cell.check_connection(ip_address: ip_address)
            
            return cell
        }
        
        // Data
        if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "data_cell", for: indexPath) as! DataTableViewCell
            
            cell.time.text = "blahh"
            cell.duration.text = "10000000 sec"
            cell.num_today.text = "1"
            
            return cell
        }
        else {
            let table = UITableViewCell()
            return table
        }
        
        /*
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DataTableViewCell
        
        cell.time.text = Data["time"]!.reversed()[indexPath.row]
        
        cell.duration.text = "Duration: " + Data["duration"]!.reversed()[indexPath.row] + " sec"
        
        cell.num_today.text = "counter: " + String(Data["time"]!.count - indexPath.row)
    */
        
    }
    
    // MARK: Startup
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set large title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Run when app opens appears
        NotificationCenter.default.addObserver(self,
        selector: #selector(appWillEnterForeground),
        name: UIApplication.willEnterForegroundNotification,
        object: nil)
        
        // Grab data every 5 seconds from SQL
        get_data()
        _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(get_data), userInfo: nil, repeats: true)
    }
    
    @objc func appWillEnterForeground() {
        get_data()
        data_view.reloadData()
    }
    

}

