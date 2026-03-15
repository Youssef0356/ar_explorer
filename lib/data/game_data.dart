import 'package:flutter/material.dart';
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

// --- Zones and Levels ---
final List<ARZone> arGameZones = [
  ARZone(
    id: 'zone_1',
    name: 'Zone 1 — Foundations',
    accentColor: const Color(0xFF00E5FF), // accentCyan
    levels: [
      ARLevel(
        id: 'z1_l1',
        title: 'AR Basics',
        goal: 'Capture the world and initialize a session.',
        correctSequence: ['camera', 'imu', 'renderer'],
        availableNodes: [nodeCamera, nodeIMU, nodeRenderer, nodeSLAM],
        zoneId: 'zone_1',
        isFree: true,
      ),
      ARLevel(
        id: 'z1_l2',
        title: 'Plane Detection',
        goal: 'Identify a table surface for placement.',
        correctSequence: ['camera', 'plane_detection', 'renderer'],
        availableNodes: [nodeCamera, nodePlaneDetection, nodeRenderer, nodeHitTest],
        zoneId: 'zone_1',
        isFree: true,
      ),
      ARLevel(
        id: 'z1_boss',
        title: 'Boss: Full ARCore Pipeline',
        goal: 'Complete the end-to-end ARCore loop.',
        isBoss: true,
        timeLimit: 60,
        correctSequence: ['camera', 'imu', 'slam', 'plane_detection', 'hit_test', 'anchor', 'renderer'],
        availableNodes: [nodeCamera, nodeIMU, nodeSLAM, nodePlaneDetection, nodeHitTest, nodeAnchor, nodeRenderer, nodeLightEstimation],
        zoneId: 'zone_1',
      ),
    ],
  ),
  ARZone(
    id: 'zone_2',
    name: 'Zone 2 — Tracking',
    accentColor: const Color(0xFF2979FF), // accentBlue
    levels: [
      ARLevel(
        id: 'z2_l1',
        title: 'SLAM',
        goal: 'Establish stable 6DOF tracking.',
        correctSequence: ['camera', 'imu', 'slam'],
        availableNodes: [nodeCamera, nodeIMU, nodeSLAM, nodeRelocalization],
        zoneId: 'zone_2',
      ),
      ARLevel(
        id: 'z2_l2',
        title: 'ARKit Session',
        goal: 'Initialize an Apple ARKit world tracking session.',
        correctSequence: ['camera', 'slam', 'renderer'],
        availableNodes: [nodeCamera, nodeSLAM, nodeRenderer, nodeLightEstimation],
        zoneId: 'zone_2',
      ),
      ARLevel(
        id: 'z2_boss',
        title: 'Boss: Full Relocalization Chain',
        goal: 'Recover tracking after a rapid movement.',
        isBoss: true,
        timeLimit: 60,
        correctSequence: ['camera', 'imu', 'slam', 'relocalization', 'renderer'],
        availableNodes: [nodeCamera, nodeIMU, nodeSLAM, nodeRelocalization, nodeRenderer, nodePlaneDetection],
        zoneId: 'zone_2',
      ),
    ],
  ),
  ARZone(
    id: 'zone_3',
    name: 'Zone 3 — Platforms',
    accentColor: const Color(0xFFD1C4E9), // accentPurple
    levels: [
      ARLevel(
        id: 'z3_l1',
        title: 'Unity AR Foundation',
        goal: 'Bridge cross-platform features.',
        correctSequence: ['camera', 'slam', 'plane_detection', 'renderer'],
        availableNodes: [nodeCamera, nodeSLAM, nodePlaneDetection, nodeRenderer, nodeOpenXR],
        zoneId: 'zone_3',
      ),
      ARLevel(
        id: 'z3_l2',
        title: 'Vuforia',
        goal: 'Image-based marker tracking.',
        correctSequence: ['camera', 'renderer'], // Simplified for game
        availableNodes: [nodeCamera, nodeRenderer, nodeSLAM],
        zoneId: 'zone_3',
      ),
      ARLevel(
        id: 'z3_boss',
        title: 'Boss: Cross-Platform Pipeline',
        goal: 'Build a standard Unity AR Foundation setup.',
        isBoss: true,
        timeLimit: 60,
        correctSequence: ['camera', 'imu', 'slam', 'plane_detection', 'renderer'],
        availableNodes: [nodeCamera, nodeIMU, nodeSLAM, nodePlaneDetection, nodeRenderer, nodeOpenXR],
        zoneId: 'zone_3',
      ),
    ],
  ),
  ARZone(
    id: 'zone_4',
    name: 'Zone 4 — Advanced',
    accentColor: const Color(0xFFFFC107), // accentAmber
    levels: [
      ARLevel(
        id: 'z4_l1',
        title: 'OpenXR',
        goal: 'Standardize sensor access.',
        correctSequence: ['camera', 'openxr', 'renderer'],
        availableNodes: [nodeCamera, nodeOpenXR, nodeRenderer, nodeOcclusion],
        zoneId: 'zone_4',
      ),
      ARLevel(
        id: 'z4_l2',
        title: 'Occlusion',
        goal: 'Enable realistic depth layering.',
        correctSequence: ['camera', 'slam', 'occlusion', 'renderer'],
        availableNodes: [nodeCamera, nodeSLAM, nodeOcclusion, nodeRenderer],
        zoneId: 'zone_4',
      ),
      ARLevel(
        id: 'z4_boss',
        title: 'Boss: OpenXR + Occlusion',
        goal: 'Combine standards with advanced depth.',
        isBoss: true,
        timeLimit: 60,
        correctSequence: ['camera', 'imu', 'openxr', 'occlusion', 'renderer'],
        availableNodes: [nodeCamera, nodeIMU, nodeOpenXR, nodeOcclusion, nodeRenderer, nodeSpatialAnchor],
        zoneId: 'zone_4',
      ),
    ],
  ),
  ARZone(
    id: 'zone_5',
    name: 'Zone 5 — Master',
    accentColor: const Color(0xFFFF4081), // accentPink
    levels: [
      ARLevel(
        id: 'z5_l1',
        title: 'Light Estimation',
        goal: 'Match virtual shadows to the sun.',
        correctSequence: ['camera', 'light_estimation', 'renderer'],
        availableNodes: [nodeCamera, nodeLightEstimation, nodeRenderer, nodeSpatialAnchor],
        zoneId: 'zone_5',
      ),
      ARLevel(
        id: 'z5_l2',
        title: 'Spatial Anchors',
        goal: 'Persistent world-scale content.',
        correctSequence: ['camera', 'slam', 'spatial_anchor'],
        availableNodes: [nodeCamera, nodeSLAM, nodeSpatialAnchor, nodeOcclusion],
        zoneId: 'zone_5',
      ),
      ARLevel(
        id: 'z5_boss',
        title: 'Boss: Full Production AR System',
        goal: 'Construct the ultimate persistent AR experience.',
        isBoss: true,
        timeLimit: 60,
        correctSequence: ['camera', 'imu', 'slam', 'plane_detection', 'light_estimation', 'occlusion', 'spatial_anchor', 'renderer'],
        availableNodes: [nodeCamera, nodeIMU, nodeSLAM, nodePlaneDetection, nodeLightEstimation, nodeOcclusion, nodeSpatialAnchor, nodeRenderer],
        zoneId: 'zone_5',
      ),
    ],
  ),
];
