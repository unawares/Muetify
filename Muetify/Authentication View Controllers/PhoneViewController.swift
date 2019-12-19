//
//  PhoneViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/16/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit
import FirebaseAuth
import PhoneNumberKit


class PhoneViewController: UIViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var phoneNumberTextField: KZPhoneNumberTextField!
    var authTask: URLSessionDataTask!
    
    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        phoneNumberTextField.withPrefix = true
        phoneNumberTextField.withExamplePlaceholder = true
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            AuthService().setToken(token: token).getUser { [weak self] user, error in
                DispatchQueue.main.sync {
                    if let error = error {
                        self?.showMessage(title: "Error", message: error.localizedDescription)
                    } else {
                        if let navigationController = self?.storyboard?.instantiateViewController(withIdentifier: "main") as? MainNavigationController {
                            self?.present(navigationController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        
    }
    
    func sendConfirmationCode(completion: @escaping ((String, String) -> Void)) {
        
        let phoneNumberKit = PhoneNumberKit()
        
        guard phoneNumberTextField.isValidNumber else {
            showMessage(title: "Invalid Phone Number", message: "Please, provide a valid phone number")
            return
        }
        
        if let phoneNumberText = phoneNumberTextField.text,
            let phoneNumber = try? phoneNumberKit.parse(phoneNumberText) {
            
            self.indicator.startAnimating()
            authTask?.cancel()
            
            authTask = AuthService().syncPhoneNumber(forPhoneNumber: PhoneNumberModel(phoneNumber: phoneNumber.numberString)) { [weak self] phoneNumberModel, error in
                
                DispatchQueue.main.sync {
                    if let error = error {
                        self?.showMessage(title: "Error", message: error.localizedDescription)
                        self?.indicator.stopAnimating()
                    } else if let phoneNumberModel = phoneNumberModel {
                        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumberModel.phoneNumber, uiDelegate: nil) { (verificationID, error) in
                            if let error = error {
                                self?.showMessage(title: "Error", message: error.localizedDescription)
                            } else if let verificationID = verificationID {
                                completion(phoneNumberModel.phoneNumber, verificationID)
                            }
                            self?.indicator.stopAnimating()
                        }
                    }
                }
                
            }
            
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        sendConfirmationCode { [weak self] (phoneNumber, verificationID) in
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            if let viewController = self?.storyboard?.instantiateViewController(withIdentifier: "phone_verify") as? PhoneVerifyViewController {
                viewController.phoneNumber = phoneNumber
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    

}


class KZPhoneNumberTextField: PhoneNumberTextField {
    
    override var defaultRegion: String {
        
        get {
            return "KZ"
        }
    
        set {
            
        }
        
    }
    
}