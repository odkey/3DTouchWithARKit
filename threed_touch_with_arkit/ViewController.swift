//
//  ViewController.swift
//  threed_touch_with_arkit
//
//  Created by Yota Odaka on 2018/02/15.
//  Copyright © 2018 Yota Odaka. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
  
  @IBOutlet var sceneView: ARSCNView!
  
  private var is3DTouchAvailable: Bool! = false
  private var touchStrengthLabel: UILabel?
  
  private var hasAnyPlaneBeenDetected: Bool! = false
  
  private var detectedPlaneIdentifier: UUID?
  private var cubeNode: SCNNode?
  
  var viewMaxWidth: CGFloat! {
    return self.view.bounds.width
  }
  
  var viewMaxHeight: CGFloat! {
    return self.view.bounds.height
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if self.traitCollection.forceTouchCapability == .available {
      self.is3DTouchAvailable = true
      self.initTouchStrengthLabel()
    }
    self.sceneView.delegate = self
    self.sceneView.showsStatistics = false
    self.sceneView.autoenablesDefaultLighting = true
    self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    let scene = SCNScene()
    self.sceneView.scene = scene
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    sceneView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the view's session
    sceneView.session.pause()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.makeTouchStrengthAppear(touches: touches)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.makeTouchStrengthAppear(touches: touches)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.makeTouchStrengthDisappear()
  }
  
  // MARK: - ARSCNViewDelegate
  
  /*
   // Override to create and configure nodes for anchors added to the view's session.
   func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
   let node = SCNNode()
   
   return node
   }
   */
  
  func renderer(_ renderer: SCNSceneRenderer,
                didAdd node: SCNNode, for anchor: ARAnchor) {
    if let planeAnchor = anchor as? ARPlaneAnchor {
      if self.hasAnyPlaneBeenDetected {
        return
      }
      self.detectedPlaneIdentifier = anchor.identifier
      let cubeGeo =
        SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0)
      cubeGeo.firstMaterial?.diffuse.contents = UIColor.cyan
      self.cubeNode = SCNNode(geometry: cubeGeo)
      self.sceneView.scene.rootNode.addChildNode(self.cubeNode!)
      self.cubeNode?.name = "cube"
      self.cubeNode?.opacity = 1.0
      self.cubeNode?.simdTransform = planeAnchor.transform
      self.hasAnyPlaneBeenDetected = true
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    if let planeAnchor = anchor as? ARPlaneAnchor {
      if planeAnchor.identifier == self.detectedPlaneIdentifier {
        self.cubeNode?.simdTransform = planeAnchor.transform
      }
    }
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    // Present an error message to the user
    
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
  }
  
  func initTouchStrengthLabel() {
    self.touchStrengthLabel =
      UILabel(frame: CGRect(x: 0, y: self.viewMaxHeight/2.0-viewMaxHeight/10.0,
                            width: self.viewMaxWidth, height: viewMaxHeight/5.0))
    self.touchStrengthLabel?.textAlignment = .center
    
    self.touchStrengthLabel?.textColor = UIColor.white
    self.touchStrengthLabel?.alpha = 0.0
    self.touchStrengthLabel?.isHidden = true
    self.view.addSubview(self.touchStrengthLabel!)
  }
  
  func makeTouchStrengthAppear(touches: Set<UITouch>) {
    if !(self.is3DTouchAvailable) {
      return
    }
    guard let touch = touches.first else {
      return
    }
    let strengthRatio = Float(touch.force / touch.maximumPossibleForce)
    let strengthPercent = round(strengthRatio * 100)
    guard let label = self.touchStrengthLabel else {
      return
    }
    label.text = "\(strengthPercent)%"
    label.isHidden = false
    UIView.animate(withDuration: 0.2, animations: {() -> Void  in
      label.alpha = 1.0
    })
    guard let geo = self.cubeNode?.geometry as? SCNBox else {
      return
    }
    geo.chamferRadius = CGFloat(0.05 * strengthRatio)
  }
  
  func makeTouchStrengthDisappear() {
    if !(self.is3DTouchAvailable) {
      return
    }
    guard let label = self.touchStrengthLabel else {
      return
    }
    UIView.animate(
      withDuration: 0.4,
      animations: {() -> Void in
        label.alpha = 0.0
      },
      completion: {(success: Bool) -> Void in
        if success {
          label.isHidden = true
        }
      })
  }
  

}
