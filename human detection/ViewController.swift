//
//  ViewController.swift
//  human detection
//
//  Created by Ben Woo on 10/1/20.
//  Copyright © 2020 Ben Woo. All rights reserved.
//

import UIKit
import WebKit
import Charts


class ViewController: UIViewController, WKNavigationDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: Variables
    @IBOutlet weak var data_view: UITableView!
    
    public let ip_address = "192.168.1.249:5000"
    public var Data:[String:[String]] = ["year":["2020"], "month":["01"], "day":["1"], "time":["10:10"], "duration":["50"]]
    

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
                        self.data_view.reloadSections([1,2], with: UITableView.RowAnimation.fade)
                    }
                    
                }
            }
        }
        task.resume()
    }
    
    // MARK: Proccess time
    let formatter = RelativeDateTimeFormatter()
    func time(year: String, month: String, day: String) -> String {
        return "\(day)-\(month)-\(year)"
    }
    
    // MARK: Table view for data
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var title = "error"
        switch section {
        case 0: title = "Video Feed"
        case 1: title = "Chart"
        case 2: title = "Data"
        default: break
        }
        
        return title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.white.withAlphaComponent(0.7)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 21)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 0
        switch indexPath.section {
        case 0: height = 310
        case 1: height = 10 // 400
        case 2: height = 88
        default: break
        }
        
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var row = 0
        switch section {
        case 0: row = 1
        case 1: row = 1
        case 2: row = Data["time"]!.count
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
        
        // Chart
        if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chart_cell", for: indexPath) as! ChartTableViewCell
            
            var today = 0
            
            
            
            // cell.times_today =
            
            var dataPoints = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            
            var values: [Double] = [1,2,3,4,5,6,7]
            
            cell.draw_chart(dataPoints: dataPoints, values: values)
            
            cell.line_chart.isHidden = true
            
            
            return cell
        }
        
        // Data
        if (indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "data_cell", for: indexPath) as! DataTableViewCell
            
            let index = Data["time"]!.count - indexPath.row - 1
            
            cell.time.text = time(year: Data["year"]![index], month: Data["month"]![index], day: Data["day"]![index]) + ", \(Data["time"]![index])"
            
            cell.duration.text = "Duration: \(Data["duration"]![index]) sec"
            cell.num_today.text = "Counter: " + Data["day"]![index]
            
            return cell
        }
        
        let table = UITableViewCell()
        return table
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
        // data_view.reloadSections([1], with: .none)
    }
    

}

