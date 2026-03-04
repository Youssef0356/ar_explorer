import 'package:flutter/material.dart';

import '../models/module_model.dart';
import '../models/topic_model.dart';

// ═══════════════════════════════════════════════════════════════════
//  ALL LEARNING MODULES — Content Data
// ═══════════════════════════════════════════════════════════════════

final List<LearningModule> allModules = [
  // ───────────────────────────────────────────────────────────────
  //  MODULE 0 — AR Basics (Definitions Only)
  // ───────────────────────────────────────────────────────────────
  LearningModule(
    id: 'intro_ar_basics',
    title: 'AR Basics: Core Definitions',
    description:
        'Start here if you are new to AR. Clear, simple definitions and mental models — no math, no SDKs.',
    icon: Icons.school_rounded,
    order: 0,
    unlockCost: 0,
    requiredQuizId: null,
    topics: [
      Topic(
        id: 'what_is_ar',
        title: 'What Is Augmented Reality?',
        subtitle: 'A precise, practical definition of AR.',
        contentBlocks: [
          const ContentBlock.heading('Augmented Reality in One Sentence'),
          const ContentBlock.body(
            'Augmented Reality (AR) overlays digital content onto the real world in real time, '
            'in a way that respects perspective and movement of the user.',
          ),
          const ContentBlock.subheading('Key Ingredients'),
          const ContentBlock.bullet(
            'You still see the real world (through a camera or transparent display).',
          ),
          const ContentBlock.bullet(
            'Digital content is aligned with that world (it appears to “stick” to places or objects).',
          ),
          const ContentBlock.bullet(
            'As you move, the content updates in real time to stay consistent.',
          ),
          const ContentBlock.info(
            'If the digital content does not react to your movement or the environment, it is closer '
            'to a “filter” or video effect than true AR.',
          ),
        ],
      ),
      Topic(
        id: 'ar_vs_vr_mr_xr',
        title: 'AR vs VR vs MR vs XR',
        subtitle: 'Understand the vocabulary used in the industry.',
        contentBlocks: [
          const ContentBlock.heading('Reality Vocabulary'),
          const ContentBlock.body(
            'Recruiters and senior engineers expect you to use these terms precisely. '
            'They describe where an experience sits on the spectrum between the real world and a fully virtual one.',
          ),
          const ContentBlock.subheading('Virtual Reality (VR)'),
          const ContentBlock.body(
            'VR fully replaces your view of the real world with a virtual one. You only see digital content.',
          ),
          const ContentBlock.subheading('Augmented Reality (AR)'),
          const ContentBlock.body(
            'AR shows you the real world first, then adds digital information on top of it.',
          ),
          const ContentBlock.subheading('Mixed Reality (MR)'),
          const ContentBlock.body(
            'MR is a broader term that covers experiences where real and virtual content coexist and can interact. '
            'Many AR headsets describe themselves as MR devices.',
          ),
          const ContentBlock.subheading('Extended Reality (XR)'),
          const ContentBlock.body(
            'XR is an umbrella marketing term that includes AR, VR, and MR.',
          ),
          const ContentBlock.info(
            'In interviews, describe AR as “world-first, digital-second”. VR is “digital-only”.',
          ),
        ],
      ),
      Topic(
        id: 'ar_examples_and_misconceptions',
        title: 'Real-World Examples & Misconceptions',
        subtitle: 'See where AR is used and what people get wrong.',
        contentBlocks: [
          const ContentBlock.heading('Where You Already See AR'),
          const ContentBlock.bullet(
            'Snapchat / Instagram face filters that lock to your head.',
          ),
          const ContentBlock.bullet(
            'Google Maps Live View arrows on the street in front of you.',
          ),
          const ContentBlock.bullet(
            'Industrial assembly instructions floating over a machine.',
          ),
          const ContentBlock.subheading('Common Misconceptions'),
          const ContentBlock.bullet(
            '“AR always needs a headset” — Many production systems run on phones and tablets.',
          ),
          const ContentBlock.bullet(
            '“AR is only for games” — The biggest money is in training, logistics, maintenance, and healthcare.',
          ),
          const ContentBlock.bullet(
            '“Any 3D overlay is AR” — If it does not track the real world, it is closer to a video effect.',
          ),
          const ContentBlock.warning(
            'As an aspiring AR expert, avoid vague definitions. Being precise about AR vs VR vs MR is your first credibility test.',
          ),
        ],
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  MODULE 1 — Coordinate Systems (Foundations)
  // ───────────────────────────────────────────────────────────────
  LearningModule(
    id: 'foundations_coordinate_systems',
    title: 'Coordinate Systems for AR',
    description:
        'Build an intuitive understanding of world, camera, and screen spaces — before touching any SDK.',
    icon: Icons.language_rounded,
    order: 1,
    unlockCost: 0,
    requiredQuizId: null,
    topics: [
      Topic(
        id: 'why_coords_matter',
        title: 'Why Coordinate Systems Matter',
        subtitle: 'The invisible skeleton under every AR scene.',
        contentBlocks: [
          const ContentBlock.heading('AR Is 3D Math Wearing a Nice UI'),
          const ContentBlock.body(
            'Every AR experience is built on a set of coordinate systems: invisible 3D grids that define where '
            'the camera is, where objects live, and how they move.',
          ),
          const ContentBlock.subheading('Without Coordinate Systems…'),
          const ContentBlock.bullet(
            'Virtual objects would not know “where” to appear in the real world.',
          ),
          const ContentBlock.bullet(
            'You could not place an object on a table or at 1 meter in front of the user.',
          ),
          const ContentBlock.bullet(
            'Two users could not agree on “the same” location in space.',
          ),
          const ContentBlock.info(
            'You do not need to compute matrices yet. At this stage, focus on mental models: origins, axes, and how spaces relate.',
          ),
        ],
      ),
      Topic(
        id: 'common_spaces',
        title: 'Common Spaces in AR',
        subtitle: 'World, camera, screen, and object space.',
        contentBlocks: [
          const ContentBlock.heading('The Main Spaces'),
          const ContentBlock.subheading('World Space'),
          const ContentBlock.body(
            'A stable 3D coordinate system tied to the real environment. Anchors and planes live here.',
          ),
          const ContentBlock.subheading('Camera Space'),
          const ContentBlock.body(
            'A coordinate system centered on the device camera. Forward is “where the camera looks”.',
          ),
          const ContentBlock.subheading('Screen Space'),
          const ContentBlock.body(
            'A 2D coordinate system for the screen. Touch positions and UI elements use this space.',
          ),
          const ContentBlock.subheading('Local / Object Space'),
          const ContentBlock.body(
            'Each virtual object has its own local origin and axes, making it easy to move or rotate whole models.',
          ),
          const ContentBlock.info(
            'In most AR SDKs, a “pose” is a transform from one space to another — for example, from world space into camera space.',
          ),
        ],
      ),
      Topic(
        id: 'coord_mistakes',
        title: 'Typical Coordinate System Mistakes',
        subtitle: 'Problems you avoid by understanding spaces early.',
        contentBlocks: [
          const ContentBlock.heading('Common Pitfalls'),
          const ContentBlock.bullet(
            'Mixing units — confusing meters with arbitrary units from 3D models.',
          ),
          const ContentBlock.bullet(
            'Forgetting that y-up vs z-up conventions differ between engines.',
          ),
          const ContentBlock.bullet(
            'Placing content in camera space when you meant world space, causing objects to “stick” to the camera.',
          ),
          const ContentBlock.subheading('Mental Debugging Checklist'),
          const ContentBlock.numbered(
            '1. Ask: “In which space am I right now?” (screen, camera, world, local).',
          ),
          const ContentBlock.numbered(
            '2. Check whether the origin and axes directions match your expectation.',
          ),
          const ContentBlock.numbered(
            '3. Verify that you convert between spaces only when necessary (e.g., tap → ray → world point).',
          ),
          const ContentBlock.warning(
            'When you see objects jumping or rotating in strange ways, a coordinate system mismatch is often the cause.',
          ),
        ],
      ),
    ],
  ),
  // ───────────────────────────────────────────────────────────────
  //  MODULE 2 — Strategic AR Foundations
  // ───────────────────────────────────────────────────────────────
  LearningModule(
    id: 'mod_intro',
    title: 'Strategic AR Foundations',
    description:
        'A comprehensive masterclass on the AR spatial stack, hardware paradigms, and industrial ecosystems.',
    icon: Icons.explore_rounded,
    order: 2,
    unlockCost: 0,
    requiredQuizId: null,
    topics: [
      Topic(
        id: 'spatial_foundations',
        title: 'Foundations of the Spatial Stack',
        subtitle: 'Milgram\'s Continuum and the Pillars of Registration',
        contentBlocks: [
          const ContentBlock.heading('The Evolution of Spatial Computing'),
          const ContentBlock.body(
            'We are currently undergoing a third foundational shift: moving from mobile to spatial computing. '
            'In a professional context, AR is the real-time integration of digital artifacts that respect '
            'the laws of physics, perspective, and lighting within the user’s physical environment.',
          ),
          const ContentBlock.subheading('The Reality-Virtuality Continuum'),
          const ContentBlock.body(
            'Paul Milgram’s spectrum maps the transition from Physical World to Virtual Reality. '
            '**Mixed Reality (MR)** encompasses everything in between. AR sits closer to the "Real Environment", '
            'prioritizing the physical world while enhancing it with contextual digital overlays.',
          ),
          const ContentBlock.info(
            '**Registration**: The precise alignment of virtual objects in 3D space. Failure results in "drift," '
            'where objects appear to slide or jump, breaking immersion.',
          ),
          const ContentBlock.subheading('The Three Pillars of AR'),
          const ContentBlock.bullet(
            '**1. Tracking (Pose Estimation)**: Determining the device\'s "Pose" (position and orientation) across 6-Degrees-of-Freedom (6DoF).',
          ),
          const ContentBlock.bullet(
            '**2. Scene Understanding**: Interpreting geometry and semantics (Detecting planes, generating depth maps).',
          ),
          const ContentBlock.bullet(
            '**3. Rendering**: Drawing virtual content to match real-world perspective and environmental lighting.',
          ),
        ],
      ),
      Topic(
        id: 'hardware_paradigms',
        title: 'Hardware Paradigms',
        subtitle: 'Handheld vs. Head-Mounted Architectures',
        contentBlocks: [
          const ContentBlock.heading('Handheld vs. Head-Mounted (HMD)'),
          const ContentBlock.body(
            'Handheld AR (Smartphones) is widely accessible but suffers from the "windowing" effect. '
            'Head-Mounted Displays (HMDs) provide "presence" and hands-free workflows.',
          ),
          const ContentBlock.subheading('Field of View (FOV) and Clarity'),
          const ContentBlock.bullet(
            '**Xreal Air 2**: Portable, 46° FOV - Ideal for personal media.',
          ),
          const ContentBlock.bullet(
            '**Microsoft HoloLens 2**: 52° FOV - The enterprise standard for spatial mapping.',
          ),
          const ContentBlock.bullet(
            '**Apple Vision Pro**: ~100° FOV, 23 Million Pixels - Near-retina clarity using Video See-Through (VST).',
          ),
          const ContentBlock.info(
            'HMDs are essential for guided assembly and surgery. Studies show workers using HMDs '
            'demonstrate significantly better performance and lower error rates than those using tablets.',
          ),
        ],
      ),
      Topic(
        id: 'software_ecosystems',
        title: 'Software & Development Engines',
        subtitle: 'Unity, Unreal, and Professional SDKs',
        contentBlocks: [
          const ContentBlock.heading('The "Big Three" Paths'),
          const ContentBlock.bullet(
            '**Unity**: Industry leader. Uses **AR Foundation** to abstract ARKit (iOS) and ARCore (Android) into one API.',
          ),
          const ContentBlock.bullet(
            '**Unreal Engine (C++)**: Preferred for high-fidelity industrial simulations and visual accuracy.',
          ),
          const ContentBlock.bullet(
            '**Native (Swift/Kotlin)**: Highest performance. Best for LiDAR-heavy apps on iOS or Geospatial apps on Android.',
          ),
          const ContentBlock.subheading('Enterprise: Vuforia Model Targeting'),
          const ContentBlock.body(
            'Vuforia excels at Recognizing specific 3D objects (e.g., a specific engine model). This is a '
            'critical differentiator where simple plane detection is insufficient.',
          ),
        ],
      ),
      Topic(
        id: 'webar_revolution',
        title: 'The WebAR Revolution',
        subtitle: 'Lowering Friction with 8th Wall and WebXR',
        contentBlocks: [
          const ContentBlock.heading('Why WebAR?'),
          const ContentBlock.body(
            '70% of potential users drop off if required to install a native app for a single-use experience. '
            'WebAR solves this "friction factor" by running directly in the mobile browser.',
          ),
          const ContentBlock.subheading('Technical Performance'),
          const ContentBlock.body(
            'Running in a browser sandbox means no direct GPU access. To maintain 60FPS, WebAR uses:',
          ),
          const ContentBlock.bullet(
            '**WebAssembly (Wasm)**: For high-performance computer vision tasks.',
          ),
          const ContentBlock.bullet(
            '**Asset Compression (Draco)**: To shrink 3D models for fast loading.',
          ),
          const ContentBlock.info(
            '**8th Wall** is the professional leader in WebAR SLAM tracking, supporting older hardware '
            'where basic libraries like AR.js might fail.',
          ),
        ],
      ),
      Topic(
        id: 'spatial_engineering',
        title: 'Advanced Spatial Engineering',
        subtitle: 'Occlusion, Anchors, and Relocalization',
        contentBlocks: [
          const ContentBlock.heading('Occlusion: The Depth Indicator'),
          const ContentBlock.body(
            'Without occlusion, digital content "floats" unnaturally. Objects must be able to hide '
            'behind physical walls or people.',
          ),
          const ContentBlock.bullet(
            '**Dynamic Occlusion**: Uses LiDAR/RGB to hide objects behind moving people/pets.',
          ),
          const ContentBlock.bullet(
            '**Mesh-Based Occlusion**: High stability for static furniture and walls.',
          ),
          const ContentBlock.warning(
            '**Z-Fighting**: Occurs when two surfaces at the same depth flicker as they compete for rendering priority.',
          ),
          const ContentBlock.subheading('Persistence & Spatial Anchors'),
          const ContentBlock.body(
            'Persistence allows virtual content to stay fixed in a location across multiple sessions.',
          ),
          const ContentBlock.bullet(
            '**Azure Spatial Anchors (ASA)**: Cloud-based, scalable for large industrial sites.',
          ),
          const ContentBlock.bullet(
            '**Google Cloud Anchors**: Optimized for multi-user shared AR social experiences.',
          ),
          const ContentBlock.info(
            '**Relocalization**: The process of a device recognizing its environment and resetting '
            'its coordinate system to align with a stored spatial map.',
          ),
        ],
      ),
      Topic(
        id: 'ux_and_safety',
        title: 'Human-Centric Design',
        subtitle: 'Reducing Cognitive Load in Spatial UI',
        contentBlocks: [
          const ContentBlock.heading('The 5 Pillars of Spatial UX'),
          const ContentBlock.bullet(
            '**Environment**: UI must not cover faces or real-world safety hazards.',
          ),
          const ContentBlock.bullet(
            '**Onboarding**: Use visual hints (scan floor) instead of heavy text.',
          ),
          const ContentBlock.bullet(
            '**Movement**: Encourage physical movement without causing "neck strain".',
          ),
          const ContentBlock.bullet(
            '**Interface**: Use **Progressive Disclosure**—reveal details only upon demand.',
          ),
          const ContentBlock.bullet(
            '**Interaction**: Replace menus with natural gestures (Grab, Move, Pin).',
          ),
          const ContentBlock.subheading('Situational Awareness'),
          const ContentBlock.body(
            'Apps used while moving must simplify UI when walking is detected. Never place content directly '
            'over the ground where it might hide physical steps or hazards.',
          ),
        ],
      ),
      Topic(
        id: 'industrial_applications',
        title: 'Professional Domains',
        subtitle: 'AR Transforming the Global Workforce',
        contentBlocks: [
          const ContentBlock.heading('Industrial Impact'),
          const ContentBlock.body(
            'AR is bridging the gap between digital data and physical labor in these critical sectors:',
          ),
          const ContentBlock.bullet(
            '**Medical**: Surgical planning and sub-millimeter registration for real-time vitals overlay.',
          ),
          const ContentBlock.bullet(
            '**Logistics**: Route optimization and real-time barcode integration for warehouse staff.',
          ),
          const ContentBlock.bullet(
            '**Architecture**: Infrastructure visualization and large-scale GPS-denied navigation.',
          ),
          const ContentBlock.info(
            'Example: **KLM Airlines** uses the Engine Shop app on Apple Vision Pro for trainees to '
            'study full-fidelity 3D repair instructions, significantly reducing training errors.',
          ),
        ],
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  MODULE 3 — Technical Concepts
  // ───────────────────────────────────────────────────────────────
  LearningModule(
    id: 'mod_tech',
    title: 'Technical Concepts',
    description: 'How modern AR systems operate internally.',
    icon: Icons.memory_rounded,
    order: 3,
    unlockCost: 0,
    requiredQuizId: null,
    topics: [
      Topic(
        id: 'sensor_fusion',
        title: 'Sensor Fusion',
        subtitle: 'Combining camera, gyroscope, and accelerometer.',
        contentBlocks: [
          const ContentBlock.heading('Sensor Fusion in AR'),
          const ContentBlock.body(
            'Sensor fusion is the process of combining data from multiple sensors to produce a more accurate '
            'and stable estimation of the device\'s position and orientation. In mobile AR, three primary sensors '
            'work together: the camera, gyroscope, and accelerometer.',
          ),
          const ContentBlock.subheading('Sensor Roles'),
          const ContentBlock.numbered(
            '1. Camera — Provides visual features for tracking and environment understanding.',
          ),
          const ContentBlock.numbered(
            '2. Gyroscope — Measures rotational velocity, enabling fast orientation changes.',
          ),
          const ContentBlock.numbered(
            '3. Accelerometer — Measures linear acceleration, supporting translation estimation.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('Fusion Techniques'),
          const ContentBlock.bullet(
            'Kalman Filtering — Combines noisy measurements with predictive models.',
          ),
          const ContentBlock.bullet(
            'Complementary Filtering — Blends high-frequency gyro data with low-frequency accelerometer data.',
          ),
          const ContentBlock.bullet(
            'Visual-Inertial Odometry (VIO) — Fuses camera and IMU data for precise 6DoF tracking.',
          ),
          const ContentBlock.info(
            'VIO is the backbone of ARCore and ARKit tracking. It allows centimeter-level accuracy in position '
            'estimation by continuously matching visual features across camera frames while correcting drift with IMU data.',
          ),
        ],
      ),
      Topic(
        id: 'slam',
        title: 'SLAM',
        subtitle: 'Simultaneous Localization and Mapping.',
        contentBlocks: [
          const ContentBlock.heading(
            'SLAM — Simultaneous Localization and Mapping',
          ),
          const ContentBlock.body(
            'SLAM is the computational problem of constructing a map of an unknown environment while simultaneously '
            'tracking the agent\'s (device\'s) location within that map. It is the foundation of markerless AR tracking.',
          ),
          const ContentBlock.subheading('How SLAM Works'),
          const ContentBlock.numbered(
            '1. Feature Extraction — Key visual features (corners, edges) are detected in each camera frame.',
          ),
          const ContentBlock.numbered(
            '2. Feature Matching — Features are matched across frames to determine motion.',
          ),
          const ContentBlock.numbered(
            '3. Map Building — Matched features are triangulated to create a 3D point cloud (sparse map).',
          ),
          const ContentBlock.numbered(
            '4. Pose Estimation — The device\'s position and orientation are calculated relative to the map.',
          ),
          const ContentBlock.numbered(
            '5. Loop Closure — When the device revisits a location, the map is corrected for accumulated drift.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('SLAM Variants'),
          const ContentBlock.bullet('Visual SLAM — Uses camera images only.'),
          const ContentBlock.bullet(
            'Visual-Inertial SLAM — Combines camera with IMU sensors for robustness.',
          ),
          const ContentBlock.bullet(
            'LiDAR SLAM — Uses depth sensors (e.g., iPad Pro LiDAR).',
          ),
          const ContentBlock.warning(
            'SLAM can fail in environments with few features (blank walls), fast motion (blur), or drastic lighting changes.',
          ),
        ],
      ),
      Topic(
        id: 'plane_detection',
        title: 'Plane Detection',
        subtitle: 'Finding flat surfaces in the real world.',
        contentBlocks: [
          const ContentBlock.heading('Plane Detection'),
          const ContentBlock.body(
            'Plane detection is the process of identifying flat surfaces in the real world using the device\'s camera '
            'and sensor data. It is essential for placing virtual objects on tables, floors, or walls.',
          ),
          const ContentBlock.subheading('Detection Process'),
          const ContentBlock.numbered(
            '1. Feature points are detected and tracked across multiple frames.',
          ),
          const ContentBlock.numbered(
            '2. Clusters of coplanar feature points are identified.',
          ),
          const ContentBlock.numbered(
            '3. A plane model (position, orientation, boundary) is fitted to the cluster.',
          ),
          const ContentBlock.numbered(
            '4. As more data is gathered, the plane boundary expands and refines.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('Plane Types'),
          const ContentBlock.bullet(
            'Horizontal Planes — Floors, tables, countertops.',
          ),
          const ContentBlock.bullet(
            'Vertical Planes — Walls, doors, whiteboards.',
          ),
          const ContentBlock.bullet(
            'Arbitrary Planes — Sloped surfaces (limited support).',
          ),
          const ContentBlock.info(
            'Textured surfaces detect faster. Smooth, reflective, or transparent surfaces are challenging for plane detection.',
          ),
        ],
      ),
      Topic(
        id: 'feature_tracking',
        title: 'Feature Point Tracking',
        subtitle: 'Detecting and following visual keypoints.',
        contentBlocks: [
          const ContentBlock.heading('Feature Point Tracking'),
          const ContentBlock.body(
            'Feature point tracking is the process of detecting distinctive visual features (keypoints) in camera '
            'images and tracking them across consecutive frames. These keypoints form the foundation for motion '
            'estimation, SLAM, and environmental understanding.',
          ),
          const ContentBlock.subheading('Common Feature Detectors'),
          const ContentBlock.bullet(
            'ORB (Oriented FAST and Rotated BRIEF) — Fast, rotation-invariant.',
          ),
          const ContentBlock.bullet(
            'SIFT (Scale-Invariant Feature Transform) — Robust but computationally heavy.',
          ),
          const ContentBlock.bullet(
            'FAST (Features from Accelerated Segment Test) — Extremely fast corner detection.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('Tracking Pipeline'),
          const ContentBlock.numbered(
            '1. Detect features in the current frame.',
          ),
          const ContentBlock.numbered(
            '2. Match features with those from the previous frame.',
          ),
          const ContentBlock.numbered(
            '3. Compute the relative transformation (rotation + translation).',
          ),
          const ContentBlock.numbered('4. Update the device pose estimation.'),
          const ContentBlock.warning(
            'Feature tracking degrades in low-light, motion-blur, or repetitive-pattern environments.',
          ),
        ],
      ),
      Topic(
        id: 'light_estimation',
        title: 'Light Estimation',
        subtitle: 'Realistic lighting for virtual objects.',
        contentBlocks: [
          const ContentBlock.heading('Light Estimation'),
          const ContentBlock.body(
            'Light estimation analyzes the real environment\'s lighting conditions from camera images and applies '
            'similar lighting to virtual objects. This is crucial for making AR content look realistic and integrated '
            'with the real world.',
          ),
          const ContentBlock.subheading('What Is Estimated'),
          const ContentBlock.bullet(
            'Ambient Light Intensity — Overall brightness of the scene.',
          ),
          const ContentBlock.bullet(
            'Color Temperature — Warm (yellowish) vs. cool (bluish) lighting.',
          ),
          const ContentBlock.bullet(
            'Directional Light — Direction and intensity of the main light source.',
          ),
          const ContentBlock.bullet(
            'Environmental HDR — Full spherical map for reflections and shadows.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('Implementation in AR SDKs'),
          const ContentBlock.numbered(
            '1. ARCore provides ambient intensity, color correction, and Environmental HDR modes.',
          ),
          const ContentBlock.numbered(
            '2. ARKit supports ambient intensity and environment probes.',
          ),
          const ContentBlock.numbered(
            '3. AR Foundation exposes a unified API via ARCameraManager for light estimation.',
          ),
          const ContentBlock.info(
            'Environmental HDR provides the most realistic results but requires more processing power. Use ambient '
            'intensity for better performance on low-end devices.',
          ),
        ],
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  MODULE 4 — Development
  // ───────────────────────────────────────────────────────────────
  LearningModule(
    id: 'mod_dev',
    title: 'Development',
    description: 'Building AR apps with Vuforia, ARCore & AR Foundation.',
    icon: Icons.code_rounded,
    order: 4,
    unlockCost: 0,
    requiredQuizId: null,
    topics: [
      Topic(
        id: 'vuforia_dev',
        title: 'Vuforia Development',
        subtitle: 'ImageTarget setup and tracking behavior.',
        contentBlocks: [
          const ContentBlock.heading('Vuforia-Based Development'),
          const ContentBlock.body(
            'This section covers the practical development workflow using Vuforia Engine for marker-based AR. '
            'We focus on ImageTarget configuration, anchoring, tracking behavior, and stability handling.',
          ),
          const ContentBlock.subheading('ImageTarget Configuration'),
          const ContentBlock.numbered(
            '1. Create an account on the Vuforia Developer Portal.',
          ),
          const ContentBlock.numbered(
            '2. Create a new database and upload target images.',
          ),
          const ContentBlock.numbered(
            '3. Review the star rating — aim for 4–5 stars for reliable tracking.',
          ),
          const ContentBlock.numbered(
            '4. Download the database package for Unity or native SDK.',
          ),
          const ContentBlock.numbered(
            '5. Import into your project and attach to an ImageTarget object.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('Anchoring Techniques'),
          const ContentBlock.bullet(
            'Static Anchoring — Content stays attached to the target and moves with it.',
          ),
          const ContentBlock.bullet(
            'Extended Tracking — Content persists even when the target is out of view.',
          ),
          const ContentBlock.bullet(
            'Mid-Air Anchoring — Content is placed at a fixed world position after initial detection.',
          ),
          const ContentBlock.subheading('Tracking Behavior'),
          const ContentBlock.body(
            'Vuforia provides tracking status callbacks that inform the application when a target is tracked, '
            'extended-tracked, or lost. Handling these states correctly is critical for user experience.',
          ),
          const ContentBlock.code(
            'void OnTrackableStateChanged(\n'
            '    TrackableBehaviour.Status previousStatus,\n'
            '    TrackableBehaviour.Status newStatus) {\n'
            '  if (newStatus == TrackableBehaviour.Status.DETECTED ||\n'
            '      newStatus == TrackableBehaviour.Status.TRACKED) {\n'
            '    OnTrackingFound();\n'
            '  } else {\n'
            '    OnTrackingLost();\n'
            '  }\n'
            '}',
          ),
          const ContentBlock.subheading('Stability Handling'),
          const ContentBlock.bullet(
            'Use Extended Tracking to maintain content when the marker leaves the camera view.',
          ),
          const ContentBlock.bullet(
            'Implement smooth transitions between TRACKED and EXTENDED_TRACKED states.',
          ),
          const ContentBlock.bullet(
            'Show user guidance when tracking is lost (e.g., "Point camera at the target").',
          ),
        ],
      ),
      Topic(
        id: 'arcore_dev',
        title: 'ARCore Development',
        subtitle: 'Session management and plane detection.',
        contentBlocks: [
          const ContentBlock.heading('ARCore-Based Development'),
          const ContentBlock.body(
            'ARCore development involves managing AR sessions, detecting planes, performing raycasts, '
            'and managing anchors. This section covers the core workflow.',
          ),
          const ContentBlock.subheading('Session Management'),
          const ContentBlock.numbered(
            '1. Check if ARCore is installed and the device is compatible.',
          ),
          const ContentBlock.numbered(
            '2. Create and configure an ArSession with desired features.',
          ),
          const ContentBlock.numbered(
            '3. Resume the session when the activity resumes; pause when it pauses.',
          ),
          const ContentBlock.numbered(
            '4. Handle session errors gracefully (camera permission denied, unsupported device).',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('Anchor Lifecycle'),
          const ContentBlock.body(
            'Anchors are the primary mechanism for placing content in the real world. An anchor is a fixed point '
            'in the world coordinate system that ARCore continuously updates as the environment map improves.',
          ),
          const ContentBlock.bullet(
            'Create anchors from hit test results or trackables.',
          ),
          const ContentBlock.bullet(
            'Monitor TrackingState (TRACKING, PAUSED, STOPPED).',
          ),
          const ContentBlock.bullet(
            'Detach anchors when no longer needed to save resources.',
          ),
          const ContentBlock.subheading('Raycasting'),
          const ContentBlock.body(
            'Raycasting (hit testing) sends a virtual ray from a 2D screen point into the 3D world to detect '
            'intersections with tracked geometry (planes, feature points).',
          ),
          const ContentBlock.code(
            'List<HitResult> hitResults = frame.hitTest(motionEvent);\nfor (HitResult hit : hitResults) {\n  Trackable trackable = hit.getTrackable();\n  if (trackable instanceof Plane) {\n    Anchor anchor = hit.createAnchor();\n    // Place content at this anchor\n    break;\n  }\n}',
          ),
          const ContentBlock.info(
            'Always filter hit results by trackable type. Prioritize plane hits over feature point hits for '
            'more stable placement.',
          ),
        ],
      ),
      Topic(
        id: 'ar_foundation_dev',
        title: 'AR Foundation Development',
        subtitle: 'Cross-platform AR with Unity.',
        contentBlocks: [
          const ContentBlock.heading('AR Foundation Development'),
          const ContentBlock.body(
            'AR Foundation provides a unified API that works across ARCore and ARKit. This section covers '
            'the core managers and their implementation patterns.',
          ),
          const ContentBlock.subheading('AR Session Origin Setup'),
          const ContentBlock.numbered(
            '1. Add an AR Session object to the scene (manages AR lifecycle).',
          ),
          const ContentBlock.numbered(
            '2. Add an AR Session Origin object (defines world origin and camera).',
          ),
          const ContentBlock.numbered(
            '3. Attach AR Camera to Session Origin as a child.',
          ),
          const ContentBlock.numbered(
            '4. Add desired managers (Plane, Raycast, Anchor) to the Session Origin.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('AR Managers'),
          const ContentBlock.bullet(
            'ARPlaneManager — Detects planes and instantiates plane prefabs.',
          ),
          const ContentBlock.bullet(
            'ARRaycastManager — Performs raycasts against tracked geometry.',
          ),
          const ContentBlock.bullet(
            'ARAnchorManager — Creates and manages world-locked anchors.',
          ),
          const ContentBlock.bullet(
            'ARPointCloudManager — Visualizes tracked feature points.',
          ),
          const ContentBlock.subheading('Cross-Platform Raycast Example'),
          const ContentBlock.code(
            'if (arRaycastManager.Raycast(\n'
            '    screenPosition, hits, TrackableType.PlaneWithinPolygon)) {\n'
            '  var hitPose = hits[0].pose;\n'
            '  if (spawnedObject == null) {\n'
            '    spawnedObject = Instantiate(prefab, hitPose.position, hitPose.rotation);\n'
            '  } else {\n'
            '    spawnedObject.transform.position = hitPose.position;\n'
            '  }\n'
            '}',
          ),
          const ContentBlock.subheading('Unified API Design'),
          const ContentBlock.body(
            'The strength of AR Foundation is that the same C# code runs on both Android (ARCore) and iOS (ARKit). '
            'Platform differences are handled automatically by the respective XR plugins. This significantly reduces '
            'development time and maintenance burden for cross-platform AR applications.',
          ),
          const ContentBlock.warning(
            'Not all features are available on both platforms. Check the AR Foundation compatibility matrix '
            'before using advanced features like face tracking or body tracking.',
          ),
        ],
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  MODULE 5 — Stabilization & Performance
  // ───────────────────────────────────────────────────────────────
  LearningModule(
    id: 'mod_stab',
    title: 'Stabilization & Performance',
    description: 'Techniques for reliable and smooth AR experiences.',
    icon: Icons.speed_rounded,
    order: 5,
    unlockCost: 0,
    requiredQuizId: null,
    topics: [
      Topic(
        id: 'anchor_stability',
        title: 'Anchor-Based Positioning',
        subtitle: 'Stable content placement strategies.',
        contentBlocks: [
          const ContentBlock.heading('Anchor-Based Positioning'),
          const ContentBlock.body(
            'Anchors are the primary mechanism for ensuring virtual content stays fixed in the real world. '
            'Proper anchor management is essential for a stable AR experience.',
          ),
          const ContentBlock.subheading('Best Practices'),
          const ContentBlock.bullet(
            'Place anchors on well-tracked surfaces (planes with high confidence).',
          ),
          const ContentBlock.bullet(
            'Minimize the number of active anchors to reduce computational overhead.',
          ),
          const ContentBlock.bullet(
            'Re-anchor content periodically if tracking quality degrades.',
          ),
          const ContentBlock.bullet(
            'Use Cloud Anchors for shared/multi-user experiences.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('Anchor Confidence'),
          const ContentBlock.body(
            'Anchors have a tracking state that reflects their reliability. Monitor this state and respond accordingly '
            '— hide content when tracking is PAUSED, remove it when STOPPED.',
          ),
          const ContentBlock.info(
            'On ARCore, use Anchor.getTrackingState(). On AR Foundation, use ARAnchor.trackingState. '
            'Both provide TRACKING, LIMITED, and NOT_TRACKING states.',
          ),
        ],
      ),
      Topic(
        id: 'tracking_state',
        title: 'Tracking State Monitoring',
        subtitle: 'Responding to tracking quality changes.',
        contentBlocks: [
          const ContentBlock.heading('Tracking State Monitoring'),
          const ContentBlock.body(
            'AR tracking quality fluctuates based on environmental conditions, device motion, and sensor reliability. '
            'Monitoring and responding to tracking state changes is critical for a robust AR experience.',
          ),
          const ContentBlock.subheading('Tracking States'),
          const ContentBlock.numbered(
            '1. TRACKING — Full 6DoF pose is available. Content renders normally.',
          ),
          const ContentBlock.numbered(
            '2. PAUSED / LIMITED — Reduced tracking quality. Show cautionary UI.',
          ),
          const ContentBlock.numbered(
            '3. NOT_TRACKING — Tracking is lost. Hide AR content, show recovery guidance.',
          ),
          const ContentBlock.subheading('Recovery Strategies'),
          const ContentBlock.bullet(
            'Show a visual hint: "Move your device slowly to restore tracking."',
          ),
          const ContentBlock.bullet(
            'Freeze the last known pose to prevent jitter.',
          ),
          const ContentBlock.bullet(
            'Gradually fade out content when tracking degrades.',
          ),
          const ContentBlock.bullet(
            'Re-initialize the session if tracking cannot be recovered.',
          ),
          const ContentBlock.warning(
            'Never hide the camera feed when tracking is lost — it disorients the user. Instead, overlay a translucent guidance message.',
          ),
        ],
      ),
      Topic(
        id: 'drift_reduction',
        title: 'Drift Reduction',
        subtitle: 'Minimizing positional drift over time.',
        contentBlocks: [
          const ContentBlock.heading('Drift Reduction Techniques'),
          const ContentBlock.body(
            'Drift occurs when small tracking errors accumulate over time, causing virtual content to shift from its '
            'intended position. Several techniques can reduce drift.',
          ),
          const ContentBlock.subheading('Techniques'),
          const ContentBlock.bullet(
            'Loop Closure — When SLAM revisits a known area, it corrects the accumulated error.',
          ),
          const ContentBlock.bullet(
            'Re-anchoring — Periodically create new anchors near the user to refresh tracking accuracy.',
          ),
          const ContentBlock.bullet(
            'IMU Bias Correction — Calibrate accelerometer and gyroscope biases during static periods.',
          ),
          const ContentBlock.bullet(
            'Multi-anchor Strategies — Use multiple anchors across the scene to distribute error.',
          ),
          const ContentBlock.info(
            'Cloud Anchors can also help reduce drift in multi-session scenarios by aligning to a server-side map.',
          ),
        ],
      ),
      Topic(
        id: 'performance_opt',
        title: 'Performance Optimization',
        subtitle: 'Frame rate, memory, and rendering efficiency.',
        contentBlocks: [
          const ContentBlock.heading('Performance Optimization'),
          const ContentBlock.body(
            'AR applications must maintain 60 FPS for a comfortable experience. Dropped frames cause visible jitter '
            'and can trigger motion sickness. Optimization is essential.',
          ),
          const ContentBlock.subheading('Rendering Optimization'),
          const ContentBlock.bullet(
            'Reduce polygon count — Use LOD (Level of Detail) for 3D models.',
          ),
          const ContentBlock.bullet(
            'Use texture atlases — Combine multiple textures into one draw call.',
          ),
          const ContentBlock.bullet(
            'Limit real-time shadows — Use baked lighting where possible.',
          ),
          const ContentBlock.bullet(
            'Cull off-screen objects — Don\'t render what the user can\'t see.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('Memory Management'),
          const ContentBlock.bullet('Unload unused assets and textures.'),
          const ContentBlock.bullet(
            'Compress textures (use ASTC/ETC2 for mobile).',
          ),
          const ContentBlock.bullet(
            'Pool and recycle objects instead of instantiating/destroying.',
          ),
          const ContentBlock.subheading('AR-Specific Tips'),
          const ContentBlock.bullet(
            'Limit the number of tracked planes displayed.',
          ),
          const ContentBlock.bullet(
            'Reduce feature point cloud rendering density.',
          ),
          const ContentBlock.bullet(
            'Use lower camera resolution if high-res is not needed.',
          ),
          const ContentBlock.bullet(
            'Throttle plane detection after initial placement is complete.',
          ),
          const ContentBlock.warning(
            'Profile on real devices, not in the editor. AR performance characteristics differ significantly between '
            'desktop simulation and mobile hardware.',
          ),
        ],
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  MODULE 6 — Advanced Topics (Locked)
  // ───────────────────────────────────────────────────────────────
  LearningModule(
    id: 'mod_advanced',
    title: 'Advanced AR Knowledge',
    description: 'Deep-dive topics unlocked after assessments.',
    icon: Icons.lock_rounded,
    order: 6,
    unlockCost: 0,
    requiredQuizId: null,
    topics: [
      Topic(
        id: 'cloud_anchors',
        title: 'Cloud Anchors & Shared AR',
        subtitle: 'Multi-user AR experiences.',
        contentBlocks: [
          const ContentBlock.heading('Cloud Anchors'),
          const ContentBlock.body(
            'Cloud Anchors allow multiple users to share the same AR experience by resolving anchors across devices. '
            'A host device creates an anchor and uploads it to the cloud; other devices resolve the same anchor to '
            'see content in the same real-world location.',
          ),
          const ContentBlock.subheading('Workflow'),
          const ContentBlock.numbered(
            '1. Host creates an anchor and calls hostCloudAnchor().',
          ),
          const ContentBlock.numbered(
            '2. The cloud processes the anchor and returns a Cloud Anchor ID.',
          ),
          const ContentBlock.numbered(
            '3. The host shares this ID with other users (via server, QR code, etc.).',
          ),
          const ContentBlock.numbered(
            '4. Resolving devices call resolveCloudAnchor(id) to place content at the same location.',
          ),
          const ContentBlock.info(
            'Cloud Anchors require good environmental mapping. Ensure the host device scans the area thoroughly before hosting.',
          ),
        ],
      ),
      Topic(
        id: 'depth_occlusion',
        title: 'Depth & Occlusion',
        subtitle: 'Making virtual objects interact with real geometry.',
        contentBlocks: [
          const ContentBlock.heading('Depth API & Occlusion'),
          const ContentBlock.body(
            'The Depth API provides a per-pixel depth map of the real environment, enabling virtual objects to be '
            'occluded by real-world objects. This dramatically improves realism.',
          ),
          const ContentBlock.subheading('Occlusion Types'),
          const ContentBlock.bullet(
            'Environmental Occlusion — Real objects in front hide virtual objects behind them.',
          ),
          const ContentBlock.bullet(
            'Self-Occlusion — Parts of a virtual object occlude other parts correctly.',
          ),
          const ContentBlock.subheading('Implementation'),
          const ContentBlock.numbered(
            '1. Enable the Depth API in your AR session configuration.',
          ),
          const ContentBlock.numbered(
            '2. Access the depth texture from the camera frame.',
          ),
          const ContentBlock.numbered(
            '3. Compare virtual object depth with real-world depth per pixel.',
          ),
          const ContentBlock.numbered(
            '4. Discard virtual fragments that are behind real geometry.',
          ),
          const ContentBlock.warning(
            'The Depth API uses machine learning on-device and may have accuracy limitations on low-end devices.',
          ),
        ],
      ),
      Topic(
        id: 'ar_future',
        title: 'Future of AR',
        subtitle: 'Emerging trends and technologies.',
        contentBlocks: [
          const ContentBlock.heading('The Future of Augmented Reality'),
          const ContentBlock.body(
            'AR technology is rapidly evolving. This section explores upcoming trends and technologies that will shape '
            'the next generation of AR experiences.',
          ),
          const ContentBlock.subheading('Emerging Trends'),
          const ContentBlock.bullet(
            'AR Glasses / Smart Glasses — Hands-free, always-on AR (Apple Vision Pro, Meta Orion).',
          ),
          const ContentBlock.bullet(
            'World-Scale AR — Persistent, city-scale 3D maps for outdoor AR navigation.',
          ),
          const ContentBlock.bullet(
            'AI + AR — Generative AI creating real-time 3D content; AI scene understanding.',
          ),
          const ContentBlock.bullet(
            'WebXR — Browser-based AR without installing native apps.',
          ),
          const ContentBlock.bullet(
            'Haptic Feedback — Tactile sensations for interacting with virtual objects.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('Challenges Ahead'),
          const ContentBlock.bullet(
            'Privacy concerns with always-on cameras and spatial data.',
          ),
          const ContentBlock.bullet(
            'Battery and thermal constraints on mobile devices.',
          ),
          const ContentBlock.bullet(
            'Standardization across platforms and form factors.',
          ),
          const ContentBlock.bullet(
            'Social acceptance of AR devices in public spaces.',
          ),
          const ContentBlock.info(
            'The AR industry is projected to reach \$340 billion by 2028. Understanding these trends positions you '
            'as a forward-thinking AR developer.',
          ),
        ],
      ),
    ],
  ),
];
