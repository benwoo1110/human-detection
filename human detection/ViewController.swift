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
    @IBOutlet weak var video_feed: WKWebView!
    @IBOutlet weak var test: UILabel!
    @IBOutlet weak var data_view: UITableView!
    
    public let ip_address = "192.168.1.181:5000"
    
    public var Data:[String:[String]] = ["time":[], "duration":[], "num_today":[]]
    
    // MARK: Checking connection
    func doLabelChange(Response: String = "Disconnected") {
        DispatchQueue.main.async {
            if (Response == "connected") {
                self.test.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
                self.test.text = "Connected"
                
                self.video_feed.alpha = 1
            }
            else {
                self.test.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
                self.test.text = "Disconnected"
                
                self.video_feed.alpha = 0.2
            }
        }
    }
    
    func check_connection() {
        // Prepare URL
        guard let url = URL(string: "http://\(ip_address)/data") else { return }
        
        // Set as disconnected first
        self.doLabelChange()
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        request.httpMethod = "POST"

        let connect = "Connection from iPhone"
        request.httpBody = try! JSONEncoder().encode(connect)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    self.doLabelChange(Response: dataString)
                }
            }
            
        }
        task.resume()
    }
    
    
    // MARK: Recieving data
    func save_data(dictionary: [String:[String]]) {
        DispatchQueue.main.async {
            self.Data = dictionary
            }
    }
    
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
    
    
    // MARK: Table view for data
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data["time"]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DataTableViewCell
        
        cell.time.text = Data["time"]!.reversed()[indexPath.row]
        
        cell.duration.text = "Duration: " + Data["duration"]!.reversed()[indexPath.row] + " sec"
        
        cell.num_today.text = "counter: " + String(Data["time"]!.count - indexPath.row)
        
        return cell
    }
    
    // MARK: Startup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Run when app opens appears
        NotificationCenter.default.addObserver(self,
        selector: #selector(appWillEnterForeground),
        name: UIApplication.willEnterForegroundNotification,
        object: nil)
        
        // Check connection
        test.textAlignment = .center
        test.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        test.layer.cornerRadius = 15
        test.layer.masksToBounds = true
        
        check_connection()
        
        // Grab data from SQL
        get_data()
        _ = Timer.scheduledTimer(timeInterval: 5.0,
                                 target: self,
                                 selector: #selector(get_data),
                                 userInfo: nil,
                                 repeats: true)
        
        // Load live video feed
        video_feed.layer.cornerRadius = 30
        video_feed.layer.masksToBounds = true
        video_feed.scrollView.isScrollEnabled = false
        video_feed.scrollView.bounces = false
        video_feed.backgroundColor = .black
        
        let url = URL(string: "http://\(ip_address)/video_feed")!
        video_feed.load(URLRequest(url: url))
        
    }
    
    @objc func appWillEnterForeground() {
        check_connection()
        get_data()
        
        let url = URL(string: "http://\(ip_address)/video_feed")!
        video_feed.load(URLRequest(url: url))
    }

}

