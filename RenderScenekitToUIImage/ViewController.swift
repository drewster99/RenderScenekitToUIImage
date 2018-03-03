//
//  ViewController.swift
//  RenderScenekitToUIImage
//
//  Created by Andrew Benson on 2/11/18.
//  Copyright © 2018 Nuclear Cyborg Corp. All rights reserved.
//

import UIKit
import SceneKit
import MetalKit

class ViewController: UIViewController {


    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet  var sceneView: SCNView!
    var scene = SCNScene()
    var hiddenScene = SCNScene()
    var renderer : SCNRenderer?
    var renderTime = TimeInterval(0)
    var timer : Timer?
    
    @IBAction func continuousButtonTouchDown(_ sender: Any) {
        print("continuous down")
    
        timer = Timer.scheduledTimer(withTimeInterval: 0.016667, repeats: true, block: { (t) in
            print("Timer")
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
      
                print("queue")
                let image = strongSelf.renderer!.snapshot(atTime: strongSelf.renderTime, with: strongSelf.sceneView.frame.size, antialiasingMode: SCNAntialiasingMode.multisampling4X)
                strongSelf.imageView.image = image
                
                strongSelf.renderTime += 0.016667
            }
        })
    }
    @IBAction func continuousButtonTouchUp(_ sender: Any) {
        print("continuous up")
        timer?.invalidate()
    }
    @IBAction func button2Clicked(_ sender: Any) {

        print("Snapshotting hidden (blue) scene.")
        let image = renderer!.snapshot(atTime: renderTime, with: sceneView.frame.size, antialiasingMode: SCNAntialiasingMode.multisampling4X)
        
        print ("image = \(image)")
        imageView.image = image
        
        renderTime += 1
    
    }
    
    func setupBlueScene() {

        let cube = SCNBox(width: 1, height: 0.5, length: 2, chamferRadius: 0.15)
        cube.materials[0].diffuse.contents = UIColor.blue.cgColor
        let cubeNode = SCNNode()
        cubeNode.geometry = cube
        hiddenScene.rootNode.addChildNode(cubeNode)

        let light1 = SCNLight()
        light1.type = .spot
        light1.zNear = 0
        light1.zFar = 20
        light1.attenuationStartDistance = 5
        light1.attenuationEndDistance = 100
        light1.spotInnerAngle = 5
        light1.spotOuterAngle = 30
        light1.intensity = 1000
        light1.automaticallyAdjustsShadowProjection = true
        
        let light2 = SCNLight()
        light2.type = .ambient
        light2.intensity = 100
        
        let lightNode1 = SCNNode()
        lightNode1.position = SCNVector3Make(0, 1, 3)
        lightNode1.light = light1
        lightNode1.look(at: SCNVector3Make(0, 0, 0))
        let lightNode2 = SCNNode()
        lightNode2.light = light2
        
        hiddenScene.rootNode.addChildNode(lightNode1)
        hiddenScene.rootNode.addChildNode(lightNode2)

        cubeNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi / 2, z: CGFloat.pi * 2, duration: 7)))
       
        // This will fail if you are on the simulator:
        renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice(), options: nil)
        renderer!.scene = hiddenScene
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        
        sceneView.autoenablesDefaultLighting = false
        sceneView.allowsCameraControl = true
        
        
        let cube = SCNBox(width: 1, height: 0.5, length: 2, chamferRadius: 0.20)
        cube.materials[0].diffuse.contents = UIColor.red.cgColor
        let cubeNode = SCNNode()
        cubeNode.geometry = cube
        
        scene.rootNode.addChildNode(cubeNode)
        sceneView.scene = scene
        
        let light1 = SCNLight()
        light1.type = .spot
        light1.zNear = 0
        light1.zFar = 20
        light1.attenuationStartDistance = 5
        light1.attenuationEndDistance = 100
        light1.spotInnerAngle = 10
        light1.spotOuterAngle = 30
        light1.intensity = 1000
        light1.automaticallyAdjustsShadowProjection = true
        
        let light2 = SCNLight()
        light2.type = .ambient
        light2.intensity = 100
    
        let lightNode1 = SCNNode()
        lightNode1.position = SCNVector3Make(0, 3, 3)
        lightNode1.light = light1
        lightNode1.look(at: SCNVector3Make(0, 0, 0))
        let lightNode2 = SCNNode()
        lightNode2.light = light2
        
        scene.rootNode.addChildNode(lightNode1)
        scene.rootNode.addChildNode(lightNode2)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(snapshotVisibleSCNView))
        sceneView.addGestureRecognizer(tap)
        
        setupBlueScene()
    }
    
    @objc func snapshotVisibleSCNView() {
        print("Snapshotting visible (red) view.")
        imageView.image = sceneView.snapshot()
    }
}

