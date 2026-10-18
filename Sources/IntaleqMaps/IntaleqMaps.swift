/**
 * وظيفة الملف: واجهة الدخول أو نقطة تشغيل حزمة IntaleqMaps.
 */
import Foundation

/**
 * Main entry point for Intaleq Commercial Maps SDK for iOS (Swift).
 * Fully compatible with Google Maps SDK API conventions.
 */
public class IntaleqMaps {

    public static let shared = IntaleqMaps()

    public private(set) var apiKey: String = ""
    public private(set) var baseUrl: String = "https://map-saas.intaleqapp.com"
    public private(set) var isInitialized: Bool = false

    private init() {}

    /**
     * Initializes the Intaleq Maps SDK with your SaaS API Key.
     */
    public static func initialize(apiKey: String, baseUrl: String = "https://map-saas.intaleqapp.com") {
        shared.apiKey = apiKey
        shared.baseUrl = baseUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        shared.isInitialized = true
    }
}
