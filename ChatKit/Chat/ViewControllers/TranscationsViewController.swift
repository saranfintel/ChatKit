//
//  TranscationsViewController.swift
//  ChatKit
//
//  Created by saran on 28/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import UIKit

class TranscationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var transactionDetails: [TransactionDetails] = []
    var displayType: String = EMPTY_STRING
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        self.tableView.register(UINib(nibName: "ChatTransactionInfoCell", bundle: ChatWorkflowManager.bundle), forCellReuseIdentifier: "ChatTransactionInfoCell")
        self.tableView.separatorColor = ChatColor.sepertorLineTheme()
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        
    }
    
}

extension TranscationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView?.dequeueReusableCell(withIdentifier: "ChatTransactionInfoCell") as? ChatTransactionInfoCell else {
            return UITableViewCell()
        }
        let transactions = transactionDetails[indexPath.row]
        cell.updateCellValues(at: indexPath, transactions: transactions, displayType: displayType)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(CELL_HEIGHT)
    }
}

