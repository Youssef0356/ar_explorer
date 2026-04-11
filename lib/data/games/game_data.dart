import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/game_models.dart';

// --- Shared Nodes Pool ---
const nodeCamera = ARNode(
  id: 'camera',
  name: 'Camera Stream',
  description: 'RGB video feed from device camera — the foundation of all AR',
  hint: 'Needs access to the device camera to see the real world',
  icon: Icons.camera_alt_rounded,
  type: ARNodeType.input,
  errorMessage: 'Camera feed unavailable — check permissions and try again',
);

const nodeIMU = ARNode(
  id: 'imu',
  name: 'IMU Sensors',
  description: 'Accelerometer & Gyroscope — tracks device movement and orientation',
  hint: 'Detects when you tilt, rotate, or move your phone',
  icon: Icons.vibration_rounded,
  type: ARNodeType.input,
  errorMessage: 'Motion sensors unavailable — check device hardware',
);

const nodePlaneDetection = ARNode(
  id: 'plane_detection',
  name: 'Plane Detection',
  description: 'Finds flat horizontal and vertical surfaces like tables, floors, and walls',
  hint: 'Scans for flat surfaces where virtual objects can be placed',
  icon: Icons.grid_4x4_rounded,
  type: ARNodeType.process,
  errorMessage: 'No surfaces detected — move your camera slowly across a flat area',
);

const nodeSLAM = ARNode(
  id: 'slam',
  name: 'SLAM Tracking',
  description: 'Builds a 3D map of the environment while tracking the device position',
  hint: 'Creates a mental map of your room so AR stays in place',
  icon: Icons.track_changes_rounded,
  type: ARNodeType.process,
  errorMessage: 'Tracking lost — move slowly and point at recognizable features',
);

const nodeHitTest = ARNode(
  id: 'hit_test',
  name: 'Hit Test',
  description: 'Shoots a ray from the screen into the real world to find where to place objects',
  hint: 'Converts your finger tap on screen into a real-world 3D position',
  icon: Icons.ads_click_rounded,
  type: ARNodeType.process,
  errorMessage: 'Hit test failed — tap on a detected flat surface, not empty space',
);

const nodeAnchor = ARNode(
  id: 'anchor',
  name: 'Anchor Node',
  description: 'Locks virtual content to a specific real-world point so it stays put',
  hint: 'Makes virtual objects "stick" to real surfaces and remember their location',
  icon: Icons.push_pin_rounded,
  type: ARNodeType.output,
  errorMessage: 'Cannot anchor — perform a hit test first to find where to attach',
);

const nodeRenderer = ARNode(
  id: 'renderer',
  name: '3D Renderer',
  description: 'Draws virtual 3D models, shadows, and effects on top of the camera feed',
  hint: 'The final step that makes virtual objects visible on your screen',
  icon: Icons.view_in_ar_rounded,
  type: ARNodeType.output,
  errorMessage: 'Rendering failed — check that camera and tracking are active first',
);

const nodeLightEstimation = ARNode(
  id: 'light_estimation',
  name: 'Light Estimation',
  description: 'Analyzes real-world lighting to make virtual objects match their environment',
  hint: 'Makes virtual objects look natural by copying the real room lighting',
  icon: Icons.light_mode_rounded,
  type: ARNodeType.process,
  errorMessage: 'Light estimation failed — ensure camera feed is active and bright enough',
);

const nodeOcclusion = ARNode(
  id: 'occlusion',
  name: 'Occlusion',
  description: 'Hides parts of virtual objects when real-world objects block them',
  hint: 'Makes virtual objects disappear behind real furniture and walls',
  icon: Icons.layers_rounded,
  type: ARNodeType.output,
  errorMessage: 'Occlusion unavailable — depth data requires SLAM and camera',
);

const nodeSpatialAnchor = ARNode(
  id: 'spatial_anchor',
  name: 'Spatial Anchor',
  description: 'Cloud-stored anchor that remembers its location across sessions and devices',
  hint: 'Saves object locations to the cloud so they persist for everyone',
  icon: Icons.cloud_done_rounded,
  type: ARNodeType.output,
  errorMessage: 'Spatial anchor failed — requires local anchor and internet connection',
);

const nodeOpenXR = ARNode(
  id: 'openxr',
  name: 'OpenXR Runtime',
  description: 'Cross-platform standard that abstracts AR/VR hardware differences',
  hint: 'A translator that makes AR apps work on any headset or phone',
  icon: Icons.settings_input_component_rounded,
  type: ARNodeType.utility,
  errorMessage: 'OpenXR initialization failed — platform may not be supported',
);

const nodeRelocalization = ARNode(
  id: 'relocalization',
  name: 'Relocalization',
  description: 'Recovers tracking position by matching current view to saved map features',
  hint: 'Finds your place again when tracking is lost by recognizing the room',
  icon: Icons.sync_rounded,
  type: ARNodeType.process,
  errorMessage: 'Cannot relocalize — move back to a previously seen area slowly',
);

// --- Zones and Levels: ARena Multiplayer AR Strategy Game ---
final List<ARZone> arGameZones = [
  // ═══════════════════════════════════════════════════════════
  // ZONE 1 — See the World (like HTML)
  // ═══════════════════════════════════════════════════════════
  ARZone(
    id: 'zone_1',
    name: 'Zone 1 — The Foundations',
    accentColor: AppTheme.accentPurple,
    levels: [
      // Level 1: Open the camera
      ARLevel(
        id: 'z1_l1',
        title: 'The Magic Window',
        projectTask: 'Our client wants a phone that acts like a piece of glass! Build a "Magic Window" that shows the real world on the screen.',
        goal: 'Connect the camera (Eyes) to the renderer (Brain) so the app can see what\'s happening.',
        buildContext: 'This is the most basic AR setup. You need to turn on the camera sensors and pipe that video feed directly to your display renderer. Without this, the world is just a black void!',
        correctSequence: ['camera', 'imu', 'renderer'],
        availableNodes: [nodeCamera, nodeIMU, nodeRenderer, nodeSLAM],
        zoneId: 'zone_1',
        isFree: true,
        variations: [
          ARLevelVariation(
            projectTask: 'A drone company needs a live camera feed on the pilot\'s tablet! Build the "Drone Eye" system so the pilot can see everything the drone sees.',
            goal: 'Stream the drone\'s camera and motion data to a live display renderer.',
            buildContext: 'Just like a phone AR app, a drone needs its camera feed piped to a screen. The IMU tells the pilot which way the drone is tilting.',
            correctSequence: ['camera', 'imu', 'renderer'],
            availableNodes: [nodeCamera, nodeIMU, nodeRenderer, nodeSLAM],
          ),
          ARLevelVariation(
            projectTask: 'A delivery robot needs eyes! Build the "Robot Vision" pipeline so it can see the sidewalk ahead and react to obstacles.',
            goal: 'Give the robot a live visual feed with motion awareness for navigation.',
            buildContext: 'Robots use the same camera + IMU combo as AR phones. The camera sees the world, the IMU tracks tilt and acceleration, and the renderer displays it all.',
            correctSequence: ['camera', 'imu', 'renderer'],
            availableNodes: [nodeCamera, nodeIMU, nodeRenderer, nodePlaneDetection],
          ),
        ],
      ),
      // Level 2: Find the floor
      ARLevel(
        id: 'z1_l2',
        title: 'The Invisible Floor',
        projectTask: 'The client is complaining that their virtual pet keeps falling through the ground! We need to help the phone find the floor.',
        goal: 'Teach the app to recognize flat surfaces (planes) so we have somewhere to stand.',
        buildContext: 'To put objects on a table or floor, the app must "detect" those planes first. This requires analyzing the camera feed for flat horizontal surfaces.',
        correctSequence: ['camera', 'plane_detection', 'renderer'],
        availableNodes: [nodeCamera, nodePlaneDetection, nodeRenderer, nodeHitTest],
        zoneId: 'zone_1',
        isFree: true,
        variations: [
          ARLevelVariation(
            projectTask: 'An interior design app needs to measure rooms! Build the "AR Tape Measure" that detects the floor and walls to calculate distances.',
            goal: 'Detect flat surfaces so the app can measure real-world dimensions.',
            buildContext: 'Room measurement apps work by detecting planes (floor, walls) with the camera. Once surfaces are found, the app can calculate distances between points.',
            correctSequence: ['camera', 'plane_detection', 'renderer'],
            availableNodes: [nodeCamera, nodePlaneDetection, nodeRenderer, nodeSLAM],
          ),
          ARLevelVariation(
            projectTask: 'A gardening app wants users to place virtual flowers on their real lawn! First, the app needs to find the grass surface.',
            goal: 'Detect the ground plane so virtual plants can be placed on real grass.',
            buildContext: 'Before placing any virtual object outdoors, the app must detect the ground plane. The camera feed is analyzed to find flat horizontal surfaces like lawns and patios.',
            correctSequence: ['camera', 'plane_detection', 'renderer'],
            availableNodes: [nodeCamera, nodePlaneDetection, nodeRenderer, nodeAnchor],
          ),
        ],
      ),
      // Boss 1: First prototype — tap to place your HQ
      ARLevel(
        id: 'z1_boss',
        title: 'Boss: Plant the Flag',
        projectTask: 'It\'s time for our first real demo. The client wants to tap on the floor and "plant a flag" that stays exactly where they put it.',
        goal: 'Build a full pipeline that detects a floor and anchors an object to it.',
        buildContext: 'This is a complete engineering cycle: See the world, track your position (SLAM), find a surface, and use a "Hit Test" to turn a screen tap into a physical location.',
        isBoss: true,
        mode: GameMode.boss,
        timeLimit: 60,
        correctSequence: ['camera', 'imu', 'slam', 'plane_detection', 'hit_test', 'anchor', 'renderer'],
        availableNodes: [nodeCamera, nodeIMU, nodeSLAM, nodePlaneDetection, nodeHitTest, nodeAnchor, nodeRenderer, nodeLightEstimation],
        zoneId: 'zone_1',
      ),
    ],
  ),

  // ═══════════════════════════════════════════════════════════
  // ZONE 2 — Spatial Awareness
  // ═══════════════════════════════════════════════════════════
  ARZone(
    id: 'zone_2',
    name: 'Zone 2 — Spatial Awareness',
    accentColor: AppTheme.accentBlue,
    levels: [
      // Level 3: Give ARena a 6DOF compass
      ARLevel(
        id: 'z2_l1',
        title: 'The Spatial Compass',
        projectTask: 'The client noticed their virtual statues spin around when they walk. We need a "Spatial Compass" to lock them in place.',
        goal: 'Establish true 6-Degrees-of-Freedom (6DoF) so objects know which way is North.',
        buildContext: 'SLAM (Simultaneous Localization and Mapping) is the secret sauce. It uses the camera and IMU to build a map. Without it, the app has no memory of where it is.',
        correctSequence: ['camera', 'imu', 'slam'],
        availableNodes: [nodeCamera, nodeIMU, nodeSLAM, nodeRelocalization],
        zoneId: 'zone_2',
        isFree: true, // First level of zone is free
        variations: [
          ARLevelVariation(
            projectTask: 'A hospital needs indoor navigation! Patients get lost in long corridors. Build an "AR Wayfinder" that always knows where you are inside the building.',
            goal: 'Use SLAM to create a live indoor position tracker — like GPS but indoors.',
            buildContext: 'Indoors, GPS doesn\'t work. SLAM replaces it by using the camera and IMU to build a local map and track your position within it in real time.',
            correctSequence: ['camera', 'imu', 'slam'],
            availableNodes: [nodeCamera, nodeIMU, nodeSLAM, nodePlaneDetection],
          ),
          ARLevelVariation(
            projectTask: 'A museum wants AR audio guides that trigger automatically when you stand in front of an exhibit. Build the "Exhibit Tracker" positioning system.',
            goal: 'Track the visitor\'s exact position in the museum so content triggers at the right spot.',
            buildContext: 'The museum app needs to know exactly where the visitor is standing. SLAM builds a 3D map of the gallery and tracks the phone\'s position within it.',
            correctSequence: ['camera', 'imu', 'slam'],
            availableNodes: [nodeCamera, nodeIMU, nodeSLAM, nodeRenderer],
          ),
        ],
      ),
      // Level 4: Universal Translator
      ARLevel(
        id: 'z2_l2',
        title: 'The Universal Translator',
        projectTask: 'We need this app to work on both Android and iPhone without rewriting the whole engine! Build a bridge between them.',
        goal: 'Use a cross-platform pipeline that works across different AR hardware.',
        buildContext: 'By focusing on core tracking (SLAM) and standard rendering, we can build a "platform-agnostic" engine that doesn\'t care what phone the user is holding.',
        correctSequence: ['camera', 'slam', 'renderer'],
        availableNodes: [nodeCamera, nodeSLAM, nodeRenderer, nodeLightEstimation],
        zoneId: 'zone_2',
        variations: [
          ARLevelVariation(
            projectTask: 'A remote support company wants technicians to guide repairs through AR — drawing arrows on the real machine. It must work on any phone the field worker has!',
            goal: 'Build a minimal, cross-device AR pipeline that tracks space and renders overlays.',
            buildContext: 'Remote assistance AR must run everywhere. By sticking to camera → SLAM → renderer, the pipeline stays lean and compatible across Android and iOS.',
            correctSequence: ['camera', 'slam', 'renderer'],
            availableNodes: [nodeCamera, nodeSLAM, nodeRenderer, nodeHitTest],
          ),
          ARLevelVariation(
            projectTask: 'A car dealership wants customers to preview vehicles in AR — in the showroom, at home, anywhere! Build a "Virtual Showroom" that runs on every smartphone.',
            goal: 'Create a universal AR viewer that renders 3D cars with spatial tracking on all devices.',
            buildContext: 'Customers use all kinds of phones. A cross-platform pipeline using camera, SLAM, and renderer ensures every customer gets the same premium AR experience.',
            correctSequence: ['camera', 'slam', 'renderer'],
            availableNodes: [nodeCamera, nodeSLAM, nodeRenderer, nodeOpenXR],
          ),
        ],
      ),
      // Boss 2: Survive a mid-game phone drop
      ARLevel(
        id: 'z2_boss',
        title: 'Boss: The Memory Reset',
        projectTask: 'Oh no! The user dropped their phone and the AR "broke". We need a way to remember the room and recover the position.',
        goal: 'Build a robust pipeline that can "Relocalize" (recognize the room) after a crash.',
        buildContext: 'When tracking is lost, "Relocalization" compares the current camera view with the map it built earlier to find its place again. It\'s like waking up in a room and recognizing the furniture.',
        isBoss: true,
        mode: GameMode.boss,
        timeLimit: 60,
        correctSequence: ['camera', 'imu', 'slam', 'relocalization', 'renderer'],
        availableNodes: [nodeCamera, nodeIMU, nodeSLAM, nodeRelocalization, nodeRenderer, nodePlaneDetection],
        zoneId: 'zone_2',
      ),
    ],
  ),

  // ═══════════════════════════════════════════════════════════
  // ZONE 3 — Build on Surfaces (like JavaScript)
  // ═══════════════════════════════════════════════════════════
  ARZone(
    id: 'zone_3',
    name: 'Zone 3 — Interactive Logic',
    accentColor: const Color(0xFFD1C4E9),
    levels: [
      // Level 5: Open Bridge
      ARLevel(
        id: 'z3_l1',
        title: 'The Open Bridge',
        projectTask: 'A new headset just hit the market! We need to make sure our code works there too, without changing a single line of our sensor logic.',
        goal: 'Use the OpenXR "Bridge" to translate our custom sensors into a universal language.',
        buildContext: 'OpenXR is a universal adapter. It sits between the hardware and your code, so you don\'t have to worry about whether the user has an Android, iPhone, or AR Headset.',
        correctSequence: ['camera', 'slam', 'plane_detection', 'renderer'],
        availableNodes: [nodeCamera, nodeSLAM, nodePlaneDetection, nodeRenderer, nodeOpenXR],
        zoneId: 'zone_3',
        isFree: true, // First level of zone is free
        variations: [
          ARLevelVariation(
            projectTask: 'A school wants their AR science app to work on classroom tablets AND the new VR headsets in the lab. Build a pipeline that runs on both!',
            goal: 'Create a multi-device AR pipeline with surface detection for placing 3D models.',
            buildContext: 'Educational AR must support cheap tablets and expensive headsets. Using camera, SLAM, and plane detection in a standard pipeline makes the app hardware-agnostic.',
            correctSequence: ['camera', 'slam', 'plane_detection', 'renderer'],
            availableNodes: [nodeCamera, nodeSLAM, nodePlaneDetection, nodeRenderer, nodeIMU],
          ),
          ARLevelVariation(
            projectTask: 'A factory needs an AR repair manual that works with safety glasses, tablets, and phones. Build a "Universal AR Manual" that adapts to any device!',
            goal: 'Build a device-agnostic pipeline that detects work surfaces and overlays repair instructions.',
            buildContext: 'Industrial AR must be flexible. The same pipeline (camera → SLAM → plane detection → renderer) works whether the technician wears AR glasses or holds a tablet.',
            correctSequence: ['camera', 'slam', 'plane_detection', 'renderer'],
            availableNodes: [nodeCamera, nodeSLAM, nodePlaneDetection, nodeRenderer, nodeLightEstimation],
          ),
        ],
      ),
      // Level 6: Secret Portal
      ARLevel(
        id: 'z3_l2',
        title: 'The Secret Portal',
        projectTask: 'The client wants a "Magic Card" that opens a portal when you point your phone at it. No scanning needed—just tracking the image!',
        goal: 'Bypass environmental scanning and use image tracking to establish a world origin.',
        buildContext: 'Sometimes we don\'t need to scan the whole room. Pointing at a specific "Tracker" or "Image" lets the app know exactly where (0,0,0) is instantly.',
        correctSequence: ['camera', 'renderer'],
        availableNodes: [nodeCamera, nodeRenderer, nodeSLAM],
        zoneId: 'zone_3',
        variations: [
          ARLevelVariation(
            projectTask: 'A restaurant wants their paper menu to come alive! Point your phone at a dish photo and a 3D version of the food appears. Build the "AR Menu" pipeline.',
            goal: 'Use image-based tracking to overlay 3D content directly — no room scanning needed.',
            buildContext: 'The menu itself acts as the tracking target. The camera recognizes the printed image and immediately knows where to place the 3D food model — no SLAM required.',
            correctSequence: ['camera', 'renderer'],
            availableNodes: [nodeCamera, nodeRenderer, nodePlaneDetection],
          ),
          ARLevelVariation(
            projectTask: 'A movie studio wants their posters to play the film trailer when you point your phone at them. Build the "Living Poster" image tracker!',
            goal: 'Trigger AR content from a flat printed image without environmental scanning.',
            buildContext: 'The poster is the marker. Camera recognizes the unique image pattern, locks onto it, and the renderer overlays a video or 3D animation right on top. Simple and magical.',
            correctSequence: ['camera', 'renderer'],
            availableNodes: [nodeCamera, nodeRenderer, nodeIMU],
          ),
        ],
      ),
      // Boss 3: Holographic Table
      ARLevel(
        id: 'z3_boss',
        title: 'Boss: The Holographic Table',
        projectTask: 'Two players want to see the same virtual game board on the same table at the same time. We need a perfectly synced coordinate space.',
        goal: 'Establish a shared, rock-solid coordinate system that stays synced for everyone.',
        buildContext: 'For multiplayer AR, sync is everything. You need to strip away any device-specific lighting or hardware overrides and focus on the raw sensory data (SLAM + Planes) that everyone shares.',
        isBoss: true,
        mode: GameMode.boss,
        timeLimit: 60,
        correctSequence: ['camera', 'imu', 'slam', 'plane_detection', 'renderer'],
        availableNodes: [nodeCamera, nodeIMU, nodeSLAM, nodePlaneDetection, nodeRenderer, nodeOpenXR, nodeLightEstimation],
        zoneId: 'zone_3',
      ),
    ],
  ),

  // ═══════════════════════════════════════════════════════════
  // ZONE 4 — Visual Realism
  // ═══════════════════════════════════════════════════════════
  ARZone(
    id: 'zone_4',
    name: 'Zone 4 — Visual Realism',
    accentColor: const Color(0xFFFFC107),
    levels: [
      // Level 7: Helmet View
      ARLevel(
        id: 'z4_l1',
        title: 'The Helmet View',
        projectTask: 'The project is moving to AR glasses! We need to update our pipeline to handle "double-vision" (stereoscopic) rendering.',
        goal: 'Update the pipeline to support Head-Mounted Displays (HMDs) through OpenXR.',
        buildContext: 'Wearing a headset changes everything. Instead of one screen, we have two. OpenXR manages this complex stereoscopic view so we can focus on the AR experience.',
        correctSequence: ['camera', 'openxr', 'renderer'],
        availableNodes: [nodeCamera, nodeOpenXR, nodeRenderer, nodeOcclusion],
        zoneId: 'zone_4',
        isFree: true, // First level of zone is free
        variations: [
          ARLevelVariation(
            projectTask: 'A factory needs VR safety training! Workers wear headsets to practice dangerous tasks safely. Build the "VR Training Simulator" display pipeline.',
            goal: 'Route the camera feed through OpenXR to render stereoscopic views in a training headset.',
            buildContext: 'Safety training in VR requires the same stereoscopic rendering pipeline. OpenXR handles the two-eye display so workers see depth correctly through their headset.',
            correctSequence: ['camera', 'openxr', 'renderer'],
            availableNodes: [nodeCamera, nodeOpenXR, nodeRenderer, nodeSLAM],
          ),
          ARLevelVariation(
            projectTask: 'A surgeon needs a heads-up display during operations! Build the "AR Surgery Assist" so vital patient data floats in the doctor\'s field of vision.',
            goal: 'Create a headset-compatible pipeline using OpenXR for medical AR overlays.',
            buildContext: 'Medical AR glasses use OpenXR to manage stereoscopic rendering. The camera captures the operating field, and the renderer overlays patient vitals and guidance.',
            correctSequence: ['camera', 'openxr', 'renderer'],
            availableNodes: [nodeCamera, nodeOpenXR, nodeRenderer, nodeLightEstimation],
          ),
        ],
      ),
      // Level 8: Behind the Scenes
      ARLevel(
        id: 'z4_l2',
        title: 'Behind the Scenes',
        projectTask: 'Our virtual trees are appearing IN FRONT of real chairs! It looks like an X-ray. We need to hide virtual objects behind real ones.',
        goal: 'Use "Occlusion" to make virtual objects hide behind real-world geometry.',
        buildContext: 'Occlusion uses depth data from the camera and SLAM to hide virtual pixels that are "behind" real objects. It\'s the key to making digital objects feel solid.',
        correctSequence: ['camera', 'slam', 'occlusion', 'renderer'],
        availableNodes: [nodeCamera, nodeSLAM, nodeOcclusion, nodeRenderer, nodePlaneDetection],
        zoneId: 'zone_4',
        variations: [
          ARLevelVariation(
            projectTask: 'A pet simulator needs a virtual cat that hides behind real furniture! When the cat walks behind the couch, it should disappear naturally.',
            goal: 'Use depth-based occlusion so the virtual pet is hidden behind real-world objects.',
            buildContext: 'For believable virtual pets, the app uses SLAM to understand room depth, then occlusion hides the pet\'s pixels when real furniture is in front of it.',
            correctSequence: ['camera', 'slam', 'occlusion', 'renderer'],
            availableNodes: [nodeCamera, nodeSLAM, nodeOcclusion, nodeRenderer, nodeIMU],
          ),
          ARLevelVariation(
            projectTask: 'An AR treasure hunt hides gold coins around the room! But players can see coins through walls — that\'s cheating! Fix the depth rendering.',
            goal: 'Enable occlusion so hidden treasure stays hidden behind real walls and furniture.',
            buildContext: 'Treasure should only be visible when there\'s a clear line of sight. SLAM maps the room\'s geometry, and occlusion ensures coins behind real objects stay invisible.',
            correctSequence: ['camera', 'slam', 'occlusion', 'renderer'],
            availableNodes: [nodeCamera, nodeSLAM, nodeOcclusion, nodeRenderer, nodeAnchor],
          ),
        ],
      ),
      // Boss 4: Solid Structure
      ARLevel(
        id: 'z4_boss',
        title: 'Boss: The Solid Structure',
        projectTask: 'It\'s the final presentation to the CEO. The AR must look absolutely real—no drifting, no "X-ray" artifacts, and full headset support.',
        goal: 'Build the ultimate enterprise-grade pipeline with occlusion and stereoscopic support.',
        buildContext: 'This is the most complex single-user setup: Universal input (OpenXR), spatial awareness (SLAM), and realistic depth compositing (Occlusion) all running at once.',
        isBoss: true,
        mode: GameMode.boss,
        timeLimit: 60,
        correctSequence: ['camera', 'imu', 'openxr', 'occlusion', 'renderer'],
        availableNodes: [nodeCamera, nodeIMU, nodeOpenXR, nodeOcclusion, nodeRenderer, nodeSpatialAnchor, nodeSLAM],
        zoneId: 'zone_4',
      ),
    ],
  ),

  // ═══════════════════════════════════════════════════════════
  // ZONE 5 — Professional Shipping
  // ═══════════════════════════════════════════════════════════
  ARZone(
    id: 'zone_5',
    name: 'Zone 5 — Professional Shipping',
    accentColor: const Color(0xFFFF4081),
    levels: [
      // Level 9: The Real Shadow
      ARLevel(
        id: 'z5_l1',
        title: 'The Real Shadow',
        projectTask: 'The client wants the virtual lamp to cast a shadow on their real table. We need to "steal" the lighting from the room!',
        goal: 'Capture the real room lighting to make virtual objects cast realistic shadows.',
        buildContext: 'Light Estimation analyzes the camera feed to guess the sun\'s direction and brightness. We then feed this to the renderer to make virtual lighting match the real world.',
        correctSequence: ['camera', 'light_estimation', 'renderer'],
        availableNodes: [nodeCamera, nodeLightEstimation, nodeRenderer, nodeSpatialAnchor],
        zoneId: 'zone_5',
        isFree: true, // First level of zone is free
        variations: [
          ARLevelVariation(
            projectTask: 'An interior design app lets users preview furniture in their room. But the virtual sofa looks "flat" and fake! Match it to the room\'s real lighting.',
            goal: 'Use light estimation so virtual furniture has the same shadows and highlights as the real room.',
            buildContext: 'Shoppers won\'t buy furniture that looks fake on screen. Light estimation reads the room\'s light direction and color from the camera, then applies it to the 3D models.',
            correctSequence: ['camera', 'light_estimation', 'renderer'],
            availableNodes: [nodeCamera, nodeLightEstimation, nodeRenderer, nodeOcclusion],
          ),
          ARLevelVariation(
            projectTask: 'A jewelry brand wants customers to "try on" virtual rings. But the diamonds look dull in dim rooms and washed-out in sunlight! Fix the lighting match.',
            goal: 'Capture ambient lighting so virtual jewelry sparkles naturally in any environment.',
            buildContext: 'Jewelry AR must match ambient light perfectly. Light estimation detects brightness and color temperature from the camera feed, then the renderer applies realistic reflections.',
            correctSequence: ['camera', 'light_estimation', 'renderer'],
            availableNodes: [nodeCamera, nodeLightEstimation, nodeRenderer, nodeSLAM],
          ),
        ],
      ),
      // Level 10: The Time Capsule
      ARLevel(
        id: 'z5_l2',
        title: 'The Time Capsule',
        projectTask: 'The user wants their virtual base to still be there when they come back tomorrow—even if they close the app entirely.',
        goal: 'Use Cloud-Spatial-Anchors to save the object\'s location to the internet.',
        buildContext: 'Persistence is hard. By saving the "visual signature" of a room to the cloud, we can re-place the same object exactly where it was in a future session.',
        correctSequence: ['camera', 'slam', 'spatial_anchor'],
        availableNodes: [nodeCamera, nodeSLAM, nodeSpatialAnchor, nodeOcclusion],
        zoneId: 'zone_5',
        variations: [
          ARLevelVariation(
            projectTask: 'Street artists want to paint virtual graffiti on real walls that stays forever! Anyone walking by should see the same art. Build the "AR Graffiti Wall".',
            goal: 'Save virtual artwork to the cloud so it persists across sessions and devices.',
            buildContext: 'Cloud spatial anchors save the visual fingerprint of the wall location. Any user who visits later can download the anchor and see the graffiti in the exact same spot.',
            correctSequence: ['camera', 'slam', 'spatial_anchor'],
            availableNodes: [nodeCamera, nodeSLAM, nodeSpatialAnchor, nodeRenderer],
          ),
          ARLevelVariation(
            projectTask: 'A memorial park wants visitors to leave virtual flowers at a monument. The flowers must still be there weeks later for other visitors to see.',
            goal: 'Use cloud-based spatial anchors to persist virtual objects at a real-world location permanently.',
            buildContext: 'Memorial AR uses spatial anchors stored in the cloud. SLAM maps the monument, the anchor saves its position, and future visitors resolve the same anchor to see all the flowers.',
            correctSequence: ['camera', 'slam', 'spatial_anchor'],
            availableNodes: [nodeCamera, nodeSLAM, nodeSpatialAnchor, nodeLightEstimation],
          ),
        ],
      ),
      // Final Boss: SHIP IT
      ARLevel(
        id: 'z5_boss',
        title: 'Final Boss: The Masterpiece',
        projectTask: 'This is it. Build the "Perfect AR App". It must see, track, detect, light, hide, and save. The entire engineering pipeline in one.',
        goal: 'Synthesize everything you\'ve learned into a complete, professional AR engine.',
        buildContext: 'The absolute peak of AR Systems Engineering. High-performance sensor fusion, environmental lighting, depth occlusion, and cloud persistence. Ship it, Architect!',
        isBoss: true,
        mode: GameMode.boss,
        timeLimit: 60,
        correctSequence: ['camera', 'imu', 'slam', 'plane_detection', 'light_estimation', 'occlusion', 'spatial_anchor', 'renderer'],
        availableNodes: [nodeCamera, nodeIMU, nodeSLAM, nodePlaneDetection, nodeLightEstimation, nodeOcclusion, nodeSpatialAnchor, nodeRenderer],
        zoneId: 'zone_5',
      ),
    ],
  ),
];
