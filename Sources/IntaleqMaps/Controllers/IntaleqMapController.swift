/**
 * وظيفة الملف: تنفيذ جزء IntaleqMapController ضمن حزمة العميل أو التطبيق.
 */
import Foundation

/**
 * Controller for an IntaleqMapView instance on iOS.
 * Mirrors IntaleqMapController from Flutter SDK and GMSMapView from Google Maps iOS SDK.
 */
public class IntaleqMapController {

    private var markers: [InlqMarkerId: InlqMarker] = [:]
    private var polylines: [InlqPolylineId: InlqPolyline] = [:]
    private var polygons: [InlqPolygonId: InlqPolygon] = [:]
    private var circles: [InlqCircleId: InlqCircle] = [:]

    public private(set) var cameraPosition: InlqCameraPosition = InlqCameraPosition(
        target: InlqLatLng(latitude: 31.9539, longitude: 35.9106),
        zoom: 12.0
    )

    public var onCameraMove: ((InlqCameraPosition) -> Void)?
    public var onCameraIdle: (() -> Void)?
    public var onMapTap: ((InlqLatLng) -> Void)?
    public var onMapLongPress: ((InlqLatLng) -> Void)?

    public init() {}

    /**
     * Animates camera movement to the new position defined in the update.
     */
    public func animateCamera(with update: InlqCameraUpdate, duration: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
        applyCameraUpdate(update)
        completion?()
    }

    /**
     * Instantly repositions camera to the new position defined in the update.
     */
    public func moveCamera(with update: InlqCameraUpdate) {
        applyCameraUpdate(update)
    }

    private func applyCameraUpdate(_ update: InlqCameraUpdate) {
        switch update {
        case .newLatLng(let latLng):
            cameraPosition = InlqCameraPosition(target: latLng, zoom: cameraPosition.zoom, viewingAngle: cameraPosition.viewingAngle, bearing: cameraPosition.bearing)
        case .newLatLngZoom(let latLng, let zoom):
            cameraPosition = InlqCameraPosition(target: latLng, zoom: zoom, viewingAngle: cameraPosition.viewingAngle, bearing: cameraPosition.bearing)
        case .newCameraPosition(let pos):
            cameraPosition = pos
        case .zoomIn:
            cameraPosition = InlqCameraPosition(target: cameraPosition.target, zoom: cameraPosition.zoom + 1.0, viewingAngle: cameraPosition.viewingAngle, bearing: cameraPosition.bearing)
        case .zoomOut:
            cameraPosition = InlqCameraPosition(target: cameraPosition.target, zoom: max(0.0, cameraPosition.zoom - 1.0), viewingAngle: cameraPosition.viewingAngle, bearing: cameraPosition.bearing)
        }
        onCameraMove?(cameraPosition)
        onCameraIdle?()
    }

    // ── Markers ─────────────────────────────────────────────────────────────

    @discardableResult
    public func addMarker(_ marker: InlqMarker) -> InlqMarker {
        markers[marker.markerId] = marker
        return marker
    }

    public func removeMarker(withId id: InlqMarkerId) {
        markers.removeValue(forKey: id)
    }

    public func clearMarkers() {
        markers.removeAll()
    }

    public func getMarkers() -> [InlqMarker] {
        return Array(markers.values)
    }

    // ── Polylines ───────────────────────────────────────────────────────────

    @discardableResult
    public func addPolyline(_ polyline: InlqPolyline) -> InlqPolyline {
        polylines[polyline.polylineId] = polyline
        return polyline
    }

    public func removePolyline(withId id: InlqPolylineId) {
        polylines.removeValue(forKey: id)
    }

    public func clearPolylines() {
        polylines.removeAll()
    }

    public func getPolylines() -> [InlqPolyline] {
        return Array(polylines.values)
    }

    // ── Polygons ────────────────────────────────────────────────────────────

    @discardableResult
    public func addPolygon(_ polygon: InlqPolygon) -> InlqPolygon {
        polygons[polygon.polygonId] = polygon
        return polygon
    }

    public func removePolygon(withId id: InlqPolygonId) {
        polygons.removeValue(forKey: id)
    }

    public func clearPolygons() {
        polygons.removeAll()
    }

    public func getPolygons() -> [InlqPolygon] {
        return Array(polygons.values)
    }

    // ── Circles ─────────────────────────────────────────────────────────────

    @discardableResult
    public func addCircle(_ circle: InlqCircle) -> InlqCircle {
        circles[circle.circleId] = circle
        return circle
    }

    public func removeCircle(withId id: InlqCircleId) {
        circles.removeValue(forKey: id)
    }

    public func clearCircles() {
        circles.removeAll()
    }

    public func getCircles() -> [InlqCircle] {
        return Array(circles.values)
    }

    /**
     * Clears all overlays from the map.
     */
    public func clear() {
        clearMarkers()
        clearPolylines()
        clearPolygons()
        clearCircles()
    }
}
