import 'package:flutter/material.dart';
import '../../models/slam_game_models.dart';

final List<SLAMLevel> allSlamLevels = [
  // ── LEVEL 1: The Patterned Studio ──
  SLAMLevel(
    id: 'slam_lab_1',
    levelNumber: 1,
    title: 'The Patterned Studio',
    subtitle: 'Feature Extraction & Triangulation Basics',
    description:
        'Calibrate your FAST corner detector. Maintain at least 4 triangulated points within the camera frustum as the sensor scans the studio.',
    conceptExplanation:
        'A monocular AR camera cannot perceive absolute scale from a single photo. SLAM uses Epipolar Geometry and Perspective-n-Point (PnP) solvers to triangulate at least 4 non-collinear 2D feature points into 3D world space, locking 6DoF pose.',
    practicalTip:
        'Tune the FAST threshold slider until at least 4 points illuminate in green. Watch the triangulation rays lock onto the camera!',
    defaultFastThreshold: 0.70, // Intentionally too high at start so player has to lower it to ~0.45
    defaultRansacEnabled: false,
    xpReward: 35,
    pathDurationSeconds: 16.0,
    sensorWaypoints: [
      const Offset(0.20, 0.75),
      const Offset(0.40, 0.60),
      const Offset(0.65, 0.65),
      const Offset(0.75, 0.40),
      const Offset(0.45, 0.30),
      const Offset(0.20, 0.75),
    ],
    obstacles: [
      const SLAMObstacle(
        id: 'obs_rug_1',
        rect: Rect.fromLTWH(0.35, 0.35, 0.32, 0.32),
        type: ObstacleType.texturedRug,
        label: 'Geometric Rug',
      ),
      const SLAMObstacle(
        id: 'obs_desk_1',
        rect: Rect.fromLTWH(0.12, 0.15, 0.28, 0.18),
        type: ObstacleType.furniture,
        label: 'Workstation',
      ),
    ],
    featurePoints: [
      // Rug corners (high contrast)
      SLAMFeaturePoint(id: 'p1', position: const Offset(0.37, 0.37), contrast: 0.92),
      SLAMFeaturePoint(id: 'p2', position: const Offset(0.65, 0.37), contrast: 0.88),
      SLAMFeaturePoint(id: 'p3', position: const Offset(0.37, 0.65), contrast: 0.85),
      SLAMFeaturePoint(id: 'p4', position: const Offset(0.65, 0.65), contrast: 0.95),
      SLAMFeaturePoint(id: 'p5', position: const Offset(0.51, 0.51), contrast: 0.78),
      // Desk corners
      SLAMFeaturePoint(id: 'p6', position: const Offset(0.14, 0.17), contrast: 0.72),
      SLAMFeaturePoint(id: 'p7', position: const Offset(0.38, 0.17), contrast: 0.68),
      SLAMFeaturePoint(id: 'p8', position: const Offset(0.14, 0.31), contrast: 0.75),
      SLAMFeaturePoint(id: 'p9', position: const Offset(0.38, 0.31), contrast: 0.82),
      // Wall poster
      SLAMFeaturePoint(id: 'p10', position: const Offset(0.78, 0.18), contrast: 0.62),
      SLAMFeaturePoint(id: 'p11', position: const Offset(0.86, 0.18), contrast: 0.65),
    ],
  ),

  // ── LEVEL 2: The Blank Hallway ──
  SLAMLevel(
    id: 'slam_lab_2',
    levelNumber: 2,
    title: 'The Blank Hallway',
    subtitle: 'Low Texture & Sensor Starvation',
    description:
        'Monochrome white walls produce zero gradients. Prevent tracking failure by lowering the sensitivity threshold to capture faint texture around doorframes.',
    conceptExplanation:
        'When you point your smartphone AR at a clean white ceiling or plain wall, tracking fails immediately. FAST (Features from Accelerated Segment Test) requires brightness differences across a ring of 16 surrounding pixels.',
    practicalTip:
        'If the FAST threshold is above 0.50, blank walls provide 0 points and drift surges! Lower sensitivity to 0.25–0.35 to catch subtle wall seams.',
    defaultFastThreshold: 0.65,
    defaultRansacEnabled: false,
    xpReward: 40,
    pathDurationSeconds: 18.0,
    sensorWaypoints: [
      const Offset(0.15, 0.50),
      const Offset(0.35, 0.50),
      const Offset(0.55, 0.50),
      const Offset(0.75, 0.50),
      const Offset(0.85, 0.50),
    ],
    obstacles: [
      const SLAMObstacle(
        id: 'wall_top',
        rect: Rect.fromLTWH(0.05, 0.25, 0.90, 0.05),
        type: ObstacleType.wall,
        label: 'Matte White Wall (Featureless)',
      ),
      const SLAMObstacle(
        id: 'wall_bottom',
        rect: Rect.fromLTWH(0.05, 0.70, 0.90, 0.05),
        type: ObstacleType.wall,
        label: 'Matte White Wall (Featureless)',
      ),
      const SLAMObstacle(
        id: 'door_frame',
        rect: Rect.fromLTWH(0.48, 0.22, 0.10, 0.08),
        type: ObstacleType.furniture,
        label: 'Wood Doorframe',
      ),
    ],
    featurePoints: [
      // Faint wall imperfections
      SLAMFeaturePoint(id: 'p1', position: const Offset(0.22, 0.32), contrast: 0.32),
      SLAMFeaturePoint(id: 'p2', position: const Offset(0.26, 0.68), contrast: 0.35),
      // Doorframe high contrast
      SLAMFeaturePoint(id: 'p3', position: const Offset(0.49, 0.28), contrast: 0.85),
      SLAMFeaturePoint(id: 'p4', position: const Offset(0.57, 0.28), contrast: 0.88),
      SLAMFeaturePoint(id: 'p5', position: const Offset(0.49, 0.34), contrast: 0.78),
      SLAMFeaturePoint(id: 'p6', position: const Offset(0.57, 0.34), contrast: 0.82),
      // Floor baseboard seam
      SLAMFeaturePoint(id: 'p7', position: const Offset(0.68, 0.68), contrast: 0.38),
      SLAMFeaturePoint(id: 'p8', position: const Offset(0.74, 0.32), contrast: 0.34),
      SLAMFeaturePoint(id: 'p9', position: const Offset(0.82, 0.68), contrast: 0.36),
      SLAMFeaturePoint(id: 'p10', position: const Offset(0.84, 0.32), contrast: 0.40),
    ],
  ),

  // ── LEVEL 3: The Busy Coffee Shop ──
  SLAMLevel(
    id: 'slam_lab_3',
    levelNumber: 3,
    title: 'The Busy Coffee Shop',
    subtitle: 'Dynamic Noise & RANSAC Outlier Rejection',
    description:
        'People are walking past your camera! Their moving features will corrupt your ego-motion calculation unless you engage RANSAC outlier rejection.',
    conceptExplanation:
        'Standard visual odometry assumes a static world (rigid-body assumption). If 40% of detected features belong to a walking person, the camera thinks the world is rotating. RANSAC isolates the largest consensus set of static points.',
    practicalTip:
        'Enable the "RANSAC Filter" switch! Watch moving pedestrian points turn RED (rejected) while static floor & counter points stay GREEN.',
    defaultFastThreshold: 0.38,
    defaultRansacEnabled: false,
    xpReward: 45,
    pathDurationSeconds: 20.0,
    sensorWaypoints: [
      const Offset(0.20, 0.80),
      const Offset(0.45, 0.65),
      const Offset(0.50, 0.45),
      const Offset(0.65, 0.30),
      const Offset(0.80, 0.35),
    ],
    obstacles: [
      const SLAMObstacle(
        id: 'counter',
        rect: Rect.fromLTWH(0.15, 0.15, 0.45, 0.15),
        type: ObstacleType.furniture,
        label: 'Espresso Counter',
      ),
      const SLAMObstacle(
        id: 'person_1',
        rect: Rect.fromLTWH(0.40, 0.45, 0.12, 0.12),
        type: ObstacleType.movingPerson,
        label: 'Walking Customer',
      ),
      const SLAMObstacle(
        id: 'person_2',
        rect: Rect.fromLTWH(0.60, 0.55, 0.12, 0.12),
        type: ObstacleType.movingPerson,
        label: 'Barista',
      ),
    ],
    featurePoints: [
      // Static Espresso Counter Points
      SLAMFeaturePoint(id: 's1', position: const Offset(0.18, 0.18), contrast: 0.85),
      SLAMFeaturePoint(id: 's2', position: const Offset(0.38, 0.18), contrast: 0.90),
      SLAMFeaturePoint(id: 's3', position: const Offset(0.56, 0.18), contrast: 0.80),
      SLAMFeaturePoint(id: 's4', position: const Offset(0.18, 0.28), contrast: 0.78),
      SLAMFeaturePoint(id: 's5', position: const Offset(0.56, 0.28), contrast: 0.82),
      // Static Floor Tile Corners
      SLAMFeaturePoint(id: 's6', position: const Offset(0.25, 0.55), contrast: 0.65),
      SLAMFeaturePoint(id: 's7', position: const Offset(0.32, 0.75), contrast: 0.70),
      SLAMFeaturePoint(id: 's8', position: const Offset(0.72, 0.70), contrast: 0.68),
      SLAMFeaturePoint(id: 's9', position: const Offset(0.80, 0.50), contrast: 0.72),
      // Dynamic moving points (People)
      SLAMFeaturePoint(id: 'd1', position: const Offset(0.43, 0.48), contrast: 0.95, isDynamic: true, velocity: const Offset(0.015, -0.01)),
      SLAMFeaturePoint(id: 'd2', position: const Offset(0.48, 0.52), contrast: 0.92, isDynamic: true, velocity: const Offset(0.015, -0.01)),
      SLAMFeaturePoint(id: 'd3', position: const Offset(0.63, 0.58), contrast: 0.88, isDynamic: true, velocity: const Offset(-0.01, 0.012)),
      SLAMFeaturePoint(id: 'd4', position: const Offset(0.68, 0.62), contrast: 0.84, isDynamic: true, velocity: const Offset(-0.01, 0.012)),
    ],
  ),

  // ── LEVEL 4: The Glass Atrium ──
  SLAMLevel(
    id: 'slam_lab_4',
    levelNumber: 4,
    title: 'The Glass Atrium',
    subtitle: 'Specular Reflections & Epipolar Violations',
    description:
        'Glass walls reflect the room and outdoor lighting. Use the combination of FAST sensitivity and RANSAC to avoid tracking "ghost" reflections.',
    conceptExplanation:
        'Reflections in glass move at a different apparent speed than real surfaces when you move your head. This violates epipolar geometry constraints and causes depth maps to compute negative or infinite z-depths.',
    practicalTip:
        'Filter reflective points with RANSAC and keep your focus locked on the wooden floor and structural pillars.',
    defaultFastThreshold: 0.42,
    defaultRansacEnabled: false,
    xpReward: 50,
    pathDurationSeconds: 20.0,
    sensorWaypoints: [
      const Offset(0.20, 0.75),
      const Offset(0.40, 0.70),
      const Offset(0.60, 0.55),
      const Offset(0.75, 0.35),
      const Offset(0.50, 0.30),
    ],
    obstacles: [
      const SLAMObstacle(
        id: 'glass_wall',
        rect: Rect.fromLTWH(0.65, 0.10, 0.28, 0.45),
        type: ObstacleType.reflectiveGlass,
        label: 'Glass Window (Specular)',
      ),
      const SLAMObstacle(
        id: 'pillar_1',
        rect: Rect.fromLTWH(0.25, 0.35, 0.10, 0.10),
        type: ObstacleType.wall,
        label: 'Solid Pillar',
      ),
    ],
    featurePoints: [
      // Solid pillar points
      SLAMFeaturePoint(id: 'p1', position: const Offset(0.26, 0.36), contrast: 0.90),
      SLAMFeaturePoint(id: 'p2', position: const Offset(0.34, 0.36), contrast: 0.88),
      SLAMFeaturePoint(id: 'p3', position: const Offset(0.26, 0.44), contrast: 0.86),
      SLAMFeaturePoint(id: 'p4', position: const Offset(0.34, 0.44), contrast: 0.92),
      // Solid floor seams
      SLAMFeaturePoint(id: 'p5', position: const Offset(0.22, 0.65), contrast: 0.65),
      SLAMFeaturePoint(id: 'p6', position: const Offset(0.45, 0.75), contrast: 0.70),
      SLAMFeaturePoint(id: 'p7', position: const Offset(0.55, 0.68), contrast: 0.68),
      // Reflective ghost points on glass
      SLAMFeaturePoint(id: 'r1', position: const Offset(0.72, 0.18), contrast: 0.84, isReflective: true, isDynamic: true),
      SLAMFeaturePoint(id: 'r2', position: const Offset(0.82, 0.24), contrast: 0.86, isReflective: true, isDynamic: true),
      SLAMFeaturePoint(id: 'r3', position: const Offset(0.75, 0.38), contrast: 0.80, isReflective: true, isDynamic: true),
    ],
  ),

  // ── LEVEL 5: Loop Closure & Drift Correction ──
  SLAMLevel(
    id: 'slam_lab_5',
    levelNumber: 5,
    title: 'The Great Loop',
    subtitle: 'Drift Accumulation & Keyframe Relocalization',
    description:
        'A full 360° circular orbit accumulates unavoidable inertial drift. Guide the drone back to the starting keyframe and trigger Loop Closure to snap drift to 0.0mm!',
    conceptExplanation:
        'Even with pristine tracking, sensor noise causes SLAM to accumulate tiny drift (0.5mm per meter). Loop Closure matches the current camera frame against a saved bag-of-words (BoW) dictionary of past keyframes to optimize the whole pose graph.',
    practicalTip:
        'Keep tracking stable throughout the entire orbit. When you complete the circle near the origin keyframe, tap "Relocalize" to trigger Loop Closure!',
    defaultFastThreshold: 0.40,
    defaultRansacEnabled: true,
    xpReward: 60,
    pathDurationSeconds: 24.0,
    sensorWaypoints: [
      const Offset(0.50, 0.85), // Start (Keyframe A)
      const Offset(0.20, 0.70),
      const Offset(0.18, 0.35),
      const Offset(0.45, 0.18),
      const Offset(0.80, 0.30),
      const Offset(0.82, 0.70),
      const Offset(0.50, 0.85), // Return to Keyframe A (Loop closed!)
    ],
    obstacles: [
      const SLAMObstacle(
        id: 'central_sculpture',
        rect: Rect.fromLTWH(0.40, 0.42, 0.20, 0.20),
        type: ObstacleType.furniture,
        label: 'AR Sculpture (Static Anchor)',
      ),
    ],
    featurePoints: [
      // Keyframe Origin Landmarks (High contrast benchmark)
      SLAMFeaturePoint(id: 'kf1', position: const Offset(0.45, 0.82), contrast: 0.95),
      SLAMFeaturePoint(id: 'kf2', position: const Offset(0.55, 0.82), contrast: 0.95),
      SLAMFeaturePoint(id: 'kf3', position: const Offset(0.48, 0.90), contrast: 0.90),
      SLAMFeaturePoint(id: 'kf4', position: const Offset(0.52, 0.90), contrast: 0.90),
      // Central sculpture features
      SLAMFeaturePoint(id: 'c1', position: const Offset(0.42, 0.44), contrast: 0.92),
      SLAMFeaturePoint(id: 'c2', position: const Offset(0.58, 0.44), contrast: 0.88),
      SLAMFeaturePoint(id: 'c3', position: const Offset(0.42, 0.60), contrast: 0.90),
      SLAMFeaturePoint(id: 'c4', position: const Offset(0.58, 0.60), contrast: 0.94),
      // Perimeter room features
      SLAMFeaturePoint(id: 'p1', position: const Offset(0.15, 0.30), contrast: 0.75),
      SLAMFeaturePoint(id: 'p2', position: const Offset(0.16, 0.75), contrast: 0.80),
      SLAMFeaturePoint(id: 'p3', position: const Offset(0.84, 0.28), contrast: 0.78),
      SLAMFeaturePoint(id: 'p4', position: const Offset(0.85, 0.72), contrast: 0.82),
    ],
  ),
];
