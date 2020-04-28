//
//  AccountsViewController.swift
//  ChatKit
//
//  Created by saran on 28/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import UIKit

class AccountsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var accounts: [Account] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        self.tableView.register(UINib(nibName: "ChatConnectedAccountCell", bundle: ChatWorkflowManager.bundle), forCellReuseIdentifier: "ChatConnectedAccountCell")
        self.tableView.separatorColor = ChatColor.sepertorLineTheme()
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        
    }

    
}

extension AccountsViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView?.dequeueReusableCell(withIdentifier: "ChatConnectedAccountCell") as? ChatConnectedAccountCell else {
            return UITableViewCell()
        }
        let account = accounts[indexPath.row]
        cell.selectionStyle = .none
        cell.updateCellValues(at: indexPath, account: account)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(CELL_HEIGHT)
    }
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(CELL_HEIGHT)
    }
}
