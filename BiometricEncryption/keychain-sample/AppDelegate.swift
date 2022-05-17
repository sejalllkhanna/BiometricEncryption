

import UIKit
import LocalAuthentication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var context = LAContext()
    var time2 = ""
    var TimeInterval = 0
    var seconds: Int = 10
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        let dateString2 = df.string(from: date)
        print(dateString2)
        time2 = dateString2
        
        let dateDiff = findDateDiff()
        TimeInterval = dateDiff
        let difference  = TimeInterval
    
        if difference > seconds {
            context = LAContext()
            context.localizedCancelTitle = "Cancel"
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                
                let reason = "Log in to your account"
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { [self] success, error in
                    if success {
                        self.context.invalidate()
                    }
                }
            }
        }else{
            print("ERROR")
        }
        
    }
    
    func findDateDiff() -> Int {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        let time1Str = time
        let time2Str = time2
        
        guard let time1 = df.date(from: time1Str),
              let time2 = df.date(from: time2Str) else { return 0 }
        
        let interval = time2.timeIntervalSince(time1)
        return Int(interval.rounded())
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
}

extension String {
    func numberOfSeconds() -> Int {
        let components: Array = self.components(separatedBy: ":")
        let hours = Int(components[0]) ?? 0
        print(hours)
        print(self)
        let minutes = Int(components[1]) ?? 0
        let seconds = Int(components[2]) ?? 0
        return (hours * 3600) + (minutes * 60) + seconds
    }
}
