//
//  Copyright © Aelptos. All rights reserved.
//

import UIKit
import HealthKit
import MapboxMaps

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

        guard let accessToken = Bundle.main.infoDictionary?["MBXAccessToken"] as? String else { fatalError("MBXAccessToken is not defined") }
        let myResourceOptions = ResourceOptions(accessToken: accessToken)
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)
    }
}

extension DetailViewControllerMapBox: DetailViewProtocol {
    func prepareView(with workout: HKWorkout) {}

    func update(with locations: [CLLocation]) {}

    func showExportButton() {}
}
