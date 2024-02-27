//
//  CourierPreferences.swift
//  
//
//  Created by https://github.com/mikemilla on 2/26/24.
//

import UIKit

@available(iOS 15.0, *)
@available(iOSApplicationExtension, unavailable)
@objc open class CourierPreferences: UIView, UITableViewDelegate, UITableViewDataSource, UISheetPresentationControllerDelegate {
    
    // MARK: Channels
    
    private let availableChannels: [CourierUserPreferencesChannel]
    
    // MARK: Data
    
    private(set) var topics: [CourierUserPreferencesTopic] = []
    
    // MARK: UI
    
    @objc public let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let courierBar = CourierBar()
    
    public init(
        availableChannels: [CourierUserPreferencesChannel] = CourierUserPreferencesChannel.allCases
    ) {
        
        self.availableChannels = availableChannels
        
        if (availableChannels.isEmpty) {
            fatalError("Must pass at least 1 channel to the CourierPreferences initializer.")
        }
        
        super.init(frame: .zero)
        setup()
        
    }
    
    override init(frame: CGRect) {
        self.availableChannels = CourierUserPreferencesChannel.allCases
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.availableChannels = CourierUserPreferencesChannel.allCases
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
//        addCourierBar()
        addTableView()
        
        refresh()
        
    }
    
    @objc func refresh() {
        
        Task {
            
            refreshControl.beginRefreshing()
            
            let preferences = try await Courier.shared.getUserPreferences()
            topics = preferences.items
            
            tableView.reloadData()
            refreshControl.endRefreshing()
            
            
        }
        
    }
    
    // TODO: This
    private func addCourierBar() {
        
        addSubview(courierBar)
        
        NSLayoutConstraint.activate([
            courierBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            courierBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            courierBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    private func addTableView() {
        
        // Create the table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CourierTopicTableViewCell.self, forCellReuseIdentifier: CourierTopicTableViewCell.id)

        // Add the refresh control
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    @objc private func onRefresh() {
        refresh()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CourierTopicTableViewCell.id, for: indexPath) as! CourierTopicTableViewCell

        let topic = topics[indexPath.row]
        cell.configureCell(topic: topic)

        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = topics[indexPath.row]
        showSheet(topic: topic)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    private func showSheet(topic: CourierUserPreferencesTopic) {
        
        guard let parentViewController = parentViewController else {
            fatalError("CourierPreferences must be added to a view hierarchy with a ViewController.")
        }
        
        let sheetViewController = PreferencesSheetViewController()
        sheetViewController.topic = topic
        sheetViewController.view.backgroundColor = .white // TODO: HERE
        
        // Create the sheet controller
        let sheetPresentationController = sheetViewController.sheetPresentationController
        sheetPresentationController?.delegate = self
        sheetPresentationController?.prefersGrabberVisible = true
        sheetPresentationController?.preferredCornerRadius = 16
        
        // TODO: Handle all cases
        // Create a map of the values
        var switches = [CourierUserPreferencesChannel: CourierUserPreferencesStatus]()
        
        // If required prevent usage
        // If "IN" default to on or do custom routing
        // If "OUT" default to off or do custom routing
        
//        availableChannels.forEach { channel in
//            
//            switch (topic.status) {
//            case .optedIn:
//                switches[channel] = topic.customRouting.isEmpty ? .optedIn :
////            case .optedOut:
////            case .required:
////            default:
//            }
//            
////            switches[channel] = topic.customRouting.isEmpty ? topic.status :
//        }
        
        let sheet = CourierPreferencesSheet(
            title: topic.topicName,
            channels: availableChannels, 
            topic: topic,
            viewController: sheetViewController,
            onSheetClose: {
//                sheetPresentationController?.presentingViewController.dismiss(animated: true) {
//                    if let newTopic = sheetViewController.topic {
//                        self.savePreferences(newTopic: newTopic)
//                    }
//                }
            }
        )
        
        sheet.translatesAutoresizingMaskIntoConstraints = false
        sheetViewController.view.addSubview(sheet)
        
        NSLayoutConstraint.activate([
            sheet.topAnchor.constraint(equalTo: sheetViewController.view.topAnchor),
            sheet.leadingAnchor.constraint(equalTo: sheetViewController.view.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: sheetViewController.view.trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: sheetViewController.view.bottomAnchor)
        ])
        
        sheet.layoutIfNeeded()
        
        if #available(iOS 16.0, *) {
            let customDetent = UISheetPresentationController.Detent.custom { context in
                self.getSheetHeight(sheet: sheet)
            }
            sheetPresentationController?.detents = [customDetent, .large()]
        } else {
            sheetPresentationController?.detents = [.medium(), .large()]
        }
        
        parentViewController.present(sheetViewController, animated: true, completion: nil)
        
    }
    
    // Called when the view controller sheet is closed
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
        // Get the view controller
        let viewController = presentationController.presentedViewController as? PreferencesSheetViewController
        
        // Get the topic of the view controller
        if let topic = viewController?.topic {
            savePreferences(newTopic: topic)
        }
        
    }
    
    private func savePreferences(newTopic: CourierUserPreferencesTopic) {
        
        Courier.shared.putUserPreferencesTopic(
            topicId: newTopic.topicId,
            status: newTopic.status,
            hasCustomRouting: newTopic.hasCustomRouting,
            customRouting: newTopic.customRouting,
            onSuccess: {
                print("YAY")
            },
            onFailure: { error in
                print(error)
            }
        )
        
    }
    
    private func getSheetHeight(sheet: CourierPreferencesSheet) -> CGFloat {
        
        let margins = CourierPreferencesSheet.marginTop + CourierPreferencesSheet.marginBottom
        
        let navBarHeight = sheet.navigationBar.frame.height == 0 ? 56 : sheet.navigationBar.frame.height
        
        let itemHeight: CGFloat = CGFloat(64 * CourierUserPreferencesChannel.allCases.count)
        
        return margins + navBarHeight + itemHeight
        
    }
    
}

internal class CourierTopicTableViewCell: UITableViewCell {
    
    static let id = "CourierTopicTableViewCell"
    
    let itemLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(itemLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            itemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            itemLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            itemLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configureCell(topic: CourierUserPreferencesTopic) {
        itemLabel.text = topic.convertToJSONString()
    }
    
}

extension CourierUserPreferencesTopic {
    
    @objc func convertToJSONString() -> String? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.prettyPrinted]
        do {
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error converting to JSON: \(error.localizedDescription)")
        }
        return nil
    }
    
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            parentResponder = responder.next
        }
        return nil
    }
}

internal class PreferencesSheetViewController: UIViewController {
    var topic: CourierUserPreferencesTopic? = nil
}
