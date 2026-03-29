import 'package:flutter/material.dart';
import '../models/coding_game_models.dart';

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
        ],
        mascotHint: 'Vuforia uses TargetWidth for physical size.',
        feedbackExplanation: 'Correct! Setting the physical target size is essential for accurate scale tracking.',
      ),
      CodingLevel(
        id: 'v1_boss',
        title: 'VUFORIA BOSS: 3D Tracking',
        goal: 'Scale and track a 3D model on the target.',
        isBoss: true,
        isFree: true, // Zone 1 is free for all users
        timeLimit: 60,
        lines: [
          CodeLine(text: 'public void OnTargetFound() {', indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'virtualObject.SetActive(true);'),
          ], indent: 2),
          CodeLine(text: '}', indent: 1),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'SetActive', correctSlotId: 's1'),
          WordChip(id: 'd1', label: 'Show', correctSlotId: 'none'),
        ],
        mascotHint: 'Unity uses SetActive to show/hide game objects.',
        feedbackExplanation: 'Perfect! You\'ve mastered the Vuforia C# lifecycle.',
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
        ],
        mascotHint: 'In ARKit, anchors are added directly to the session.',
        feedbackExplanation: 'Correct! ARAnchors pin virtual content to physical locations.',
      ),
      CodingLevel(
        id: 'ak1_boss',
        title: 'ARKIT BOSS: Light Estimation',
        goal: 'Enable and apply light estimation.',
        isBoss: true,
        timeLimit: 75,
        lines: [
          CodeLine(text: 'func updateLight() {', indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'let intensity = frame.lightEstimate?.ambientIntensity'),
          ], indent: 2),
          CodeLine(text: '}', indent: 1),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'lightEstimate', correctSlotId: 's1'),
          WordChip(id: 'd1', label: 'getLight', correctSlotId: 'none'),
        ],
        mascotHint: 'The frame object contains the light estimate data.',
        feedbackExplanation: 'Brilliant! You can now match virtual lighting to reality.',
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
        ],
        mascotHint: 'Always close images in Kotlin to prevent memory leaks.',
        feedbackExplanation: 'Correct. Managing depth buffers is crucial for performance.',
      ),
      CodingLevel(
        id: 'ac1_boss',
        title: 'ARCORE BOSS: Cloud Anchors',
        goal: 'Host a cloud anchor.',
        isBoss: true,
        timeLimit: 90,
        lines: [
          CodeLine(text: 'session.hostCloudAnchorAsync(localAnchor) { anchor, status ->', indent: 0),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'if (status == Anchor.CloudAnchorState.SUCCESS)'),
          ], indent: 1),
          CodeLine(text: '}', indent: 0),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'SUCCESS', correctSlotId: 's1'),
          WordChip(id: 'd1', label: 'DONE', correctSlotId: 'none'),
        ],
        mascotHint: 'Check the CloudAnchorState enum.',
        feedbackExplanation: 'Masterful! Cloud Anchors are the key to shared AR.',
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
        ],
        mascotHint: 'Meta uses pinching as the primary interactive gesture.',
        feedbackExplanation: 'Correct! Hand tracking is essential for modern standalone XR.',
      ),
      CodingLevel(
        id: 'mq1_boss',
        title: 'QUEST BOSS: Spatial Mesh',
        goal: 'Access the scene reconstruction mesh.',
        isBoss: true,
        timeLimit: 120,
        lines: [
          CodeLine(text: 'OVRSceneManager sceneManager;', indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'sceneManager.LoadSceneModel();'),
          ], indent: 1),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'LoadSceneModel', correctSlotId: 's1'),
          WordChip(id: 'd1', label: 'StartScan', correctSlotId: 'none'),
        ],
        mascotHint: 'LoadSceneModel pulls the room data into the app.',
        feedbackExplanation: 'Excellent! You now know how to build room-aware XR apps.',
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
        ],
        mascotHint: 'A-Frame uses the gltf-model component for 3D assets.',
        feedbackExplanation: 'Correct! GLTF is the JPEG of 3D on the web.',
      ),
      CodingLevel(
        id: 'wx1_boss',
        title: 'WEBXR BOSS: Hit Testing',
        goal: 'Implement AR hit testing in JS.',
        isBoss: true,
        timeLimit: 100,
        lines: [
          CodeLine(text: 'this.el.addEventListener("ar-hit-test", (e) => {', indent: 1),
          CodeLine(slots: [
            CodeSlot(id: 's1', label: 'const pose = e.detail.pose;'),
          ], indent: 2),
          CodeLine(text: '});', indent: 1),
        ],
        wordBank: [
          WordChip(id: 'w1', label: 'pose', correctSlotId: 's1'),
          WordChip(id: 'd1', label: 'position', correctSlotId: 'none'),
        ],
        mascotHint: 'The event detail contains the XR hit test pose.',
        feedbackExplanation: 'Superior work! You are now a WebXR Engineering Master.',
      ),
    ],
  ),
];
