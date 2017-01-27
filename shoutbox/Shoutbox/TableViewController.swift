//
//  TableViewController.swift
//  Shoutbox
//
//  Created by Michał Topór-Futer on 20/01/17.
//  Copyright © 2017 Futerzak. All rights reserved.
//

import UIKit
import Alamofire
import DGElasticPullToRefresh

fileprivate let BackendSecret = ""
fileprivate let ServerUrl = ""
fileprivate let ServerFullUrl = ServerUrl + BackendSecret

typealias MessageType = (messageText: String, from: String, time: Date)

class TableViewController: UITableViewController {

    var messages = Array<MessageType>() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.fetchDataFromServer()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        
    }
    @IBAction func newMessageButton(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("New message", comment: ""), message: NSLocalizedString("Please state your name and message", comment: ""), preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("Your name", comment: "")
        } )
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("Your message", comment: "")
        } )
        let sendAction = UIAlertAction(title: NSLocalizedString("Send", comment: ""), style: .default, handler: { action in
            let name = alertController.textFields?[0].text
            let message = alertController.textFields?[1].text
            self.sendMessage(message: message!, from: name!)
            
        })
        alertController.addAction(sendAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: { _ in })
        
        
    }
    
    private func sendMessage(message: String, from: String) {
        Alamofire.request(ServerFullUrl, method: .post, parameters: ["name": from, "message": message])
            .responseJSON{ response in
                guard response.error == nil else {
                    self.showErrorMessage()
                    return;
                }
                self.fetchDataFromServer()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchDataFromServer()
    }

    private func fetchDataFromServer() {
        Alamofire.request(ServerFullUrl).responseJSON { response in
            guard response.error == nil, let messages = ((response.result.value as? Dictionary<String, Any>)?["entries"] as? Array<Dictionary<String, Any>>) else {
                
                self.showErrorMessage()
                self.tableView.dg_stopLoading()
                return;
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            
            var messagesArray: Array<MessageType> = []
            
            messages.forEach({ message in
                let messageText = message["message"] as! String
                let from = message["name"] as! String
                 let timestampText = message["timestamp"] as! String
                let messageDate = formatter.date(from: timestampText)!
               
                let msg : MessageType = (messageText: messageText, from: from, time: messageDate)
                
                messagesArray.append(msg)
                
            })
            
            messagesArray.reverse()
            self.messages = messagesArray
            self.tableView.dg_stopLoading()
            
        }
    }
    
    private func showErrorMessage() {
        let alertController = UIAlertController(title: NSLocalizedString("ConnectionErrorTitle", comment: ""), message: NSLocalizedString("ConnectionErrorMessage", comment: ""), preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { _ in })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: { _ in })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        let message = messages[indexPath.row]
        
        cell.textLabel?.text = getCurrentTimestamp(from: message.time)
        cell.detailTextLabel?.text = message.from + NSLocalizedString("Says", comment: "") + message.messageText

        

        return cell
    }
    
    private func getCurrentTimestamp(from date: Date) -> String {
       
        let now = Date().timeIntervalSince(date)
        
        var value: Int
        var timeUnit: String
        
        switch now{
            case 0..<60:
            value = Int(now)
            timeUnit = NSLocalizedString("seconds", comment: "")
            break;
        case 60..<3600:
            value = Int(now/60)
            timeUnit = NSLocalizedString("minutes", comment: "")
            break;
        case 3600..<86400:
            value = Int(now/3600)
            timeUnit = NSLocalizedString("hours", comment: "")
            break;
            
            default:
            value = Int(now/86400)
            timeUnit = NSLocalizedString("days", comment: "")
            
        }
        
        
        return "\(value) \(timeUnit) " + NSLocalizedString("ago", comment: "")
    }
    
    
}
