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
