
import UIKit
import CommonCrypto
import LocalAuthentication
import CryptoKit

 var time = ""


@available(iOS 13.0, *)
class SecuredKeyViewController: UIViewController, UITextFieldDelegate {
    
    var key: SecKey?

    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    
    var clearText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EmailTextField.delegate = self
        PasswordTextField.delegate = self
    }
    
    var context = LAContext()

    func textFieldDidChangeSelection(_ textField: UITextField) {
        clearText = EmailTextField.text!
    }
    
    @IBAction func StartEncryption(_ sender: Any) {
        context = LAContext()
        context.localizedCancelTitle = "Cancel"
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            
            let reason = "Log in to your account"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { [self] success, error in
                if success {
                
                    let date = Date()
                    let df = DateFormatter()
                    df.dateFormat = "HH:mm:ss"
                    let dateString = df.string(from: date)
                    print(dateString)
                    time = dateString
                    
                    DispatchQueue.main.async { [self] in
                        guard let email = EmailTextField.text, email != "" else {
                            return
                        }
                        let emailEncryption = encrypt(message: email)
                        KeychainWrapper.shared.set(value: emailEncryption!.tag, key: "Email_Tag")
                        KeychainWrapper.shared.set(value: emailEncryption!.ciphertext, key: "Email")
                    }
        DispatchQueue.main.async {
            self.EmailTextField.text = ""
        }
        context.invalidate()
                }
            }
        }
    }
    
    @IBAction func onDecryptClick(_ sender: Any) {
        context = LAContext()
        context.localizedCancelTitle = "Cancel"
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            
            let reason = "Log in to your account"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { [self] success, error in
                if success {
                    
                    let iv = "123456789012".data(using: .utf8)!
                    guard let emailTagDetails = KeychainWrapper.shared.get(for: "Email_Tag"),
                          let cipherTextData = KeychainWrapper.shared.get(for: "Email") else {
                        return
                    }
                    
                    let emailEncrypted = try! AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: iv), ciphertext: cipherTextData, tag: emailTagDetails)
                    let email = self.decrypt(sealedBox: emailEncrypted)
                    DispatchQueue.main.async {
                        self.EmailTextField.text = email
                    }
                    
                    context.invalidate()
                    
                } else {
                    print(error?.localizedDescription ?? "Failed to authenticate")
                }
            }
        } else {
            print(error?.localizedDescription ?? "Can't evaluate policy")
        }
    }
    
    func encrypt(message: String) -> AES.GCM.SealedBox? {
        let key = "1234567890123456".data(using: .utf8)!
        let auth = "1234567890123456".data(using: .utf8)!
        let iv = "123456789012".data(using: .utf8)!
        
        return try? AES.GCM.seal(message.data(using: .utf8)!, using: SymmetricKey(data: key), nonce: AES.GCM.Nonce(data: iv), authenticating: auth)
    }
    
    @available(iOS 13.0, *)
    func decrypt(sealedBox: AES.GCM.SealedBox) -> String? {
        let key = "1234567890123456".data(using: .utf8)!
        let auth = "1234567890123456".data(using: .utf8)!
        
        return String(data: try! AES.GCM.open(sealedBox, using: SymmetricKey(data: key), authenticating: auth), encoding: .utf8)
    }
    
}

extension Data {
    public func toHexString() -> String {
        return reduce("", {$0 + String(format: "%02X ", $1)})
    }
    
    func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &hash)
        }
        return Data(bytes: hash)
    }
    
}

//
//
//func CheckForBiometricAccess(){
//    if state == .loggedin {
//        state = .loggedout
//    } else {
//        context = LAContext()
//        context.localizedCancelTitle = "Cancel"
//        var error: NSError?
//        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
//
//            let reason = "Log in to your account"
//            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
//                if success {
//
//                } else {
//                    print(error?.localizedDescription ?? "Failed to authenticate")
//                }
//            }
//        } else {
//            print(error?.localizedDescription ?? "Can't evaluate policy")
//        }
//    }
//}
