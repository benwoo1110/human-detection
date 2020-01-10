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
    
    public let ip_address = "192.168.1.249:5000"
    
    public var Response: String = "LOL"
    public var Data:[String:[String]] = ["time":["lol", "test"], "duration":["10", "10000"]]
    
    // MARK: Checking connection
    func doLabelChange() {
        DispatchQueue.main.async {
               self.test.text = self.Response
            }
    }
    
    func test_post() {
        // Prepare URL
        guard let url = URL(string: "http://\(ip_address)/data") else { return }
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        request.httpMethod = "POST"

        let dictionary = ["email": "username", "userPwd": "password"]
        request.httpBody = try! JSONEncoder().encode(dictionary)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    self.Response = dataString
                    print("data: \(self.Response)")
                    self.doLabelChange()
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
        return 132
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data["time"]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DataTableViewCell
        
        cell.time.text = Data["time"]![indexPath.row]
        
        cell.duration.text = Data["duration"]![indexPath.row] + " sec"
        
        cell.num_today.text = String(indexPath.row + 1)
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        get_data()
        
        _ = Timer.scheduledTimer(timeInterval: 5.0,
                                 target: self,
                                 selector: #selector(get_data),
                                 userInfo: nil,
                                 repeats: true)
        
        let url = URL(string: "http://\(ip_address)/video_feed")!
        video_feed.load(URLRequest(url: url))
        
        test_post()
    }
}

