//
//  ViewController.swift
//  VariousCurrentSituations
//
//  Created by iganin on 2018/07/18.
//  Copyright © 2018年 iganin. All rights reserved.
//

import UIKit
import CoreLocation

final class CurrentLocationViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet private weak var locationMameLabel: UILabel!
    @IBOutlet private weak var updateButton: UIButton! {
        didSet {
            updateButton.clipsToBounds = true
            updateButton.layer.cornerRadius = 4.0
        }
    }
    
    @IBAction private func updateButtonTapped(_ sender: UIButton) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied, .notDetermined, .restricted:
            return
        }
    }
    
    // MARK: - Property
    let viewModel = ViewModel()
    var locationManager: CLLocationManager!
    var locationName: String? {
        didSet {
            locationMameLabel.text = locationName // Labelの更新
        }
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
        viewModel.didChangeState = { [weak self] state in
            guard let `self` = self else { return }
            switch state {
            case .none: break
            case .loading: break // loadingの表示
            case .success(let string):
                // loadingの非表示
                self.locationName = string
            case .failure(_):
                // loadingの非表示
                let title = "エラー"
                let message = "位置情報の取得に失敗しました"
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Private Method
private extension CurrentLocationViewController {
}

// MARK: - CLLocationManagerDelegate
extension CurrentLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse: break // 許可済み
        case .denied, .restricted: break // 許可していない
        case .notDetermined: locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        viewModel.fetchLocationName(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}