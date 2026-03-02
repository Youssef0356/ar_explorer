import '../models/quiz_model.dart';

// ═══════════════════════════════════════════════════════════════════
//  QUIZ DATA — Interview Time Assessments
// ═══════════════════════════════════════════════════════════════════

final Map<String, Quiz> allQuizzes = {
  // ───────────────────────────────────────────────────────────────
  //  QUIZ 1 — Introduction to AR
  // ───────────────────────────────────────────────────────────────
  'quiz_intro': Quiz(
    id: 'quiz_intro',
    moduleId: 'mod_intro',
    title: 'Interview Time: AR Fundamentals',
    questions: [
      const QuizQuestion(
        id: 'q1_1',
        question: 'What distinguishes AR from VR?',
        options: [
          'AR replaces the real world entirely',
          'AR enhances the real world with digital overlays',
          'AR requires a headset to function',
          'AR only works with markers',
        ],
        correctIndex: 1,
        explanation:
            'AR augments the real environment by overlaying digital content, whereas VR replaces the environment entirely.',
      ),
      const QuizQuestion(
        id: 'q1_2',
        question: 'Which of the following is NOT a core technology of ARCore?',
        options: [
          'Motion Tracking',
          'Light Estimation',
          'Face Mesh Generation',
          'Environmental Understanding',
        ],
        correctIndex: 2,
        explanation:
            'ARCore\'s three core technologies are Motion Tracking, Environmental Understanding, and Light Estimation. Face mesh is an additional feature.',
      ),
      const QuizQuestion(
        id: 'q1_3',
        question: 'What does Vuforia use to rate image target quality?',
        options: [
          'Percentage score (0–100%)',
          'Star rating (1–5)',
          'Color analysis',
          'Resolution check',
        ],
        correctIndex: 1,
        explanation:
            'Vuforia rates image targets with 1–5 stars based on the number and distribution of detectable features.',
      ),
      const QuizQuestion(
        id: 'q1_4',
        question: 'What is the primary role of AR Foundation?',
        options: [
          'It replaces ARCore and ARKit entirely',
          'It provides a cross-platform abstraction for AR development',
          'It is a standalone AR rendering engine',
          'It only works on iOS devices',
        ],
        correctIndex: 1,
        explanation:
            'AR Foundation provides a unified API layer that abstracts platform-specific AR SDKs (ARCore, ARKit) in Unity.',
      ),
      const QuizQuestion(
        id: 'q1_5',
        question:
            'Which type of AR uses GPS and sensors to place content without visual markers?',
        options: [
          'Marker-Based AR',
          'Projection-Based AR',
          'Markerless AR',
          'Superimposition AR',
        ],
        correctIndex: 2,
        explanation:
            'Markerless AR relies on GPS, accelerometers, SLAM, and other sensors to position content without physical markers.',
      ),
      const QuizQuestion(
        id: 'q1_6',
        question: 'Which component in AR Foundation manages the AR lifecycle?',
        options: [
          'AR Camera Manager',
          'AR Session',
          'AR Plane Manager',
          'AR Anchor Manager',
        ],
        correctIndex: 1,
        explanation:
            'AR Session manages the overall AR lifecycle including enabling, disabling, and resetting the session.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  QUIZ 2 — Technical Concepts
  // ───────────────────────────────────────────────────────────────
  'quiz_tech': Quiz(
    id: 'quiz_tech',
    moduleId: 'mod_tech',
    title: 'Interview Time: Technical Concepts',
    questions: [
      const QuizQuestion(
        id: 'q2_1',
        question: 'What is Visual-Inertial Odometry (VIO)?',
        options: [
          'A technique for rendering 3D models',
          'Fusion of camera and IMU data for 6DoF tracking',
          'A method to compress AR textures',
          'A network protocol for cloud anchors',
        ],
        correctIndex: 1,
        explanation:
            'VIO combines visual feature tracking from the camera with inertial measurement unit (IMU) data for precise 6 degrees of freedom tracking.',
      ),
      const QuizQuestion(
        id: 'q2_2',
        question: 'What does SLAM stand for?',
        options: [
          'Spatial Layout and Mapping',
          'Simultaneous Localization and Mapping',
          'Surface Light and Material',
          'Sensor-Level Augmented Modeling',
        ],
        correctIndex: 1,
        explanation:
            'SLAM stands for Simultaneous Localization and Mapping — building a map of the environment while tracking position within it.',
      ),
      const QuizQuestion(
        id: 'q2_3',
        question:
            'Which type of surface is MOST challenging for plane detection?',
        options: [
          'Wooden desk with visible grain',
          'Carpet with a pattern',
          'Smooth, transparent glass table',
          'Tiled floor with distinct tiles',
        ],
        correctIndex: 2,
        explanation:
            'Smooth, reflective, or transparent surfaces lack detectable features and are very challenging for plane detection algorithms.',
      ),
      const QuizQuestion(
        id: 'q2_4',
        question: 'What is the purpose of loop closure in SLAM?',
        options: [
          'To close the AR session',
          'To correct accumulated drift when revisiting a known area',
          'To lock the frame rate at 60 FPS',
          'To finalize the 3D model export',
        ],
        correctIndex: 1,
        explanation:
            'Loop closure detects when the device returns to a previously mapped area and corrects the accumulated drift in the map.',
      ),
      const QuizQuestion(
        id: 'q2_5',
        question:
            'Which feature detector is known for being extremely fast at corner detection?',
        options: ['SIFT', 'ORB', 'FAST', 'SURF'],
        correctIndex: 2,
        explanation:
            'FAST (Features from Accelerated Segment Test) is designed for rapid corner detection, making it suitable for real-time AR.',
      ),
      const QuizQuestion(
        id: 'q2_6',
        question: 'Environmental HDR in light estimation provides:',
        options: [
          'Only ambient brightness',
          'A full spherical lighting map for reflections and shadows',
          'Only color temperature',
          'A binary light/dark indicator',
        ],
        correctIndex: 1,
        explanation:
            'Environmental HDR provides a complete spherical environment map that enables realistic reflections, specular highlights, and shadows on virtual objects.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  QUIZ 3 — Development
  // ───────────────────────────────────────────────────────────────
  'quiz_dev': Quiz(
    id: 'quiz_dev',
    moduleId: 'mod_dev',
    title: 'Interview Time: AR Development',
    questions: [
      const QuizQuestion(
        id: 'q3_1',
        question: 'In Vuforia, what does "Extended Tracking" allow?',
        options: [
          'Tracking targets from a greater distance',
          'Content persistence even when the target leaves the camera view',
          'Tracking multiple targets simultaneously',
          'Higher resolution target images',
        ],
        correctIndex: 1,
        explanation:
            'Extended Tracking allows AR content to remain visible and tracked even after the original image target is no longer in the camera\'s field of view.',
      ),
      const QuizQuestion(
        id: 'q3_2',
        question: 'In ARCore, what is the purpose of a Raycast (hit test)?',
        options: [
          'To measure the brightness of the scene',
          'To find intersections between a 2D screen point and real-world geometry',
          'To compress the camera feed',
          'To transfer data to the cloud',
        ],
        correctIndex: 1,
        explanation:
            'Raycasting sends a virtual ray from a 2D screen point into the 3D world to detect intersections with tracked planes or feature points.',
      ),
      const QuizQuestion(
        id: 'q3_3',
        question: 'Which AR Foundation manager handles surface detection?',
        options: [
          'ARAnchorManager',
          'ARRaycastManager',
          'ARPlaneManager',
          'ARCameraManager',
        ],
        correctIndex: 2,
        explanation:
            'ARPlaneManager is responsible for detecting and visualizing planes (horizontal and vertical surfaces) in the real world.',
      ),
      const QuizQuestion(
        id: 'q3_4',
        question:
            'Why should you filter hit results by trackable type in ARCore?',
        options: [
          'To reduce battery usage',
          'To prioritize stable plane hits over less reliable feature point hits',
          'To enable cloud anchors',
          'To improve camera resolution',
        ],
        correctIndex: 1,
        explanation:
            'Plane hits provide more stable and reliable placement than feature point hits. Filtering ensures better user experience.',
      ),
      const QuizQuestion(
        id: 'q3_5',
        question: 'What does AR Session Origin define in AR Foundation?',
        options: [
          'The UI layout of the application',
          'The transform space and origin point for AR content',
          'The network configuration for cloud features',
          'The target image database location',
        ],
        correctIndex: 1,
        explanation:
            'AR Session Origin defines the world coordinate system\'s origin point and transform space in which AR content is placed.',
      ),
      const QuizQuestion(
        id: 'q3_6',
        question:
            'What should your app do when Vuforia reports a TRACKING_LOST state?',
        options: [
          'Immediately close the app',
          'Continue rendering content normally',
          'Show user guidance to re-find the target',
          'Restart the device',
        ],
        correctIndex: 2,
        explanation:
            'When tracking is lost, the app should provide user guidance (e.g., "Point camera at the target") to help recover tracking.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  QUIZ 4 — Stabilization & Performance
  // ───────────────────────────────────────────────────────────────
  'quiz_stab': Quiz(
    id: 'quiz_stab',
    moduleId: 'mod_stab',
    title: 'Interview Time: Stabilization & Performance',
    questions: [
      const QuizQuestion(
        id: 'q4_1',
        question:
            'What is the minimum frame rate recommended for a comfortable AR experience?',
        options: ['24 FPS', '30 FPS', '60 FPS', '120 FPS'],
        correctIndex: 2,
        explanation:
            'AR applications should maintain 60 FPS to prevent jitter and motion sickness. Lower frame rates cause visible tracking artifacts.',
      ),
      const QuizQuestion(
        id: 'q4_2',
        question: 'What causes positional drift in AR?',
        options: [
          'Too many 3D models in the scene',
          'Accumulated small tracking errors over time',
          'Incorrect texture formats',
          'High screen resolution',
        ],
        correctIndex: 1,
        explanation:
            'Drift occurs when small errors in position estimation compound over time, causing virtual content to gradually shift from its intended position.',
      ),
      const QuizQuestion(
        id: 'q4_3',
        question: 'Which technique helps reduce rendering overhead in AR?',
        options: [
          'Increasing polygon count for realism',
          'Using real-time ray tracing',
          'Using LOD (Level of Detail) for 3D models',
          'Adding more light sources',
        ],
        correctIndex: 2,
        explanation:
            'LOD reduces polygon count based on distance from the camera, significantly reducing rendering overhead while maintaining visual quality.',
      ),
      const QuizQuestion(
        id: 'q4_4',
        question: 'Why should you limit the number of active anchors?',
        options: [
          'Anchors use significant storage space',
          'Each anchor adds computational overhead for tracking',
          'Anchors slow down the camera feed',
          'The OS limits anchor count to 5',
        ],
        correctIndex: 1,
        explanation:
            'Each active anchor requires computational resources to maintain and update its pose. Too many anchors degrade tracking performance.',
      ),
      const QuizQuestion(
        id: 'q4_5',
        question:
            'What should your app display when tracking state is PAUSED/LIMITED?',
        options: [
          'A blank screen',
          'A loading spinner replacing the camera feed',
          'The camera feed with a cautionary overlay message',
          'A settings menu',
        ],
        correctIndex: 2,
        explanation:
            'Never hide the camera feed. Show a translucent guidance overlay to help the user restore tracking without disorienting them.',
      ),
      const QuizQuestion(
        id: 'q4_6',
        question:
            'Which texture compression format is recommended for mobile AR?',
        options: ['PNG (uncompressed)', 'BMP', 'ASTC/ETC2', 'TIFF'],
        correctIndex: 2,
        explanation:
            'ASTC and ETC2 are GPU-native compressed formats optimized for mobile devices, reducing memory usage while maintaining quality.',
      ),
    ],
  ),
};
