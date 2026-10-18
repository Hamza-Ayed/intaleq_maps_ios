/**
 * وظيفة الملف: توفير واجهة عرض الخريطة IntaleqMapView لنظام iOS تدعم العرض ثنائي وثلاثي الأبعاد (2D & 3D).
 */
import Foundation
import WebKit
import SwiftUI

#if canImport(UIKit)
import UIKit
public typealias InlqBaseView = UIView
#elseif canImport(AppKit)
import AppKit
public typealias InlqBaseView = NSView
#endif

public protocol IntaleqMapViewDelegate: AnyObject {
    func mapView(_ mapView: IntaleqMapView, didTapAt coordinate: InlqLatLng)
    func mapView(_ mapView: IntaleqMapView, didChangeCameraPosition position: InlqCameraPosition)
    func mapViewDidFinishLoading(_ mapView: IntaleqMapView)
}

/**
 * High-performance iOS Map View displaying Intaleq 2D & 3D vector maps.
 * Compatible with Google Maps SDK GMSMapView conventions.
 */
public class IntaleqMapView: InlqBaseView, WKScriptMessageHandler, WKNavigationDelegate {

    public weak var delegate: IntaleqMapViewDelegate?
    public private(set) var controller: IntaleqMapController
    private var webView: WKWebView!
    private var isMapLoaded: Bool = false
    private var pendingAsyncCallbacks: [(IntaleqMapController) -> Void] = []
    
    public var is3DEnabled: Bool = false {
        didSet {
            set3DMode(is3DEnabled)
        }
    }

    public init(frame: CGRect, camera: InlqCameraPosition = InlqCameraPosition(target: InlqLatLng(latitude: 31.9539, longitude: 35.9106), zoom: 12.0)) {
        self.controller = IntaleqMapController()
        super.init(frame: frame)
        setupWebView(initialCamera: camera)
    }

    required init?(coder: NSCoder) {
        self.controller = IntaleqMapController()
        super.init(coder: coder)
        setupWebView(initialCamera: InlqCameraPosition(target: InlqLatLng(latitude: 31.9539, longitude: 35.9106), zoom: 12.0))
    }

    private func setupWebView(initialCamera: InlqCameraPosition) {
        let contentController = WKUserContentController()
        contentController.add(self, name: "intaleqMapBridge")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        webView = WKWebView(frame: bounds, configuration: config)
        #if canImport(UIKit)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.08, alpha: 1.0)
        webView.scrollView.isScrollEnabled = false
        #elseif canImport(AppKit)
        webView.autoresizingMask = [.width, .height]
        #endif
        webView.navigationDelegate = self
        addSubview(webView)

        loadMapHTML(initialCamera: initialCamera)
    }

    private func loadMapHTML(initialCamera: InlqCameraPosition) {
        let styleUrl = IntaleqStyles.terrain
        let initialLat = initialCamera.target.latitude
        let initialLng = initialCamera.target.longitude
        let initialZoom = initialCamera.zoom
        let initialPitch = initialCamera.viewingAngle
        let initialBearing = initialCamera.bearing

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
            <title>Intaleq Maps</title>
            <script src="https://unpkg.com/maplibre-gl@4.7.1/dist/maplibre-gl.js"></script>
            <link href="https://unpkg.com/maplibre-gl@4.7.1/dist/maplibre-gl.css" rel="stylesheet" />
            <style>
                html, body, #map { margin: 0; padding: 0; width: 100%; height: 100%; background: #101014; }
                .marker-pin {
                    width: 32px;
                    height: 32px;
                    border-radius: 50% 50% 50% 0;
                    background: #0071E3;
                    position: absolute;
                    transform: rotate(-45deg);
                    left: 50%;
                    top: 50%;
                    margin: -16px 0 0 -16px;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.4);
                    border: 2px solid #ffffff;
                }
            </style>
        </head>
        <body>
            <div id="map"></div>
            <script>
                var map = new maplibregl.Map({
                    container: 'map',
                    style: '\(styleUrl)',
                    center: [\(initialLng), \(initialLat)],
                    zoom: \(initialZoom),
                    pitch: \(initialPitch),
                    bearing: \(initialBearing),
                    attributionControl: false
                });

                var activeMarkers = {};

                map.on('load', function() {
                    window.webkit.messageHandlers.intaleqMapBridge.postMessage({ type: 'onMapReady' });
                });

                map.on('click', function(e) {
                    window.webkit.messageHandlers.intaleqMapBridge.postMessage({
                        type: 'onMapClick',
                        lat: e.lngLat.lat,
                        lng: e.lngLat.lng
                    });
                });

                map.on('moveend', function() {
                    var c = map.getCenter();
                    window.webkit.messageHandlers.intaleqMapBridge.postMessage({
                        type: 'onCameraMove',
                        lat: c.lat,
                        lng: c.lng,
                        zoom: map.getZoom(),
                        pitch: map.getPitch(),
                        bearing: map.getBearing()
                    });
                });

                function setMapStyle(styleUrl) {
                    map.setStyle(styleUrl);
                }

                function set3D(enabled) {
                    if (enabled) {
                        map.easeTo({ pitch: 65, bearing: -35, duration: 1200 });
                    } else {
                        map.easeTo({ pitch: 0, bearing: 0, duration: 1000 });
                    }
                }

                function animateTo(lat, lng, zoom, pitch, bearing) {
                    var opt = { center: [lng, lat], duration: 1200 };
                    if (zoom !== undefined && zoom !== null) opt.zoom = zoom;
                    if (pitch !== undefined && pitch !== null) opt.pitch = pitch;
                    if (bearing !== undefined && bearing !== null) opt.bearing = bearing;
                    map.flyTo(opt);
                }

                function addMarker(id, lat, lng, title) {
                    if (activeMarkers[id]) {
                        activeMarkers[id].remove();
                    }
                    var el = document.createElement('div');
                    el.className = 'marker-pin';
                    var m = new maplibregl.Marker({ element: el })
                        .setLngLat([lng, lat])
                        .addTo(map);
                    if (title) {
                        var popup = new maplibregl.Popup({ offset: 25 }).setText(title);
                        m.setPopup(popup);
                    }
                    activeMarkers[id] = m;
                }

                function clearMarkers() {
                    for (var k in activeMarkers) {
                        activeMarkers[k].remove();
                    }
                    activeMarkers = {};
                }
            </script>
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: URL(string: IntaleqMaps.shared.baseUrl))
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "intaleqMapBridge",
              let dict = message.body as? [String: Any],
              let type = dict["type"] as? String else { return }

        switch type {
        case "onMapReady":
            isMapLoaded = true
            delegate?.mapViewDidFinishLoading(self)
            for cb in pendingAsyncCallbacks {
                cb(controller)
            }
            pendingAsyncCallbacks.removeAll()

        case "onMapClick":
            if let lat = dict["lat"] as? Double, let lng = dict["lng"] as? Double {
                let coord = InlqLatLng(latitude: lat, longitude: lng)
                delegate?.mapView(self, didTapAt: coord)
            }

        case "onCameraMove":
            if let lat = dict["lat"] as? Double,
               let lng = dict["lng"] as? Double,
               let zoom = dict["zoom"] as? Double,
               let pitch = dict["pitch"] as? Double,
               let bearing = dict["bearing"] as? Double {
                let pos = InlqCameraPosition(
                    target: InlqLatLng(latitude: lat, longitude: lng),
                    zoom: Float(zoom),
                    viewingAngle: pitch,
                    bearing: bearing
                )
                delegate?.mapView(self, didChangeCameraPosition: pos)
            }

        default:
            break
        }
    }

    // MARK: - Public API

    public func getMapAsync(completion: @escaping (IntaleqMapController) -> Void) {
        if isMapLoaded {
            completion(controller)
        } else {
            pendingAsyncCallbacks.append(completion)
        }
    }

    public func set3DMode(_ enabled: Bool) {
        self.is3DEnabled = enabled
        let js = "set3D(\(enabled ? "true" : "false"));"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    public func setStyle(styleUrl: String) {
        let js = "setMapStyle('\(styleUrl)');"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    public func setMapType(_ mapType: IntaleqMapType) {
        switch mapType {
        case .terrain:
            setStyle(styleUrl: IntaleqStyles.terrain)
        case .dark:
            setStyle(styleUrl: IntaleqStyles.dark)
        case .satellite:
            setStyle(styleUrl: IntaleqStyles.satellite)
        case .normal, .light:
            setStyle(styleUrl: IntaleqStyles.normal)
        case .none:
            break
        }
    }

    public func animateCamera(to coordinate: InlqLatLng, zoom: Float? = nil, pitch: Double? = nil, bearing: Double? = nil) {
        let zoomStr = zoom != nil ? "\(zoom!)" : "null"
        let pitchStr = pitch != nil ? "\(pitch!)" : "null"
        let bearingStr = bearing != nil ? "\(bearing!)" : "null"
        let js = "animateTo(\(coordinate.latitude), \(coordinate.longitude), \(zoomStr), \(pitchStr), \(bearingStr));"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    public func addMarker(id: String, coordinate: InlqLatLng, title: String? = nil) {
        let titleEscaped = title?.replacingOccurrences(of: "'", with: "\\'") ?? ""
        let js = "addMarker('\(id)', \(coordinate.latitude), \(coordinate.longitude), '\(titleEscaped)');"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    public func clearMarkers() {
        webView.evaluateJavaScript("clearMarkers();", completionHandler: nil)
    }
}

// MARK: - SwiftUI Support
#if canImport(UIKit)
public struct IntaleqMapViewRepresentable: UIViewRepresentable {
    public var camera: InlqCameraPosition
    public var is3D: Bool
    public var mapType: IntaleqMapType
    public var onMapReady: ((IntaleqMapView) -> Void)?

    public init(
        camera: InlqCameraPosition = InlqCameraPosition(target: InlqLatLng(latitude: 31.9539, longitude: 35.9106), zoom: 12.0),
        is3D: Bool = false,
        mapType: IntaleqMapType = .terrain,
        onMapReady: ((IntaleqMapView) -> Void)? = nil
    ) {
        self.camera = camera
        self.is3D = is3D
        self.mapType = mapType
        self.onMapReady = onMapReady
    }

    public func makeUIView(context: Context) -> IntaleqMapView {
        let mapView = IntaleqMapView(frame: .zero, camera: camera)
        mapView.getMapAsync { _ in
            mapView.setMapType(mapType)
            if is3D {
                mapView.set3DMode(true)
            }
            onMapReady?(mapView)
        }
        return mapView
    }

    public func updateUIView(_ uiView: IntaleqMapView, context: Context) {
        uiView.set3DMode(is3D)
        uiView.setMapType(mapType)
    }
}
#elseif canImport(AppKit)
public struct IntaleqMapViewRepresentable: NSViewRepresentable {
    public var camera: InlqCameraPosition
    public var is3D: Bool
    public var mapType: IntaleqMapType
    public var onMapReady: ((IntaleqMapView) -> Void)?

    public init(
        camera: InlqCameraPosition = InlqCameraPosition(target: InlqLatLng(latitude: 31.9539, longitude: 35.9106), zoom: 12.0),
        is3D: Bool = false,
        mapType: IntaleqMapType = .terrain,
        onMapReady: ((IntaleqMapView) -> Void)? = nil
    ) {
        self.camera = camera
        self.is3D = is3D
        self.mapType = mapType
        self.onMapReady = onMapReady
    }

    public func makeNSView(context: Context) -> IntaleqMapView {
        let mapView = IntaleqMapView(frame: .zero, camera: camera)
        mapView.getMapAsync { _ in
            mapView.setMapType(mapType)
            if is3D {
                mapView.set3DMode(true)
            }
            onMapReady?(mapView)
        }
        return mapView
    }

    public func updateNSView(_ nsView: IntaleqMapView, context: Context) {
        nsView.set3DMode(is3D)
        nsView.setMapType(mapType)
    }
}
#endif
