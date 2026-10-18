/**
 * وظيفة الملف: تنفيذ جزء IntaleqStyles ضمن حزمة العميل أو التطبيق.
 */
import Foundation

/**
 * Predefined map visual styles for the Intaleq Map SDK for iOS (Swift).
 * Mirrors IntaleqStyles from Flutter SDK.
 */
public struct IntaleqStyles {
    public static var dark: String {
        let keyParam = IntaleqMaps.shared.apiKey.isEmpty ? "" : "?key=\(IntaleqMaps.shared.apiKey)"
        return "\(IntaleqMaps.shared.baseUrl)/style-dark.json\(keyParam)"
    }

    public static var light: String {
        let keyParam = IntaleqMaps.shared.apiKey.isEmpty ? "" : "?key=\(IntaleqMaps.shared.apiKey)"
        return "\(IntaleqMaps.shared.baseUrl)/style.json\(keyParam)"
    }

    public static var normal: String {
        let keyParam = IntaleqMaps.shared.apiKey.isEmpty ? "" : "?key=\(IntaleqMaps.shared.apiKey)"
        return "\(IntaleqMaps.shared.baseUrl)/style.json\(keyParam)"
    }

    public static var satellite: String {
        let keyParam = IntaleqMaps.shared.apiKey.isEmpty ? "" : "?key=\(IntaleqMaps.shared.apiKey)"
        return "\(IntaleqMaps.shared.baseUrl)/style-satellite.json\(keyParam)"
    }

    public static var outdoors: String {
        let keyParam = IntaleqMaps.shared.apiKey.isEmpty ? "" : "?key=\(IntaleqMaps.shared.apiKey)"
        return "\(IntaleqMaps.shared.baseUrl)/style-tourism.json\(keyParam)"
    }

    public static var terrain: String {
        let keyParam = IntaleqMaps.shared.apiKey.isEmpty ? "" : "?key=\(IntaleqMaps.shared.apiKey)"
        return "\(IntaleqMaps.shared.baseUrl)/style-3d-terrain.json\(keyParam)"
    }
}

public enum IntaleqMapType: String, Codable {
    case none
    case normal
    case light
    case satellite
    case dark
    case terrain
}
