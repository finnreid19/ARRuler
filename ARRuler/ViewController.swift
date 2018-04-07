import UIKit
import SceneKit
import ARKit

extension SCNGeometry {
    class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
        
    }
}



class ViewController: UIViewController {
    
    @IBOutlet weak var crosshair: UILabel!
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        let scene = SCNScene()
        
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    @IBOutlet var crosshairLabel: UILabel!
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        if case .limited(let reason) = camera.trackingState {
            print(reason)
        }
    }
    
    var coordinates: [SCNVector3] = []
    var counter = 0
    @IBOutlet var label: UILabel!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else{return}
        print(touch.location(in: sceneView))
        
        let frameSize: CGPoint = CGPoint(x: UIScreen.main.bounds.size.width*0.5,y: UIScreen.main.bounds.size.height*0.5)
        
        let result = sceneView.hitTest(frameSize, types: [ARHitTestResult.ResultType.featurePoint]) //https://github.com/DroidsOnRoids/MeasureARKit/blob/master/ARSampleApp/ViewController.swift
        guard let hitResult = result.last else{return}
        let hitTransform = SCNMatrix4(hitResult.worldTransform)
        let hitVector = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43) //makes a point with xyz coordinates
        createBall(position: hitVector)
        if counter == 0 || counter%2 == 0{
            coordinates.append(hitVector)
        }
        else{
            coordinates.append(hitVector)
            print(getShoeSize(position1: coordinates[counter-1], position2: coordinates[counter]))
            self.label.text = (getShoeSize(position1: coordinates[counter-1], position2: coordinates[counter]).description)
            let line = SCNGeometry.lineFrom(vector: coordinates[counter-1], toVector: coordinates[counter])
            let lineNode = SCNNode(geometry: line)
            lineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            sceneView.scene.rootNode.addChildNode(lineNode)
        }
        
        
        counter+=1

    }
    
    func square(number: Float) -> Float {
        return number * number
    }
    
    func getShoeSize(position1: SCNVector3, position2: SCNVector3) -> Float{ //add argument for womens, other countries, etc.
        
        let distanceX = position1.x-position2.x
        let distanceY = position1.y-position2.y
        let distanceZ = position1.z-position2.z
        let distanceInMeters = sqrtf(square(number: distanceX) + square(number: distanceY) + square(number: distanceZ))
        let distanceInCentimeters = distanceInMeters*100
        return distanceInCentimeters
        
        //how to find distance between two points on 3D plane http://www.math.usm.edu/lambers/mat169/fall09/lecture17.pdf
        
        
    }
    
    
    
    func createBall(position: SCNVector3){
        let ballShape = SCNSphere(radius: 0.005)
        let ballNode = SCNNode(geometry: ballShape)
        ballNode.position = position
        sceneView.scene.rootNode.addChildNode(ballNode)
    }
    

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}


