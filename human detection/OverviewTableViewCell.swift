//
//  DataTableViewCell.swift
//  human detection
//
//  Created by Ben Woo on 10/1/20.
//  Copyright © 2020 Ben Woo. All rights reserved.
//

import UIKit
import WebKit

class VideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var video_feed: WKWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        video_feed.layer.cornerRadius = 30
        video_feed.layer.masksToBounds = true
        video_feed.scrollView.isScrollEnabled = false
        video_feed.scrollView.bounces = false
        video_feed.backgroundColor = .black
        
        status.textAlignment = .center
        status.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        status.layer.cornerRadius = 15
        status.layer.masksToBounds = true
    }
    
    // MARK: Check connection
    func check_connection(ip_address: String) {
        // Set as disconnected first
        self.doLabelChange()
        
        // Prepare URL
        guard let url = URL(string: "http://\(ip_address)/data") else { return }
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
                    self.videoFeed(ip_address: ip_address)
                }
            }
        }
        task.resume()
    }
    
    // MARK: Update status label
    func doLabelChange(Response: String = "Disconnected") {
        DispatchQueue.main.async {
            if (Response == "connected") {
                self.status.backgroundColor = UIColor.green.withAlphaComponent(0.5)
                self.status.text = "Connected"
                
                self.video_feed.alpha = 1
            }
            else {
                self.status.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                self.status.text = "Disconnected"
                
                self.video_feed.alpha = 0.2
            }
        }
    }
    
    // MARK: Start video feed
    func videoFeed(ip_address: String) {
        DispatchQueue.main.async {
            let url = URL(string: "http://\(ip_address)/video_feed")!
            self.video_feed.load(URLRequest(url: url))
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class DataTableViewCell: UITableViewCell {

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var num_today: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        //layer.cornerRadius = 30
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
