//
//  Copyright © Aelptos. All rights reserved.
//

import UIKit
import HealthKit
import MapboxMaps

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
        setupMap()
    }

    func update(with locations: [CLLocation]) {
        guard !locations.isEmpty else { return }
        DispatchQueue.main.async {
            self.drawRoute(with: locations)
        }
    }

    func showExportButton() {}
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
    }
}
