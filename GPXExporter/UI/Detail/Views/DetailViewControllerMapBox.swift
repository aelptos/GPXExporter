//
//  Copyright © Aelptos. All rights reserved.
//

import UIKit
import HealthKit
import MapboxMaps
import SwiftUI

fileprivate let mapBoxAccessTokenKey = "MBXAccessToken"

final class DetailViewControllerMapBox: UIViewController {
    private let presenter: DetailPresenterProtocol
    private var mapView: MapView!

    init(
        presenter: DetailPresenterProtocol
    ) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.viewDidLoad()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            refreshMapStyle()
        }
    }
}

extension DetailViewControllerMapBox: DetailViewProtocol {
    func prepareView(with workout: HKWorkout) {
        setupNavigation()
        setupMap()
        setupBanner(with: workout)
    }

    func update(with locations: [CLLocation]) {
        guard !locations.isEmpty else { return }
        DispatchQueue.main.async {
            self.drawRoute(with: locations)
        }
    }

    func showExportButton() {
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .action,
                target: self,
                action: #selector(self.onShareButtonTap)
            )
        }
    }
}

private extension DetailViewControllerMapBox {
    func setupNavigation() {
        title = "detail.title".localized
        navigationItem.largeTitleDisplayMode = .never
        resetNavigationBarAppearance()
    }
    
    func resetNavigationBarAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        navigationItem.compactAppearance = navigationBarAppearance
    }

    @objc func onShareButtonTap() {
        presenter.didRequestShare()
    }
}

private extension DetailViewControllerMapBox {
    func setupMap() {
        let resourceOptions = ResourceOptions(
            accessToken: getAccessToken()
        )
        let mapInitOptions = MapInitOptions(
            resourceOptions: resourceOptions,
            styleURI: getStyle()
        )
        mapView = MapView(
            frame: view.bounds,
            mapInitOptions: mapInitOptions
        )
        mapView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        mapView.ornaments.options.scaleBar.visibility = .hidden
        view.addSubview(mapView)
    }

    func getAccessToken() -> String {
        guard let accessToken = Bundle.main.infoDictionary?[mapBoxAccessTokenKey] as? String else {
            fatalError("\(mapBoxAccessTokenKey) is not defined in the Info.plist")
        }
        return accessToken
    }

    func getStyle() -> StyleURI {
        if traitCollection.userInterfaceStyle == .light {
            return .light
        }
        return .dark
    }

    func refreshMapStyle() {
        mapView.mapboxMap.loadStyleURI(getStyle())
    }
}

private extension DetailViewControllerMapBox {
    func drawRoute(with locations: [CLLocation]) {
        let coordinates = locations.map { $0.coordinate }
        var annotation = PolylineAnnotation(
            lineCoordinates: coordinates
        )
        annotation.lineColor = StyleColor(view.tintColor)
        annotation.lineWidth = 3
        mapView.annotations.makePolylineAnnotationManager().annotations = [annotation]
        updateCamera(for: annotation.geometry)
    }

    func updateCamera(for geometry: Geometry) {
        let newCamera = mapView.mapboxMap.camera(
            for: geometry,
            padding: makePadding(),
            bearing: 0,
            pitch: 0
        )
        mapView.camera.ease(to: newCamera, duration: 0.5)
    }

    func makePadding() -> UIEdgeInsets {
        let inset: CGFloat = 50
        return UIEdgeInsets(
            top: inset,
            left: inset,
            bottom: inset,
            right: inset
        )
    }
}

private extension DetailViewControllerMapBox {
    func setupBanner(with workout: HKWorkout) {
        let host = UIHostingController(rootView: WorkoutView(workout: workout, vibrancy: true))
        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        host.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        host.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        host.didMove(toParent: self)
        host.view.layer.cornerRadius = 16
        host.view.layer.masksToBounds = true
        host.view.backgroundColor = .clear
    }
}
