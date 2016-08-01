//
//  LeftMenuViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import RealmSwift
import SwiftFetchedResultsController

class LeftMenuViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    lazy var fetchedResultsController: FetchedResultsController<Channel> = self.realmFetchedResultsController()
    var realm: Realm?

    
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var membersListButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureTableView()
        self.configureInitialSelectedChannel()
    }
    
    
    //MARK: - Configuration
    
    private func configureView() {
    }
    
    private func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = ColorBucket.sideMenuBackgroundColor
    }
    
    private func configureInitialSelectedChannel() {
        let indexPathForFirstRow = NSIndexPath(forRow: 0, inSection: 0) as NSIndexPath
        let initialSelectedChannel = self.fetchedResultsController.objectAtIndexPath(indexPathForFirstRow)
        ChannelObserver.sharedObserver.selectedChannel = initialSelectedChannel
    }
    
    
    //MARK: - Private
    
    private func didSelectChannelAtIndexPath(indexPath: NSIndexPath) -> Void {
        let selectedChannel = self.fetchedResultsController.objectAtIndexPath(indexPath)! as Channel
        ChannelObserver.sharedObserver.selectedChannel = selectedChannel
        self.tableView.reloadData()
        self.toggleLeftSideMenu()
    }
    
    private func toggleLeftSideMenu() {
        self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
    }
}

extension LeftMenuViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.numberOfRowsForSectionIndex(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = indexPath.section == 0 ? PublicChannelTableViewCell.reuseIdentifier() : PrivateChannelTableViewCell.reuseIdentifier()
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LeftMenuTableViewCellProtocol
        let channel = self.fetchedResultsController.objectAtIndexPath(indexPath) as Channel?
        cell.configureWithChannel(channel!, selected: (channel?.isSelected)!)
        
        return cell as! UITableViewCell
    }
}

extension LeftMenuViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSelectChannelAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 42
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRectMake(0, 0, UIScreen.screenWidth(), 20))
        view.backgroundColor = ColorBucket.sideMenuBackgroundColor
        
        return view
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRectMake(0, 0, UIScreen.screenWidth(), 20))
        view.backgroundColor = ColorBucket.sideMenuBackgroundColor
        
        return view
    }
}

extension LeftMenuViewController {
    // MARK: - FetchedResultsController
    
    func realmFetchedResultsController() -> FetchedResultsController<Channel> {
        let predicate = NSPredicate(format: "identifier != %@", "fds")
        let realm = try! Realm()
        let fetchRequest = FetchRequest<Channel>(realm: realm, predicate: predicate)
        fetchRequest.predicate = nil
        let sortDescriptorSection = SortDescriptor(property: ChannelAttributes.privateType.rawValue, ascending: false)
        let sortDescriptorName = SortDescriptor(property: ChannelAttributes.displayName.rawValue, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorSection, sortDescriptorName]
        let fetchedResultsController = FetchedResultsController<Channel>(fetchRequest: fetchRequest, sectionNameKeyPath: ChannelAttributes.privateType.rawValue, cacheName: nil)
        fetchedResultsController.delegate = nil//self
        fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }
}