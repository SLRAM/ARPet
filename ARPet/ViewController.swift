//
//  ViewController.swift
//  ARPet
//
//  Created by Stephanie Ramirez on 2/1/21.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {

	@IBOutlet var arView: ARView!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.startPlaneDetection()
		//for tap placement
//		self.arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
		//for auto placement
		self.placeCube()
//		self.arView.enableObjectRemoval()
		self.arView.enableObjectInteration()
	}

	@objc func handleTap(recognizer: UITapGestureRecognizer) {
		let tapLocation = recognizer.location(in: self.arView)

		let results = self.arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)

		if let firstResult = results.first {
			let worldPosition = simd_make_float3(firstResult.worldTransform.columns.3)
			let sphere = self.createSphere()
			self.placeObjectInWorld(object: sphere, at: worldPosition)
		}
	}

	func startPlaneDetection() {
		self.arView.automaticallyConfigureSession = true
		let configuration = ARWorldTrackingConfiguration()
		configuration.planeDetection = [.horizontal]
		configuration.environmentTexturing = .automatic

		self.arView.session.run(configuration)
	}

	func createSphere() -> ModelEntity {
		let sphere = MeshResource.generateSphere(radius: 0.5)
		let sphereMaterial = SimpleMaterial(color: .black, isMetallic: true)
		let sphereEntity = ModelEntity(mesh: sphere, materials: [sphereMaterial])
		return sphereEntity
	}

	func createCube() -> ModelEntity {
		let cube = MeshResource.generateBox(size: 0.2)
		let cubeMaterial = SimpleMaterial(color: .blue, roughness: 0.5, isMetallic: true)
		let cubeEntity = ModelEntity(mesh: cube, materials: [cubeMaterial])
		return cubeEntity
	}

	func placeCube() {
		let cube = self.createCube()
		self.placeObjectOnPlane(object: cube)
	}

	func placeObjectInWorld(object: ModelEntity, at location: SIMD3<Float>) {
		let objectAnchor = AnchorEntity(world: location)
		objectAnchor.name = "CubeAnchor"
		objectAnchor.addChild(object)

		self.arView.scene.addAnchor(objectAnchor)
	}

	func placeObjectOnPlane(object: ModelEntity) {
		let objectAnchor = AnchorEntity(plane: .horizontal)
		objectAnchor.addChild(object)

		self.arView.scene.addAnchor(objectAnchor)
	}

	//generate collision shapes (needed for gestures)
	func generateCollisionShapes(modelEntity: ModelEntity) {
		modelEntity.generateCollisionShapes(recursive: true)
		// install gestures
		self.arView.installGestures([.translation, .rotation, .scale], for: modelEntity)
	}


}

extension ARView {
	//remove object from scene

	func enableObjectRemoval() {
		let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
		self.addGestureRecognizer(longPressGestureRecognizer)
	}

	@objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
		let location = recognizer.location(in: self)
		if let entity = self.entity(at: location), let anchorEntity = entity.anchor, anchorEntity.name == "CubeAnchor" {
			anchorEntity.removeFromParent()
			print("Removed anchor with name: \(anchorEntity.name)")
		}
	}

	func enableObjectInteration() {
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
		self.addGestureRecognizer(tapGestureRecognizer)
	}

	//access static gesture category (petting, feeding) enum and switch for animation and stat adjustment?
	@objc func handleTap(recognizer: UITapGestureRecognizer) {
		let location = recognizer.location(in: self)
		//can access entity.playAnimation for custom reactions to gesture
		if let entity = self.entity(at: location) {
//			entity.playAnimation(named: <#T##String#>)
			print("entity tapped: \(entity.name)")
		}
	}
}
