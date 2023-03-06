import UIKit

@available(iOS 13.0.0, *)
@objc open class Courier: NSObject {
    
    // MARK: Courier
    
    /*
     
      ______  ______  __  __  ______  __  ______  ______
     /\  ___\/\  __ \/\ \/\ \/\  == \/\ \/\  ___\/\  == \
     \ \ \___\ \ \/\ \ \ \_\ \ \  __<\ \ \ \  __\\ \  __<
      \ \_____\ \_____\ \_____\ \_\ \_\ \_\ \_____\ \_\ \_\
       \/_____/\/_____/\/_____/\/_/ /_/\/_/\/_____/\/_/ /_/
     
     
     Full Documentation: https://github.com/trycourier/courier-ios
     
     
     */
    
    public static var agent = CourierAgent.native_ios
    internal static let version = "2.0.0"
    
    /**
     * Singleton reference to the SDK
     * Please ensure you use this to maintain state
     */
    @objc public static let shared = Courier()
    
    /**
     * The features of the SDK
     */
    internal lazy var auth = CourierAuth()
    internal lazy var push = CourierPush()
    internal lazy var inbox = CourierInbox()
    internal lazy var messaging = CourierMessaging()
    internal let logging = CourierLogging()
    
    // MARK: Init
    
    private override init() {
        
#if DEBUG
        logging.isDebugging = true
#endif
        
        super.init()
        
    }
    
}
