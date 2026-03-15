import 'package:flutter/material.dart';
import '../models/game_models.dart';

// --- Shared Nodes Pool ---
const nodeCamera = ARNode(
  id: 'camera',
  name: 'Camera Stream',
  description: 'Capture real-world RGB data',
  icon: Icons.camera_alt_rounded,
  type: ARNodeType.input,
  errorMessage: 'Error: Cannot process without visual input',
);

const nodeIMU = ARNode(
  id: 'imu',
  name: 'IMU Sensors',
  description: 'Accelerometer & Gyroscope data',
  icon: Icons.vibration_rounded,
  type: ARNodeType.input,
);

const nodePlaneDetection = ARNode(
  id: 'plane_detection',
  name: 'Plane Detection',
  description: 'Identify horizontal/vertical surfaces',
  icon: Icons.grid_4x4_rounded,
  type: ARNodeType.process,
  errorMessage: 'Error: Surface required for placement',
);

const nodeSLAM = ARNode(
  id: 'slam',
  name: 'SLAM Tracking',
  description: 'Simultaneous Localization and Mapping',
  icon: Icons.track_changes_rounded,
  type: ARNodeType.process,
  errorMessage: 'Error: Positional tracking lost',
);

const nodeHitTest = ARNode(
  id: 'hit_test',
  name: 'Hit Test',
  description: 'Raycast from screen to real-world',
  icon: Icons.ads_click_rounded,
  type: ARNodeType.process,
  errorMessage: 'Error: Raycast failed to find surface',
);

const nodeAnchor = ARNode(
  id: 'anchor',
  name: 'Anchor Node',
  description: 'Fix virtual content to a real-world point',
  icon: Icons.push_pin_rounded,
  type: ARNodeType.output,
  errorMessage: 'Error: Cannot anchor without HitTest',
);

const nodeRenderer = ARNode(
  id: 'renderer',
  name: '3D Renderer',
  description: 'Draw 3D objects on screen',
  icon: Icons.view_in_ar_rounded,
  type: ARNodeType.output,
);

const nodeLightEstimation = ARNode(
  id: 'light_estimation',
  name: 'Light Estimation',
  description: 'Match virtual lighting to real world',
  icon: Icons.light_mode_rounded,
  type: ARNodeType.process,
);

const nodeOcclusion = ARNode(
  id: 'occlusion',
  name: 'Occlusion',
  description: 'Hide virtual objects behind real ones',
  icon: Icons.layers_rounded,
  type: ARNodeType.output,
);

const nodeSpatialAnchor = ARNode(
  id: 'spatial_anchor',
  name: 'Spatial Anchor',
  description: 'Persistent cloud-based location',
  icon: Icons.cloud_done_rounded,
  type: ARNodeType.output,
);

const nodeOpenXR = ARNode(
  id: 'openxr',
  name: 'OpenXR Runtime',
  description: 'Standardized AR/VR interface',
  icon: Icons.settings_input_component_rounded,
  type: ARNodeType.utility,
);

const nodeRelocalization = ARNode(
  id: 'relocalization',
  name: 'Relocalization',
  description: 'Restore tracking from known features',
  icon: Icons.sync_rounded,
  type: ARNodeType.process,
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
