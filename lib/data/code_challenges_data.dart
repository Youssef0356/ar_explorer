import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/game_models.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  CODE FILL-IN CHALLENGES — organized by AR platform
// ═══════════════════════════════════════════════════════════════════════════════

final List<CodeZone> codeGameZones = [
  // ═══════════════════════════════════════════════════════════════════════════
  // ZONE 1 — Vuforia (C# / Unity)
  // ═══════════════════════════════════════════════════════════════════════════
  CodeZone(
    id: 'code_z1',
    name: 'Vuforia Engine',
    platform: 'Unity / C#',
    icon: Icons.qr_code_scanner_rounded,
    accentColor: AppTheme.accentPurple,
    challenges: [
      // ── Level 1: Image Target Basics ──
      CodeChallenge(
        id: 'cz1_l1',
        zoneId: 'code_z1',
        title: 'Image Target Handler',
        subtitle: 'Enable rendering when a marker is found',
        language: 'csharp',
        isFree: true,
        codeTemplate: '''public class MarkerHandler : ___BLANK1___
{
    protected override void ___BLANK2___()
    {
        GetComponent<Renderer>().enabled = true;
    }
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'DefaultObserverEventHandler',
            hint: 'Vuforia base class for tracking events',
            explanation: 'DefaultObserverEventHandler is the Vuforia base class that provides OnTrackingFound and OnTrackingLost callbacks.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'OnTrackingFound',
            hint: 'Called when Vuforia recognizes the target',
            explanation: 'OnTrackingFound() fires when the camera detects and starts tracking the image target.',
          ),
        ],
        distractors: ['MonoBehaviour', 'OnTrackingLost', 'ARSession'],
      ),
      // ── Level 2: Vuforia Initialization ──
      CodeChallenge(
        id: 'cz1_l2',
        zoneId: 'code_z1',
        title: 'Vuforia Startup',
        subtitle: 'Initialize and start the Vuforia engine',
        language: 'csharp',
        isFree: true,
        codeTemplate: '''void Start()
{
    VuforiaApplication.Instance.___BLANK1___;
}

void OnVuforiaStarted()
{
    ___BLANK2___.SetActive(true);
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'OnVuforiaStarted += OnVuforiaStarted',
            hint: 'Subscribe to the engine start event',
            explanation: 'OnVuforiaStarted is an event that fires when the Vuforia engine is fully initialized and ready.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'arContent',
            hint: 'The AR content container to activate',
            explanation: 'arContent is the parent GameObject containing all AR objects — hidden until Vuforia is ready.',
          ),
        ],
        distractors: ['OnInitialized', 'Destroy(this)', 'VuforiaRuntime'],
      ),
      // ── Level 3: Virtual Button ──
      CodeChallenge(
        id: 'cz1_l3',
        zoneId: 'code_z1',
        title: 'Virtual Buttons',
        subtitle: 'Handle virtual button press on a target',
        language: 'csharp',
        codeTemplate: '''public class VBHandler : MonoBehaviour,
    ___BLANK1___
{
    public void OnButtonPressed(___BLANK2___)
    {
        transform.GetChild(0).gameObject.SetActive(true);
    }

    public void OnButtonReleased(VirtualButtonBehaviour vb)
    {
        transform.GetChild(0).gameObject.SetActive(false);
    }
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'IVirtualButtonEventHandler',
            hint: 'Interface for virtual button callbacks',
            explanation: 'IVirtualButtonEventHandler is the Vuforia interface that defines OnButtonPressed and OnButtonReleased methods.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'VirtualButtonBehaviour vb',
            hint: 'The parameter type for button press',
            explanation: 'VirtualButtonBehaviour contains the pressed button reference so you can identify which virtual button was tapped.',
          ),
        ],
        distractors: ['IObserverEventHandler', 'Button btn', 'TargetBehaviour tb'],
      ),
      // ── Level 4: Multi-Target ──
      CodeChallenge(
        id: 'cz1_l4',
        zoneId: 'code_z1',
        title: 'Multi-Target Setup',
        subtitle: 'Configure a multi-sided target for 3D objects',
        language: 'csharp',
        codeTemplate: '''void ConfigureMultiTarget()
{
    var observer = ___BLANK1___;
    observer.___BLANK2___(gameObject);
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'GetComponent<ObserverBehaviour>()',
            hint: 'Get the Vuforia observer component',
            explanation: 'ObserverBehaviour is the Vuforia 10+ component attached to target GameObjects that replaces the old TrackableBehaviour.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'OnTargetStatusChanged += OnStatusChanged',
            hint: 'Subscribe to status change events',
            explanation: 'OnTargetStatusChanged fires whenever the target tracking status changes (found, lost, extended tracked).',
          ),
        ],
        distractors: ['FindObjectOfType<ARSession>()', 'SetActive', 'OnTrackingFound'],
      ),
      // ── Boss: Full Vuforia Pipeline ──
      CodeChallenge(
        id: 'cz1_boss',
        zoneId: 'code_z1',
        title: 'Boss: Full AR Scene',
        subtitle: 'Wire a complete Vuforia AR scene from scratch',
        language: 'csharp',
        isBoss: true,
        timeLimit: 90,
        codeTemplate: '''public class ARSceneManager : ___BLANK1___
{
    public GameObject model;

    protected override void ___BLANK2___()
    {
        model.___BLANK3___(true);
        GetComponent<Renderer>().enabled = true;
    }

    protected override void OnTrackingLost()
    {
        model.SetActive(false);
    }
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'DefaultObserverEventHandler',
            hint: 'Vuforia base class for events',
            explanation: 'Inheriting from DefaultObserverEventHandler gives you the full tracking lifecycle.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'OnTrackingFound',
            hint: 'Override the method called when target is detected',
            explanation: 'OnTrackingFound activates visual elements when the camera sees the image target.',
          ),
          CodeBlank(
            id: 'BLANK3',
            correctToken: 'SetActive',
            hint: 'Unity method to show/hide GameObjects',
            explanation: 'SetActive(true) makes the 3D model visible in the scene when tracking starts.',
          ),
        ],
        distractors: ['MonoBehaviour', 'Start', 'Destroy', 'OnEnable'],
      ),
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // ZONE 2 — ARKit (Swift)
  // ═══════════════════════════════════════════════════════════════════════════
  CodeZone(
    id: 'code_z2',
    name: 'ARKit',
    platform: 'iOS / Swift',
    icon: Icons.apple_rounded,
    accentColor: AppTheme.accentBlue,
    challenges: [
      // ── Level 1: AR Session Setup ──
      CodeChallenge(
        id: 'cz2_l1',
        zoneId: 'code_z2',
        title: 'AR Session Config',
        subtitle: 'Configure world tracking with plane detection',
        language: 'swift',
        codeTemplate: '''let config = ___BLANK1___()
config.planeDetection = ___BLANK2___
sceneView.session.run(config)''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'ARWorldTrackingConfiguration',
            hint: 'The configuration class for 6DOF tracking',
            explanation: 'ARWorldTrackingConfiguration enables full 6 degrees of freedom tracking using the rear camera.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: '.horizontal',
            hint: 'Detect flat surfaces like floors and tables',
            explanation: '.horizontal tells ARKit to look for horizontal flat surfaces in the environment.',
          ),
        ],
        distractors: ['ARFaceTrackingConfiguration', '.vertical', 'ARSession'],
      ),
      // ── Level 2: Adding 3D Content ──
      CodeChallenge(
        id: 'cz2_l2',
        zoneId: 'code_z2',
        title: 'Place a 3D Object',
        subtitle: 'Add a virtual cube at a detected anchor',
        language: 'swift',
        codeTemplate: '''func renderer(_ renderer: SCNSceneRenderer,
    didAdd node: ___BLANK1___, for anchor: ARAnchor)
{
    let box = ___BLANK2___(width: 0.1, height: 0.1,
                          length: 0.1, chamferRadius: 0)
    node.addChildNode(SCNNode(geometry: box))
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'SCNNode',
            hint: 'SceneKit node added for each new anchor',
            explanation: 'SCNNode is the SceneKit object that ARKit automatically creates and positions at the anchor location.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'SCNBox',
            hint: 'SceneKit geometry for a box shape',
            explanation: 'SCNBox creates a 3D box geometry with configurable width, height, length, and corner radius.',
          ),
        ],
        distractors: ['ARNode', 'SCNSphere', 'UIView'],
      ),
      // ── Level 3: Hit Test ──
      CodeChallenge(
        id: 'cz2_l3',
        zoneId: 'code_z2',
        title: 'Tap to Place',
        subtitle: 'Use ray casting to place objects on surfaces',
        language: 'swift',
        codeTemplate: '''@objc func handleTap(_ gesture: UITapGestureRecognizer)
{
    let location = gesture.location(in: sceneView)
    let results = sceneView.___BLANK1___(
        from: location,
        allowing: .___BLANK2___,
        alignment: .horizontal
    )
    guard let result = results.first else { return }
    placeObject(at: result)
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'raycastQuery',
            hint: 'Cast a ray from screen point into the 3D world',
            explanation: 'raycastQuery creates a ray from the 2D screen tap point and finds intersections with real-world surfaces.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'estimatedPlane',
            hint: 'Target type for the raycast',
            explanation: '.estimatedPlane tells the raycast to find both detected and estimated flat surfaces.',
          ),
        ],
        distractors: ['hitTest', 'existingPlaneGeometry', 'touchesBegan'],
      ),
      // ── Level 4: Light Estimation ──
      CodeChallenge(
        id: 'cz2_l4',
        zoneId: 'code_z2',
        title: 'Light Estimation',
        subtitle: 'Match virtual lighting to the real world',
        language: 'swift',
        codeTemplate: '''func renderer(_ renderer: SCNSceneRenderer,
    updateAtTime time: TimeInterval)
{
    guard let estimate = sceneView.session
        .currentFrame?.___BLANK1___ else { return }
    let intensity = estimate.___BLANK2___
    lightNode.light?.intensity = intensity
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'lightEstimate',
            hint: 'Property containing lighting data from ARKit',
            explanation: 'lightEstimate provides real-world lighting info measured from the camera image each frame.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'ambientIntensity',
            hint: 'The brightness level in lumens',
            explanation: 'ambientIntensity is measured in lumens (0–2000) and represents the overall brightness of the scene.',
          ),
        ],
        distractors: ['colorTemperature', 'lightProbe', 'environmentTexture'],
      ),
      // ── Boss: Full ARKit App ──
      CodeChallenge(
        id: 'cz2_boss',
        zoneId: 'code_z2',
        title: 'Boss: Build an ARKit App',
        subtitle: 'Complete session, detection, and placement in 90s',
        language: 'swift',
        isBoss: true,
        timeLimit: 90,
        codeTemplate: '''override func viewDidLoad() {
    super.viewDidLoad()
    let config = ___BLANK1___()
    config.planeDetection = [___BLANK2___]
    config.___BLANK3___ = true
    sceneView.session.run(config)
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'ARWorldTrackingConfiguration',
            hint: 'Main configuration for world tracking',
            explanation: 'ARWorldTrackingConfiguration enables full 6DOF tracking with the rear camera.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: '.horizontal, .vertical',
            hint: 'Detect both floor and wall surfaces',
            explanation: 'Combining .horizontal and .vertical detects both floors/tables and walls.',
          ),
          CodeBlank(
            id: 'BLANK3',
            correctToken: 'isLightEstimationEnabled',
            hint: 'Enable lighting analysis',
            explanation: 'isLightEstimationEnabled = true tells ARKit to analyze ambient light for realistic rendering.',
          ),
        ],
        distractors: ['ARFaceTrackingConfiguration', '.all', 'isAutoFocusEnabled', 'environmentTexturing'],
      ),
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // ZONE 3 — ARCore (Kotlin)
  // ═══════════════════════════════════════════════════════════════════════════
  CodeZone(
    id: 'code_z3',
    name: 'ARCore',
    platform: 'Android / Kotlin',
    icon: Icons.android_rounded,
    accentColor: const Color(0xFFD1C4E9),
    challenges: [
      // ── Level 1: Session Setup ──
      CodeChallenge(
        id: 'cz3_l1',
        zoneId: 'code_z3',
        title: 'ARCore Session',
        subtitle: 'Create and configure an AR session',
        language: 'kotlin',
        codeTemplate: '''val session = ___BLANK1___(this)
val config = Config(session)
config.___BLANK2___ = Config.PlaneFindingMode.HORIZONTAL
session.configure(config)''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'Session',
            hint: 'The main ARCore entry point',
            explanation: 'Session is the core ARCore class that manages the AR state including tracking and environmental understanding.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'planeFindingMode',
            hint: 'Config property for surface detection',
            explanation: 'planeFindingMode tells ARCore what types of surfaces to look for — HORIZONTAL, VERTICAL, or HORIZONTAL_AND_VERTICAL.',
          ),
        ],
        distractors: ['ArSession', 'planeDetection', 'trackingMode'],
      ),
      // ── Level 2: Hit Test & Anchor ──
      CodeChallenge(
        id: 'cz3_l2',
        zoneId: 'code_z3',
        title: 'Tap to Place',
        subtitle: 'Perform a hit test and create an anchor',
        language: 'kotlin',
        codeTemplate: '''fun onTap(frame: Frame, motionEvent: MotionEvent)
{
    val hitResults = frame.___BLANK1___(motionEvent)
    val hit = hitResults.firstOrNull() ?: return
    val anchor = hit.___BLANK2___()
    placeModel(anchor)
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'hitTest',
            hint: 'Cast a ray from the tap into the scene',
            explanation: 'hitTest takes a MotionEvent and returns a list of HitResult objects where the ray intersects tracked planes.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'createAnchor',
            hint: 'Lock a position in world space',
            explanation: 'createAnchor() creates a persistent anchor at the hit point so the placed object stays fixed as you move.',
          ),
        ],
        distractors: ['raycast', 'getTrackable', 'createNode'],
      ),
      // ── Level 3: Plane Rendering ──
      CodeChallenge(
        id: 'cz3_l3',
        zoneId: 'code_z3',
        title: 'Visualize Planes',
        subtitle: 'Render detected planes as overlays',
        language: 'kotlin',
        codeTemplate: '''fun onDrawFrame() {
    val frame = session.___BLANK1___()
    for (plane in session.___BLANK2___<Plane>(Plane::class.java)) {
        if (plane.trackingState == TrackingState.TRACKING) {
            drawPlane(plane)
        }
    }
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'update',
            hint: 'Get the latest AR frame',
            explanation: 'session.update() gets the latest Frame object containing the camera image, tracking state, and all detected planes.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'getAllTrackables',
            hint: 'Query all detected objects of a type',
            explanation: 'getAllTrackables<Plane>() returns every plane ARCore has detected in the current environment.',
          ),
        ],
        distractors: ['getFrame', 'getTrackables', 'getPlanes'],
      ),
      // ── Level 4: Augmented Image ──
      CodeChallenge(
        id: 'cz3_l4',
        zoneId: 'code_z3',
        title: 'Augmented Images',
        subtitle: 'Detect and track reference images',
        language: 'kotlin',
        codeTemplate: '''val imageDb = ___BLANK1___(session)
val bitmap = BitmapFactory.decodeResource(resources, R.drawable.target)
imageDb.___BLANK2___("marker1", bitmap, 0.15f)
config.augmentedImageDatabase = imageDb''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'AugmentedImageDatabase',
            hint: 'Database of reference images to detect',
            explanation: 'AugmentedImageDatabase stores the reference images that ARCore will try to detect in the camera feed.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'addImage',
            hint: 'Register a new image to the database',
            explanation: 'addImage takes a name, bitmap, and physical width in meters so ARCore knows the real size of the target.',
          ),
        ],
        distractors: ['ImageDatabase', 'registerTarget', 'loadImage'],
      ),
      // ── Boss: Full ARCore Flow ──
      CodeChallenge(
        id: 'cz3_boss',
        zoneId: 'code_z3',
        title: 'Boss: ARCore App Pipeline',
        subtitle: 'Build a full AR placement flow in 90s',
        language: 'kotlin',
        isBoss: true,
        timeLimit: 90,
        codeTemplate: '''val session = ___BLANK1___(this)
val config = Config(session)
config.planeFindingMode = Config.PlaneFindingMode.___BLANK2___
config.lightEstimationMode =
    Config.LightEstimationMode.___BLANK3___
session.configure(config)''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'Session',
            hint: 'Core ARCore class',
            explanation: 'Session manages the AR runtime and is the first thing you create.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'HORIZONTAL_AND_VERTICAL',
            hint: 'Detect both floors and walls',
            explanation: 'HORIZONTAL_AND_VERTICAL detects both floor/table surfaces and vertical walls.',
          ),
          CodeBlank(
            id: 'BLANK3',
            correctToken: 'ENVIRONMENTAL_HDR',
            hint: 'High quality light estimation mode',
            explanation: 'ENVIRONMENTAL_HDR provides realistic lighting including main directional light, ambient spherical harmonics, and specular highlights.',
          ),
        ],
        distractors: ['ArSession', 'HORIZONTAL', 'DISABLED', 'AMBIENT_INTENSITY'],
      ),
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // ZONE 4 — Meta Quest XR (C++ / Unity)
  // ═══════════════════════════════════════════════════════════════════════════
  CodeZone(
    id: 'code_z4',
    name: 'Meta Quest XR',
    platform: 'Quest / C#',
    icon: Icons.vrpano_rounded,
    accentColor: const Color(0xFFFFC107),
    challenges: [
      // ── Level 1: OVR Camera Rig ──
      CodeChallenge(
        id: 'cz4_l1',
        zoneId: 'code_z4',
        title: 'Camera Rig Setup',
        subtitle: 'Configure the OVR Camera Rig for Quest',
        language: 'csharp',
        codeTemplate: '''void Start()
{
    ___BLANK1___ cameraRig =
        FindObjectOfType<___BLANK1___>();
    cameraRig.___BLANK2___ =
        OVRManager.TrackingOrigin.FloorLevel;
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'OVRCameraRig',
            hint: 'Meta\'s camera rig component for Quest',
            explanation: 'OVRCameraRig is Meta\'s main camera component that manages head tracking, eye cameras, and tracking origin.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'trackingOriginType',
            hint: 'Where the floor is relative to the headset',
            explanation: 'trackingOriginType sets whether the origin is at eye level or floor level — FloorLevel is standard for room-scale.',
          ),
        ],
        distractors: ['Camera', 'XRRig', 'originType'],
      ),
      // ── Level 2: Controller Input ──
      CodeChallenge(
        id: 'cz4_l2',
        zoneId: 'code_z4',
        title: 'Controller Input',
        subtitle: 'Read trigger press from Quest controllers',
        language: 'csharp',
        codeTemplate: '''void Update()
{
    if (___BLANK1___.Get(___BLANK2___))
    {
        SpawnObject();
    }
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'OVRInput',
            hint: 'Meta\'s input API class',
            explanation: 'OVRInput is the unified input system for Meta Quest controllers, hand tracking, and headset buttons.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'OVRInput.Button.PrimaryIndexTrigger',
            hint: 'The main trigger button',
            explanation: 'PrimaryIndexTrigger maps to the index finger trigger on the dominant hand controller.',
          ),
        ],
        distractors: ['Input', 'OVRInput.Button.Start', 'KeyCode.Space'],
      ),
      // ── Level 3: Passthrough ──
      CodeChallenge(
        id: 'cz4_l3',
        zoneId: 'code_z4',
        title: 'Passthrough Mode',
        subtitle: 'Enable camera passthrough for mixed reality',
        language: 'csharp',
        codeTemplate: '''void EnablePassthrough()
{
    OVRManager.instance.___BLANK1___ = true;
    var layer = gameObject
        .AddComponent<___BLANK2___>();
    layer.overlayType = OVROverlay.OverlayType.Underlay;
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'isInsightPassthroughEnabled',
            hint: 'Property to enable camera passthrough',
            explanation: 'isInsightPassthroughEnabled activates the Quest cameras for mixed reality passthrough.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'OVRPassthroughLayer',
            hint: 'Component that renders the passthrough feed',
            explanation: 'OVRPassthroughLayer renders the camera feed as a background layer so virtual objects appear mixed with reality.',
          ),
        ],
        distractors: ['passthroughEnabled', 'OVROverlay', 'OVRComposition'],
      ),
      // ── Level 4: Spatial Anchors ──
      CodeChallenge(
        id: 'cz4_l4',
        zoneId: 'code_z4',
        title: 'Spatial Anchors',
        subtitle: 'Save a persistent anchor in the real world',
        language: 'csharp',
        codeTemplate: '''async void CreateAnchor(Vector3 position)
{
    var anchor = new GameObject("Anchor")
        .AddComponent<___BLANK1___>();
    anchor.transform.position = position;
    bool saved = await anchor.___BLANK2___();
    Debug.Log(saved ? "Anchor saved!" : "Failed");
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'OVRSpatialAnchor',
            hint: 'Meta\'s persistent anchor component',
            explanation: 'OVRSpatialAnchor represents a world-locked anchor that can persist across sessions on Quest.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'SaveAnchorAsync',
            hint: 'Persist the anchor to local storage',
            explanation: 'SaveAnchorAsync persists the anchor to the Quest headset storage so it can be loaded again in future sessions.',
          ),
        ],
        distractors: ['OVRAnchor', 'SaveAsync', 'PersistAnchor'],
      ),
      // ── Boss: Full Quest MR App ──
      CodeChallenge(
        id: 'cz4_boss',
        zoneId: 'code_z4',
        title: 'Boss: Quest MR Scene',
        subtitle: 'Build a mixed reality experience in 90s',
        language: 'csharp',
        isBoss: true,
        timeLimit: 90,
        codeTemplate: '''void Start()
{
    OVRManager.instance.___BLANK1___ = true;

    if (___BLANK2___.Get(
        OVRInput.Button.PrimaryIndexTrigger))
    {
        var anchor = new GameObject("Anchor")
            .AddComponent<___BLANK3___>();
        anchor.transform.position = hitPosition;
    }
}''',
        blanks: [
          CodeBlank(
            id: 'BLANK1',
            correctToken: 'isInsightPassthroughEnabled',
            hint: 'Enable the camera passthrough',
            explanation: 'Passthrough must be enabled before any MR content can be displayed.',
          ),
          CodeBlank(
            id: 'BLANK2',
            correctToken: 'OVRInput',
            hint: 'Meta\'s input system class',
            explanation: 'OVRInput handles all controller and hand input on Quest devices.',
          ),
          CodeBlank(
            id: 'BLANK3',
            correctToken: 'OVRSpatialAnchor',
            hint: 'Persistent world-locked anchor',
            explanation: 'OVRSpatialAnchor creates a persistent anchor that survives app restarts.',
          ),
        ],
        distractors: ['passthroughEnabled', 'Input', 'OVRAnchor', 'ARAnchor'],
      ),
    ],
  ),
];
