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
        title: 'Initialize Passthrough',
        projectTask: 'Initialize the base AR Session and establish a continuous camera feed to the rendering pipeline.',
        goal: 'Configure a viable AR Session capable of rendering spatial content.',
        buildContext: 'The foundational setup for any AR application. The system requires camera access to process passthrough video, IMU data for preliminary orientation tracking, and a rendering context to display spatial objects. No environmental tracking is performed at this stage.',
        correctSequence: ['camera', 'imu', 'renderer'],
        availableNodes: [nodeCamera, nodeIMU, nodeRenderer, nodeSLAM],
        zoneId: 'zone_1',
        isFree: true,
      ),
      // Level 2: Find the battlefield floor
      ARLevel(
        id: 'z1_l2',
        title: 'Establish Spatial Mesh',
        projectTask: 'Enable spatial awareness by detecting and tracking horizontal planar surfaces within the physical environment.',
        goal: 'Establish an environmental mesh for stable spatial anchoring.',
        buildContext: 'Surface detection algorithms analyze visual feature points from the camera feed and fuse them with IMU data to estimate the position and extent of flat surfaces like floors and tables, essential for anchoring virtual objects stably.',
        correctSequence: ['camera', 'plane_detection', 'renderer'],
        availableNodes: [nodeCamera, nodePlaneDetection, nodeRenderer, nodeHitTest],
        zoneId: 'zone_1',
        isFree: true,
      ),
      // Boss 1: First prototype — tap to place your HQ
      ARLevel(
        id: 'z1_boss',
        title: 'Boss: Deploy Anchor',
        projectTask: 'Instantiate a virtual asset securely attached to the spatial mesh. It must remain stable against 6DoF camera movement.',
        goal: 'Place your first stable spatial anchor on a physical surface.',
        buildContext: 'This sequence demands a complete sensor fusion pipeline. The system performs a hit test against the detected spatial mesh, instantiates an anchor at the intersection coordinate, and attaches the rendered asset payload to ensure positional stability against device movement.',
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
        title: 'Establish 6DoF Coordinates',
        projectTask: 'Ensure virtual assets resolve consistent world-space rotations independent of camera pose.',
        goal: 'Establish stable 6DoF world coordinates for spatial consistency.',
        buildContext: 'Spatial assets require directional vectors locked to world space, not local device space. This setup ensures that as the camera operator rotates around the asset, its rotation matrix remains stable relative to the physical environment constraint.',
        correctSequence: ['camera', 'imu', 'slam'],
        availableNodes: [nodeCamera, nodeIMU, nodeSLAM, nodeRelocalization],
        zoneId: 'zone_2',
      ),
      // Level 4: Keep the lights on
      ARLevel(
        id: 'z2_l2',
        title: 'Cross-Platform Render',
        projectTask: 'Architect a standardized rendering pipeline capable of operating gracefully across distinct AR APIs.',
        goal: 'Initialize a cross-platform AR session.',
        buildContext: 'The abstraction layer requires a common denominator pipeline. This sequence represents the minimum viable architecture to process SLAM coordinates into a standard rendering context, ignoring specialized, platform-exclusive environmental data.',
        correctSequence: ['camera', 'slam', 'renderer'],
        availableNodes: [nodeCamera, nodeSLAM, nodeRenderer, nodeLightEstimation],
        zoneId: 'zone_2',
      ),
      // Boss 2: Survive a mid-game phone drop
      ARLevel(
        id: 'z2_boss',
        title: 'Boss: Interruption Recovery',
        projectTask: 'The AR pipeline must successfully reacquire world-space coordinates following a catastrophic SLAM tracking failure.',
        goal: 'Build a robust AR tracking state machine that survives sensor interruption.',
        buildContext: 'Production applications experience frequent tracking degradation (e.g., lens obstruction or sudden acceleration). A robust pipeline implements a Relocalization node directly after the SLAM state to smoothly recover the spatial map from localized feature data.',
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
        title: 'Abstract Hardware Interfaces',
        projectTask: 'Design a unified architecture capable of deploying identical executables to ARKit and ARCore runtimes.',
        goal: 'Build a cross-platform foundation session.',
        buildContext: 'By injecting an abstraction layer, the specific heuristics of plane detection and rendering are handed off to the native API underlying the OpenXR runtime. The developer builds against unified interfaces, ensuring deployment parity.',
        correctSequence: ['camera', 'slam', 'plane_detection', 'renderer'],
        availableNodes: [nodeCamera, nodeSLAM, nodePlaneDetection, nodeRenderer, nodeOpenXR],
        zoneId: 'zone_3',
      ),
      // Level 6: Add the game box — marker-based tutorial
      ARLevel(
        id: 'z3_l2',
        title: 'Implement Image Tracking',
        projectTask: 'Bypass environmental SLAM by establishing a spatial coordinate origin directly from a 2D optical marker.',
        goal: 'Use image tracking for accelerated spatial referencing.',
        buildContext: 'Fiducial markers or tracked images bypass the need for plane scanning by providing explicit transformation matrices. The marker\'s centroid explicitly defines the world origin (0,0,0), providing the shortest path to a valid render context.',
        correctSequence: ['camera', 'renderer'],
        availableNodes: [nodeCamera, nodeRenderer, nodeSLAM],
        zoneId: 'zone_3',
      ),
      // Boss 3: Full playable map
      ARLevel(
        id: 'z3_boss',
        title: 'Boss: Instantiate Spatial Context',
        projectTask: 'Two distinct device clients must resolve identical planar coordinates for a shared spatial volume.',
        goal: 'Establish a shared, synchronized coordinate space.',
        buildContext: 'This requires strict adherence to tracking fundamentals. The architecture must reject device-specific data injections (like OpenXR or lighting overrides) that might desynchronize the shared spatial assumptions across diverse client hardware.',
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
        title: 'HMD Integration Requirements',
        projectTask: 'Update the pipeline configuration to accept stereoscopic displays and Head-Mounted Display (HMD) coordinate spaces.',
        goal: 'Add OpenXR runtime bindings for headset compatibility.',
        buildContext: 'Head-Mounted displays require the OpenXR abstraction to sit fundamentally between the input sensors and the output renderer, acting as a translator for specialized stereoscopic pipelines without altering the core SLAM logic.',
        correctSequence: ['camera', 'openxr', 'renderer'],
        availableNodes: [nodeCamera, nodeOpenXR, nodeRenderer, nodeOcclusion],
        zoneId: 'zone_4',
      ),
      // Level 8: Units hide behind real chairs
      ARLevel(
        id: 'z4_l2',
        title: 'Implement Depth Masking',
        projectTask: 'Integrate real-time depth mapping to compute accurate Z-buffering against physical foreground objects.',
        goal: 'Enable realistic depth layering and spatial occlusion.',
        buildContext: 'Occlusion processing relies fundamentally on the dense point cloud or depth map generated by the SLAM node. It uses this spatial data to construct a depth mask, discarding rendered fragments that exist spatially behind physical geometry.',
        correctSequence: ['camera', 'slam', 'occlusion', 'renderer'],
        availableNodes: [nodeCamera, nodeSLAM, nodeOcclusion, nodeRenderer, nodePlaneDetection],
        zoneId: 'zone_4',
      ),
      // Boss 4: HoloLens launch
      ARLevel(
        id: 'z4_boss',
        title: 'Boss: Enterprise Asset Deployment',
        projectTask: 'Deploy stereoscopically rendered assets that accurately composite against physical environments utilizing edge-aware depth testing.',
        goal: 'Pass the physical tangibility rendering validation for enterprise demos.',
        buildContext: 'This architecture represents peak standalone complexity: standardizing sensor input via OpenXR telemetry, passing coordinated matrices to an occlusion processor to generate depth buffers, and finalizing via the renderer to ensure physical tangibility.',
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
        title: 'Environmental Lighting Fusion',
        projectTask: 'Extract directional color and intensity coefficients from the camera feed to dynamically update PBR materials.',
        goal: 'Match virtual radiometry to the real-world luminous environment.',
        buildContext: 'Providing realistic shading requires tapping the camera\'s exposure and color temperature data via the Light Estimation node, which then feeds real-time spherical harmonics into the rendering pipeline prior to the final composition.',
        correctSequence: ['camera', 'light_estimation', 'renderer'],
        availableNodes: [nodeCamera, nodeLightEstimation, nodeRenderer, nodeSpatialAnchor],
        zoneId: 'zone_5',
      ),
      // Level 10: Your base is still there tomorrow
      ARLevel(
        id: 'z5_l2',
        title: 'Implement Spatial Persistence',
        projectTask: 'Serialize spatial coordinates and local feature maps to a cloud database to survive application termination.',
        goal: 'Enable asynchronous spatial anchor persistence.',
        buildContext: 'Spatial persistence decouples AR content from the immediate session lifecycle. The system caches the visual feature signature around the anchor point, uploads it, and relies on future relocalization sweeps to reinstantiate the tracked node upon subsequent launches.',
        correctSequence: ['camera', 'slam', 'spatial_anchor'],
        availableNodes: [nodeCamera, nodeSLAM, nodeSpatialAnchor, nodeOcclusion],
        zoneId: 'zone_5',
      ),
      // Final Boss: SHIP IT
      ARLevel(
        id: 'z5_boss',
        title: 'Final Boss: Release Candidate Validation',
        projectTask: 'Implement a comprehensive AR pipeline featuring environment sensing, depth mapping, dynamic global illumination, and cross-session persistence.',
        goal: 'Compile a complete, enterprise-grade augmented reality application pipeline.',
        buildContext: 'The culmination of complete Systems Engineering. This architecture seamlessly integrates sensor fusion, spatial awareness, radiometric estimation, depth compositing, external session persistence, and final rendering into a robust, concurrent pipeline module.',
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
