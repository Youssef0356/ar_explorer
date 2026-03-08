import 'dart:math';

const Map<String, String> arKeywordsData = {
  "Augmented Reality (AR)": "An interactive experience where digital information is overlaid onto the real-world environment in real-time.",
  "Virtual Reality (VR) vs. Augmented Reality (AR)": "VR completely immerses the user in a simulated digital environment, while AR overlays digital content onto the physical world.",
  "Mixed Reality (MR)": "A blend of physical and digital worlds where real and holographic objects coexist and interact in real-time.",
  "Degrees of Freedom (DoF)": "The number of independent parameters that define an object's movement in 3D space. 3DoF allows rotational tracking, while 6DoF adds positional tracking (translation).",
  "World Coordinate System": "The global, fixed 3D space framework used to track the user's device and consistently place virtual objects relative to the real world.",
  "Local Coordinate System (Object Space)": "The coordinate system relative to a specific 3D model or object, defining its local scale, rotation, and center point.",
  "Camera Coordinate System": "A dynamic coordinate system originating from the device's camera lens, moving and rotating as the user moves their device.",
  "Anchor (Trackable)": "A fixed point or feature in the real world that the AR system tracks to keep virtual objects stable and in place over time.",
  "Marker-based AR": "AR experiences that rely on recognizing specific visual cues, like QR codes or distinct image targets, to trigger and align digital content.",
  "Markerless AR": "AR that uses device sensors, cameras, and algorithms to map the environment and place objects without needing physical markers.",
  "Location-based AR": "AR experiences tied to specific geographic coordinates using GPS, compass, and network data.",
  "SLAM (Simultaneous Localization and Mapping)": "The computational problem of constructing a map of an unknown environment while simultaneously keeping track of the device's location within it.",
  "Point Cloud": "A set of data points in 3D space, typically representing the external surface of a real-world object or environment detected by the device.",
  "Raycasting (Hit Testing)": "A method of calculating the intersection between a virtual 3D ray extending from the user's screen and a detected real-world surface to place an object.",
  "Occlusion": "A rendering technique where real-world objects visually block virtual objects that are positioned behind them, increasing realism.",
  "Plane Detection": "The ability of an AR system to identify horizontal and vertical flat surfaces, such as floors, tables, or walls, in the physical environment.",
  "ARKit": "Apple's official software development framework for building augmented reality experiences exclusively for iOS and iPadOS devices.",
  "ARCore": "Google's platform for building augmented reality experiences, compatible with Android devices and, to a limited extent, iOS.",
  "AR Foundation": "A Unity framework that provides a unified workflow, allowing developers to build once and deploy to both ARKit and ARCore devices.",
  "Drift": "The gradual accumulation of tracking errors over time, causing virtual objects to appear to slide or float away from their anchored real-world positions.",
  "Feature Points": "Visually distinct areas in the real world, such as corners or high-contrast textures, that an AR camera uses to track movement.",
  "Latency in AR": "The delay between a user's physical movement and the corresponding update of the digital content. High latency causes tracking lag and motion sickness.",
  "Environmental Understanding (Semantics)": "An advanced AR system's ability to perceive the semantic meaning of the real world, distinguishing between objects like a window, a chair, or the sky.",
  "Light Estimation": "An algorithm that analyzes real-world lighting via the camera feed to apply realistic digital lighting, color correction, and shadows to virtual objects.",
  "Persistence / Cloud Anchors": "The ability to save an AR spatial map and anchors to a cloud server, allowing multiple users to share an experience or return to it later."
};

MapEntry<String, String> getDailyKeyword() {
  final now = DateTime.now();
  // Use the current date as a seed so the random number is the same all day
  final seed = now.year * 10000 + now.month * 100 + now.day;
  final random = Random(seed);
  
  final entries = arKeywordsData.entries.toList();
  final index = random.nextInt(entries.length);
  
  return entries[index];
}
