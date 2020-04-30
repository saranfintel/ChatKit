//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Sarankumar on 10/12/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import CoreData
import AVKit
import AVFoundation
import Speech

class ChatViewController: MessagesViewController, UIGestureRecognizerDelegate {
    
    // Int Declaration
    var fetchLimit: Int = kMessageThreshold
    // This flag is to determine whether to reload the only cell in the "load earlier section". If there are no messages (inclusive of both ChatDBMessage and ChatDBUnsentMessage objects), then we need to show EmptyStateCell. Else, show LoadEarlierCell/NoMoreEarlierMessages
    
    // BOOL Declaration
    var shouldRefreshLoadEarlierCell = false
    var isFetchingEarlierMessages = false
    var canMakeLoadMoreCall = true

    // Dict Declaration
    let emojis = ["thank you" : "👍", "laugh": "😂😂😂", "Hi": "👋👋👋", "omg": "😱😱😱", "smile": "😃😃😃","love": "❤️"]
    
    let refreshControl = UIRefreshControl()

    var playerLayer = AVPlayerLayer()
    var player: AVPlayer?
    
    var customView: UIView?


    // Voice to Text vars
    var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    var timer:Timer?
    var count: Int = 0
    
    var chatViewModel: ChatViewModel? = ChatViewModel()

    // Date formatter
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = timeFormat
        return formatter
    }()

    //BOA changes
    var updatedMicStatus = true
    var listenerTimer:Timer?
    var lastString = ""
    var lastStringLength = 0

    let typingBubble = TypingBubble(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 50)))

    var floatingQuestionViewFlag: Bool = false
    var floatingQuestionView: SiriContentView = {
        let myNewView = SiriContentView.instanceFromNib()
        myNewView.setOldProperties()
        return myNewView
    }()
    /// A InputBarButtonItem used as the audio button and initially placed in the rightStackView
    var audioButton: InputBarButtonItem = {
        return InputBarButtonItem()
            .configure {
                $0.setSize(CGSize(width: 36, height: 36), animated: false)
                $0.isEnabled = true
                $0.title = "Audio"
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            }.onTouchUpInside {
                $0.inputBarAccessoryView?.didSelectSendButton()
        }
    }()
    
    /// A InputBarButtonItem used as the changeLanguage button and initially placed in the rightStackView
    var changeLanguageButton: InputBarButtonItem = {
        return InputBarButtonItem()
            .configure {
                $0.setSize(CGSize(width: 36, height: 36), animated: false)
                $0.isEnabled = true
                $0.title = "EN"
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            }.onTouchUpInside {
                $0.inputBarAccessoryView?.didSelectSendButton()
        }
    }()
            
    // MARK:- View controller Delegate Methods
    override func viewDidLoad() {
        self.setupCollectionViewCell()
        super.viewDidLoad()
        self.setupView()
        self.setupFetchResultsView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let sections = self.fetchedResultsController.sections, sections.count == 0 {
            self.loadMoreMessages()
        }
        messageInputBar.bringSubviewToFront(messageInputBar.topStackView)
        messageInputBar.topStackView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        floatingQuestionView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        floatingQuestionView.setLayoutProperties()
        messageInputBar.layoutStackViews()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.layoutIfNeeded()
    }
        
    // MARK:-  Setup All CollectionView Cell on ChatViewController
    private func setupCollectionViewCell() {
        
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: ChatCustomMessagesFlowLayout())
        messagesCollectionView.register(UINib(nibName:"ChatAccountCollectionViewCell",bundle: ChatWorkflowManager.bundle), forCellWithReuseIdentifier: "ChatAccountCollectionViewCell")
        messagesCollectionView.register(UINib(nibName:"ChatTransactionCollectionViewCell",bundle: ChatWorkflowManager.bundle), forCellWithReuseIdentifier: "ChatTransactionCollectionViewCell")
        messagesCollectionView.register(UINib(nibName:"CustomHorizontalStackCollectionViewCell",bundle: ChatWorkflowManager.bundle), forCellWithReuseIdentifier: "CustomHorizontalStackCollectionViewCell")
        messagesCollectionView.register(UINib(nibName:"VerticalStackViewiCollectionViewCell",bundle: ChatWorkflowManager.bundle), forCellWithReuseIdentifier: "VerticalStackViewiCollectionViewCell")
       
        messagesCollectionView.register(UINib(nibName:"ChatCardRecoCollectionViewCell",bundle: ChatWorkflowManager.bundle), forCellWithReuseIdentifier: "ChatCardRecoCollectionViewCell")
        messagesCollectionView.register(UINib(nibName:"ChatDefaultCollectionViewCell",bundle: ChatWorkflowManager.bundle), forCellWithReuseIdentifier: "ChatDefaultCollectionViewCell")
        messagesCollectionView.register(UINib(nibName:"ChatGiphyCollectionViewCell",bundle: ChatWorkflowManager.bundle), forCellWithReuseIdentifier: "ChatGiphyCollectionViewCell")
        messagesCollectionView.register(UINib(nibName:"ChatMessageCollectionViewCell",bundle: ChatWorkflowManager.bundle), forCellWithReuseIdentifier: "ChatMessageCollectionViewCell")
        messagesCollectionView.register(UINib(nibName:"ChatBarChartCollectionViewCell",bundle: ChatWorkflowManager.bundle), forCellWithReuseIdentifier: "ChatBarChartCollectionViewCell")
        
        messagesCollectionView.register(UINib(nibName:"ChatCardRecoCollectionViewCell",bundle: ChatWorkflowManager.bundle), forCellWithReuseIdentifier: "ChatCardRecoCollectionViewCell")
        
        messagesCollectionView.register(UINib(nibName:"ChatPieCollectionViewCell",bundle: ChatWorkflowManager.bundle), forCellWithReuseIdentifier: "ChatPieCollectionViewCell")

        messagesCollectionView.register(UINib(nibName:"ChatPieChartCollectionViewCell",bundle: ChatWorkflowManager.bundle), forCellWithReuseIdentifier: "ChatPieChartCollectionViewCell")

        messagesCollectionView.register(UINib(nibName: "ChatSectionHeaderReusableView", bundle: ChatWorkflowManager.bundle), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ChatSectionHeaderReusableView")
        messagesCollectionView.register(UINib(nibName: "ChatSectionFooterReusableView", bundle: ChatWorkflowManager.bundle), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "ChatSectionFooterReusableView")
        
    }
    
    // MARK:- SetupView - ChatViewController Bottom menu (Type, Send, Audio controls)

    private func setupView() {
        title = ChatSession.title()
        chatViewModel?.loadLanguageList(completionStatusHandler: { (isSuccess) in
            DispatchQueue.main.async {
                self.changeLanguageButton.title = self.chatViewModel?.selectedLanguage.initial
            }
        })

        //Top
        messageInputBar.setStackViewItems([floatingQuestionView], forStack: .top, animated: false)
        let thingsTapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.thingMayAskTapped(_:)))
        thingsTapGesture.numberOfTapsRequired = 1
        floatingQuestionView.headerLabel?.addGestureRecognizer(thingsTapGesture)
        floatingQuestionView.contentView?.isHidden = true

        self.addTapGestureRecognizer(floatingQuestionView.firstInfoLabel ?? UILabel())
        self.addTapGestureRecognizer(floatingQuestionView.secondInfoLabel ?? UILabel())
        self.addTapGestureRecognizer(floatingQuestionView.thirdInfoLabel ?? UILabel())
        self.addTapGestureRecognizer(floatingQuestionView.fourthInfoLabel ?? UILabel())

        messageInputBar.setRightStackViewWidthConstant(to: 120, animated: false)
        messageInputBar.setStackViewItems([messageInputBar.sendButton, audioButton, changeLanguageButton], forStack: .right, animated: false)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.microphoneTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        audioButton.addGestureRecognizer(tapGesture)

        let languageTapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.changeLanguageTapped(_:)))
        languageTapGesture.numberOfTapsRequired = 1
        changeLanguageButton.addGestureRecognizer(languageTapGesture)


        changeLanguageButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        changeLanguageButton.setSize(CGSize(width: 36, height: 36), animated: false)
        changeLanguageButton.setTitleColor(ChatColor.appTheme(), for: .normal)


        audioButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        audioButton.setSize(CGSize(width: 36, height: 36), animated: false)
        let imageMic = UIImage.init(named: "SiriRecord", in: ChatWorkflowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        audioButton.setBackgroundImage(imageMic, for: .normal)
        audioButton.tintColor = ChatColor.appTheme()
        audioButton.title = nil
        messageInputBar.inputTextView.placeholder = ""
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        let imageSend = UIImage.init(named: "Send", in: ChatWorkflowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

        messageInputBar.sendButton.image = imageSend
        messageInputBar.sendButton.tintColor = ChatColor.appTheme()
        messageInputBar.sendButton.title = nil
        
        configureMessageCollectionView()
        self.initSFSpeechRecognizer()
    }
    
    func addTapGestureRecognizer(_ label: UILabel) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.flyingLabelTapped(_:)))
        tapGesture.delegate = self
        label.addGestureRecognizer(tapGesture)
    }

    @objc func flyingLabelTapped(_ recognizer : UIGestureRecognizer) {
        if let tappedlabel = recognizer.view as? UILabel, let text = tappedlabel.text, text != "" {
            self.sendMessage(message: text)
        }
    }

    // MARK:- Configure CollectionView Delegates

    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        createActivityIndicatorView()
    }
        
    //MARK:- Fetch all message from Core Data Methods
    private func setupFetchResultsView() {
        //FecthRequest delegate methods declared
        fetchLimit = kMessageThreshold
        self.fetchedResultsController.fetchRequest.fetchLimit = fetchLimit
        if let totalCount = ChatCoreDataManager.getTotalCountOfSentMessages(context: ChatCoreDataStack.sharedInstance.mainManagedObjectContext), totalCount != 0 {
            if totalCount - fetchLimit < 20 {
                self.fetchedResultsController.fetchRequest.fetchLimit = totalCount
                self.fetchedResultsController.fetchRequest.fetchOffset = 0
                self.canMakeLoadMoreCall = false
            } else {
                self.fetchedResultsController.fetchRequest.fetchLimit = fetchLimit
                self.fetchedResultsController.fetchRequest.fetchOffset = totalCount - fetchLimit
            }
            //self.fetchedResultsController.fetchRequest.fetchOffset = totalCount > fetchLimit ? totalCount - fetchLimit : totalCount
        }
        self.fetchedResultsController.delegate = self
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("fetch error: \(error.localizedDescription)")
        }
        self.unsentMessageFetchedResultsController.delegate = self
        self.unsentMessageFetchedResultsController.fetchRequest.predicate = getPredicateForUnsentMessages()
        do {
            try self.unsentMessageFetchedResultsController.performFetch()
        } catch let error as NSError {
            print("fetch error: \(error.localizedDescription)")
        }
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.performBatchUpdates(nil, completion: { (result) in
            self.messagesCollectionView.scrollToBottom(animated: false)
        })
    }
    

    /**
     Fetch message from DB based on messageId
     */
    internal var fetchedResultsController: NSFetchedResultsController<ChatDBMessage>  {
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }
        let fetchRequest: NSFetchRequest<ChatDBMessage> = ChatDBMessage.fetchRequest()
        //        let postedAtSortDescriptor = NSSortDescriptor(key: "postedAt", ascending: true)
        let idSortDescriptor = NSSortDescriptor(key: "messageId", ascending: true)
        fetchRequest.sortDescriptors = [idSortDescriptor]
        fetchRequest.fetchLimit = fetchLimit
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ChatCoreDataStack.sharedInstance.mainManagedObjectContext, sectionNameKeyPath: "sectionTitle", cacheName: nil)
        self._fetchedResultsController = fetchedResultsController
        self._fetchedResultsController?.delegate = self
        
        return self._fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<ChatDBMessage>?
    internal var unsentMessageFetchedResultsController: NSFetchedResultsController<ChatDBUnsentMessage>  {
        if self._unsentMessageFetchedResultsController != nil {
            return self._unsentMessageFetchedResultsController!
        }
        let fetchRequest: NSFetchRequest<ChatDBUnsentMessage> = ChatDBUnsentMessage.fetchRequest()
        let postedAtSortDescriptor = NSSortDescriptor(key: "postedAt", ascending: true)
        let statusSortDescriptor = NSSortDescriptor(key: "status", ascending: true)
        fetchRequest.sortDescriptors = [postedAtSortDescriptor, statusSortDescriptor]
        if let predicate = self.getPredicateForUnsentMessages() {
            fetchRequest.predicate = predicate
        }
        fetchRequest.includesPendingChanges = false
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ChatCoreDataStack.sharedInstance.mainManagedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self._unsentMessageFetchedResultsController = fetchedResultsController
        self._unsentMessageFetchedResultsController?.delegate = self
        
        return self._unsentMessageFetchedResultsController!
    }
    
    var _unsentMessageFetchedResultsController: NSFetchedResultsController<ChatDBUnsentMessage>?
    func getPredicateForUnsentMessages() -> NSPredicate? {
        var predicate: NSPredicate?
        predicate = NSPredicate(format: "status == %d || status == %d || status == %d ", Int16(MessageStatus.Published.rawValue), Int16(MessageStatus.Sending.rawValue), Int16(MessageStatus.Failed.rawValue))
        return predicate
    }
    
    
    //MARK:- Activity Inidicator view
    fileprivate func createActivityIndicatorView() {
        additionalBottomInset = 0;
        customView = UIView(frame: CGRect(x: self.view.frame.origin.x, y: messageInputBar.frame.origin.y, width: self.view.frame.size.width, height: 50))
        customView?.backgroundColor = UIColor.clear
        messageInputBar.addSubview(customView ?? UIView())
        customView?.addSubview(typingBubble)
        typingBubble.backgroundColor = .clear
        typingBubble.center = CGPoint(x: 30, y: -10)
        typingBubble.typingIndicator.dotColor = ChatColor.appTheme()
        typingBubble.typingIndicator.isBounceEnabled = true
        typingBubble.typingIndicator.isFadeEnabled = true
        typingBubble.isPulseEnabled = true
        customView?.isHidden = true
    }
            
    //MARK:- Hide Activity Indicator View
    fileprivate func showhideActivityIndicatorView(show: Bool) {
        messageInputBar.bringSubviewToFront(customView ?? UIView())
        customView?.isHidden = (show == true) ? false : true
        if show {
            typingBubble.startAnimating()
        } else {
            typingBubble.stopAnimating()
        }
    }
    
    //MARK:-Collection View Cell Animation.

    func collectioViewCellAnimation(animatedCell: UICollectionViewCell)  {
        // TODO : This is for initial animation Tryout.
       animatedCell.transform = animatedCell.transform.scaledBy(x:0.001, y: 0.001)
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.2, initialSpringVelocity: 2.5 , options: .curveLinear, animations: {
            animatedCell.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
                                      }) { (finished) in
                                        UIView.animate(withDuration: 0.1, animations: {
                                                  animatedCell.transform = CGAffineTransform.identity
                                              })
                                      }

        
    }
    //MARK:- CollectionView Delegate Methods
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom(let data) = message.kind {
            guard let messageDB = data as? ChatDBMessage else {
                return super.collectionView(collectionView, cellForItemAt: indexPath)
            }
            if messageDB.mediaType == "gif" {
                guard let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ChatGiphyCollectionViewCell", for: indexPath) as? ChatGiphyCollectionViewCell else {
                    return super.collectionView(collectionView, cellForItemAt: indexPath)
                }
                return cell
            }
            if let displayType: DisplayType = DisplayType(rawValue: messageDB.displayType ?? "message") {
                switch displayType {
                case .accountsWithOutstandingRed, .accountsWithUtilizationRed, .accountsWithGreen, .accountsWithPayoffOrange:
                    //Accounts
                    guard let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ChatAccountCollectionViewCell", for: indexPath) as? ChatAccountCollectionViewCell else {
                        return super.collectionView(collectionView, cellForItemAt: indexPath)
                    }
                    cell.delegate = self
                    cell.configurationCell(message: messageDB)
                    return cell
                case .messageWithAmountTransactions, .messageWithGraphTransactions, .messageWithBarTransactions, .messageWithPieTransactions, .accountTransactions, .messageWithTransaction:
                    //Transactions
                    guard let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ChatTransactionCollectionViewCell", for: indexPath) as? ChatTransactionCollectionViewCell else {
                        return super.collectionView(collectionView, cellForItemAt: indexPath)
                    }
                    cell.delegate = self
                    cell.displayType = messageDB.displayType ?? ""
                    cell.configurationCell(message: messageDB)
                    return cell
                case .messageWithPieChart:
                    //Piechart
                    guard let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ChatPieChartCollectionViewCell", for: indexPath) as? ChatPieChartCollectionViewCell else {
                        return super.collectionView(collectionView, cellForItemAt: indexPath)
                    }
                    cell.configurationCell(message: messageDB)
                    return cell
                case .messageWithBarChat:
                    //Bar chart
                    guard let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ChatBarChartCollectionViewCell", for: indexPath) as? ChatBarChartCollectionViewCell else {
                        return super.collectionView(collectionView, cellForItemAt: indexPath)
                    }
                    cell.configurationCell(message: messageDB)
                    return cell
                case .cardRecommendation:
                    //Card Reco
                    guard let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ChatCardRecoCollectionViewCell", for: indexPath) as? ChatCardRecoCollectionViewCell else {
                        return super.collectionView(collectionView, cellForItemAt: indexPath)
                    }
                    cell.configurationCell(message: messageDB)
                    return cell
                case .horizontalQuestions:
                    guard let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "CustomHorizontalStackCollectionViewCell", for: indexPath) as? CustomHorizontalStackCollectionViewCell else {
                        return super.collectionView(collectionView, cellForItemAt: indexPath)
                    }
                    cell.configureCell(message: messageDB)
                    return cell
                case .verticalQuestions:
                    guard let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "VerticalStackViewiCollectionViewCell", for: indexPath) as? VerticalStackViewiCollectionViewCell else {
                        return super.collectionView(collectionView, cellForItemAt: indexPath)
                    }
                    cell.configureCell(message: messageDB)
                    return cell
                case .messageWithNotes:
                        guard let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ChatMessageCollectionViewCell", for: indexPath) as? ChatMessageCollectionViewCell else {
                            return super.collectionView(collectionView, cellForItemAt: indexPath)
                        }
                        cell.configureCell(message: messageDB)
                        return cell

                default:
                    guard let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ChatDefaultCollectionViewCell", for: indexPath) as? ChatDefaultCollectionViewCell else {
                        return super.collectionView(collectionView, cellForItemAt: indexPath)
                    }
                    cell.dateLabel.text = formatter.string(from: message.sentDate)
                    return cell
                }
            }
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let sections = self.fetchedResultsController.sections, sections.count > 0 {
            if section != (messagesCollectionView.numberOfSections - 1) {
                return CGSize(width: self.view.frame.width, height: 40)
            }
        }
        return CGSize(width: self.view.frame.width, height: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let sections = self.unsentMessageFetchedResultsController.sections, sections.count > 0 {
            if sections[0].numberOfObjects > 0 && section == 2 {
                return CGSize(width: self.view.frame.width, height: 20)
            }
        }
        return CGSize(width: self.view.frame.width, height: 0)
    }
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: "ChatSectionHeaderReusableView",
                                                                                   for: indexPath) as? ChatSectionHeaderReusableView else {
                                                                                    return UICollectionReusableView()
            }
            headerView.timeLabel.text = ""
            if let sections = self.fetchedResultsController.sections, sections.count > 0 {
                if indexPath.section != (messagesCollectionView.numberOfSections - 1) {
                    let sectionTitle = sections[indexPath.section].name
                    headerView.timeLabel.text = sectionTitle
                }
            }
            return headerView
            //Swift4.2
        //case UICollectionView.elementKindSectionFooter:
            //Swift 4.0
        case UICollectionView.elementKindSectionFooter:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: "ChatSectionFooterReusableView",
                                                                                   for: indexPath) as? ChatSectionFooterReusableView else {
                                                                                    return UICollectionReusableView()
            }
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
    
    /**
     Long Press
     */
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if(action == NSSelectorFromString("delete:")) {
            self.showMenu(at: indexPath)
            return true;
        }
        return false
    }
    
    //MARK:- Message Label Attributed Text
    /**
     Not Using this method
     */

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let date = formatter.string(from: message.sentDate)
        return NSAttributedString(string: date, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }

    //MARK:- On Message long press show menu
    private func showMenu(at indexPath: IndexPath) {
        var canShowRetry = false
        var canShowDelete = false
        var clientTempID: Double = 0
        let readMessageCount = self.fetchedResultsController.sections?.count ?? 0
        let unreadMessageCount = self.unsentMessageFetchedResultsController.sections?.count ?? 0
        if indexPath.section < readMessageCount {
            /*guard let sentMessage = self.fetchedResultsController.object(at: indexPath) as? ChatDBMessage else {
             }*/
        } else if indexPath.section < (readMessageCount + unreadMessageCount) {
            let modifiedIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - readMessageCount)
            if modifiedIndexPath.section < unreadMessageCount {
                let unsentMessage = self.unsentMessageFetchedResultsController.object(at: modifiedIndexPath)
                if unsentMessage.status == Int16(MessageStatus.Failed.rawValue) {
                    canShowRetry = true
                    canShowDelete = true
                    clientTempID = unsentMessage.clientTempID
                }
            }
        }
        let optionsAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // Copy text
        let copyTextAction = UIAlertAction(title: "Copy", style: .default) { (_) in
        }
        optionsAlertController.addAction(copyTextAction)
        
        // Retry
        if canShowRetry {
            let retryAction = UIAlertAction(title: "Retry", style: .default) { (_) in
                ChatMessageDataModel.sentMessage(withClientTempID: clientTempID)
            }
            optionsAlertController.addAction(retryAction)
        }
        if canShowDelete {
            let retryAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                // allow deletion of unsent message only if the status is failed
                ChatMessageDataModel.delete(unsentMessageWithClientTempId: clientTempID)
            }
            optionsAlertController.addAction(retryAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        }
        optionsAlertController.addAction(cancelAction)
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            //            optionsAlertController.popoverPresentationController?.sourceView = cell
            //            optionsAlertController.popoverPresentationController?.sourceRect = cell.bounds
        }
        self.present(optionsAlertController, animated: true, completion: nil)
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        ChatSession.deleteImages()
        self.dismiss(animated: true, completion: nil)
    }

    deinit {
        print("ChatViewController Deinit")
        chatViewModel = nil
    }

}

// MARK: -  extension : InputBarAccessory View Delegate Method
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let str = component as? String {
                inputBar.inputTextView.text = ""
                self.sendMessage(message: str)
            } else if let _ = component as? UIImage {
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom(animated: true)
    }

    func sendMessage(message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.showhideActivityIndicatorView(show: true)
        }
        if let messageDict = ChatMessageDataModel.messagePayloadDictionary(forText: message) {
            ChatMessageDataModel.insertUnsentMessageToDB(fromMessageDetails: messageDict, completionHandler: { (isSuccess, resultt, error) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.showhideActivityIndicatorView(show: false)
                }
            })
        }
    }
}



