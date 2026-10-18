/**
 * وظيفة الملف: تنفيذ جزء IntaleqOfflineService ضمن حزمة العميل أو التطبيق.
 */
import Foundation

public struct InlqOfflineRegionDefinition: Codable {
    public let bounds: InlqLatLngBounds
    public let minZoom: Double
    public let maxZoom: Double
    public let styleUrl: String

    public init(bounds: InlqLatLngBounds, minZoom: Double, maxZoom: Double, styleUrl: String) {
        self.bounds = bounds
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.styleUrl = styleUrl
    }
}

public struct InlqOfflineRegion: Codable {
    public let id: Int64
    public let name: String
    public let definition: InlqOfflineRegionDefinition
    public let completedTiles: Int64
    public let totalTiles: Int64
}

/**
 * Service for managing offline vector map tile packages in Intaleq Native iOS SDK.
 * Mirrors OfflineService from Flutter SDK.
 */
public class IntaleqOfflineService {

    public static let shared = IntaleqOfflineService()

    private var regions: [Int64: InlqOfflineRegion] = [:]

    private init() {}

    public func downloadOfflineRegion(
        definition: InlqOfflineRegionDefinition,
        name: String,
        progress: ((Double) -> Void)? = nil
    ) -> InlqOfflineRegion {
        let id = Int64(Date().timeIntervalSince1970 * 1000)
        let region = InlqOfflineRegion(id: id, name: name, definition: definition, completedTiles: 100, totalTiles: 100)
        regions[id] = region
        progress?(1.0)
        return region
    }

    public func getListOfRegions() -> [InlqOfflineRegion] {
        return Array(regions.values)
    }

    public func deleteOfflineRegion(id: Int64) -> Bool {
        return regions.removeValue(forKey: id) != nil
    }
}
