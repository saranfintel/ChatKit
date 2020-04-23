//
//  CountryPopViewController.swift
//  Eva
//
//  Created by saran on 25/06/19.
//  Copyright © 2019 Eva. All rights reserved.
//

import UIKit

class CountryPopViewController: UIViewController, SBCardPopupContent {
    
    @IBOutlet weak var pickerView: UIPickerView!
    let pickerData: [String] = ["English", "Hindi", "Arabic", "Spanish"]

    var popupViewController: CardPopupViewController?
    var allowsTapToDismissPopupCard: Bool = true
    var allowsSwipeToDismissPopupCard: Bool = true
    
    static func create() -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
         let chatViewController = storyBoard.instantiateViewController(withIdentifier: "CountryPopViewController") as! CountryPopViewController
            return chatViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func countrySelectButtonClicked(_ sender: Any) {
        let selectedYearPicker = pickerData[pickerView.selectedRow(inComponent: 0)]
        if selectedYearPicker == "English" {
            UserDefaults(suiteName: App_Group_ID)?.set("en-US", forKey: voiceLanguage)
        } else if selectedYearPicker == "Hindi" {
            UserDefaults(suiteName: App_Group_ID)?.set("hi-IN", forKey: voiceLanguage)
        } else if selectedYearPicker == "Arabic" {
            UserDefaults(suiteName: App_Group_ID)?.set("ar-SA", forKey: voiceLanguage)
        } else if selectedYearPicker == "Spanish" {
            UserDefaults(suiteName: App_Group_ID)?.set("es-ES", forKey: voiceLanguage)
        }
        self.popupViewController?.close()
    }

}

extension CountryPopViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}
