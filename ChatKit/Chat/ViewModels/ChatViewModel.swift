//
//  ChatViewModel.swift
//  ChatKit
//
//  Created by saran on 26/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import UIKit

class ChatViewModel: NSObject {
    
    var languageList: [Language]? = []
    var selectedIndex: Int = 0
    var selectedLanguage: Language = Language.empty()
    
    func loadLanguageList(completionStatusHandler: @escaping CompletionStatusHandler) {
        if let jsonDict = ChatUtils.loadJSONFromBundle(name: "Languages", bundle: ChatWorkflowManager.bundle) {
            languageList = (jsonDict <-- "payload") ?? []
            guard let locale = UserDefaults.standard.object(forKey: voiceLanguage) as? String, let index = languageList?.firstIndex(where: { $0.locale == locale }) else {
                selectedLanguage = languageList?[selectedIndex] ?? Language.empty()
                    completionStatusHandler(true)
                return
                }
            selectedLanguage = languageList?[index] ?? Language.empty()
            selectedIndex = index
            completionStatusHandler(true)

        }
    }
    
    func totalCount() -> Int {
        return (self.languageList != nil ? self.languageList!.count : 0)
    }
    
    func getLanguageAtIndex(index: Int) -> Language? {
        if index < self.languageList!.count {
            return self.languageList![index]
        }
        return nil
    }
    
    func saveSelectedLanguage() {
        if let language = self.getLanguageAtIndex(index: selectedIndex) {
            selectedLanguage = language
            UserDefaults.standard.set(language.locale, forKey: voiceLanguage)
            UserDefaults.standard.synchronize()
        }
    }

    deinit {
        print("ChatViewModel deinit")
        languageList = nil
    }

}
