import '../models/quiz_model.dart';

// ═══════════════════════════════════════════════════════════════════
//  QUIZ DATA — Interview Time Assessments
//  NOTE: All options are kept at similar length so correct answers
//  are NOT identifiable by simply picking the longest option.
// ═══════════════════════════════════════════════════════════════════

final Map<String, Quiz> allQuizzes = {
  // ───────────────────────────────────────────────────────────────
  //  QUIZ — AR Basics (Definitions)
  // ───────────────────────────────────────────────────────────────
  'quiz_intro_basics': Quiz(
    id: 'quiz_intro_basics',
    moduleId: 'intro_ar_basics',
    title: 'Checkup: AR Basics & Vocabulary',
    questions: [
      const QuizQuestion(
        id: 'q_intro_1',
        question: 'Which statement best describes Augmented Reality (AR)?',
        options: [
          'A fully virtual world that replaces the user\'s view of reality entirely',
          'Digital content overlaid onto the real world in real time',
          'Any 3D animation rendered on a screen or display device',
          'A 360° video experience played back without user interaction',
        ],
        correctIndex: 1,
        explanation:
            'AR keeps the real world visible and adds digital content that responds to your movement.',
      ),
      const QuizQuestion(
        id: 'q_intro_2',
        question: 'What is the MAIN difference between AR and VR?',
        options: [
          'AR runs only on phones while VR requires a dedicated PC setup',
          'AR overlays digital content on the real world; VR replaces it entirely',
          'AR consumes significantly less battery power than VR in all cases',
          'VR always requires physical hand controllers to function properly',
        ],
        correctIndex: 1,
        explanation:
            'In VR you only see a virtual world. In AR the physical environment is still your primary reference.',
      ),
      const QuizQuestion(
        id: 'q_intro_3',
        question: 'Which term is an umbrella that includes AR, VR and MR?',
        options: ['XR (Extended Reality)', 'GPU (Graphics Processing Unit)', 'SLAM (Simultaneous Localization)', 'FOV (Field of View)'],
        correctIndex: 0,
        explanation:
            'XR (Extended Reality) is a broad label that covers AR, VR and MR.',
      ),
      const QuizQuestion(
        id: 'q_intro_4',
        question:
            'Which of the following is the BEST example of a true AR experience?',
        options: [
          'A 3D logo always centered on screen regardless of how you move',
          'A face filter that tracks and stays locked to the user\'s head',
          'A 360° video playing in a loop on a standard flat display screen',
          'A static 3D model embedded and rendered inside a PDF document',
        ],
        correctIndex: 1,
        explanation:
            'Tracking and registration are key: the digital content must stay aligned with real-world motion.',
      ),
      const QuizQuestion(
        id: 'q_intro_5',
        question: 'Which misconception is MOST common among AR beginners?',
        options: [
          'AR is only applicable for enterprise and industrial use cases',
          'AR always requires a headset and cannot run on smartphones at all',
          'AR has no practical use in educational or training environments',
          'AR and VR use completely different underlying mathematical models',
        ],
        correctIndex: 1,
        explanation:
            'Many powerful AR solutions run entirely on smartphones and tablets.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  QUIZ — Spatial UX & Design
  // ───────────────────────────────────────────────────────────────
  'quiz_spatial_ux': Quiz(
    id: 'quiz_spatial_ux',
    moduleId: 'mod_spatial_ux',
    title: 'Checkup: Spatial UX & Design',
    passingScore: 70,
    questions: [
      const QuizQuestion(
        id: 'q_ux_1',
        question: 'Which of the following is NOT one of the 5 pillars of spatial UX?',
        options: [
          'Environment Safety',
          'Progressive Disclosure',
          'Keyboard-only Navigation',
          'Natural Gestures',
        ],
        correctIndex: 2,
        explanation: 'Spatial UX focuses on natural interactions (gestures, movement) and environmental safety rather than traditional 2D input methods.',
      ),
      const QuizQuestion(
        id: 'q_ux_2',
        question: 'What is the recommended "comfort zone" for fixed AR UI elements?',
        options: [
          '0.3m – 0.8m (arm\'s reach or closer to the viewer)',
          '1.25m – 2.0m at a slight downward angle from the user',
          '3.0m – 5.0m in the middle distance of the environment',
          'Directly on the detected floor plane below the user\'s feet',
        ],
        correctIndex: 1,
        explanation: 'Placing UI between 1.25m and 2m at a slight downward angle prevents eye strain and maintains comfort.',
      ),
      const QuizQuestion(
        id: 'q_ux_3',
        question: 'What does "Billboarding" do for a virtual UI panel?',
        options: [
          'It scales the panel up to fill the entire field of view',
          'It always rotates the panel to face toward the user',
          'It anchors the panel flush against a detected physical wall',
          'It fades the panel out when the user moves further away',
        ],
        correctIndex: 1,
        explanation: 'Billboarding ensures that floating text or UI remains readable regardless of the user\'s position relative to the object.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  QUIZ 1 — Introduction to AR
  // ───────────────────────────────────────────────────────────────
  'quiz_intro': Quiz(
    id: 'quiz_intro',
    moduleId: 'mod_intro',
    title: 'Mastery Interview: Spatial AR',
    questions: [
      const QuizQuestion(
        id: 'q_milgram_spectrum',
        question:
            'According to Paul Milgram, what does Mixed Reality (MR) encompass?',
        options: [
          'Only high-end VR headsets with six-axis motion tracking',
          'The entire spectrum between the Physical World and Virtual Reality',
          'Only smartphone AR apps using the device\'s rear camera',
          '3D rendering pipelines that operate without any spatial tracking',
        ],
        correctIndex: 1,
        explanation:
            'MR is the broader technical term for the entire middle ground where physical and digital objects co-exist and interact.',
      ),
      const QuizQuestion(
        id: 'q_hmd_performance',
        question:
            'Why do industrial sectors prefer Head-Mounted Displays (HMDs) over Handheld AR for guided assembly?',
        options: [
          'HMDs have a much lower total cost of ownership per device',
          'HMDs provide hands-free workflows and a higher sense of presence',
          'HMDs achieve significantly longer battery life during long shifts',
          'HMDs eliminate the need for any Wi-Fi or network connectivity',
        ],
        correctIndex: 1,
        explanation:
            'Hands-free operation is critical for industrial workers who must use their hands for assembly while viewing digital instructions.',
      ),
      const QuizQuestion(
        id: 'q_webar_friction',
        question: 'What is the "Friction Factor" in mobile AR deployment?',
        options: [
          'The physical heat generated by the GPU during heavy AR sessions',
          'The significant user drop-off caused by requiring a native app download',
          'The drag coefficient affecting how smoothly virtual objects are placed',
          'The difficulty users experience trying to scan a printed QR code',
        ],
        correctIndex: 1,
        explanation:
            'WebAR mitigates friction by allowing users to access content instantly through a browser without an App Store download.',
      ),
      const QuizQuestion(
        id: 'q_wasm_webar',
        question:
            'How do WebAR frameworks like 8th Wall maintain 60FPS tracking within a browser sandbox?',
        options: [
          'By dynamically reducing the screen resolution during tracking phases',
          'By using WebAssembly (Wasm) to run computer vision at near-native speed',
          'By disabling the camera feed when full tracking is not required',
          'By offloading all tracking computation to remote cloud servers',
        ],
        correctIndex: 1,
        explanation:
            'Wasm allows near-native execution speed for complex tracking algorithms within the browser environment.',
      ),
      const QuizQuestion(
        id: 'q_hybrid_occlusion',
        question: 'What is "Z-fighting" in the context of AR rendering?',
        options: [
          'Two AR users competing to place an anchor at the same world point',
          'Two surfaces at the same depth flickering as they compete for rendering priority',
          'A failure in the accelerometer causing orientation drift over time',
          'A screen lag artifact caused by critically low device battery level',
        ],
        correctIndex: 1,
        explanation:
            'Z-fighting is a visual artifact where the engine cannot determine which object is in front of the other due to identical depth values.',
      ),
      const QuizQuestion(
        id: 'q_asa_benefit',
        question:
            'What is a primary advantage of Azure Spatial Anchors (ASA) for large-scale enterprise?',
        options: [
          'It is provided completely free of charge for all enterprise customers',
          'It enables cloud-based persistence and cross-platform multi-device collaboration',
          'It directly increases the optical field of view of the connected headset',
          'It automatically deletes outdated map data after a configurable time period',
        ],
        correctIndex: 1,
        explanation:
            'ASA enables multi-device shared AR by storing the spatial map in the cloud, allowing an iOS device and a HoloLens to see the same content.',
      ),
      const QuizQuestion(
        id: 'q_relocalization',
        question: 'What happens during "Relocalization" in a SLAM system?',
        options: [
          'The entire device operating system performs a forced restart',
          'The system matches the current view to a stored map to re-establish its pose',
          'The camera hardware automatically switches from RGB to infrared mode',
          'The GPS coordinates of the device are refreshed from the network',
        ],
        correctIndex: 1,
        explanation:
            'Relocalization is the "Aha!" moment when the device recognizes where it is based on previously mapped features.',
      ),
      const QuizQuestion(
        id: 'q_progressive_disclosure',
        question:
            'What does the UX principle of "Progressive Disclosure" aim to solve in AR?',
        options: [
          'High hardware latency caused by slow sensor fusion pipelines',
          'HUD clutter and cognitive overload from too much simultaneous information',
          'Short battery life caused by continuous high-intensity GPU rendering',
          'Slow internet speeds during cloud anchor upload and resolution phases',
        ],
        correctIndex: 1,
        explanation:
            'By revealing details only upon demand, you keep the user\'s field of view clear and focus their attention on critical tasks.',
      ),
      const QuizQuestion(
        id: 'q_klm_visionpro',
        question:
            'In the KLM Royal Dutch Airlines case study, why was AR used on the Apple Vision Pro?',
        options: [
          'To entertain aircraft passengers with immersive content during long flights',
          'To train technicians on complex engine repairs using full-fidelity 3D overlays',
          'To speed up the check-in and boarding ticket scanning process significantly',
          'To automatically weigh and scan passenger luggage at the gate terminals',
        ],
        correctIndex: 1,
        explanation:
            'AR training with high-fidelity 3D overlays significantly reduces errors and accelerates learning in complex mechanical tasks.',
      ),
      const QuizQuestion(
        id: 'q_registration_failure',
        question:
            'What is the technical term for virtual objects "sliding" or "jumping" due to tracking errors?',
        options: ['Latency', 'Drift', 'Z-Fighting', 'Ghosting'],
        correctIndex: 1,
        explanation:
            'Drift occurs when the tracking system accumulates small errors, causing the virtual content to lose its alignment with the physical world.',
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
          'A GPU technique for rendering photorealistic 3D models in real time',
          'Fusion of camera and IMU data to achieve precise 6DoF pose tracking',
          'A lossless compression method for reducing AR texture file sizes',
          'A network protocol used for synchronizing cloud anchors across devices',
        ],
        correctIndex: 1,
        explanation:
            'VIO combines visual feature tracking from the camera with inertial measurement unit (IMU) data for precise 6 degrees of freedom tracking.',
      ),
      const QuizQuestion(
        id: 'q2_2',
        question: 'What does SLAM stand for?',
        options: [
          'Spatial Layout and Augmented Mapping',
          'Simultaneous Localization and Mapping',
          'Surface Light and Ambient Modelling',
          'Sensor-Level Augmented Measurement',
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
          'Wooden desk with clearly visible natural grain texture',
          'Carpet floor covered in a busy multi-colour repeating pattern',
          'Smooth, transparent glass table with no visible surface features',
          'Tiled bathroom floor with distinct, regularly spaced grout lines',
        ],
        correctIndex: 2,
        explanation:
            'Smooth, reflective, or transparent surfaces lack detectable features and are very challenging for plane detection algorithms.',
      ),
      const QuizQuestion(
        id: 'q2_4',
        question: 'What is the purpose of loop closure in SLAM?',
        options: [
          'To cleanly terminate the current AR session and free all resources',
          'To correct accumulated drift when the device revisits a known area',
          'To lock the rendering frame rate at a consistent 60 FPS on all devices',
          'To finalize and export the current 3D point cloud map to storage',
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
          'Only a single ambient brightness value measured in lux',
          'A full spherical lighting map enabling realistic reflections and shadows',
          'Only the colour temperature of the dominant light source in the scene',
          'A simple binary indicator of whether the environment is lit or dark',
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
          'Tracking image targets from a much greater physical distance away',
          'Content persistence even when the target leaves the camera\'s field of view',
          'Detecting multiple distinct image targets simultaneously in one scene',
          'Increasing the resolution of the target image database on device',
        ],
        correctIndex: 1,
        explanation:
            'Extended Tracking allows AR content to remain visible and tracked even after the original image target is no longer in the camera\'s field of view.',
      ),
      const QuizQuestion(
        id: 'q3_2',
        question: 'In ARCore, what is the purpose of a Raycast (hit test)?',
        options: [
          'To measure and report the current ambient brightness of the scene',
          'To find intersections between a 2D screen point and real-world geometry',
          'To compress the live camera feed for efficient network transmission',
          'To upload local anchor feature data to the cloud anchor service',
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
          'Filtering by type reduces the overall battery consumption during sessions',
          'Plane hits are more stable and reliable than raw feature point hits',
          'Filtering is required to enable cloud anchor hosting functionality',
          'It directly improves the resolution of the live camera preview feed',
        ],
        correctIndex: 1,
        explanation:
            'Plane hits provide more stable and reliable placement than feature point hits. Filtering ensures better user experience.',
      ),
      const QuizQuestion(
        id: 'q3_5',
        question: 'What does AR Session Origin define in AR Foundation?',
        options: [
          'The layout and anchoring behaviour of all on-screen UI elements',
          'The world coordinate system origin and transform space for AR content',
          'The network endpoint used when connecting to the cloud anchor service',
          'The file path where the Vuforia image target database is located',
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
          'Force-quit the application and return the user to the home screen',
          'Continue rendering all virtual content exactly as it was before',
          'Display guidance to help the user re-find and re-scan the target',
          'Restart the entire device to re-initialize the Vuforia engine fresh',
        ],
        correctIndex: 2,
        explanation:
            'When tracking is lost, the app should provide user guidance (e.g., "Point camera at the target") to help recover tracking.',
      ),
      const QuizQuestion(
        id: 'q3_7',
        question: 'Which framework is Apple\'s modern standard for AR rendering?',
        options: [
          'SceneKit (older general-purpose 3D framework)',
          'RealityKit (purpose-built for AR with PBR and LiDAR)',
          'Metal (low-level GPU API for custom shader pipelines)',
          'UIKit (the primary 2D interface and layout framework)',
        ],
        correctIndex: 1,
        explanation: 'RealityKit is purpose-built for AR, offering native LiDAR support and physically-based rendering.',
      ),
      const QuizQuestion(
        id: 'q3_8',
        question: 'What does setting arcore:required in the AndroidManifest do?',
        options: [
          'It forces the app to run at a higher priority in the Android task scheduler',
          'It filters the app so only AR-compatible devices see it on Google Play',
          'It automatically requests the CAMERA permission on behalf of the app',
          'It enables a special 60 FPS turbo rendering mode for ARCore scenes',
        ],
        correctIndex: 1,
        explanation: '"Required" ensures the app is only visible to users whose devices support ARCore.',
      ),
      const QuizQuestion(
        id: 'q3_9',
        question: 'What is the "AR Manager" pattern used for?',
        options: [
          'Automating in-app purchase and subscription management logic',
          'Separating spatial tracking logic cleanly from the UI layer',
          'Scaling 3D models proportionally based on the detected plane size',
          'Automatically optimizing battery consumption across AR sessions',
        ],
        correctIndex: 1,
        explanation: 'The AR Manager acts as a single controller for the AR session, keeping your UI code clean and decoupled.',
      ),
      const QuizQuestion(
        id: 'q3_10',
        question: 'Where must you define NSCameraUsageDescription on iOS?',
        options: [
          'In the AppDelegate.swift file\'s application launch method',
          'In Info.plist as a required privacy usage description string',
          'In the Podfile as a custom CocoaPods configuration entry',
          'Inside Assets.xcassets as a special metadata configuration key',
        ],
        correctIndex: 1,
        explanation: 'iOS requires this string in the Info.plist to explain why the app needs camera access, or it will crash.',
      ),
      const QuizQuestion(
        id: 'q3_11',
        question: 'Which feature allows virtual objects to render BEHIND people?',
        options: [
          'Depth API / People Occlusion using ML or LiDAR segmentation',
          'Z-Fighting detection which resolves depth conflicts per-pixel',
          'LOD (Level of Detail) which swaps geometry based on distance',
          'Frustum Culling which removes objects outside the camera view',
        ],
        correctIndex: 0,
        explanation: 'People Occlusion uses ML or LiDAR to segment humans, allowing virtual content to be hidden behind them.',
      ),
      const QuizQuestion(
        id: 'q3_12',
        question: 'Can you test ARCore tracking in the standard Android Emulator?',
        options: [
          'Yes, the standard emulator supports full ARCore tracking natively',
          'No, real tracking requires physical hardware sensors and a camera',
          'Yes, but tracking data is rendered only in grayscale in the emulator',
          'Yes, using the special "AR Mode" plugin available in the AVD manager',
        ],
        correctIndex: 1,
        explanation: 'While basic logic can be tested in simulators, true AR tracking requires physical hardware sensors (IMU) and a real camera.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  QUIZ 6 — Stability & Performance Deep Dive
  // ───────────────────────────────────────────────────────────────
  'quiz_stability_performance': Quiz(
    id: 'quiz_stability_performance',
    moduleId: 'mod_stability_performance',
    title: 'Stability & Performance Quiz',
    passingScore: 70,
    questions: [
      const QuizQuestion(
        id: 'q_stab_perf_1',
        question: 'What is the minimum frame rate recommended for a comfortable AR experience?',
        options: ['24 FPS', '30 FPS', '60 FPS', '120 FPS'],
        correctIndex: 2,
        explanation: 'AR applications should maintain 60 FPS to prevent jitter and motion sickness. Lower frame rates cause visible tracking artifacts.',
      ),
      const QuizQuestion(
        id: 'q_stab_perf_2',
        question: 'What causes positional drift in AR?',
        options: [
          'Placing too many high-polygon 3D models within a single AR scene',
          'Accumulated small tracking errors compounding over time in the session',
          'Using incorrect texture formats that cause GPU memory overflow issues',
          'Setting the screen resolution too high for the device\'s GPU to handle',
        ],
        correctIndex: 1,
        explanation: 'Drift occurs when small errors in position estimation compound over time, causing virtual content to gradually shift from its intended position.',
      ),
      const QuizQuestion(
        id: 'q_stab_perf_3',
        question: 'What is a "Draw Call"?',
        options: [
          'A touch input event triggered when the user taps to draw a line',
          'A command from the CPU instructing the GPU to render a set of polygons',
          'A background network request downloading a texture from a CDN server',
          'An OS-level callback that saves the current rendered frame to storage',
        ],
        correctIndex: 1,
        explanation: 'Draw calls are expensive. Every time a new material or object needs rendering, the CPU must prepare and send a draw call to the GPU.',
      ),
      const QuizQuestion(
        id: 'q_stab_perf_4',
        question: 'What is the most effective way to reduce Draw Calls?',
        options: [
          'Increase the triangle count to allow the GPU to batch more geometry',
          'Lower the screen brightness so fewer pixels require fragment shading',
          'Combine multiple textures into a single Texture Atlas to enable batching',
          'Switch to higher resolution textures to reduce per-object draw overhead',
        ],
        correctIndex: 2,
        explanation: 'By combining multiple textures into an atlas, multiple objects can share the same material, allowing the CPU to send them to the GPU in a single draw call.',
      ),
      const QuizQuestion(
        id: 'q_stab_perf_5',
        question: 'What is Thermal Throttling?',
        options: [
          'The device lowering CPU/GPU clock speeds automatically to prevent overheating',
          'A hardware mechanism that pre-warms the battery in cold weather conditions',
          'A real-time rendering technique used to simulate fire and heat distortion effects',
          'A reduction in available network bandwidth when the connection is congested',
        ],
        correctIndex: 0,
        explanation: 'AR is extremely demanding. When a phone overheats, the OS throttles the processor, causing frame rates to drop drastically (stuttering).',
      ),
      const QuizQuestion(
        id: 'q_stab_perf_6',
        question: 'Which tool would you use to profile CPU and Memory usage in a Unity AR Foundation project?',
        options: [
          'Google Chrome DevTools (browser profiler for JavaScript applications)',
          'Unity Profiler (built-in CPU, GPU, memory and rendering analysis tool)',
          'Adobe Photoshop (image editing software for texture creation workflows)',
          'Postman (HTTP client used for testing and documenting REST APIs)',
        ],
        correctIndex: 1,
        explanation: 'The Unity Profiler provides deep insights into CPU time, GPU rendering, memory allocation, and garbage collection spikes.',
      ),
      const QuizQuestion(
        id: 'q_stab_perf_7',
        question: 'Why should you limit the number of active anchors?',
        options: [
          'Anchors use significant persistent storage space on the device',
          'Each active anchor adds computational overhead for pose tracking',
          'Active anchors slow down the live camera feed frame capture rate',
          'The operating system enforces a hard limit of five anchors maximum',
        ],
        correctIndex: 1,
        explanation: 'Each active anchor requires computational resources to maintain and update its pose. Too many anchors degrade tracking performance.',
      ),
      const QuizQuestion(
        id: 'q_stab_perf_8',
        question: 'Why are transparent (alpha-blended) materials bad for mobile AR performance?',
        options: [
          'Transparent materials always look visually unrealistic in AR scenes',
          'They cause overdraw because each transparent pixel is rendered multiple times',
          'Transparency causes SLAM tracking to lose visual features in the scene',
          'Alpha-blended textures occupy much more disk storage space than opaque ones',
        ],
        correctIndex: 1,
        explanation: 'Overdraw occurs when a pixel on the screen is rendered multiple times in a single frame. Heavy use of transparencies (like dense particle effects) kills mobile GPU performance.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  QUIZ — Coordinate Systems Foundations
  // ───────────────────────────────────────────────────────────────
  'quiz_foundations_coords': Quiz(
    id: 'quiz_foundations_coords',
    moduleId: 'foundations_coordinate_systems',
    title: 'Checkup: Coordinate Systems for AR',
    questions: [
      const QuizQuestion(
        id: 'q_coords_1',
        question: 'What is World Space in AR?',
        options: [
          'A 2D pixel grid where all on-screen UI buttons and panels live',
          'A stable 3D coordinate system anchored to the physical environment',
          'The coordinate system of the phone\'s raw pixel-based screen display',
          'The local XYZ axes defined at the center of a specific 3D model',
        ],
        correctIndex: 1,
        explanation:
            'World space represents the real environment; anchors and planes are defined there.',
      ),
      const QuizQuestion(
        id: 'q_coords_2',
        question: 'Camera Space is best described as:',
        options: [
          'A coordinate system with its origin at the room\'s geometric center',
          'A moving space centered on the device camera, looking forward along Z',
          'A fixed coordinate system used exclusively for rendering UI menus',
          'A GPS-referenced global coordinate system tied to latitude/longitude',
        ],
        correctIndex: 1,
        explanation:
            'In camera space, the origin sits at the camera and the forward axis points along its viewing direction.',
      ),
      const QuizQuestion(
        id: 'q_coords_3',
        question:
            'Screen Space coordinates are MOST directly used for which action?',
        options: [
          'Defining the precise world position and rotation of AR anchors',
          'Describing the GPS latitude/longitude position of the user outdoors',
          'Handling touch input positions and the layout of 2D UI elements',
          'Storing compressed 3D mesh geometry data in binary scene files',
        ],
        correctIndex: 2,
        explanation:
            'Screen space is a 2D coordinate system for pixels and UI elements — and for touch positions before they are converted to rays.',
      ),
      const QuizQuestion(
        id: 'q_coords_4',
        question:
            'Placing an object in camera space instead of world space will MOST LIKELY result in:',
        options: [
          'The object remaining perfectly fixed in the room as you walk around',
          'The object "sticking" to the camera and moving wherever you look',
          'The object becoming permanently invisible to the rendering pipeline',
          'The app crashing immediately with a null pointer reference exception',
        ],
        correctIndex: 1,
        explanation:
            'Content in camera space follows the camera; it does not stay anchored to the room.',
      ),
      const QuizQuestion(
        id: 'q_coords_5',
        question:
            'Which question should you ask first when debugging a weird AR position/rotation?',
        options: [
          '"Is my texture using the correct GPU compression format?"',
          '"How many draw calls is my current scene generating per frame?"',
          '"In which coordinate system am I currently working right now?"',
          '"What is the exact field of view angle of the AR headset I\'m using?"',
        ],
        correctIndex: 2,
        explanation:
            'Most early bugs come from mixing spaces. Knowing which coordinate system you are in is step one.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  QUIZ 6 — Advanced AR Knowledge
  // ───────────────────────────────────────────────────────────────
  'quiz_advanced_ar': Quiz(
    id: 'quiz_advanced_ar',
    moduleId: 'mod_advanced',
    title: 'Advanced AR Knowledge',
    passingScore: 70,
    questions: [
      const QuizQuestion(
        id: 'q_adv_1',
        question: 'What is the main benefit of LiDAR in AR headsets?',
        options: [
          'It synthesizes realistic spatial audio that reacts to room geometry',
          'It generates a high-fidelity instant 3D mesh of the environment',
          'It entirely replaces the need for a front-facing RGB camera sensor',
          'It projects visible holograms directly into the air without a display',
        ],
        correctIndex: 1,
        explanation: 'LiDAR uses light pulses to measure distance, instantly creating a precise 3D mesh for accurate occlusion and physics.',
      ),
      const QuizQuestion(
        id: 'q_adv_2',
        question: 'What is Dynamic Occlusion?',
        options: [
          'Hiding virtual objects behind a pre-scanned static environmental mesh',
          'Using per-frame depth data to hide virtual objects behind moving real objects',
          'A networking technique that masks latency in multiplayer AR sessions',
          'Dimming the display screen brightness to extend the device battery life',
        ],
        correctIndex: 1,
        explanation: 'Dynamic occlusion leverages machine learning or LiDAR to infer depth per-frame, hiding AR objects behind moving people or objects.',
      ),
      const QuizQuestion(
        id: 'q_adv_3',
        question: 'Which of the following creates a "Shared Experience" rather than just Persistence?',
        options: [
          'Leaving a personal 3D sticky note for someone to find the next day',
          'Two users in the same room seeing the same virtual object in real time',
          'Saving an offline spatial map of your living room for personal use later',
          'Reducing the render resolution to improve frame rate on older hardware',
        ],
        correctIndex: 1,
        explanation: 'Shared experiences involve real-time synchronization between multiple devices in the same physical space.',
      ),
      const QuizQuestion(
        id: 'q_adv_4',
        question: 'What is a spatial anchor?',
        options: [
          'A printed QR code affixed to a physical surface as a visual marker',
          'A fixed coordinate in the real world that a SLAM system tracks over time',
          'The focal length setting of the camera used for depth measurement',
          'A persistent UI button that remains docked at the bottom of the screen',
        ],
        correctIndex: 1,
        explanation: 'Spatial anchors provide a common reference point in the physical world to tie virtual objects to.',
      ),
      const QuizQuestion(
        id: 'q_adv_5',
        question: 'What happens when a SLAM system "relocalizes"?',
        options: [
          'The app\'s language and locale settings are automatically updated',
          'The system uses GPS satellites to pinpoint the device\'s global position',
          'It matches the current camera view to a stored map to determine location',
          'The device disconnects from the internet and switches to offline mode',
        ],
        correctIndex: 2,
        explanation: 'Relocalization is the process of comparing current camera frames to a saved map to regain tracking after it was lost or closed.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  QUIZ 7 — WebAR
  // ───────────────────────────────────────────────────────────────
  'quiz_webar': Quiz(
    id: 'quiz_webar',
    moduleId: 'mod_webar',
    title: 'WebAR Fundamentals Quiz',
    passingScore: 70,
    questions: [
      const QuizQuestion(
        id: 'q_webar_1',
        question: 'What is the primary advantage of WebAR over native apps?',
        options: [
          'WebAR delivers higher tracking accuracy than native SDKs on all devices',
          'Zero installation friction — the experience runs directly in the browser',
          'WebAR provides full unrestricted access to the device\'s LiDAR sensors',
          'WebAR includes built-in offline caching with no connectivity required',
        ],
        correctIndex: 1,
        explanation: 'WebAR eliminates the need for app store downloads, making it ideal for marketing and quick engagements.',
      ),
      const QuizQuestion(
        id: 'q_webar_2',
        question: 'Which browser API is the emerging standard for native browser AR/VR?',
        options: [
          'WebGL (low-level GPU rendering API for browser graphics)',
          'WebXR Device API (the W3C standard for browser AR and VR)',
          'HTML5 Canvas (a 2D drawing surface built into all browsers)',
          'WebRTC (peer-to-peer media streaming and data protocol)',
        ],
        correctIndex: 1,
        explanation: 'The WebXR Device API is the W3C standard for accessing AR and VR capabilities natively via the browser.',
      ),
      const QuizQuestion(
        id: 'q_webar_3',
        question: 'What is WebAssembly (Wasm) primarily used for in WebAR?',
        options: [
          'Defining visual styles and layout properties for AR user interface buttons',
          'Running complex computer vision algorithms at near-native browser speed',
          'Establishing secure WebSocket connections to remote tracking servers',
          'Decoding and playing back spatial audio files inside the browser sandbox',
        ],
        correctIndex: 1,
        explanation: 'Wasm allows C/C++ computer vision libraries (like SLAM engines) to run in the browser with performance close to native apps.',
      ),
      const QuizQuestion(
        id: 'q_webar_4',
        question: 'Why is model compression (like Draco) critical for WebAR?',
        options: [
          'Compression increases the visual polygon count of streamed 3D models',
          'It minimizes asset download times since no app pre-downloads content',
          'It enhances the physical accuracy of 3D model collision meshes in scenes',
          'WebGL only accepts Draco-compressed geometry as a mandatory requirement',
        ],
        correctIndex: 1,
        explanation: 'Because the user isn\'t downloading an app beforehand, all 3D assets must be downloaded on-the-fly. Small file sizes are essential.',
      ),
      const QuizQuestion(
        id: 'q_webar_5',
        question: 'What does 8th Wall provide that native WebXR does not?',
        options: [
          'A fully proprietary 3D rendering engine built on a custom GPU pipeline',
          'A managed cloud hosting service for all HTML and JavaScript files',
          'SLAM tracking that works on almost any smartphone browser without needing ARCore/ARKit',
          'Direct unrestricted programmatic access to the phone\'s raw battery API',
        ],
        correctIndex: 2,
        explanation: '8th Wall\'s custom SLAM engine runs purely in JavaScript/Wasm, giving it broader device compatibility than WebXR which requires ARCore/ARKit underneath.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  QUIZ 8 — OpenXR Standard
  // ───────────────────────────────────────────────────────────────
  'quiz_openxr': Quiz(
    id: 'quiz_openxr',
    moduleId: 'mod_openxr',
    title: 'OpenXR Quiz',
    passingScore: 70,
    questions: [
      const QuizQuestion(
        id: 'q_openxr_1',
        question: 'What problem does OpenXR primarily solve?',
        options: [
          'Low and inconsistent frame rates experienced across VR headsets',
          'API fragmentation requiring separate code for each AR/VR platform',
          'Poor compression ratios in existing 3D model file format standards',
          'Excessive battery drain caused by intensive XR rendering workloads',
        ],
        correctIndex: 1,
        explanation: 'Before OpenXR, developers had to write custom code for Oculus, SteamVR, WMR, etc. OpenXR provides a single standard API.',
      ),
      const QuizQuestion(
        id: 'q_openxr_2',
        question: 'Which organization develops and maintains the OpenXR standard?',
        options: [
          'Google (the developer of ARCore and the Android platform)',
          'Apple (the creator of ARKit and the Vision Pro headset)',
          'The Khronos Group (which also manages Vulkan and WebGL)',
          'Meta (the maker of the Quest headset product line)',
        ],
        correctIndex: 2,
        explanation: 'The Khronos Group (which also manages Vulkan and WebGL) maintains OpenXR as an open, royalty-free standard.',
      ),
      const QuizQuestion(
        id: 'q_openxr_3',
        question: 'In OpenXR architecture, what does the Application interact with directly?',
        options: [
          'The raw GPU hardware and its low-level driver interfaces',
          'The OpenXR API, which then delegates to the platform runtime',
          'The headset firmware and proprietary hardware abstraction layer',
          'The OS-level display driver responsible for compositing frames',
        ],
        correctIndex: 1,
        explanation: 'The application calls the OpenXR API, which is then translated by the OpenXR Runtime into hardware-specific operations.',
      ),
      const QuizQuestion(
        id: 'q_openxr_4',
        question: 'What happens during the OpenXR Action System binding phase?',
        options: [
          'Material textures are bound and uploaded to GPU memory buffers',
          'Network sockets are opened for multiplayer session synchronization',
          'Logical actions like "jump" are mapped to physical hardware inputs',
          'The compiled application binary is statically linked with the runtime',
        ],
        correctIndex: 2,
        explanation: 'The Action System abstracts input. Instead of querying a specific button, the app asks if "jump" happened, and the runtime handles the mapping.',
      ),
      const QuizQuestion(
        id: 'q_openxr_5',
        question: 'What is an OpenXR "Extension"?',
        options: [
          'A browser plugin that enables WebXR playback in older browsers',
          'A physical cable that connects a standalone headset to a desktop PC',
          'An optional feature like hand tracking that vendors implement on top of the core API',
          'A proprietary 3D model container format introduced with the standard',
        ],
        correctIndex: 2,
        explanation: 'Extensions allow vendors to introduce cutting-edge features before they become part of the core OpenXR standard.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  QUIZ 9 — The AR Cloud
  // ───────────────────────────────────────────────────────────────
  'quiz_ar_cloud': Quiz(
    id: 'quiz_ar_cloud',
    moduleId: 'mod_ar_cloud',
    title: 'AR Cloud Quiz',
    passingScore: 70,
    questions: [
      const QuizQuestion(
        id: 'q_arcloud_1',
        question: 'What is the "AR Cloud"?',
        options: [
          'A managed cloud service for storing and serving 3D model assets',
          'A persistent, real-time shared 3D map of the physical world',
          'A platform for streaming live video content to AR headsets remotely',
          'A weather visualization application designed for AR headset devices',
        ],
        correctIndex: 1,
        explanation: 'The AR Cloud is the conceptual infrastructure that maps the world, allowing devices to share a common spatial understanding.',
      ),
      const QuizQuestion(
        id: 'q_arcloud_2',
        question: 'Which sequence correctly describes the AR Cloud workflow?',
        options: [
          'Download assets → Render the scene → Display on screen to user',
          'Map physical space → Upload features → Relocalize → Sync state',
          'User logs in → Scans a QR code → Application displays an advert',
          'Activate GPS → Retrieve coordinates → Render a 2D overlay map',
        ],
        correctIndex: 1,
        explanation: 'Devices must map the environment, share key features to a cloud backend, allow others to relocalize against that map, and then synchronize the states of virtual objects.',
      ),
      const QuizQuestion(
        id: 'q_arcloud_3',
        question: 'What is a "Digital Twin" in the context of the AR Cloud?',
        options: [
          'A complete mirrored backup copy of the device\'s local hard drive',
          'A virtual replica of a physical space or object updated in near real time',
          'A user avatar that is designed to look exactly like its real-world owner',
          'Two identical AR headset devices that are paired and synced together',
        ],
        correctIndex: 1,
        explanation: 'Digital twins are highly accurate digital models of physical environments, often used in enterprise for simulation and spatial computing.',
      ),
      const QuizQuestion(
        id: 'q_arcloud_4',
        question: 'Why is standard GPS insufficient for the AR Cloud?',
        options: [
          'Acquiring GPS signals costs significant per-query fees from providers',
          'GPS lacks 6DoF orientation, centimeter precision, and fails indoors',
          'GPS data cannot be transmitted over standard internet connections',
          'Continuous GPS usage drains the device battery far too rapidly',
        ],
        correctIndex: 1,
        explanation: 'GPS offers meter-level accuracy globally, but AR requires centimeter-level 6DoF accuracy (position and rotation), especially indoors where GPS fails.',
      ),
      const QuizQuestion(
        id: 'q_arcloud_5',
        question: 'What is the primary privacy concern associated with the AR Cloud?',
        options: [
          'The system continuously records ambient audio without user consent',
          'Uploading visual feature scans of private spaces to remote servers',
          'The platform requires users to register with their real legal names',
          'The system tracks every website visited by users on their devices',
        ],
        correctIndex: 1,
        explanation: 'Building the AR cloud requires cameras to scan environments. Uploading these visual features raises severe privacy and security concerns for private spaces.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  QUIZ 10 — SLAM Deep Dive
  // ───────────────────────────────────────────────────────────────
  'quiz_slam_deepdive': Quiz(
    id: 'quiz_slam_deepdive',
    moduleId: 'mod_slam_deepdive',
    title: 'SLAM Deep Dive Quiz',
    passingScore: 70,
    questions: [
      const QuizQuestion(
        id: 'q_slam_1',
        question: 'What sensors are primarily fused in typical mobile VIO (Visual-Inertial Odometry)?',
        options: [
          'Rear camera and GPS module for outdoor positional tracking',
          'Camera and IMU (accelerometer/gyroscope) for pose estimation',
          'LiDAR depth sensor and a directional microphone array',
          'Wi-Fi radio and Bluetooth beacon for indoor positioning',
        ],
        correctIndex: 1,
        explanation: 'VIO fuses sparse visual feature tracking from the camera with high-frequency inertial data from the IMU to calculate pose.',
      ),
      const QuizQuestion(
        id: 'q_slam_2',
        question: 'In SLAM feature extraction, what are the two components of a feature?',
        options: [
          'Colour channel value and per-pixel brightness intensity reading',
          'Keypoint (pixel location) and Descriptor (visual identity summary)',
          'Normal vector direction and surface albedo material coefficient',
          'X-coordinate value and corresponding Y-coordinate pixel value',
        ],
        correctIndex: 1,
        explanation: 'A keypoint identifies the pixel location of a feature (like a corner), while the descriptor mathematically summarizes its visual neighborhood so it can be matched across frames.',
      ),
      const QuizQuestion(
        id: 'q_slam_3',
        question: 'What mathematical technique is crucial for rejecting bad feature matches (outliers) in SLAM?',
        options: [
          'Fast Fourier Transform for converting spatial data to frequency domain',
          'Newton-Raphson iteration method for finding polynomial equation roots',
          'RANSAC (Random Sample Consensus) for robust model fitting with outliers',
          'K-Means clustering for grouping feature descriptors by visual similarity',
        ],
        correctIndex: 2,
        explanation: 'RANSAC iteratively selects subsets of data to find the mathematical model (e.g., camera movement) that most features agree with, rejecting the outliers.',
      ),
      const QuizQuestion(
        id: 'q_slam_4',
        question: 'What happens during SLAM "Bundle Adjustment"?',
        options: [
          'The system compresses tracked 3D map points into a compact bundle file',
          'It simultaneously refines 3D map point positions and camera poses to minimize error',
          'The tracking data is serialized and sent as a bundle to the cloud service',
          'The display brightness is adjusted based on the measured ambient light level',
        ],
        correctIndex: 1,
        explanation: 'Bundle adjustment is an optimization step that takes all recent camera poses and mapped points and mathematically adjusts them to find the most accurate global solution.',
      ),
      const QuizQuestion(
        id: 'q_slam_5',
        question: 'What is essentially "Scale Ambiguity" in Monocular (single camera) SLAM?',
        options: [
          'Not knowing if an object is large and distant or small and nearby',
          'The camera being mechanically unable to achieve proper optical focus',
          'The tracking system failing to read printed QR codes at a distance',
          'Floating-point precision errors accumulating in the homography matrix',
        ],
        correctIndex: 0,
        explanation: 'A single camera alone cannot determine absolute real-world scale. It requires IMU data (accelerometer) or a known physical reference to establish true scale.',
      ),
    ],
  ),


};
