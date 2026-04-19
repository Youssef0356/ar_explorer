import 'package:flutter/material.dart';
import '../../models/coding_game_models.dart';

final List<CodingZone> codingGameZones = [
  // ── ZONE 1: VUFORIA (Unity/C#) ─────────────────────────────────────────────
  CodingZone(
    id: 'z1_vuforia',
    name: 'Vuforia Engine',
    platform: 'Unity / C#',
    icon: Icons.view_in_ar_rounded,
    accentColor: const Color(0xFF00E5FF),
    levels: [
      CodingLevel(
        id: 'v1_init',
        title: 'Observer Initialization',
        goal: 'Detect an Image Target by creating an Observer.',
        isFree: true, // Zone 1 is free for all users
        lines: [
          CodeLine(text: 'using Vuforia;', indent: 0),
          CodeLine(text: 'public class ARController : MonoBehaviour {', indent: 0),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'ObserverBehaviour'),
            CodeSlot(id: 's2', label: 'mObserver'),
            CodeSlot(id: 's3', label: ';'),
          ], indent: 1),
          CodeLine(text: '', indent: 0),
          CodeLine(text: 'void Start() {', indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's4', label: 'mObserver'),
            CodeSlot(id: 's5', label: '='),
            CodeSlot(id: 's6', label: 'VuforiaBehaviour.Instance.ObserverFactory.CreateImageTargetObserver("target");'),
          ], indent: 2),
          CodeLine(text: '}', indent: 1),
          CodeLine(text: '}', indent: 0),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'ObserverBehaviour', correctSlotId: 's1'),
          WordChip(id: 'w2', label: 'mObserver', correctSlotId: 's2'),
          WordChip(id: 'w3', label: ';', correctSlotId: 's3'),
          WordChip(id: 'w4', label: 'mObserver', correctSlotId: 's4'),
          WordChip(id: 'w5', label: '=', correctSlotId: 's5'),
          WordChip(id: 'w6', label: 'VuforiaBehaviour', correctSlotId: 's6'),
          WordChip(id: 'd1', label: 'Session', correctSlotId: 'none'),
          WordChip(id: 'd2', label: 'GameObject', correctSlotId: 'none'),
        ],
        mascotHint: 'Think about the type of behavior Vuforia uses for tracking.',
        feedbackExplanation: 'Vuforia uses ObserverBehaviours to track targets. The ObserverFactory creates these observers at runtime.',
      ),
      CodingLevel(
        id: 'v1_target',
        title: 'Image Target Config',
        goal: 'Configure the Image Target behavior.',
        isFree: true, // Zone 1 is free for all users
        lines: [
          CodeLine(text: 'void SetupTarget() {', indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'mObserver.TargetWidth = 0.5f;'),
          ], indent: 2),
          CodeLine(text: '}', indent: 1),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'TargetWidth', correctSlotId: 's1'),
          WordChip(id: 'd1', label: 'SetSize', correctSlotId: 'none'),
          WordChip(id: 'd2', label: 'PhysicalWidth', correctSlotId: 'none'),
          WordChip(id: 'd3', label: 'Width', correctSlotId: 'none'),
          WordChip(id: 'd4', label: 'ScaleX', correctSlotId: 'none'),
        ],
        mascotHint: 'Consider the property that defines the target\'s real-world horizontal dimension.',
        feedbackExplanation: 'Correct! Setting the physical target size is essential for accurate scale tracking.',
      ),
      CodingLevel(
        id: 'v1_boss',
        title: 'VUFORIA BOSS: Tracking Lifecycle',
        goal: 'Implement a robust tracking event handler to manage AR content visibility.',
        isBoss: true,
        isFree: true,
        timeLimit: 120,
        lines: [
          CodeLine(text: 'protected virtual void OnTrackingFound() {', indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'var rendererComponents = GetComponentsInChildren<Renderer>(true);'),
          ], indent: 2),
          CodeLine(text: 'foreach (var component in rendererComponents)', indent: 2),
          CodeLine(slots: [
            CodeSlot(id: 's2', label: 'component.enabled = true;'),
          ], indent: 3),
          CodeLine(text: '', indent: 0),
          CodeLine(text: '// Enable physics', indent: 2),
          CodeLine(slots: [
            CodeSlot(id: 's3', label: 'var colliderComponents = GetComponentsInChildren<Collider>(true);'),
          ], indent: 2),
          CodeLine(text: 'foreach (var component in colliderComponents)', indent: 2),
          CodeLine(slots: [
            CodeSlot(id: 's4', label: 'component.enabled = true;'),
          ], indent: 3),
          CodeLine(text: '}', indent: 1),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'GetComponentsInChildren<Renderer>(true);', correctSlotId: 's1'),
          WordChip(id: 'w2', label: 'component.enabled = true;', correctSlotId: 's2'),
          WordChip(id: 'w3', label: 'GetComponentsInChildren<Collider>(true);', correctSlotId: 's3'),
          WordChip(id: 'w4', label: 'component.enabled = true;', correctSlotId: 's4'),
          WordChip(id: 'd1', label: 'FindObjectsOfType<Renderer>();', correctSlotId: 'none'),
          WordChip(id: 'd2', label: 'component.SetActive(true);', correctSlotId: 'none'),
          WordChip(id: 'd3', label: 'gameObject.SetActive(true);', correctSlotId: 'none'),
          WordChip(id: 'd4', label: 'GetComponent<Collider>();', correctSlotId: 'none'),
        ],
        mascotHint: 'Vuforia\'s default handler toggles individual Renderers and Colliders rather than disabling the entire GameObject root.',
        feedbackExplanation: 'Toggling Renderers and Colliders instead of SetActive(false) on the root ensures that tracking scripts remain active while the target is lost.',
      ),
    ],
  ),

  // ── ZONE 2: ARKIT (iOS/Swift) ──────────────────────────────────────────────
  CodingZone(
    id: 'z2_arkit',
    name: 'ARKit Engine',
    platform: 'iOS / Swift',
    icon: Icons.apple_rounded,
    accentColor: const Color(0xFF2979FF),
    levels: [
      CodingLevel(
        id: 'ak1_session',
        title: 'ARSession Setup',
        goal: 'Start an ARKit session with plane detection.',
        isFree: true, // First level of zone is free
        lines: [
          CodeLine(text: 'import ARKit', indent: 0),
          CodeLine(text: 'let session = ARSession()', indent: 0),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'let configuration = ARWorldTrackingConfiguration()'),
          ], indent: 0),
          CodeLine(slots: [
            CodeSlot(id: 's2', label: 'configuration.planeDetection ='),
            CodeSlot(id: 's3', label: '[.horizontal, .vertical]'),
          ], indent: 0),
          CodeLine(slots: [
            CodeSlot(id: 's4', label: 'session.run(configuration)'),
          ], indent: 0),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'ARWorldTrackingConfiguration()', correctSlotId: 's1'),
          WordChip(id: 'w2', label: 'configuration.planeDetection', correctSlotId: 's2'),
          WordChip(id: 'w3', label: '[.horizontal, .vertical]', correctSlotId: 's3'),
          WordChip(id: 'w4', label: 'session.run(configuration)', correctSlotId: 's4'),
          WordChip(id: 'd1', label: 'ARConfiguration()', correctSlotId: 'none'),
          WordChip(id: 'd2', label: 'session.start()', correctSlotId: 'none'),
        ],
        mascotHint: 'Swift uses ARWorldTrackingConfiguration for the most capable AR sessions.',
        feedbackExplanation: 'ARWorldTrackingConfiguration enables 6DOF tracking and is required for plane detection features.',
      ),
      CodingLevel(
        id: 'ak1_anchor',
        title: 'Anchor Management',
        goal: 'Add an anchor to the AR session.',
        lines: [
          CodeLine(text: 'let anchor = ARAnchor(transform: matrix)', indent: 0),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'session.add(anchor: anchor)'),
          ], indent: 0),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'session.add', correctSlotId: 's1'),
          WordChip(id: 'd1', label: 'session.post', correctSlotId: 'none'),
          WordChip(id: 'd2', label: 'session.attach', correctSlotId: 'none'),
          WordChip(id: 'd3', label: 'scene.append', correctSlotId: 'none'),
          WordChip(id: 'd4', label: 'session.insert', correctSlotId: 'none'),
        ],
        mascotHint: 'Think about how you introduce an ARAnchor into the tracking environment.',
        feedbackExplanation: 'Correct! ARAnchors pin virtual content to physical locations.',
      ),
      CodingLevel(
        id: 'ak1_boss',
        title: 'ARKIT BOSS: Screen Surface Raycast',
        goal: 'Perform a raycast against estimated planes to place a 3D object.',
        isBoss: true,
        timeLimit: 150,
        lines: [
          CodeLine(text: '@objc func handleTap(_ sender: UITapGestureRecognizer) {', indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'let tapLocation = sender.location(in: sceneView)'),
          ], indent: 2),
          CodeLine(text: 'guard let query = sceneView.raycastQuery(from: tapLocation,', indent: 2),
          CodeLine(slots: [
            CodeSlot(id: 's2', label: 'allowing: .estimatedPlane, alignment: .horizontal) else { return }'),
          ], indent: 5),
          CodeLine(slots: [
            CodeSlot(id: 's3', label: 'let results = sceneView.session.raycast(query)'),
          ], indent: 2),
          CodeLine(text: 'guard let hitTestResult = results.first else { return }', indent: 2),
          CodeLine(slots: [
            CodeSlot(id: 's4', label: 'let anchor = ARAnchor(transform: hitTestResult.worldTransform)'),
          ], indent: 2),
          CodeLine(text: 'sceneView.session.add(anchor: anchor)', indent: 2),
          CodeLine(text: '}', indent: 1),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'sender.location(in: sceneView)', correctSlotId: 's1'),
          WordChip(id: 'w2', label: 'allowing: .estimatedPlane, alignment: .horizontal)', correctSlotId: 's2'),
          WordChip(id: 'w3', label: 'sceneView.session.raycast(query)', correctSlotId: 's3'),
          WordChip(id: 'w4', label: 'ARAnchor(transform: hitTestResult.worldTransform)', correctSlotId: 's4'),
          WordChip(id: 'd1', label: 'sender.view.position', correctSlotId: 'none'),
          WordChip(id: 'd2', label: 'allowing: .featurePoint, alignment: .any)', correctSlotId: 'none'),
          WordChip(id: 'd3', label: 'sceneView.hitTest(tapLocation)', correctSlotId: 'none'),
          WordChip(id: 'd4', label: 'ARAnchor(matrix: hitTestResult.localTransform)', correctSlotId: 'none'),
        ],
        mascotHint: 'Modern ARKit prefers the powerful RaycastQuery API over the deprecated hitTest method.',
        feedbackExplanation: 'A properly configured raycastQuery allows continuous surface tracking and is much more reliable than older hit-testing methods.',
      ),
    ],
  ),

  // ── ZONE 3: ARCORE (Android/Kotlin) ────────────────────────────────────────
  CodingZone(
    id: 'z3_arcore',
    name: 'ARCore / SceneView',
    platform: 'Android / Kotlin',
    icon: Icons.android_rounded,
    accentColor: const Color(0xFF4CAF50),
    levels: [
      CodingLevel(
        id: 'ac1_hit',
        title: 'Hit Testing',
        goal: 'Perform a hit test to find surfaces.',
        isFree: true, // First level of zone is free
        lines: [
          CodeLine(text: 'sceneView.onTapAR = { hitResult, _ ->', indent: 0),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'val anchor = hitResult.createAnchor()'),
          ], indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's2', label: 'val node = ModelNode(anchor)'),
          ], indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's3', label: 'sceneView.addChild(node)'),
          ], indent: 1),
          CodeLine(text: '}', indent: 0),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'hitResult.createAnchor()', correctSlotId: 's1'),
          WordChip(id: 'w2', label: 'ModelNode(anchor)', correctSlotId: 's2'),
          WordChip(id: 'w3', label: 'sceneView.addChild(node)', correctSlotId: 's3'),
          WordChip(id: 'd1', label: 'hitResult.getPose()', correctSlotId: 'none'),
          WordChip(id: 'd2', label: 'sceneView.render(node)', correctSlotId: 'none'),
        ],
        mascotHint: 'Anchors are the foundation of stable ARCore placement.',
        feedbackExplanation: 'createAnchor() attaches a virtual coordinate system to a real-world point detected by ARCore.',
      ),
      CodingLevel(
        id: 'ac1_depth',
        title: 'Depth API',
        goal: 'Access depth data for occlusion.',
        lines: [
          CodeLine(text: 'val depthImage = frame.acquireDepthImage16Bit()', indent: 0),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'depthImage.close()'),
          ], indent: 0),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'close()', correctSlotId: 's1'),
          WordChip(id: 'd1', label: 'dispose()', correctSlotId: 'none'),
          WordChip(id: 'd2', label: 'release()', correctSlotId: 'none'),
          WordChip(id: 'd3', label: 'free()', correctSlotId: 'none'),
          WordChip(id: 'd4', label: 'deallocate()', correctSlotId: 'none'),
        ],
        mascotHint: 'Image objects hold native resources that must be explicitly relinquished.',
        feedbackExplanation: 'Correct. Managing depth buffers is crucial for performance.',
      ),
      CodingLevel(
        id: 'ac1_boss',
        title: 'ARCORE BOSS: Cloud Anchor Hosting',
        goal: 'Initiate and verify the hosting sequence for a Google Cloud Anchor.',
        isBoss: true,
        timeLimit: 150,
        lines: [
          CodeLine(text: 'fun hostAnchor(session: Session, localAnchor: Anchor) {', indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'session.hostCloudAnchorAsync(localAnchor) { anchor, state ->'),
          ], indent: 2),
          CodeLine(slots: [
            CodeSlot(id: 's2', label: 'if (state == Anchor.CloudAnchorState.SUCCESS) {'),
          ], indent: 3),
          CodeLine(slots: [
            CodeSlot(id: 's3', label: 'val cloudAnchorId = anchor.cloudAnchorId'),
          ], indent: 4),
          CodeLine(text: 'saveAnchorToDatabase(cloudAnchorId)', indent: 4),
          CodeLine(text: '} else {', indent: 3),
          CodeLine(slots: [
            CodeSlot(id: 's4', label: 'Log.e("ARCore", "Failed to host: \$state")'),
          ], indent: 4),
          CodeLine(text: '}', indent: 3),
          CodeLine(text: '}', indent: 2),
          CodeLine(text: '}', indent: 1),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'session.hostCloudAnchorAsync(localAnchor) { anchor, state ->', correctSlotId: 's1'),
          WordChip(id: 'w2', label: 'if (state == Anchor.CloudAnchorState.SUCCESS) {', correctSlotId: 's2'),
          WordChip(id: 'w3', label: 'val cloudAnchorId = anchor.cloudAnchorId', correctSlotId: 's3'),
          WordChip(id: 'w4', label: 'Log.e("ARCore", "Failed to host: \$state")', correctSlotId: 's4'),
          WordChip(id: 'd1', label: 'session.createCloudAnchor(localAnchor)', correctSlotId: 'none'),
          WordChip(id: 'd2', label: 'if (state == true) {', correctSlotId: 'none'),
          WordChip(id: 'd3', label: 'val cloudAnchorId = anchor.getId()', correctSlotId: 'none'),
          WordChip(id: 'd4', label: 'throw Exception("Error hosting")', correctSlotId: 'none'),
        ],
        mascotHint: 'Hosting is an asynchronous call. It returns a callback containing a unique String identifier upon a SUCCESS state.',
        feedbackExplanation: 'Because ARCore must upload visual spatial data to Google servers, the host request is asynchronous. Developers must handle the callback correctly.',
      ),
    ],
  ),

  // ── ZONE 4: META QUEST (OpenXR/C#) ─────────────────────────────────────────
  CodingZone(
    id: 'z4_meta',
    name: 'Meta Quest XR',
    platform: 'OpenXR / C#',
    icon: Icons.headset_rounded,
    accentColor: const Color(0xFFD1C4E9),
    levels: [
      CodingLevel(
        id: 'mq1_passthrough',
        title: 'Passthrough Setup',
        goal: 'Enable mixed reality passthrough on Meta Quest.',
        isFree: true, // First level of zone is free
        lines: [
          CodeLine(text: 'public class PassthroughManager : MonoBehaviour {', indent: 0),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'OVRPassthroughLayer'),
            CodeSlot(id: 's2', label: 'passthrough;'),
          ], indent: 1),
          CodeLine(text: 'void Awake() {', indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's3', label: 'passthrough.textureOpacity = 1f;'),
          ], indent: 2),
          CodeLine(slots: [
            CodeSlot(id: 's4', label: 'passthrough.edgeRenderingEnabled = true;'),
          ], indent: 2),
          CodeLine(text: '}', indent: 1),
          CodeLine(text: '}', indent: 0),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'OVRPassthroughLayer', correctSlotId: 's1'),
          WordChip(id: 'w2', label: 'passthrough;', correctSlotId: 's2'),
          WordChip(id: 'w3', label: 'passthrough.textureOpacity', correctSlotId: 's3'),
          WordChip(id: 'w4', label: 'passthrough.edgeRenderingEnabled', correctSlotId: 's4'),
          WordChip(id: 'd1', label: 'CameraLayer', correctSlotId: 'none'),
          WordChip(id: 'd2', label: 'display.showRealWorld', correctSlotId: 'none'),
        ],
        mascotHint: 'OVR handles all Quest-specific hardware features like Passthrough.',
        feedbackExplanation: 'OVRPassthroughLayer is the primary component for controlling the MR view on Meta hardware.',
      ),
      CodingLevel(
        id: 'mq1_hand',
        title: 'Hand Tracking',
        goal: 'Detect hand gestures.',
        lines: [
          CodeLine(text: 'void Update() {', indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'if (hand.GetFingerIsPinching(HandFinger.Index))'),
          ], indent: 2),
          CodeLine(text: '}', indent: 1),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'GetFingerIsPinching', correctSlotId: 's1'),
          WordChip(id: 'd1', label: 'IsTouching', correctSlotId: 'none'),
          WordChip(id: 'd2', label: 'GetPinchStatus', correctSlotId: 'none'),
          WordChip(id: 'd3', label: 'IsFingerClosed', correctSlotId: 'none'),
          WordChip(id: 'd4', label: 'GetGestureGrab', correctSlotId: 'none'),
        ],
        mascotHint: 'What specific API method checks if a specific finger is performing the standard selection gesture?',
        feedbackExplanation: 'Correct! Hand tracking is essential for modern standalone XR.',
      ),
      CodingLevel(
        id: 'mq1_boss',
        title: 'QUEST BOSS: Hand Grab Mechanic',
        goal: 'Implement a fundamental physical grabbing mechanic using Meta Quest OVRInput.',
        isBoss: true,
        timeLimit: 150,
        lines: [
          CodeLine(text: 'void Update() {', indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'if (OVRInput.GetDown(OVRInput.Button.PrimaryHandTrigger)) {'),
          ], indent: 2),
          CodeLine(slots: [
            CodeSlot(id: 's2', label: 'GrabObject();'),
          ], indent: 3),
          CodeLine(slots: [
            CodeSlot(id: 's3', label: '} else if (OVRInput.GetUp(OVRInput.Button.PrimaryHandTrigger)) {'),
          ], indent: 2),
          CodeLine(slots: [
            CodeSlot(id: 's4', label: 'ReleaseObject();'),
          ], indent: 3),
          CodeLine(text: '}', indent: 2),
          CodeLine(text: '}', indent: 1),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'if (OVRInput.GetDown(OVRInput.Button.PrimaryHandTrigger)) {', correctSlotId: 's1'),
          WordChip(id: 'w2', label: 'GrabObject();', correctSlotId: 's2'),
          WordChip(id: 'w3', label: '} else if (OVRInput.GetUp(OVRInput.Button.PrimaryHandTrigger)) {', correctSlotId: 's3'),
          WordChip(id: 'w4', label: 'ReleaseObject();', correctSlotId: 's4'),
          WordChip(id: 'd1', label: 'if (Input.GetKeyDown(KeyCode.Space)) {', correctSlotId: 'none'),
          WordChip(id: 'd2', label: 'if (OVRInput.Get(OVRInput.Axis1D.PrimaryIndexTrigger)) {', correctSlotId: 'none'),
          WordChip(id: 'd3', label: 'Teleport();', correctSlotId: 'none'),
          WordChip(id: 'd4', label: 'DropItem();', correctSlotId: 'none'),
        ],
        mascotHint: 'Grabbing typically maps to the Hand Trigger (grip button), checking both when it is initially pressed and when it is released.',
        feedbackExplanation: 'OVRInput is the backbone of Meta Quest inputs. GetDown fires once when pressed, and GetUp fires once when released.',
      ),
    ],
  ),

  // ── ZONE 5: WEBXR (JavaScript) ─────────────────────────────────────────────
  CodingZone(
    id: 'z5_webxr',
    name: 'WebXR / A-Frame',
    platform: 'JavaScript / HTML',
    icon: Icons.web_rounded,
    accentColor: const Color(0xFFFF4081),
    levels: [
      CodingLevel(
        id: 'wx1_scene',
        title: 'WebAR Scene',
        goal: 'Define a simple A-Frame scene with AR support.',
        isFree: true, // First level of zone is free
        lines: [
          CodeLine(text: '<a-scene embedded arjs>', indent: 0),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: '<a-marker preset="hiro">'),
          ], indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's2', label: '<a-box position="0 0.5 0" color="red"></a-box>'),
          ], indent: 2),
          CodeLine(slots: [
            CodeSlot(id: 's3', label: '</a-marker>'),
          ], indent: 1),
          CodeLine(text: '<a-entity camera></a-entity>', indent: 1),
          CodeLine(text: '</a-scene>', indent: 0),
        ],
        wordBank: [
          WordChip(id: 'w1', label: '<a-marker preset="hiro">', correctSlotId: 's1'),
          WordChip(id: 'w2', label: '<a-box position="0 0.5 0" color="red"></a-box>', correctSlotId: 's2'),
          WordChip(id: 'w3', label: '</a-marker>', correctSlotId: 's3'),
          WordChip(id: 'd1', label: '<a-anchor>', correctSlotId: 'none'),
          WordChip(id: 'd2', label: '<div class="ar-scene">', correctSlotId: 'none'),
        ],
        mascotHint: 'A-Frame uses the "hiro" preset as the industry standard for marker-based WebAR.',
        feedbackExplanation: 'A-Frame simplifies WebXR by using custom HTML elements to define 3D and AR content.',
      ),
      CodingLevel(
        id: 'wx1_model',
        title: 'GLTF Loading',
        goal: 'Load a 3D model into the scene.',
        lines: [
          CodeLine(text: '<a-entity', indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'gltf-model="#myModel"'),
          ], indent: 2),
          CodeLine(text: '></a-entity>', indent: 1),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'gltf-model', correctSlotId: 's1'),
          WordChip(id: 'd1', label: 'src', correctSlotId: 'none'),
          WordChip(id: 'd2', label: 'model-url', correctSlotId: 'none'),
          WordChip(id: 'd3', label: 'obj-model', correctSlotId: 'none'),
          WordChip(id: 'd4', label: 'mesh-source', correctSlotId: 'none'),
        ],
        mascotHint: 'Which A-Frame component is explicitly designed to attach standard transmission format assets to an entity?',
        feedbackExplanation: 'Correct! GLTF is the JPEG of 3D on the web.',
      ),
      CodingLevel(
        id: 'wx1_boss',
        title: 'WEBXR BOSS: Session Initialization',
        goal: 'Request an immersive-ar WebXR session with hit-testing features.',
        isBoss: true,
        timeLimit: 150,
        lines: [
          CodeLine(text: 'async function startAR() {', indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'const supported = await navigator.xr.isSessionSupported("immersive-ar");'),
          ], indent: 2),
          CodeLine(text: 'if (supported) {', indent: 2),
          CodeLine(slots: [
            CodeSlot(id: 's2', label: 'const session = await navigator.xr.requestSession("immersive-ar", {'),
          ], indent: 3),
          CodeLine(slots: [
            CodeSlot(id: 's3', label: 'requiredFeatures: ["hit-test", "dom-overlay"],'),
          ], indent: 4),
          CodeLine(text: 'domOverlay: { root: document.getElementById("overlay") }', indent: 4),
          CodeLine(text: '});', indent: 3),
          CodeLine(slots: [
            CodeSlot(id: 's4', label: 'session.addEventListener("end", onSessionEnded);'),
          ], indent: 3),
          CodeLine(text: '}', indent: 2),
          CodeLine(text: '}', indent: 1),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'const supported = await navigator.xr.isSessionSupported("immersive-ar");', correctSlotId: 's1'),
          WordChip(id: 'w2', label: 'const session = await navigator.xr.requestSession("immersive-ar", {', correctSlotId: 's2'),
          WordChip(id: 'w3', label: 'requiredFeatures: ["hit-test", "dom-overlay"],', correctSlotId: 's3'),
          WordChip(id: 'w4', label: 'session.addEventListener("end", onSessionEnded);', correctSlotId: 's4'),
          WordChip(id: 'd1', label: 'window.requestARSession()', correctSlotId: 'none'),
          WordChip(id: 'd2', label: 'navigator.xr.startSession("vr")', correctSlotId: 'none'),
          WordChip(id: 'd3', label: 'optionalFeatures: ["camera-access"],', correctSlotId: 'none'),
          WordChip(id: 'd4', label: 'xr.onClose = onSessionEnded;', correctSlotId: 'none'),
        ],
        mascotHint: 'WebXR uses the navigator.xr API exclusively. Always verify hardware support before spawning the session container.',
        feedbackExplanation: 'This is the foundational JavaScript boilerplate needed to launch a modern immersive WebXR experience with UI overlays.',
      ),
    ],
  ),
];
