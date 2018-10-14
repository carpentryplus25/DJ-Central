//
//  MenuViewController.swift
//  DJ Central
//
//  Created by William Thompson on 6/13/17.
//  Copyright © 2017 J. W. Enterprises, LLC. All rights reserved.
//

import UIKit
import StoreKit
import MediaPlayer

class MenuViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchase", for: indexPath)
        return cell
    }
    
    
    var interactor: SlideRevealViewInteractor? = nil
    var delegate: SlideRevealViewDelegate? = nil
    var mainViewController: MainViewController? = nil
    var authorizationManager: AuthorizationManager!
    let cloudServiceController = SKCloudServiceController()
    //let appleMusicManager: AppleMusicManager
    var cloudServiceCapabilities = SKCloudServiceCapability()
    var cloudServiceStoreFrontCountryCode = "us"
    var isViewPresented: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isViewPresented = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeMenu(_ sender: Any) {
        dismiss(animated: true){
        self.isViewPresented = false
        }
    }
    
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let progress = SlideRevealViewHelper.calculateProgress(translation, viewBounds: view.bounds, direction: .Up)
        SlideRevealViewHelper.mapGestureStateToInteractor(sender.state, progress: progress, interactor: interactor){
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func delay(seconds: Double, completion:@escaping ()->()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        dismiss(animated: true){
            self.delay(seconds: 0.5){
                self.mainViewController?.reopenMenu()
                self.isViewPresented = true
            }
        }
    }
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
