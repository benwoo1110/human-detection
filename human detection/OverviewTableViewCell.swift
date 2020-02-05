//
//  DataTableViewswift
//  human detection
//
//  Created by Ben Woo on 10/1/20.
//  Copyright © 2020 Ben Woo. All rights reserved.
//

import UIKit
import WebKit
import Charts

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
        video_feed.layer.borderColor = UIColor.black.cgColor
        video_feed.layer.borderWidth = 1.0
        
        status.textAlignment = .center
        status.backgroundColor = .red
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
            // self.video_feed.load(URLRequest(url: url))
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
        
        num_today.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class ChartTableViewCell: UITableViewCell {
    
    @IBOutlet weak var line_chart: LineChartView!
    
    @IBOutlet weak var times_today: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // line_chart.layer.cornerRadius = 20
        // line_chart.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        // line_chart.layer.masksToBounds = true
        
        line_chart.dragEnabled = true
        line_chart.setScaleEnabled(true)
        
        line_chart.xAxis.drawGridLinesEnabled = false
        line_chart.xAxis.enabled = true
        line_chart.xAxis.labelPosition = .bottom
        
        line_chart.leftAxis.drawGridLinesEnabled = false
        line_chart.xAxis.enabled = true
        
        line_chart.rightAxis.enabled = false
        
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func draw_chart(dataPoints: [String], values: [Double]) {
        var dataEntries = [ChartDataEntry]()
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let set = LineChartDataSet(entries: dataEntries, label: "Weekly summary")
        set.mode = .cubicBezier
        set.cubicIntensity = 0.2
        set.drawCirclesEnabled = true
        set.lineWidth = 1.8
        set.circleRadius = 4.0
        set.setCircleColor(.black)
        set.setColor(.red)
        set.fillColor = .red
        set.fillAlpha = 0.6
        set.drawFilledEnabled = true
        set.drawHorizontalHighlightIndicatorEnabled = false
        
        // line_chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["asdjfh"])
        
        let data = LineChartData(dataSet: set)
        data.setDrawValues(true)
        data.dataSets[0].valueFormatter = self as? IValueFormatter
        line_chart.data = data
    }
}
