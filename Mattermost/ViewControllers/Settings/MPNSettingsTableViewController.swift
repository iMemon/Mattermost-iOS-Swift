//
//  MPNSettingsTableViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 26.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class MPNSettingsTableViewController: UITableViewController {
    
//MARK: Properties
    fileprivate var saveButton: UIBarButtonItem!
    
    fileprivate var notifyProps = DataManager.sharedInstance.currentUser?.notificationProperies()
    fileprivate let user = DataManager.sharedInstance.currentUser
    
    var selectedSendOption: Int = 0
    var selectedTriggerOption: Int = 0
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.menuContainerViewController.panMode = .init(0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.menuContainerViewController.panMode = .init(3)
        
        super.viewWillDisappear(animated)
    }
}


fileprivate protocol Setup {
    func initialSetup()
    func setupNavigationBar()
    func setupForCurrentNotifyProps()
}

fileprivate protocol Action {
    func backAction()
    func saveAction()
}

private protocol Navigation {
    func returtToNSettings()
}

fileprivate protocol Request {
    func updateSettings()
}


//MARK: Setup
extension MPNSettingsTableViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupForCurrentNotifyProps()
    }
    
    func setupNavigationBar() {
        self.title = "Mobile push notifications"
        
        self.saveButton = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(saveAction))
        self.saveButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.saveButton
    }
    
    func setupForCurrentNotifyProps() {
        self.selectedSendOption = Constants.NotifyProps.Send.index { return $0.state == (self.notifyProps?.push)! }!
        self.selectedTriggerOption = Constants.NotifyProps.MobilePush.Trigger.index { return $0.state == (self.notifyProps?.pushStatus)! }!
    }
}


//MARK: Action
extension MPNSettingsTableViewController: Action {
    func backAction() {
        returtToNSettings()
    }
    
    func saveAction() {
        updateSettings()
    }
}


//MARK: Navigation
extension MPNSettingsTableViewController: Navigation {
    func returtToNSettings() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: Request
extension MPNSettingsTableViewController: Request {
    func updateSettings() {
        try! RealmUtils.realmForCurrentThread().write {
            self.notifyProps?.push = Constants.NotifyProps.Send[self.selectedSendOption].state
            self.notifyProps?.pushStatus = Constants.NotifyProps.MobilePush.Trigger[self.selectedTriggerOption].state
        }
        
        Api.sharedInstance.updateNotifyProps(self.notifyProps!) { (error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                return
            }
            self.saveButton.isEnabled = false
            let message = "User notification properties were successfully updated"
            AlertManager.sharedManager.showSuccesWithMessage(message: message)
        }
    }
}


//MARK: UITableViewDataSource
extension MPNSettingsTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if (indexPath.section == 0) {
            cell.accessoryType = (self.selectedSendOption == indexPath.row) ? .checkmark : .none
        } else {
            cell.accessoryType = (self.selectedTriggerOption == indexPath.row) ? .checkmark : .none
        }
        return cell
    }
}


//MARK: UITableViewDelegate
extension MPNSettingsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = (indexPath.section == 0) ? self.selectedSendOption : self.selectedTriggerOption
        guard indexPath.row != selectedRow else { return }
        
        self.saveButton?.isEnabled = true
        tableView.cellForRow(at: IndexPath(row: selectedRow, section: indexPath.section))?.accessoryType = .none
        if indexPath.section == 0 {
            self.selectedSendOption = indexPath.row
        } else {
            self.selectedTriggerOption = indexPath.row
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
}
