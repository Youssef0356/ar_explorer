import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/game_models.dart';

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
    name: 'Zone 1 — See the World',
    accentColor: AppTheme.accentPurple,
    levels: [
      // Level 1: Open the camera
      ARLevel(
        id: 'z1_l1',
        title: 'Open the Camera',
        projectTask: 'ARena needs eyes. Give the engine a live video feed.',
        goal: 'Build the basic session.',
        buildContext: 'The most basic AR session possible — the game opens, the camera activates, and a test cube floats in space in front of the user. No surface, no tracking. Just "I can see the real world and I can draw on it."',
        correctSequence: ['camera', 'imu', 'renderer'],
        availableNodes: [nodeCamera, nodeIMU, nodeRenderer, nodeSLAM],
        zoneId: 'zone_1',
        isFree: true,
      ),
      // Level 2: Find the battlefield floor
      ARLevel(
        id: 'z1_l2',
        title: 'Find the Battlefield Floor',
        projectTask: 'ARena needs a surface to play on. Detect the floor.',
        goal: 'Scan for a valid play surface.',
        buildContext: 'The game scans the room and identifies the floor as a valid play surface. A green grid appears on it. No building placed yet — just surface detection confirmed.',
        correctSequence: ['camera', 'plane_detection', 'renderer'],
        availableNodes: [nodeCamera, nodePlaneDetection, nodeRenderer, nodeHitTest],
        zoneId: 'zone_1',
        isFree: true,
      ),
      // Boss 1: First prototype — tap to place your HQ
      ARLevel(
        id: 'z1_boss',
        title: 'Boss: First Prototype',
        projectTask: 'Tap the floor and your headquarters building appears. Walk around it. It stays.',
        goal: 'Place your first real AR building on a real floor.',
        buildContext: 'This is the first time every system works together. The player taps the floor, the HQ building appears, and it stays exactly where placed even as they walk a full circle around it. The boss requires all 7 nodes — any error clears the wrong node and costs a star.',
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
  // ZONE 2 — Track Your Position (like CSS)
  // ═══════════════════════════════════════════════════════════
  ARZone(
    id: 'zone_2',
    name: 'Zone 2 — Track Your Position',
    accentColor: AppTheme.accentBlue,
    levels: [
      // Level 3: Give ARena a 6DOF compass
      ARLevel(
        id: 'z2_l1',
        title: 'Give ARena a 6DOF Compass',
        projectTask: 'Units must face north regardless of where the player is standing.',
        goal: 'Establish stable 6DoF world coordinates.',
        buildContext: 'Directional arrows on game units that point consistently in world space. As the player walks a full circle, the arrows stay locked to the room — not rotating with the phone. This requires a stable 6DoF world coordinate system.',
        correctSequence: ['camera', 'imu', 'slam'],
        availableNodes: [nodeCamera, nodeIMU, nodeSLAM, nodeRelocalization],
        zoneId: 'zone_2',
      ),
      // Level 4: Keep the lights on
      ARLevel(
        id: 'z2_l2',
        title: 'Keep the Lights On',
        projectTask: 'HQ buildings must render cleanly on both iOS and Android without platform-specific code.',
        goal: 'Initialize a cross-platform AR session.',
        buildContext: 'The ARKit session pipeline — the minimum viable AR session on iPhone. The same three nodes also represent the ARCore equivalent. This level teaches that tracking + rendering is the base for everything else.',
        correctSequence: ['camera', 'slam', 'renderer'],
        availableNodes: [nodeCamera, nodeSLAM, nodeRenderer, nodeLightEstimation],
        zoneId: 'zone_2',
      ),
      // Boss 2: Survive a mid-game phone drop
      ARLevel(
        id: 'z2_boss',
        title: 'Boss: Survive Interruption',
        projectTask: 'Player covers the camera. Tracking lost. Uncover — base snaps back to exactly where it was.',
        goal: 'Build a robust AR session that survives real-world interruption.',
        buildContext: 'Any production AR game will face tracking loss — camera covered, user trips, phone pocketed briefly. The boss teaches the full recovery chain. The player must wire Relocalization correctly — after SLAM, before the Renderer — or the base drifts permanently on recovery.',
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
    name: 'Zone 3 — Build on Surfaces',
    accentColor: const Color(0xFFD1C4E9), // accentPurple
    levels: [
      // Level 5: Port ARena to both platforms
      ARLevel(
        id: 'z3_l1',
        title: 'Port to Both Platforms',
        projectTask: 'Same game, same code — runs on Samsung Galaxy and iPhone equally.',
        goal: 'Build a cross-platform foundation session.',
        buildContext: 'AR Foundation pipeline that works identically on ARCore and ARKit. The player learns that the abstraction layer handles platform differences — they build once, deploy twice.',
        correctSequence: ['camera', 'slam', 'plane_detection', 'renderer'],
        availableNodes: [nodeCamera, nodeSLAM, nodePlaneDetection, nodeRenderer, nodeOpenXR],
        zoneId: 'zone_3',
      ),
      // Level 6: Add the game box — marker-based tutorial
      ARLevel(
        id: 'z3_l2',
        title: 'Marker-Based Tutorial',
        projectTask: 'Point the camera at the ARena game box to unlock a bonus map. No SLAM needed.',
        goal: 'Use image tracking for quick AR entry.',
        buildContext: 'A Vuforia image target feature — point camera at the physical game box and a bonus AR map unlocks. This is deliberately the shortest pipeline in the game to teach that Vuforia replaces SLAM entirely. The marker IS the world origin.',
        correctSequence: ['camera', 'renderer'],
        availableNodes: [nodeCamera, nodeRenderer, nodeSLAM],
        zoneId: 'zone_3',
      ),
      // Boss 3: Full playable map
      ARLevel(
        id: 'z3_boss',
        title: 'Boss: Full Playable Map',
        projectTask: 'Both players scan the room. Both see the same floor grid. Both tap to place their HQ. Game begins.',
        goal: 'ARena is now a real, cross-platform playable game on a real floor.',
        buildContext: 'The biggest boss so far. The player must chain all 5 nodes correctly — and the trap nodes (OpenXR + Light Estimation) are present to test whether they know what belongs in a phone AR pipeline vs a headset pipeline.',
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
  // ZONE 4 — Make It Look Real (like Backend)
  // ═══════════════════════════════════════════════════════════
  ARZone(
    id: 'zone_4',
    name: 'Zone 4 — Make It Look Real',
    accentColor: const Color(0xFFFFC107), // accentAmber
    levels: [
      // Level 7: HQ ports to HoloLens
      ARLevel(
        id: 'z4_l1',
        title: 'HoloLens Enterprise Edition',
        projectTask: 'One ARena codebase must run on HoloLens, Quest, and phones. Wire the universal standard.',
        goal: 'Add OpenXR for headset compatibility.',
        buildContext: 'OpenXR sits between input and output — it is an adapter, not a feature. The level teaches the difference between architecture layers and feature layers.',
        correctSequence: ['camera', 'openxr', 'renderer'],
        availableNodes: [nodeCamera, nodeOpenXR, nodeRenderer, nodeOcclusion],
        zoneId: 'zone_4',
      ),
      // Level 8: Units hide behind real chairs
      ARLevel(
        id: 'z4_l2',
        title: 'Units Hide Behind Real Chairs',
        projectTask: 'A virtual unit walks behind a real chair leg. It disappears correctly. No floating through furniture.',
        goal: 'Enable realistic depth layering.',
        buildContext: 'Occlusion needs SLAM\'s depth map — it cannot function without it. Plane Detection adds no value here because occlusion works at the pixel level against any geometry, not just detected planes. This is a depth-compositing problem, not a surface-detection problem.',
        correctSequence: ['camera', 'slam', 'occlusion', 'renderer'],
        availableNodes: [nodeCamera, nodeSLAM, nodeOcclusion, nodeRenderer, nodePlaneDetection],
        zoneId: 'zone_4',
      ),
      // Boss 4: HoloLens launch
      ARLevel(
        id: 'z4_boss',
        title: 'Boss: HoloLens Launch',
        projectTask: 'The enterprise headset edition. Units are physically convincing. Every depth interaction works correctly.',
        goal: 'Pass the "does it look like it belongs" bar for enterprise demos.',
        buildContext: 'This boss is the hardest ordering challenge so far — OpenXR + IMU + Occlusion all in one sequence. The player must know that OpenXR comes after sensors but before features, and that Occlusion comes after SLAM but before Renderer.',
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
  // ZONE 5 — Ship Multiplayer (like Production)
  // ═══════════════════════════════════════════════════════════
  ARZone(
    id: 'zone_5',
    name: 'Zone 5 — Ship Multiplayer',
    accentColor: const Color(0xFFFF4081), // accentPink
    levels: [
      // Level 9: HQ casts shadows
      ARLevel(
        id: 'z5_l1',
        title: 'HQ Casts Real Shadows',
        projectTask: 'The building looks like it was actually built in the room. Its shadow points the same direction as the real chair shadow.',
        goal: 'Match virtual lighting to the real world.',
        buildContext: 'Light Estimation feeds into the renderer\'s PBR shader. Spatial Anchor uploads to the cloud. A developer who conflates polish features will pick both — the puzzle punishes that. Persistence and lighting are completely separate concerns.',
        correctSequence: ['camera', 'light_estimation', 'renderer'],
        availableNodes: [nodeCamera, nodeLightEstimation, nodeRenderer, nodeSpatialAnchor],
        zoneId: 'zone_5',
      ),
      // Level 10: Your base is still there tomorrow
      ARLevel(
        id: 'z5_l2',
        title: 'Your Base Survives Restart',
        projectTask: 'Player closes ARena. Opens it again the next morning. Their HQ is exactly where they left it.',
        goal: 'Enable cloud anchor persistence.',
        buildContext: 'Cloud anchor persistence — the game state outlives the session. The anchor uploads its feature signature to the cloud and resolves it on next launch. This is the foundation of the multiplayer shared world. No Renderer in this sequence — the anchor IS the output here.',
        correctSequence: ['camera', 'slam', 'spatial_anchor'],
        availableNodes: [nodeCamera, nodeSLAM, nodeSpatialAnchor, nodeOcclusion],
        zoneId: 'zone_5',
      ),
      // Final Boss: SHIP IT
      ARLevel(
        id: 'z5_boss',
        title: 'Final Boss: SHIP IT',
        projectTask: 'Two phones. Same room. Both players place bases. Units cast real shadows. Walk behind real furniture. Bases survive restart. ARena is complete.',
        goal: 'ARena is a complete, production-quality multiplayer AR game.',
        buildContext: '8 nodes. 60 seconds. No hints after the first failure. Every node taught across 10 levels is now required in a single pipeline. This is the hardest sequence in the game — and the most satisfying to complete. The player must use everything they learned in Zones 1–4 to pass.',
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
