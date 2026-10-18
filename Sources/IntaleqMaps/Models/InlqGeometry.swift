/**
 * وظيفة الملف: تنفيذ جزء InlqGeometry ضمن حزمة العميل أو التطبيق.
 */
import Foundation
import CoreLocation

#if canImport(UIKit)
import UIKit
public typealias InlqColor = UIColor
public typealias InlqImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias InlqColor = NSColor
public typealias InlqImage = NSImage
#endif

// ─────────────────────────────────────────────────────────────
// ID Types (Matching Flutter SDK & Google Maps iOS SDK)
// ─────────────────────────────────────────────────────────────

public struct InlqMarkerId: Hashable, Equatable, Codable {
    public let value: String
    public init(_ value: String) { self.value = value }
}

public struct InlqPolylineId: Hashable, Equatable, Codable {
    public let value: String
    public init(_ value: String) { self.value = value }
}

public struct InlqPolygonId: Hashable, Equatable, Codable {
    public let value: String
    public init(_ value: String) { self.value = value }
}

public struct InlqCircleId: Hashable, Equatable, Codable {
    public let value: String
    public init(_ value: String) { self.value = value }
}

/**
 * An immutable struct representing a latitude/longitude bounding box.
 */
public struct InlqLatLngBounds: Equatable, Codable {
    public let southwest: InlqLatLng
    public let northeast: InlqLatLng

    public init(southwest: InlqLatLng, northeast: InlqLatLng) {
        self.southwest = southwest
        self.northeast = northeast
    }

    public func contains(_ point: InlqLatLng) -> Bool {
        let inLat = point.latitude >= southwest.latitude && point.latitude <= northeast.latitude
        let inLng = point.longitude >= southwest.longitude && point.longitude <= northeast.longitude
        return inLat && inLng
    }
}

// ─────────────────────────────────────────────────────────────
// Bitmap & InfoWindow Types
// ─────────────────────────────────────────────────────────────

public class InlqBitmap {
    public enum BitmapType {
        case defaultMarker
        case defaultMarkerWithHue(CGFloat)
        case image(InlqImage)
        case asset(String)
    }

    public let type: BitmapType

    public init(type: BitmapType) {
        self.type = type
    }

    public static let defaultMarker = InlqBitmap(type: .defaultMarker)

    public static func defaultMarker(withHue hue: CGFloat) -> InlqBitmap {
        return InlqBitmap(type: .defaultMarkerWithHue(hue))
    }

    public static func from(image: InlqImage) -> InlqBitmap {
        return InlqBitmap(type: .image(image))
    }

    public static func from(assetName: String) -> InlqBitmap {
        return InlqBitmap(type: .asset(assetName))
    }
}

public struct InlqInfoWindow {
    public let title: String?
    public let snippet: String?
    public let anchor: CGPoint
    public let onTap: (() -> Void)?

    public init(title: String? = nil, snippet: String? = nil, anchor: CGPoint = CGPoint(x: 0.5, y: 0.0), onTap: (() -> Void)? = nil) {
        self.title = title
        self.snippet = snippet
        self.anchor = anchor
        self.onTap = onTap
    }

    public static let noText = InlqInfoWindow()
}

// ─────────────────────────────────────────────────────────────
// Map Overlay Elements (Matching Flutter SDK)
// ─────────────────────────────────────────────────────────────

public class InlqMarker {
    public let markerId: InlqMarkerId
    public var position: InlqLatLng
    public var alpha: CGFloat
    public var anchor: CGPoint
    public var isDraggable: Bool
    public var isFlat: Bool
    public var icon: InlqBitmap
    public var infoWindow: InlqInfoWindow
    public var rotation: Double
    public var isVisible: Bool
    public var zIndex: Int32
    public var onTap: (() -> Void)?

    public init(
        markerId: InlqMarkerId,
        position: InlqLatLng,
        alpha: CGFloat = 1.0,
        anchor: CGPoint = CGPoint(x: 0.5, y: 1.0),
        isDraggable: Bool = false,
        isFlat: Bool = false,
        icon: InlqBitmap = .defaultMarker,
        infoWindow: InlqInfoWindow = .noText,
        rotation: Double = 0.0,
        isVisible: Bool = true,
        zIndex: Int32 = 0,
        onTap: (() -> Void)? = nil
    ) {
        self.markerId = markerId
        self.position = position
        self.alpha = alpha
        self.anchor = anchor
        self.isDraggable = isDraggable
        self.isFlat = isFlat
        self.icon = icon
        self.infoWindow = infoWindow
        self.rotation = rotation
        self.isVisible = isVisible
        self.zIndex = zIndex
        self.onTap = onTap
    }
}

public class InlqPolyline {
    public let polylineId: InlqPolylineId
    public var points: [InlqLatLng]
    public var strokeColor: InlqColor
    public var strokeWidth: CGFloat
    public var isGeodesic: Bool
    public var isVisible: Bool
    public var zIndex: Int32
    public var onTap: (() -> Void)?

    public init(
        polylineId: InlqPolylineId,
        points: [InlqLatLng] = [],
        strokeColor: InlqColor = InlqColor(red: 0.0, green: 0.44, blue: 0.89, alpha: 1.0),
        strokeWidth: CGFloat = 10.0,
        isGeodesic: Bool = true,
        isVisible: Bool = true,
        zIndex: Int32 = 0,
        onTap: (() -> Void)? = nil
    ) {
        self.polylineId = polylineId
        self.points = points
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.isGeodesic = isGeodesic
        self.isVisible = isVisible
        self.zIndex = zIndex
        self.onTap = onTap
    }
}

public class InlqPolygon {
    public let polygonId: InlqPolygonId
    public var points: [InlqLatLng]
    public var holes: [[InlqLatLng]]
    public var strokeColor: InlqColor
    public var strokeWidth: CGFloat
    public var fillColor: InlqColor
    public var isVisible: Bool
    public var zIndex: Int32
    public var onTap: (() -> Void)?

    public init(
        polygonId: InlqPolygonId,
        points: [InlqLatLng] = [],
        holes: [[InlqLatLng]] = [],
        strokeColor: InlqColor = InlqColor(red: 0.0, green: 0.44, blue: 0.89, alpha: 1.0),
        strokeWidth: CGFloat = 5.0,
        fillColor: InlqColor = InlqColor(red: 0.0, green: 0.44, blue: 0.89, alpha: 0.2),
        isVisible: Bool = true,
        zIndex: Int32 = 0,
        onTap: (() -> Void)? = nil
    ) {
        self.polygonId = polygonId
        self.points = points
        self.holes = holes
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.fillColor = fillColor
        self.isVisible = isVisible
        self.zIndex = zIndex
        self.onTap = onTap
    }
}

public class InlqCircle {
    public let circleId: InlqCircleId
    public var center: InlqLatLng
    public var radiusMeters: Double
    public var strokeColor: InlqColor
    public var strokeWidth: CGFloat
    public var fillColor: InlqColor
    public var isVisible: Bool
    public var zIndex: Int32
    public var onTap: (() -> Void)?

    public init(
        circleId: InlqCircleId,
        center: InlqLatLng,
        radiusMeters: Double,
        strokeColor: InlqColor = InlqColor(red: 0.13, green: 0.77, blue: 0.36, alpha: 1.0),
        strokeWidth: CGFloat = 4.0,
        fillColor: InlqColor = InlqColor(red: 0.13, green: 0.77, blue: 0.36, alpha: 0.2),
        isVisible: Bool = true,
        zIndex: Int32 = 0,
        onTap: (() -> Void)? = nil
    ) {
        self.circleId = circleId
        self.center = center
        self.radiusMeters = radiusMeters
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.fillColor = fillColor
        self.isVisible = isVisible
        self.zIndex = zIndex
        self.onTap = onTap
    }
}
