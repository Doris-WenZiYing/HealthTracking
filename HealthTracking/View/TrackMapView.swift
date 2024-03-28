////
////  WorkoutRouteVew.swift
////  HealthTracking
////
////  Created by Doris Wen on 2024/1/19.
////
//
//import SwiftUI
//import MapKit
//
//struct TrackMapView: UIViewRepresentable {
//    @ObservedObject var viewModel: WorkoutViewModel // Assume real-time tracking usage
//    var polylineColor: UIColor = .orange
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        mapView.showsUserLocation = true
//        mapView.userTrackingMode = .follow
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        // This function is automatically called when viewModel publishes changes
//        updateMapForRoute(uiView, route: viewModel.currentRoute)
//    }
//
//    private func updateMapForRoute(_ mapView: MKMapView, route: Route) {
//        mapView.removeOverlays(mapView.overlays)
//        let coordinates = route.locations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
//        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
//        mapView.addOverlay(polyline)
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: TrackMapView
//
//        init(_ parent: TrackMapView) {
//            self.parent = parent
//        }
//
//        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//            if overlay is MKPolyline {
//                let renderer = MKPolylineRenderer(overlay: overlay)
//                renderer.strokeColor = parent.polylineColor
//                renderer.lineWidth = 4
//                return renderer
//            }
//            return MKOverlayRenderer()
//        }
//    }
//}
