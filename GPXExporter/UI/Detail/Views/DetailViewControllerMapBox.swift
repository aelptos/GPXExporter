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
}

extension DetailViewControllerMapBox: DetailViewProtocol {
    func prepareView(with workout: HKWorkout) {
        setupMap()
    }

    func update(with locations: [CLLocation]) {}

    func showExportButton() {}
}

private extension DetailViewControllerMapBox {
    func setupMap() {
        let resourceOptions = ResourceOptions(
            accessToken: getAccessToken()
        )
        let mapInitOptions = MapInitOptions(
            resourceOptions: resourceOptions
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
}
