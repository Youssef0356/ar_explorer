import '../models/flashcard_model.dart';

final Map<String, List<Flashcard>> allFlashcards = {
  'intro_ar_basics': [
    const Flashcard(id: 'fc_basics_1', moduleId: 'intro_ar_basics', front: 'What is Augmented Reality?', back: 'AR overlays digital content onto the real world in real time, respecting perspective and movement.'),
    const Flashcard(id: 'fc_basics_2', moduleId: 'intro_ar_basics', front: 'AR vs VR — key difference?', back: 'AR: world-first, digital-second. VR: digital-only, replaces your entire view.'),
    const Flashcard(id: 'fc_basics_3', moduleId: 'intro_ar_basics', front: 'What is XR?', back: 'XR (Extended Reality) is the umbrella term covering AR, VR, and MR.'),
    const Flashcard(id: 'fc_basics_4', moduleId: 'intro_ar_basics', front: 'What makes "true AR" different from a video filter?', back: 'True AR tracks the real world — digital content must react to movement and environment.'),
    const Flashcard(id: 'fc_basics_5', moduleId: 'intro_ar_basics', front: 'MR (Mixed Reality) means...', back: 'Experiences where real and virtual content coexist and can interact. Many AR headsets describe themselves as MR devices.'),
  ],
  'foundations_coordinate_systems': [
    const Flashcard(id: 'fc_coords_1', moduleId: 'foundations_coordinate_systems', front: 'Name the 4 main coordinate spaces in AR', back: 'World Space, Camera Space, Screen Space, Local/Object Space'),
    const Flashcard(id: 'fc_coords_2', moduleId: 'foundations_coordinate_systems', front: 'World Space is...', back: 'A stable 3D coordinate system tied to the real environment. Anchors and planes live here.'),
    const Flashcard(id: 'fc_coords_3', moduleId: 'foundations_coordinate_systems', front: 'What happens if you place objects in Camera Space instead of World Space?', back: 'The object "sticks" to the camera and moves with the device instead of staying fixed in the room.'),
    const Flashcard(id: 'fc_coords_4', moduleId: 'foundations_coordinate_systems', front: 'First question when debugging AR placement bugs?', back: '"In which coordinate system am I right now?" — most early bugs come from mixing spaces.'),
  ],
  'mod_intro': [
    const Flashcard(id: 'fc_intro_1', moduleId: 'mod_intro', front: 'What is Milgram\'s Continuum?', back: 'A spectrum from Physical World to Virtual Reality. Mixed Reality encompasses everything in between.'),
    const Flashcard(id: 'fc_intro_2', moduleId: 'mod_intro', front: 'Three Pillars of AR?', back: '1. Tracking (Pose Estimation)\n2. Scene Understanding\n3. Rendering'),
    const Flashcard(id: 'fc_intro_3', moduleId: 'mod_intro', front: 'What is Registration in AR?', back: 'The precise alignment of virtual objects in 3D space. Failure results in "drift."'),
    const Flashcard(id: 'fc_intro_4', moduleId: 'mod_intro', front: 'What is the "Friction Factor" in WebAR?', back: '70% of users drop off when required to install a native app. WebAR removes this friction.'),
    const Flashcard(id: 'fc_intro_5', moduleId: 'mod_intro', front: 'What is Relocalization?', back: 'When a device recognizes its environment and resets its coordinate system to align with a stored spatial map.'),
    const Flashcard(id: 'fc_intro_6', moduleId: 'mod_intro', front: 'What is Z-Fighting?', back: 'A visual artifact where two surfaces at the same depth flicker as they compete for rendering priority.'),
  ],
  'mod_tech': [
    const Flashcard(id: 'fc_tech_1', moduleId: 'mod_tech', front: 'What is VIO?', back: 'Visual-Inertial Odometry — fuses camera and IMU data for precise 6DoF tracking. Backbone of ARCore and ARKit.'),
    const Flashcard(id: 'fc_tech_2', moduleId: 'mod_tech', front: 'What is SLAM?', back: 'Simultaneous Localization and Mapping — building a map of unknown environment while tracking device position.'),
    const Flashcard(id: 'fc_tech_3', moduleId: 'mod_tech', front: '5 Steps of SLAM', back: '1. Feature Extraction\n2. Feature Matching\n3. Map Building\n4. Pose Estimation\n5. Loop Closure'),
    const Flashcard(id: 'fc_tech_4', moduleId: 'mod_tech', front: 'FAST feature detector is known for...', back: 'Extremely fast corner detection, suitable for real-time AR.'),
    const Flashcard(id: 'fc_tech_5', moduleId: 'mod_tech', front: 'When does SLAM fail?', back: 'Environments with few features (blank walls), fast motion (blur), or drastic lighting changes.'),
    const Flashcard(id: 'fc_tech_6', moduleId: 'mod_tech', front: 'Environmental HDR provides...', back: 'A full spherical lighting map for realistic reflections, specular highlights, and shadows on virtual objects.'),
  ],
  'mod_dev': [
    const Flashcard(id: 'fc_dev_1', moduleId: 'mod_dev', front: 'What is Extended Tracking (Vuforia)?', back: 'Content persists even when the image target leaves the camera view.'),
    const Flashcard(id: 'fc_dev_2', moduleId: 'mod_dev', front: 'What is Raycasting in AR?', back: 'Sending a virtual ray from a 2D screen point into the 3D world to detect intersections with tracked geometry.'),
    const Flashcard(id: 'fc_dev_3', moduleId: 'mod_dev', front: 'AR Foundation managers: ARPlaneManager does...', back: 'Detects planes and instantiates plane prefabs.'),
    const Flashcard(id: 'fc_dev_4', moduleId: 'mod_dev', front: 'Why filter hit results by trackable type?', back: 'Plane hits are more stable/reliable than feature point hits.'),
    const Flashcard(id: 'fc_dev_5', moduleId: 'mod_dev', front: 'AR Session Origin defines...', back: 'The world coordinate system\'s origin point and transform space for AR content placement.'),
  ],
  'mod_stab': [
    const Flashcard(id: 'fc_stab_1', moduleId: 'mod_stab', front: 'Minimum FPS for comfortable AR?', back: '60 FPS — lower causes jitter and motion sickness.'),
    const Flashcard(id: 'fc_stab_2', moduleId: 'mod_stab', front: 'What causes positional drift?', back: 'Accumulated small tracking errors over time.'),
    const Flashcard(id: 'fc_stab_3', moduleId: 'mod_stab', front: 'LOD (Level of Detail) means...', back: 'Reducing polygon count based on distance from camera — reduces rendering overhead while maintaining quality.'),
    const Flashcard(id: 'fc_stab_4', moduleId: 'mod_stab', front: 'Why limit active anchors?', back: 'Each anchor adds computational overhead for tracking.'),
    const Flashcard(id: 'fc_stab_5', moduleId: 'mod_stab', front: 'ASTC/ETC2 are...', back: 'GPU-native compressed texture formats optimized for mobile devices.'),
  ],
  'mod_advanced': [
    const Flashcard(id: 'fc_adv_1', moduleId: 'mod_advanced', front: 'Cloud Anchors workflow', back: '1. Host creates anchor\n2. Cloud returns an ID\n3. ID shared with other users\n4. Others resolve the anchor to see same content'),
    const Flashcard(id: 'fc_adv_2', moduleId: 'mod_advanced', front: 'Environmental Occlusion means...', back: 'Real objects in front hide virtual objects behind them.'),
    const Flashcard(id: 'fc_adv_3', moduleId: 'mod_advanced', front: 'Depth API uses...', back: 'Machine learning on-device to produce per-pixel depth maps for occlusion.'),
  ],
};
