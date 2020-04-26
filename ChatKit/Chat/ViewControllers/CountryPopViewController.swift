//
//  CountryPopViewController.swift
//  Eva
//
//  Created by saran on 25/06/19.
//  Copyright © 2019 Eva. All rights reserved.
//

import UIKit

protocol CountrySaveActionDelegate: class {
  func saveButtonPressed()
}

class CountryPopViewController: UIViewController, SBCardPopupContent {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var selectLanguageLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!

    var popupViewController: CardPopupViewController?
    var allowsTapToDismissPopupCard: Bool = true
    var allowsSwipeToDismissPopupCard: Bool = true
    var chatViewModel: ChatViewModel? = ChatViewModel()
    weak var delegate: CountrySaveActionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.backgroundColor = ChatColor.appTheme()
        selectLanguageLabel.backgroundColor = ChatColor.appTheme()
        pickerView.selectRow(chatViewModel?.selectedIndex ?? 0, inComponent: 0, animated: true)
    }
    
    @IBAction func countrySelectButtonClicked(_ sender: Any) {
        self.delegate?.saveButtonPressed()
        self.popupViewController?.close()
    }
    
    deinit {
        print("CountryPopViewController Deinit")
        chatViewModel = nil
    }

}

extension CountryPopViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return chatViewModel?.totalCount() ?? 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return chatViewModel?.getLanguageAtIndex(index: row)?.fullText ?? ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chatViewModel?.selectedIndex = row
    }

}
