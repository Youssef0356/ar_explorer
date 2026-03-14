import 'package:flutter/material.dart';

import '../models/module_model.dart';
import '../models/topic_model.dart';

// ═══════════════════════════════════════════════════════════════════
//  ALL LEARNING MODULES — Content Data
//  Reviewed & expanded for technical accuracy and professional depth.
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
            'in a way that respects the perspective, lighting, and movement of the user.',
          ),
          const ContentBlock.subheading('Key Ingredients'),
          const ContentBlock.bullet(
            'You still see the real world — through a camera feed (Video See-Through) or a transparent optical display (Optical See-Through).',
          ),
          const ContentBlock.bullet(
            'Digital content is spatially registered with that world: it appears to "stick" to real surfaces or objects.',
          ),
          const ContentBlock.bullet(
            'As you move, the digital content updates in real time to maintain consistent alignment.',
          ),
          const ContentBlock.subheading('The Two Display Approaches'),
          const ContentBlock.bullet(
            'Optical See-Through (OST): Semi-transparent lenses let light pass through directly. HoloLens 2 uses this approach.',
          ),
          const ContentBlock.bullet(
            'Video See-Through (VST): Cameras capture the world and feed it to screens inside the device. Apple Vision Pro uses this approach.',
          ),
          const ContentBlock.info(
            'If the digital content does not react to your movement or environment — it is closer '
            'to a "screen overlay" or video effect than true AR. Registration is the defining characteristic.',
          ),
          const ContentBlock.code(
            '// Conceptual AR Initialization\n'
            'ARSession session = new ARSession();\n'
            'session.run(ARWorldTrackingConfiguration());\n'
            '\n'
            '// The session now continuously updates the camera pose\n'
            '// against the real-world environment.',
          ),
          const ContentBlock.quote(
            'INTERVIEW FOCUS: If asked for a technical definition, use the 3 pillars by Ronald Azuma: '
            '1) Combines real and virtual, 2) Interactive in real time, 3) Registered in 3D.',
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
            'VR fully replaces your view of the real world with a virtual one. You only see digital content. '
            'Examples: Meta Quest, PlayStation VR.',
          ),
          const ContentBlock.subheading('Augmented Reality (AR)'),
          const ContentBlock.body(
            'AR shows you the real world first, then adds digital information on top of it. '
            'The physical world is always the primary frame of reference.',
          ),
          const ContentBlock.subheading('Mixed Reality (MR)'),
          const ContentBlock.body(
            'MR is a broader term covering experiences where real and virtual content coexist and interact. '
            'Importantly, virtual objects can be occluded by real ones. HoloLens 2 is a true MR device.',
          ),
          const ContentBlock.subheading('Extended Reality (XR)'),
          const ContentBlock.body(
            'XR is an umbrella term that includes AR, VR, and MR. It is commonly used in industry contexts '
            'and standards bodies (e.g., the OpenXR standard covers all of XR).',
          ),
          const ContentBlock.image(
            'assets/images/AR vs VR vs MR vs XR/Understanding the spectrum ARexplorer.png',
          ),
          const ContentBlock.info(
            'In interviews, describe AR as "world-first, digital-second." '
            'VR is "digital-only." MR is "world and digital interacting." Be ready to give a hardware example for each.',
          ),
          const ContentBlock.quote(
            'PRO INSIGHT: The industry is moving away from strict categories toward "Spatial Computing." '
            'Devices like the Vision Pro blurred these lines by providing a VST (Video See-Through) '
            'experience that feels like AR but technically shuts you out from the photons of the real world.',
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
            'Snapchat / Instagram face filters that track and lock to your facial features.',
          ),
          const ContentBlock.bullet(
            'Google Maps Live View: navigation arrows overlaid on the street in front of you.',
          ),
          const ContentBlock.bullet(
            'Industrial assembly instructions floating over a machine component (e.g., HoloLens in a factory).',
          ),
          const ContentBlock.bullet(
            'IKEA Place app: virtual furniture placed on your real floor with correct scale and lighting.',
          ),
          const ContentBlock.image(
            'assets/images/Real World Examples vs Common Misconceptions/Real World Examples vs Common Misconceptions.png',
          ),
          const ContentBlock.subheading('Common Misconceptions'),
          const ContentBlock.bullet(
            '"AR always needs a headset" — Many production-grade systems run on phones and tablets via ARKit and ARCore.',
          ),
          const ContentBlock.bullet(
            '"AR is only for games" — The largest commercial deployments are in industrial training, logistics, maintenance, and surgical planning.',
          ),
          const ContentBlock.bullet(
            '"Any 3D overlay is AR" — If the content does not track the real world and stay registered with it, it is a screen effect, not AR.',
          ),
          const ContentBlock.bullet(
            '"Apple Vision Pro is an AR headset" — It is a Video See-Through MR/VR headset. The wearer sees cameras, not the world directly. This is a common and costly interview mistake.',
          ),
          const ContentBlock.warning(
            'As an aspiring AR professional, precision matters. Being sloppy about AR vs VR vs MR — or OST vs VST — '
            'is your first credibility test in any technical interview.',
          ),
          const ContentBlock.code(
            '// Example: Detecting if a face is tracked (Snapchat-style AR)\n'
            'void Update() {\n'
            '  if (faceManager.trackables.count > 0) {\n'
            '    renderFaceMesh(faceManager.trackables[0]);\n'
            '  }\n'
            '}',
          ),
          const ContentBlock.quote(
            'INTERVIEW QUESTION: "Is a TikTok filter true AR?" \n'
            'Answer: Yes, because it performs real-time facial tracking (registration) and '
            'updates the 3D geometry of the mask to match the user\'s pose and lighting.',
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
    icon: Icons.grid_on_rounded,
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
            'Every AR experience is built on coordinate systems: invisible 3D grids that define '
            'where the camera is, where virtual objects live, and how everything moves together.',
          ),
          const ContentBlock.subheading('Without Coordinate Systems…'),
          const ContentBlock.bullet(
            'Virtual objects would not know "where" to appear in the real world.',
          ),
          const ContentBlock.bullet(
            'You could not say "place this object 1 metre in front of the user."',
          ),
          const ContentBlock.bullet(
            'Two users could not agree on "the same" real-world location.',
          ),
          const ContentBlock.info(
            'You do not need to compute matrices yet. Focus on the mental model: '
            'every space has an origin (a 0,0,0 point) and three axes (X, Y, Z). '
            'Moving between spaces requires a mathematical transform.',
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
            'A stable 3D coordinate system tied to the real environment. '
            'Anchors, detected planes, and persistent objects live here. '
            'This space does not move even as the user moves.',
          ),
          const ContentBlock.subheading('Camera Space (View Space)'),
          const ContentBlock.body(
            'A coordinate system centered on the device camera. '
            'Forward is "where the camera currently looks." This space moves with the device.',
          ),
          const ContentBlock.subheading('Screen Space'),
          const ContentBlock.body(
            'A 2D coordinate system measured in pixels. Touch positions and 2D UI elements use screen space. '
            'Converting a screen-space tap into a world-space ray is called raycasting.',
          ),
          const ContentBlock.subheading('Local / Object Space'),
          const ContentBlock.body(
            'Each virtual object has its own local origin and axes. '
            'Rotating an object in local space rotates it around its own centre, '
            'regardless of where it sits in world space.',
          ),
          const ContentBlock.code(
            '// Converting Screen Space (2D Tap) to World Space (3D Ray)\n'
            'Vector2 screenTap = Input.GetTouch(0).position;\n'
            'Ray ray = arCamera.ScreenPointToRay(screenTap);\n'
            '\n'
            'if (Physics.Raycast(ray, out hit)) {\n'
            '    // hit.point is now in WORLD SPACE\n'
            '    PlaceObject(hit.point);\n'
            '}',
          ),
          const ContentBlock.info(
            'In most AR SDKs, a "pose" is a transform from one space to another — '
            'for example, a 4×4 matrix from world space to camera space.',
          ),
          const ContentBlock.quote(
            'INTERVIEW DEEP DIVE: Expect questions on "Raycasting." \n'
            'It is the process of taking a 2D Screen Space point (where you tapped) '
            'and projecting it through the Camera Space into World Space to see what real-world '
            'planes or features it hits.',
          ),
        ],
      ),
      Topic(
        id: 'handedness_and_conventions',
        title: 'Handedness & Axis Conventions',
        subtitle: 'Right-handed vs left-handed coordinate systems.',
        contentBlocks: [
          const ContentBlock.heading('Why Handedness Matters'),
          const ContentBlock.body(
            'Different engines and SDKs define their axes differently. '
            'Mixing conventions is one of the most common causes of objects appearing '
            'mirrored, flipped, or rotated 90° unexpectedly.',
          ),
          const ContentBlock.subheading('Right-Handed Coordinate System'),
          const ContentBlock.body(
            'ARKit, ARCore, OpenGL, and most mathematics use a right-handed system: '
            'X points right, Y points up, and Z points toward the viewer (out of the screen). '
            'Use the right hand: point fingers along X, curl toward Y — thumb points in the Z direction.',
          ),
          const ContentBlock.subheading('Left-Handed Coordinate System'),
          const ContentBlock.body(
            'Unity and Direct3D use a left-handed system: '
            'X points right, Y points up, and Z points away from the viewer (into the screen). '
            'This is why importing models from OpenGL-based tools into Unity can cause Z-axis flips.',
          ),
          const ContentBlock.subheading('Y-Up vs Z-Up'),
          const ContentBlock.bullet(
            'Unity, ARKit, ARCore — Y is up (vertical axis).',
          ),
          const ContentBlock.bullet(
            'Blender, ROS (robotics) — Z is up. Exporting a Blender model to Unity requires a 90° axis correction.',
          ),
          const ContentBlock.warning(
            'Always check the axis convention of any 3D model or SDK before integrating it. '
            'A wrong convention silently corrupts every transform in your scene.',
          ),
          const ContentBlock.quote(
            'PRACTICAL EXERCISE: Use the "Right-Hand Rule" to debug a flipped Z-axis. '
            'Point your index finger toward +X, middle toward +Y. If your thumb points toward you, '
            'it is a right-handed system (ARKit/ARCore). If it points away, it is left-handed (Unity).',
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
            'Mixing units — confusing metres (AR world scale) with arbitrary model units from a 3D editor.',
          ),
          const ContentBlock.bullet(
            'Placing content in Camera Space when you meant World Space — objects will "stick" to the camera and move with it instead of staying in the scene.',
          ),
          const ContentBlock.bullet(
            'Ignoring Y-up vs Z-up when importing assets from Blender, Maya, or other DCCs.',
          ),
          const ContentBlock.bullet(
            'Applying rotations in the wrong order — rotation is not commutative. Rx then Ry is different from Ry then Rx.',
          ),
          const ContentBlock.subheading('Mental Debugging Checklist'),
          const ContentBlock.numbered(
            '1. Ask: "In which space am I currently working?" (screen, camera, world, or local).',
          ),
          const ContentBlock.numbered(
            '2. Verify the origin and axis directions match your expectation.',
          ),
          const ContentBlock.numbered(
            '3. Convert between spaces only when necessary — each conversion is a potential error point.',
          ),
          const ContentBlock.numbered(
            '4. Check handedness when integrating external assets or SDKs.',
          ),
          const ContentBlock.warning(
            'When objects jump, rotate strangely, or appear at (0,0,0) in world space, '
            'a coordinate system mismatch is almost always the cause.',
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
    requiredQuizId: 'quiz_foundations_coords',
    topics: [
      Topic(
        id: 'spatial_foundations',
        title: 'Foundations of the Spatial Stack',
        subtitle: 'Milgram\'s Continuum and the Pillars of Registration',
        contentBlocks: [
          const ContentBlock.heading('The Evolution of Spatial Computing'),
          const ContentBlock.body(
            'We are currently undergoing a third foundational platform shift: moving from mobile to spatial computing. '
            'In a professional context, AR is the real-time integration of digital artifacts that respect '
            'the laws of physics, perspective, and lighting within the user\'s physical environment.',
          ),
          const ContentBlock.subheading('The Reality-Virtuality Continuum'),
          const ContentBlock.body(
            'Paul Milgram\'s 1994 spectrum maps the transition from the Physical World to Virtual Reality. '
            'Mixed Reality (MR) encompasses everything in between. AR sits closer to the "Real Environment" end, '
            'prioritizing the physical world while enhancing it with contextual digital overlays.',
          ),
          const ContentBlock.info(
            'Registration: The precise spatial alignment of virtual objects with the real world. '
            'Failure results in "drift," where objects appear to slide or jump, immediately breaking immersion.',
          ),
          const ContentBlock.quote(
            'INTERVIEW DEEP DIVE: Be prepared to explain Milgram\'s Continuum. '
            'It is a scale from "Real" to "Virtual." AR is on the left (real-dominant), '
            'while VR is on the right (virtual-only). Mixed Reality (MR) is the entire bridge between them.',
          ),
          const ContentBlock.subheading('The Three Pillars of AR'),
          const ContentBlock.bullet(
            'Tracking (Pose Estimation): Determining the device\'s pose — position and orientation — across 6 Degrees of Freedom (6DoF).',
          ),
          const ContentBlock.bullet(
            'Scene Understanding: Interpreting the geometry and semantics of the environment — detecting planes, generating depth maps, recognising objects.',
          ),
          const ContentBlock.bullet(
            'Rendering: Drawing virtual content to match real-world perspective, occlusion, and environmental lighting.',
          ),
          const ContentBlock.subheading('Motion-to-Photon Latency'),
          const ContentBlock.body(
            'Latency is the delay between a physical head movement and the corresponding update on the display. '
            'For comfortable AR, this must be kept below 20 milliseconds. Latency above this threshold causes '
            'a visible "swimming" of virtual objects and can trigger nausea.',
          ),
          const ContentBlock.quote(
            'PRO TIP: To minimize latency, AR systems use "Asynchronous Timewarp" or "Late Latching." '
            'These techniques re-project the rendered image to match the absolute latest head pose '
            'just microseconds before the photons leave the display.',
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
            'Handheld AR on smartphones is widely accessible but suffers from the "windowing" effect — '
            'the user views the world through a small screen, breaking spatial presence. '
            'Head-Mounted Displays (HMDs) provide "presence" and hands-free workflows critical for industry.',
          ),
          const ContentBlock.subheading('OST vs VST — A Critical Distinction'),
          const ContentBlock.bullet(
            'Optical See-Through (OST): Holographic waveguides or half-mirrors overlay light directly onto the real world the user sees. Example: Microsoft HoloLens 2.',
          ),
          const ContentBlock.bullet(
            'Video See-Through (VST): External cameras capture the world and render it onto internal displays alongside virtual content. Example: Apple Vision Pro, Meta Quest 3.',
          ),
          const ContentBlock.warning(
            'Apple Vision Pro is a VST Mixed Reality headset — not an AR headset in the OST sense. '
            'Calling it an "AR device" in an interview without this nuance signals shallow knowledge.',
          ),
          const ContentBlock.subheading('Field of View (FOV) Comparison'),
          const ContentBlock.bullet(
            'Xreal Air 2: ~46° diagonal FOV — Portable OST glasses, ideal for personal productivity and media.',
          ),
          const ContentBlock.bullet(
            'Microsoft HoloLens 2: ~52° diagonal FOV — The enterprise benchmark for industrial spatial mapping and guided workflows.',
          ),
          const ContentBlock.bullet(
            'Apple Vision Pro: ~100° FOV — VST display with extremely high pixel density for near-retina clarity in a mixed reality context.',
          ),
          const ContentBlock.info(
            'Studies on HMD-assisted assembly show significantly lower error rates and faster task completion '
            'compared to tablet-based AR, primarily because HMDs keep both hands free.',
          ),
        ],
      ),
      Topic(
        id: 'software_ecosystems',
        title: 'Software & Development Engines',
        subtitle: 'Unity, Unreal, and Professional SDKs',
        contentBlocks: [
          const ContentBlock.heading('The Development Paths'),
          const ContentBlock.bullet(
            'Unity + AR Foundation: The industry-standard cross-platform path. AR Foundation abstracts ARKit (iOS) and ARCore (Android) into a single C# API, minimising platform-specific code.',
          ),
          const ContentBlock.bullet(
            'Unreal Engine (C++): Preferred for high-fidelity industrial simulations where photorealistic rendering accuracy is critical.',
          ),
          const ContentBlock.bullet(
            'Native Swift (ARKit) / Kotlin (ARCore): Maximum performance and direct hardware access — ideal for LiDAR-heavy apps on iOS or Geospatial API apps on Android.',
          ),
          const ContentBlock.subheading('Enterprise: Vuforia'),
          const ContentBlock.body(
            'Vuforia is the leading enterprise AR SDK, built around robust Image Target and Model Target tracking. '
            'It excels at recognising specific 3D objects — for example, a specific industrial engine model — '
            'a capability that generic plane detection cannot provide.',
          ),
          const ContentBlock.subheading('Platform SDKs at a Glance'),
          const ContentBlock.bullet(
            'ARKit (Apple): Best-in-class tracking on iOS/iPadOS. Supports LiDAR Scene Reconstruction, Face Tracking, and Object Detection.',
          ),
          const ContentBlock.bullet(
            'ARCore (Google): Cross-device Android AR. Supports Geospatial API, Depth API, and Cloud Anchors.',
          ),
          const ContentBlock.bullet(
            'OpenXR: The Khronos Group open standard that unifies XR development across platforms.',
          ),
          const ContentBlock.code(
            '// Unity AR Foundation: Checking for AR support dynamically\n'
            'IEnumerator CheckAR() {\n'
            '    yield return ARSession.CheckAvailability();\n'
            '    if (ARSession.state == ARSessionState.Supported) {\n'
            '        // Start the AR Session safely\n'
            '    }\n'
            '}',
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
            'Requiring users to download a native app for a single-use AR experience creates significant friction. '
            'Industry data consistently shows that a large proportion of users abandon an experience rather than '
            'visit an app store, download, and install. WebAR eliminates this barrier by running directly in the mobile browser.',
          ),
          const ContentBlock.subheading('Core Technologies'),
          const ContentBlock.bullet(
            'WebXR Device API: The W3C browser standard for AR and VR experiences on the web.',
          ),
          const ContentBlock.bullet(
            'Three.js / A-Frame: JavaScript 3D rendering libraries used to build WebAR scenes.',
          ),
          const ContentBlock.bullet(
            '8th Wall: The commercial leader in WebAR SLAM tracking. Runs on devices that do not natively support WebXR, providing broader compatibility.',
          ),
          const ContentBlock.subheading('Performance Techniques'),
          const ContentBlock.body(
            'Running in a browser sandbox means no direct GPU access. To maintain smooth tracking, WebAR relies on:',
          ),
          const ContentBlock.bullet(
            'WebAssembly (Wasm): Compiles computer vision code (C/C++) to near-native speed inside the browser.',
          ),
          const ContentBlock.bullet(
            'Draco Mesh Compression: Reduces 3D model file sizes by up to 10× for fast loading.',
          ),
          const ContentBlock.bullet(
            'Basis Universal Textures: GPU-friendly texture compression that reduces memory footprint.',
          ),
          const ContentBlock.info(
            'WebAR trades raw performance for reach. For consumer campaigns and marketing, WebAR often outperforms native apps due to the zero-install workflow.',
          ),
          const ContentBlock.quote(
            'PRO INSIGHT: 8th Wall (Niantic) dominates the commercial WebAR space because its SLAM '
            'engine is written in highly optimized C++ and compiled to WebAssembly, '
            'achieving tracking stability that was previously only possible in native apps.',
          ),
        ],
      ),
      Topic(
        id: 'spatial_engineering',
        title: 'Advanced Spatial Engineering',
        subtitle: 'Occlusion, Anchors, and Relocalization',
        contentBlocks: [
          const ContentBlock.heading('Occlusion: Grounding Virtual Objects'),
          const ContentBlock.body(
            'Without occlusion, virtual content "floats" unnaturally — objects appear in front of walls, tables, '
            'or people they should be behind. Correct occlusion is the single biggest leap in visual realism.',
          ),
          const ContentBlock.bullet(
            'Dynamic Occlusion: Uses per-frame depth data (from LiDAR or ML-estimated depth) to hide virtual objects behind moving real objects like people.',
          ),
          const ContentBlock.bullet(
            'Mesh-Based (Environmental) Occlusion: Builds a static mesh of the environment from LiDAR scans. High stability for walls and furniture.',
          ),
          const ContentBlock.warning(
            'Z-Fighting: A rendering artifact that occurs when two surfaces share the same depth value, '
            'causing them to flicker as the GPU cannot determine which is in front. '
            'Fix by adding a small depth offset between coplanar surfaces.',
          ),
          const ContentBlock.code(
            '// Unity Shader Graph: Z-Fighting mitigation on planes\n'
            '// In the Material settings, change the "Render Queue" \n'
            '// or add a "ZTest LEqual" with a slight Z-Offset.',
          ),
          const ContentBlock.subheading('Persistence & Spatial Anchors'),
          const ContentBlock.body(
            'Persistence allows virtual content to remain fixed in a physical location across multiple app sessions. '
            'Without persistence, every session starts fresh and objects must be replaced manually.',
          ),
          const ContentBlock.bullet(
            'Azure Spatial Anchors (ASA): Cloud-based, cross-platform (iOS, Android, HoloLens). Scalable for large industrial sites with many devices.',
          ),
          const ContentBlock.bullet(
            'Google Cloud Anchors (ARCore): Optimised for multi-user shared AR on Android. Requires a visual scan for hosting.',
          ),
          const ContentBlock.info(
            'Relocalization: When a device re-opens an app, it must recognise its current environment '
            'and re-align its coordinate system with the previously stored spatial map. '
            'This is the key technical step that makes persistence work.',
          ),
          const ContentBlock.quote(
            'INTERVIEW FOCUS: Persistence vs. Shared Experiences. \n'
            'Persistence is "Time-based" (content stays for later). '
            'Shared Experiences are "Space-based" (multiple people see the same thing now). '
            'Both rely on a shared spatial map (The AR Cloud).',
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
            'Environment: UI must never cover real-world safety hazards or block the user\'s peripheral awareness.',
          ),
          const ContentBlock.bullet(
            'Onboarding: Use visual motion hints (e.g., "scan floor animation") instead of lengthy text instructions.',
          ),
          const ContentBlock.bullet(
            'Movement: Encourage physical movement to improve tracking without causing neck strain or disorientation.',
          ),
          const ContentBlock.bullet(
            'Interface: Apply Progressive Disclosure — show summary information by default, reveal full detail only when the user requests it.',
          ),
          const ContentBlock.bullet(
            'Interaction: Replace tap-and-hold menus with natural spatial gestures — Grab, Move, Pin, Resize.',
          ),
          const ContentBlock.subheading('Situational Awareness Rules'),
          const ContentBlock.body(
            'AR apps used while moving must dynamically simplify their UI when walking is detected. '
            'Critical rule: never place virtual content directly over the ground plane at floor level — '
            'it can hide physical steps, thresholds, or obstacles and create a safety hazard.',
          ),
          const ContentBlock.info(
            'Comfort zone for fixed UI elements: 1.25m–2m in front of the user at a slight downward angle. '
            'Content too close causes eye strain; content too far is hard to read.',
          ),
          const ContentBlock.quote(
            'DESIGN TIP: Use "Billboarding" for floating UI. \n'
            'This ensures that text panels always rotate to face the user, '
            'regardless of their angle relative to the virtual object.',
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
            'AR is bridging the gap between digital data and physical work in several critical industries:',
          ),
          const ContentBlock.bullet(
            'Medical: Surgical planning with sub-millimetre registration, real-time vital sign overlays, and anatomy visualisation for training.',
          ),
          const ContentBlock.bullet(
            'Logistics & Warehousing: Pick-path route optimisation and real-time barcode scanning guides for warehouse staff, reducing pick errors.',
          ),
          const ContentBlock.bullet(
            'Architecture & Construction: Infrastructure visualisation at 1:1 scale on-site before construction begins, and GPS-denied interior navigation.',
          ),
          const ContentBlock.bullet(
            'Aerospace & Manufacturing: Step-by-step assembly guidance overlaid on physical components, replacing paper manuals and reducing training time.',
          ),
          const ContentBlock.info(
            'Case Study — KLM Royal Dutch Airlines: The Engine Shop app on Apple Vision Pro allows trainees '
            'to study full-fidelity 3D engine repair procedures in an immersive environment, '
            'significantly reducing training errors and accelerating competency development.',
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
    unlockCost: 1,
    requiredQuizId: 'quiz_intro',
    topics: [
      Topic(
        id: 'sensor_fusion',
        title: 'Sensor Fusion',
        subtitle: 'Combining camera, gyroscope, and accelerometer.',
        contentBlocks: [
          const ContentBlock.heading('Sensor Fusion in AR'),
          const ContentBlock.body(
            'Sensor fusion combines data from multiple sensors to produce a more accurate and stable '
            'estimation of device position and orientation. In mobile AR, three primary sensors work together.',
          ),
          const ContentBlock.subheading('Sensor Roles'),
          const ContentBlock.numbered(
            '1. Camera — Provides visual features for tracking and environment understanding. Effective but can fail with motion blur or poor lighting.',
          ),
          const ContentBlock.numbered(
            '2. Gyroscope — Measures angular velocity, enabling fast and accurate rotation tracking. Very low latency but accumulates drift over time.',
          ),
          const ContentBlock.numbered(
            '3. Accelerometer — Measures linear acceleration. Used to estimate translation and detect gravity direction for orientation correction.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('Fusion Techniques'),
          const ContentBlock.bullet(
            'Kalman Filter: Combines noisy sensor measurements with a predictive motion model. Produces an optimal estimate under Gaussian noise assumptions.',
          ),
          const ContentBlock.bullet(
            'Complementary Filter: Blends high-frequency gyro data with low-frequency accelerometer data. Simpler and computationally cheaper than Kalman.',
          ),
          const ContentBlock.bullet(
            'Visual-Inertial Odometry (VIO): Tightly fuses camera frames with IMU data for precise 6DoF tracking at centimetre-level accuracy.',
          ),
          const ContentBlock.info(
            'VIO is the backbone of both ARCore and ARKit. By cross-referencing visual features with IMU readings, '
            'VIO maintains accurate tracking even during brief periods of motion blur or poor lighting — '
            'situations where camera-only tracking would fail.',
          ),
          const ContentBlock.quote(
            'INTERVIEW FOCUS: Why use IMU data? \n'
            'Answer: Cameras provide high-accuracy position but at low frequency (30-60Hz) with latency. '
            'IMUs provide very high-frequency (200Hz+) updates that are nearly instant, '
            'filling the gaps between camera frames for smooth tracking.',
          ),
          const ContentBlock.code(
            '// Conceptual VIO Loop\n'
            'while (sessionLive) {\n'
            '   Pose IMUPose = readHighFrequencyIMU(); \n'
            '   Pose CameraPose = readLowFrequencyCamera();\n'
            '   \n'
            '   // Kalman Filter merges both for final frame pose\n'
            '   currentPose = KalmanFilter.fuse(IMUPose, CameraPose);\n'
            '}',
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
            'SLAM solves a circular problem: to build a map, you need to know where you are; '
            'to know where you are, you need a map. SLAM solves both simultaneously. '
            'It is the foundation of markerless AR tracking.',
          ),
          const ContentBlock.subheading('How SLAM Works (Step by Step)'),
          const ContentBlock.numbered(
            '1. Feature Extraction: Distinctive visual features (corners, edges, blobs) are detected in each camera frame.',
          ),
          const ContentBlock.numbered(
            '2. Feature Matching: Detected features are matched to those from previous frames to determine how the camera has moved.',
          ),
          const ContentBlock.numbered(
            '3. Map Building: Matched features are triangulated to create a sparse 3D point cloud map of the environment.',
          ),
          const ContentBlock.numbered(
            '4. Pose Estimation: The device\'s position and orientation are calculated relative to the growing map.',
          ),
          const ContentBlock.numbered(
            '5. Loop Closure: When the device revisits a previously mapped area, accumulated drift is detected and corrected — the map "snaps" into consistency.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('SLAM Variants'),
          const ContentBlock.bullet(
            'Visual SLAM (vSLAM): Uses camera images only. Lightweight but sensitive to lighting and texture.',
          ),
          const ContentBlock.bullet(
            'Visual-Inertial SLAM (VI-SLAM): Combines camera with IMU sensors. Much more robust — this is what ARKit and ARCore use.',
          ),
          const ContentBlock.bullet(
            'LiDAR SLAM: Uses structured-light or time-of-flight depth sensors (e.g., iPad Pro LiDAR). Accurate in low-light and texture-poor environments.',
          ),
          const ContentBlock.warning(
            'Pure vSLAM can struggle with blank walls, fast motion, or drastic lighting changes. '
            'VI-SLAM (used in ARKit/ARCore) is significantly more robust against motion blur because the IMU continues tracking during blurry frames.',
          ),
          const ContentBlock.quote(
            'PRO INSIGHT: Modern SLAM systems use "Keyframe-based optimization." '
            'Instead of processing every frame, they pick "Keyframes" (frames with high info change) '
            'and perform expensive spatial math only on those, allowing for 60FPS performance on mobile.',
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
            'Plane detection identifies flat surfaces in the environment using the device\'s camera and sensor data. '
            'It is essential for placing virtual objects on tables, floors, or walls at the correct position and orientation.',
          ),
          const ContentBlock.subheading('Detection Pipeline'),
          const ContentBlock.numbered(
            '1. Feature points are detected and tracked across multiple frames as the camera moves.',
          ),
          const ContentBlock.numbered(
            '2. Clusters of feature points that share a common geometric plane are identified.',
          ),
          const ContentBlock.numbered(
            '3. A plane model (position, normal vector, boundary polygon) is fitted to the cluster.',
          ),
          const ContentBlock.numbered(
            '4. As more data is gathered, the plane boundary continuously expands and refines.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('Plane Types'),
          const ContentBlock.bullet(
            'Horizontal Planes — Floors, tables, countertops. The most commonly detected type.',
          ),
          const ContentBlock.bullet(
            'Vertical Planes — Walls, doors, whiteboards.',
          ),
          const ContentBlock.bullet(
            'Arbitrary Planes — Sloped surfaces (limited support on most devices).',
          ),
          const ContentBlock.info(
            'Textured, matte surfaces detect fastest and most reliably. '
            'Smooth, reflective, or transparent surfaces (glass tables, mirrors, white walls) '
            'provide few trackable features and are the most common cause of failed plane detection.',
          ),
          const ContentBlock.code(
            '// AR Foundation: Detecting when a new plane is found\n'
            'void OnPlanesChanged(ARPlanesChangedEventArgs args) {\n'
            '    foreach (var addedPlane in args.added) {\n'
            '        if (addedPlane.alignment == PlaneAlignment.HorizontalUp) {\n'
            '            Debug.Log("Found floor at " + addedPlane.center);\n'
            '        }\n'
            '    }\n'
            '}',
          ),
          const ContentBlock.quote(
            'INTERVIEW QUESTION: "How can you detect planes on a white wall?" \n'
            'Answer: You technically can\'t with pure visual SLAM. Mitigation includes '
            'using LiDAR (on Pro devices) or asking the user to place a high-contrast '
            '"marker" or object in the scene to provide a feature reference.',
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
            'Feature point tracking detects distinctive visual features (keypoints) in camera images '
            'and tracks them across consecutive frames. These keypoints are the raw material for '
            'motion estimation, SLAM map building, and environmental understanding.',
          ),
          const ContentBlock.subheading('Common Feature Detectors'),
          const ContentBlock.bullet(
            'ORB (Oriented FAST and Rotated BRIEF): Fast, rotation-invariant, and patent-free. The standard choice for real-time AR.',
          ),
          const ContentBlock.bullet(
            'SIFT (Scale-Invariant Feature Transform): Highly robust against scale and rotation changes but computationally too heavy for real-time mobile use.',
          ),
          const ContentBlock.bullet(
            'FAST (Features from Accelerated Segment Test): Extremely fast corner detection. Often used in the first stage of a detection pipeline.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('Tracking Pipeline'),
          const ContentBlock.numbered(
            '1. Detect features in the current camera frame.',
          ),
          const ContentBlock.numbered(
            '2. Match features with those from the previous frame (using descriptors).',
          ),
          const ContentBlock.numbered(
            '3. Compute the relative transformation (rotation + translation) between frames.',
          ),
          const ContentBlock.numbered(
            '4. Update the device pose estimation and the sparse map.',
          ),
          const ContentBlock.warning(
            'Feature tracking degrades significantly in: low-light environments, '
            'motion blur from fast movement, and repetitive-pattern textures (e.g., brick walls, fabric) '
            'where individual features cannot be uniquely matched.',
          ),
          const ContentBlock.quote(
            'PRO TIP: When choosing Image Targets (Vuforia/ARKit), avoid symmetry. '
            'A perfectly symmetrical logo can be tracked in two orientations, '
            'causing the virtual content to flip 180 degrees randomly.',
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
            'Light estimation analyses the real environment\'s lighting conditions from camera images '
            'and applies similar lighting properties to virtual objects. '
            'This is critical for making AR content look like it genuinely belongs in the scene.',
          ),
          const ContentBlock.subheading('What Is Estimated'),
          const ContentBlock.bullet(
            'Ambient Light Intensity: The overall brightness level of the scene.',
          ),
          const ContentBlock.bullet(
            'Color Temperature: Warm (yellowish, ~3000K) vs cool (bluish, ~6500K) lighting.',
          ),
          const ContentBlock.bullet(
            'Directional Light: The primary direction and intensity of the main light source (e.g., a window or overhead lamp).',
          ),
          const ContentBlock.bullet(
            'Environmental HDR (HDRI): A full spherical environment map that captures the entire lighting environment — enabling realistic reflections, specular highlights, and accurate shadows.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('SDK Implementation'),
          const ContentBlock.numbered(
            '1. ARCore: Provides ambient intensity, color correction, and a full Environmental HDR mode.',
          ),
          const ContentBlock.numbered(
            '2. ARKit: Supports ambient intensity, directional estimates, and environment texture probes.',
          ),
          const ContentBlock.numbered(
            '3. AR Foundation: Exposes a unified API via ARCameraManager and ARCameraFrameEventArgs for cross-platform light estimation.',
          ),
          const ContentBlock.info(
            'Environmental HDR produces the most convincing results but is computationally expensive. '
            'For low-end devices or performance-critical applications, use ambient intensity + directional '
            'light as a lighter-weight alternative.',
          ),
          const ContentBlock.quote(
            'INTERVIEW DEEP DIVE: What is "IBL" (Image Based Lighting)? \n'
            'In AR, the camera feed is used to generate a 360-degree high-dynamic-range image (CubeMap) '
            'that is mirrored in reflective virtual objects (e.g., a virtual chrome ball).',
          ),
        ],
      ),
      Topic(
        id: 'image_and_object_tracking',
        title: 'Image & Object Tracking',
        subtitle: 'Marker-based and model-based recognition.',
        contentBlocks: [
          const ContentBlock.heading('Beyond Planes: Recognising Specific Things'),
          const ContentBlock.body(
            'Plane detection finds arbitrary flat surfaces. Image tracking and object tracking go further — '
            'they recognise specific, pre-defined images or 3D objects, and use them as anchors for AR content.',
          ),
          const ContentBlock.subheading('Image Tracking'),
          const ContentBlock.body(
            'The system is given a reference image (e.g., a product label, a poster, a QR-like marker). '
            'It detects this image in the camera feed and provides a precise 6DoF pose for attaching AR content.',
          ),
          const ContentBlock.bullet(
            'ARKit: ARImageTrackingConfiguration supports tracking multiple images simultaneously.',
          ),
          const ContentBlock.bullet(
            'ARCore: AugmentedImageDatabase holds reference images; AugmentedImage provides the tracked pose.',
          ),
          const ContentBlock.bullet(
            'Vuforia: ImageTarget with a star rating system (1–5) indicating how trackable an image is.',
          ),
          const ContentBlock.subheading('Object (Model) Tracking'),
          const ContentBlock.body(
            'The system is given a 3D model of a specific real object (e.g., a particular machine component). '
            'It detects and tracks that object in the real world, even as the user walks around it.',
          ),
          const ContentBlock.bullet(
            'Vuforia Model Targets: Industry-leading object tracking, used extensively in manufacturing and maintenance.',
          ),
          const ContentBlock.bullet(
            'ARKit Object Detection: Uses a scan of a physical object to generate a reference ARReferenceObject.',
          ),
          const ContentBlock.info(
            'Image quality is critical for reliable tracking. High-contrast images with rich, varied detail '
            'track best. Avoid images with large uniform colour regions, significant symmetry, or repetitive patterns.',
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
    unlockCost: 1,
    requiredQuizId: 'quiz_tech',
    topics: [
      Topic(
        id: 'vuforia_dev',
        title: 'Vuforia Development',
        subtitle: 'ImageTarget, Ground Plane, and Professional Callbacks.',
        contentBlocks: [
          const ContentBlock.heading('Vuforia-Based Development'),
          const ContentBlock.body(
            'Vuforia Engine is the enterprise standard for AR. Beyond basic targets, senior developers must master its callback system and surface detection capabilities.',
          ),
          const ContentBlock.subheading('Core Callbacks & Target Quality'),
          const ContentBlock.bullet(
            'DefaultTrackableEventHandler: Master OnTrackingFound() and OnTrackingLost(). These are called automatically when a target enters or leaves the camera view.',
          ),
          const ContentBlock.bullet(
            'Star Rating System (1–5): High-contrast, asymmetric images get 4-5 stars. Never ship an app with targets rated below 3 stars — they will drift and fail in real-world lighting.',
          ),
          const ContentBlock.bullet(
            'Initialization: Use VuforiaARController.Instance.RegisterVuforiaStartedCallback() to hook into the engine start sequence before activating AR objects.',
          ),
          const ContentBlock.subheading('Ground Plane (Surface Detection)'),
          const ContentBlock.bullet(
            'GroundPlaneStageController: Places virtual content on detected flat surfaces without any printed marker.',
          ),
          const ContentBlock.bullet(
            'PlaneFinderBehaviour: Triggers the real-time hit test that scans the floor/environment for valid placement points.',
          ),
          const ContentBlock.warning(
            'Ground Plane and Image Targets cannot run simultaneously in the same Vuforia session. You must choose one mode per scene.',
          ),
          const ContentBlock.subheading('Extended Tracking vs Device Tracker'),
          const ContentBlock.bullet(
            'Extended Tracking: A free feature where content stays fixed even if the camera looks away from the marker, using SLAM in the background.',
          ),
          const ContentBlock.bullet(
            'Device Tracker: A persistent world-tracking mode. Start it via TrackerManager.Instance.GetTracker<PositionalDeviceTracker>().Start() for long sessions where users walk away from the markers.',
          ),
          const ContentBlock.subheading('Production: License Keys'),
          const ContentBlock.body(
            'Never hardcode your license key. Store it in a ScriptableObject. Note that the "Basic" free license shuts down silently after 1,000 recognitions per month.',
          ),
          const ContentBlock.quote(
            'INTERVIEW FOCUS: Vuforia Target Quality\n'
            'Q: "A client\'s ImageTarget tracks poorly — what do you check first?"\n'
            'A: Check the target star rating in Vuforia Target Manager. Below 3 stars indicates insufficient feature points. Recommend a different image — high contrast, asymmetric, and rich in detail.',
          ),
        ],
      ),
      Topic(
        id: 'arcore_dev',
        title: 'ARCore Development',
        subtitle: 'Depth API, Instant Placement, and Geospatial VPS.',
        contentBlocks: [
          const ContentBlock.heading('ARCore Development (Android)'),
          const ContentBlock.body(
            'ARCore provides the world-tracking backbone for Android. To build flagship apps, you must go beyond simple plane detection.',
          ),
          const ContentBlock.subheading('Depth API (Native Occlusion)'),
          const ContentBlock.body(
            'Generates per-pixel depth maps using depth-from-motion — no LiDAR hardware required. Enable via config.depthMode = Config.DepthMode.AUTOMATIC.',
          ),
          const ContentBlock.bullet(
            'Occlusion: Compare virtual pixel depth against real-world depth (frame.acquireDepthImage16Bits()). If the real-world depth is closer, discard the virtual pixel.',
          ),
          const ContentBlock.bullet(
            'Accuracy: Most accurate between 0.5m and 5m. Best for e-commerce (e.g., Houzz) to ensure furniture doesn\'t "float" over real objects.',
          ),
          const ContentBlock.subheading('Instant Placement'),
          const ContentBlock.body(
            'Allows users to place objects immediately without waiting for plane scanning. Initial tracking uses estimated distance and "jumps" to full tracking once a plane is confirmed.',
          ),
          const ContentBlock.subheading('Geospatial API (VPS)'),
          const ContentBlock.body(
            'Uses Google Street View data to place AR content anywhere globally with GPS precision. VPS matches camera pixels against a global neural network point cloud.',
          ),
          const ContentBlock.bullet(
            'Anchor Types: WGS84 (Lat/Long/Alt), Terrain (lat/long only), and Rooftop anchors.',
          ),
          const ContentBlock.code(
            '// Check VPS availability before hosting\n'
            'session.checkVpsAvailabilityAsync(lat, lng) { availability ->\n'
            '  if (availability == VpsAvailability.AVAILABLE) { /* Safe to host */ }\n'
            '}',
          ),
          const ContentBlock.quote(
            'INTERVIEW FOCUS: Depth API\n'
            'Q: "How do you implement realistic occlusion in ARCore?"\n'
            'A: Enable Depth API in config. Acquire the 16-bit depth image per frame. In your shader, compare virtual depth vs real depth — if real is closer, discard the virtual fragment.',
          ),
        ],
      ),
      Topic(
        id: 'arkit_dev',
        title: 'ARKit & RealityKit (iOS)',
        subtitle: 'LiDAR, People Occlusion, and 4K Capture.',
        contentBlocks: [
          const ContentBlock.heading('The Apple AR Stack'),
          const ContentBlock.body(
            'Apple\'s stack is optimized for the A-series chips. RealityKit is built from the ground up for AR with physically-based rendering (PBR), automatic environment reflections, grounding shadows, and spatial audio.',
          ),
          const ContentBlock.subheading('RealityKit vs SceneKit — The Modern Choice'),
          const ContentBlock.bullet(
            'RealityKit: Uses Entity Component System (ECS). Entity holds Components (ModelComponent, PhysicsBodyComponent), and Systems process them. Unified across iOS, macOS, and visionOS.',
          ),
          const ContentBlock.bullet(
            'SceneKit: General-purpose 3D engine. No longer recommended for new AR projects unless maintaining old code.',
          ),
          const ContentBlock.code(
            '// RealityKit: Placing a USDZ model\n'
            'let anchor = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: [0.2, 0.2]))\n'
            'let modelEntity = try! ModelEntity.load(named: "toy_car.usdz")\n'
            'anchor.addChild(modelEntity)\n'
            'arView.scene.anchors.append(anchor)',
          ),
          const ContentBlock.subheading('People Occlusion'),
          const ContentBlock.body(
            'Segments real people so virtual content renders behind them correctly. Only available on A12 chip and later.',
          ),
          const ContentBlock.code(
            'config.frameSemantics = .personSegmentationWithDepth // Enable occlusion',
          ),
          const ContentBlock.subheading('LiDAR-Specific Features'),
          const ContentBlock.bullet(
            'Scene Reconstruction: Enables precise occlusion and physics collisions with real surfaces. Virtual balls can literally bounce off real tables.',
          ),
          const ContentBlock.bullet(
            'ARMeshGeometry: LiDAR generates a live dense mesh of the real environment instantly.',
          ),
          const ContentBlock.quote(
            'INTERVIEW FOCUS: RealityKit vs SceneKit\n'
            'Q: "Would you use SceneKit or RealityKit for a new AR project in 2025?"\n'
            'A: RealityKit. It includes PBR rendering, automatic lighting, grounding shadows, and spatial audio with no extra code. SceneKit is a general engine that predates AR and requires manual implementation of these features.',
          ),
        ],
      ),
      Topic(
        id: 'ar_foundation_dev',
        title: 'AR Foundation (Unity)',
        subtitle: 'Cross-Platform Management.',
        contentBlocks: [
          const ContentBlock.heading('AR Foundation — The Industry Standard'),
          const ContentBlock.subheading('Setup & XR Plugin Management'),
          const ContentBlock.bullet(
            'Plugins: You must install com.unity.xr.arcore and com.unity.xr.arkit separately. Forgetting one is the #1 cause of "black screens" on one platform.',
          ),
          const ContentBlock.bullet(
            'Build Settings: iOS requires Camera Usage Description in Info.plist or the app will crash on launch.',
          ),
          const ContentBlock.subheading('Graceful Degradation'),
          const ContentBlock.body(
            'Never assume a feature exists. Use "Descriptor" checks to see if hardware (like LiDAR) supports your desired feature before activating it.',
          ),
          const ContentBlock.code(
            'if (planeManager.descriptor?.supportsBoundaryVertices == true) {\n'
            '    // Use high-fidelity boundary points\n'
            '}',
          ),
          const ContentBlock.subheading('AROcclusionManager'),
          const ContentBlock.body(
            'The central component for Depth in AR Foundation. Must be explicitly added to the AR Camera to enable real-world occlusion.',
          ),
        ],
      ),
      Topic(
        id: 'permissions_publishing',
        title: 'Permissions & Build Config',
        subtitle: 'Shipping a 5-Star App.',
        contentBlocks: [
          const ContentBlock.heading('Production Readiness'),
          const ContentBlock.subheading('Android Permissions'),
          const ContentBlock.bullet(
            'CAMERA and ACCESS_FINE_LOCATION (for Geospatial) are mandatory runtime requests.',
          ),
          const ContentBlock.bullet(
            'arcore:required vs optional: "Required" filters out non-AR phones from Google Play store automatically.',
          ),
          const ContentBlock.subheading('iOS Privacy'),
          const ContentBlock.bullet(
            'NSCameraUsageDescription in Info.plist is the most critical item. Missing it = Instant App Store rejection.',
          ),
          const ContentBlock.subheading('Build Size Tips'),
          const ContentBlock.bullet(
            'Vuforia adds ~30MB to your build. Use texture compression (ETC2/ASTC) and Unity Addressables to keep your initial APK small.',
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
    description: 'Techniques for reliable, smooth, and efficient AR experiences.',
    icon: Icons.speed_rounded,
    order: 5,
    unlockCost: 1,
    requiredQuizId: 'quiz_dev',
    topics: [
      Topic(
        id: 'anchor_stability',
        title: 'Anchor-Based Positioning',
        subtitle: 'Stable content placement strategies.',
        contentBlocks: [
          const ContentBlock.heading('Anchor-Based Positioning'),
          const ContentBlock.body(
            'Anchors are the primary mechanism for keeping virtual content fixed in the real world. '
            'Proper anchor management is foundational to a stable AR experience.',
          ),
          const ContentBlock.subheading('Best Practices'),
          const ContentBlock.bullet(
            'Place anchors on high-confidence tracked surfaces — preferably plane hits over raw feature points.',
          ),
          const ContentBlock.bullet(
            'Keep the number of simultaneously active anchors as low as possible to reduce computational overhead.',
          ),
          const ContentBlock.bullet(
            'Re-anchor content if tracking quality degrades over a session.',
          ),
          const ContentBlock.bullet(
            'Use Cloud Anchors for shared or multi-user experiences where content must persist across devices and sessions.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('Anchor Tracking States'),
          const ContentBlock.body(
            'All AR platforms expose a tracking state for each anchor. Your app must respond to each state:',
          ),
          const ContentBlock.bullet(
            'TRACKING: Pose is current and reliable. Render content normally.',
          ),
          const ContentBlock.bullet(
            'LIMITED / PAUSED: Pose is unreliable. Optionally hide or freeze content to prevent jitter.',
          ),
          const ContentBlock.bullet(
            'NOT_TRACKING / STOPPED: Anchor is permanently lost. Remove associated content and prompt re-placement.',
          ),
          const ContentBlock.info(
            'On ARCore: Anchor.getTrackingState(). On AR Foundation: ARAnchor.trackingState. '
            'On ARKit: ARAnchor does not have a tracking state directly — monitor via ARSessionDelegate.',
          ),
          const ContentBlock.code(
            '// Unity AR Foundation: Handling Anchor States\n'
            'void OnAnchorsChanged(ARAnchorsChangedEventArgs args) {\n'
            '    foreach (var updatedAnchor in args.updated) {\n'
            '        if (updatedAnchor.trackingState == TrackingState.None) {\n'
            '            // Anchor lost: optionally hide the attached 3D model\n'
            '            updatedAnchor.gameObject.SetActive(false);\n'
            '        }\n'
            '    }\n'
            '}',
          ),
          const ContentBlock.quote(
            'INTERVIEW FOCUS: Why use multiple anchors? \n'
            'Answer: SLAM maps are not perfectly rigid. As the map is refined, different areas '
            'of the physical world may shift relative to each other. Using local anchors ensures '
            'that objects stay fixed relative to the geometry closest to them.',
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
            'AR tracking quality fluctuates continuously based on environmental conditions, device motion, '
            'and sensor reliability. A robust app responds gracefully to every tracking state.',
          ),
          const ContentBlock.subheading('Tracking States (AR Foundation)'),
          const ContentBlock.numbered(
            '1. TrackingState.Tracking: Full 6DoF pose available. All AR content renders normally.',
          ),
          const ContentBlock.numbered(
            '2. TrackingState.Limited: Tracking is degraded. Show cautionary UI. Freeze or hide moving content.',
          ),
          const ContentBlock.numbered(
            '3. TrackingState.None: Tracking is fully lost. Hide AR content. Show recovery guidance.',
          ),
          const ContentBlock.subheading('Recovery Strategies'),
          const ContentBlock.bullet(
            'Display a contextual hint: "Move your device slowly in a scanning motion to restore tracking."',
          ),
          const ContentBlock.bullet(
            'Freeze the last known object pose to prevent jitter — don\'t let the object jump erratically.',
          ),
          const ContentBlock.bullet(
            'Gradually fade out AR content as tracking degrades, rather than abruptly hiding it.',
          ),
          const ContentBlock.bullet(
            'Re-initialise the AR session if tracking cannot be recovered after a timeout.',
          ),
          const ContentBlock.warning(
            'Never hide the camera feed when tracking is lost — it disorients the user completely. '
            'Always keep the camera visible and overlay a translucent guidance message on top of it.',
          ),
          const ContentBlock.quote(
            'PRO TIP: Use "Visual Consistency" cues. \n'
            'If tracking is LIMITED, desaturate the virtual content or show a ghosting effect. '
            'This non-verbally communicates to the user that the alignment is currently approximate.',
          ),
        ],
      ),
      Topic(
        id: 'drift_reduction',
        title: 'Drift Reduction',
        subtitle: 'Minimising positional drift over time.',
        contentBlocks: [
          const ContentBlock.heading('What Is Drift and Why Does It Happen?'),
          const ContentBlock.body(
            'Drift occurs when small, cumulative errors in pose estimation cause virtual content to '
            'gradually shift from its intended real-world position. Over a long session, even centimetre-scale '
            'drift becomes visually obvious and breaks the AR illusion.',
          ),
          const ContentBlock.subheading('Drift Reduction Techniques'),
          const ContentBlock.bullet(
            'Loop Closure: When SLAM detects that the device has revisited a mapped area, it corrects the accumulated error across the whole map — a global correction.',
          ),
          const ContentBlock.bullet(
            'Re-anchoring: Periodically creating new anchors near the user refreshes local tracking accuracy.',
          ),
          const ContentBlock.bullet(
            'IMU Bias Estimation: The system continuously estimates and corrects sensor biases in the accelerometer and gyroscope.',
          ),
          const ContentBlock.bullet(
            'Multi-anchor Distribution: Spreading multiple anchors across a scene distributes error instead of concentrating it in one area.',
          ),
          const ContentBlock.bullet(
            'Cloud Anchor Relocalization: Re-aligning to a cloud-stored spatial map at session start provides a high-accuracy global reference.',
          ),
          const ContentBlock.info(
            'For enterprise deployments requiring millimetre accuracy (e.g., surgical planning, precision assembly), '
            'GPS or fiducial marker corrections are added on top of VIO to bound drift to acceptable levels.',
          ),
          const ContentBlock.quote(
            'INTERVIEW QUESTION: "How do you solve drift in a city-scale experience?" \n'
            'Answer: Use a Visual Positioning System (VPS) like Google Geospatial or Niantic Lightship. '
            'These systems relocalize against a massive database of pre-scanned street-level features '
            'to reset the coordinate system and eliminate accumulated VIO drift.',
          ),
        ],
      ),
      Topic(
        id: 'performance_opt',
        title: 'Performance Optimization',
        subtitle: 'Frame rate, memory, and rendering efficiency.',
        contentBlocks: [
          const ContentBlock.heading('Why 60 FPS Is the Minimum Target'),
          const ContentBlock.body(
            'AR applications must maintain 60 FPS for a comfortable, stable experience. '
            'Dropped frames cause visible jitter in the AR overlay, break the illusion of registration, '
            'and can trigger motion discomfort. On HMDs, even lower frame rates can cause nausea.',
          ),
          const ContentBlock.subheading('Rendering Optimisation'),
          const ContentBlock.bullet(
            'LOD (Level of Detail): Automatically swap high-poly models for lower-poly versions at increasing distances.',
          ),
          const ContentBlock.bullet(
            'Texture Atlasing: Combine multiple textures into one, reducing draw calls.',
          ),
          const ContentBlock.bullet(
            'Baked Lighting: Pre-calculate static lighting offline. Reserve real-time lighting only for dynamic elements.',
          ),
          const ContentBlock.bullet(
            'Frustum & Occlusion Culling: Do not render objects the camera cannot see.',
          ),
          const ContentBlock.divider(),
          const ContentBlock.subheading('Memory Management'),
          const ContentBlock.bullet(
            'Unload unused assets and textures when they leave the scene.',
          ),
          const ContentBlock.bullet(
            'Use GPU-compressed texture formats: ASTC on iOS, ETC2 on Android. These load directly to the GPU without CPU decompression.',
          ),
          const ContentBlock.bullet(
            'Object Pooling: Reuse GameObjects instead of Instantiate/Destroy cycles, which cause GC spikes.',
          ),
          const ContentBlock.subheading('AR-Specific Optimisations'),
          const ContentBlock.bullet(
            'Disable plane visualisation meshes after initial object placement.',
          ),
          const ContentBlock.bullet(
            'Throttle or stop plane detection once the user has placed their content.',
          ),
          const ContentBlock.bullet(
            'Reduce camera feed resolution if maximum resolution is not required for tracking.',
          ),
          const ContentBlock.bullet(
            'Monitor GPU and CPU thermal state — extended AR sessions heat the device, triggering throttling that drops FPS.',
          ),
          const ContentBlock.warning(
            'Always profile on physical target devices, not in the Unity Editor or simulator. '
            'Mobile GPU characteristics, thermal throttling, and camera pipeline overhead differ dramatically '
            'from desktop hardware. Use Xcode Instruments (iOS) or Android GPU Inspector for accurate profiling.',
          ),
          const ContentBlock.code(
            '// Unity: Dynamic resolution scaling based on frame rate\n'
            'void Update() {\n'
            '    if (1.0f / Time.deltaTime < 30f) {\n'
            '        // FPS dropped below 30, reduce render scale\n'
            '        ScalableBufferManager.ResizeBuffers(0.5f, 0.5f);\n'
            '    }\n'
            '}',
          ),
          const ContentBlock.quote(
            'PRO INSIGHT: The "Draw Call" bottleneck in AR. \n'
            'In AR, the CPU is often the bottleneck because it has to manage the camera pipeline, '
            'CV tracking, and 3D scene logic simultaneously. Optimize by batching static meshes '
            'to keep draw calls under 100 for mobile.',
          ),
        ],
      ),
      Topic(
        id: 'thermal_and_battery',
        title: 'Thermal Management & Battery',
        subtitle: 'Sustaining AR over long sessions.',
        contentBlocks: [
          const ContentBlock.heading('The AR Battery and Thermal Challenge'),
          const ContentBlock.body(
            'AR is among the most power-intensive mobile workloads: the camera runs continuously, '
            'computer vision algorithms process every frame, and the GPU renders both the camera feed '
            'and 3D content simultaneously. Long sessions degrade performance through thermal throttling.',
          ),
          const ContentBlock.subheading('Thermal Throttling'),
          const ContentBlock.body(
            'When a device reaches its thermal limit, the OS reduces CPU and GPU clock speeds to prevent damage. '
            'This can cause sudden, severe FPS drops mid-session — even if the app was performing well initially.',
          ),
          const ContentBlock.subheading('Mitigation Strategies'),
          const ContentBlock.bullet(
            'Monitor thermal state (iOS: ProcessInfo.processInfo.thermalState) and reduce rendering quality dynamically when the device gets hot.',
          ),
          const ContentBlock.bullet(
            'Use lower camera resolutions when high resolution is not needed for tracking accuracy.',
          ),
          const ContentBlock.bullet(
            'Cap the frame rate at 30 FPS during low-interaction phases (e.g., watching a video in AR) to reduce heat.',
          ),
          const ContentBlock.bullet(
            'Avoid running heavy background tasks (network, file I/O) simultaneously with the AR session.',
          ),
          const ContentBlock.info(
            'For long-duration industrial AR sessions (30+ minutes), thermal management is as critical '
            'as tracking quality. A device that throttles to 15 FPS after 20 minutes makes the app unusable.',
          ),
          const ContentBlock.code(
            '// iOS Swift: Monitoring Thermal State\n'
            'NotificationCenter.default.addObserver(self, selector: #selector(thermalStateChanged), '
            'name: ProcessInfo.thermalStateDidChangeNotification, object: nil)\n\n'
            '@objc func thermalStateChanged() {\n'
            '    let state = ProcessInfo.processInfo.thermalState\n'
            '    if state == .serious || state == .critical {\n'
            '        // Disable heavy post-processing / particles\n'
            '    }\n'
            '}',
          ),
          const ContentBlock.quote(
            'INTERVIEW FOCUS: Thermal Management. \n'
            'Question: "How do you detect and react to overheating?" \n'
            'Answer: Use platform APIs (iOS: thermalState, Android: PowerManager) to monitor temperature. '
            'If high, dynamically lower the render resolution, cap the FPS at 30, or disable heavy '
            'post-processing effects.',
          ),
        ],
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  MODULE 6 — Advanced Topics
  // ───────────────────────────────────────────────────────────────
  LearningModule(
    id: 'mod_advanced',
    title: 'Advanced AR Knowledge',
    description: 'Deep-dive topics: Cloud Anchors, Depth API, and the future of AR.',
    icon: Icons.rocket_launch_rounded,
    order: 6,
    unlockCost: 1,
    requiredQuizId: 'quiz_stab',
    topics: [
      Topic(
        id: 'cloud_anchors',
        title: 'Cloud Anchors & Shared AR',
        subtitle: 'Multi-User Persistence.',
        contentBlocks: [
          const ContentBlock.heading('Cloud Anchors & Shared Experiences'),
          const ContentBlock.body(
            'Cloud Anchors allow multiple users to see the same virtual object in the same physical spot, even across iOS and Android.',
          ),
          const ContentBlock.subheading('Workflow & Reliability'),
          const ContentBlock.numbered(
            '1. Host device creates an anchor. Always check CloudAnchorState == SUCCESS before sharing the ID.',
          ),
          const ContentBlock.numbered(
            '2. TTL (Time to Live): Anchors expire in 24h by default. Set ttlDays (up to 365) for long-term persistence.',
          ),
          const ContentBlock.numbered(
            '3. Resolving: Guest devices call resolveCloudAnchorAsync(id) to align their coordinate systems.',
          ),
          const ContentBlock.info(
            'ERROR_HOSTING_DATASET_PROCESSING_FAILED means the environment wasn\'t mapped richly enough. Move the device more to capture a better feature point cloud.',
          ),
          const ContentBlock.quote(
            'INTERVIEW FOCUS: Shared AR Architecture\n'
            'Q: "How do you build a multi-user AR app with 10 users?"\n'
            'A: Use ARCore Cloud Anchors. One device hosts the anchor while scanning the surface. The resulting ID is shared via a background server (like Firebase). Other devices resolve that ID to synchronize their spatial coordinates.',
          ),
        ],
      ),
      Topic(
        id: 'depth_occlusion',
        title: 'Depth API & Occlusion',
        subtitle: 'Realistic Environment Interaction.',
        contentBlocks: [
          const ContentBlock.heading('How the Depth API Works'),
          const ContentBlock.body(
            'The Depth-from-motion algorithm takes multiple RGB frames from different angles and compares pixel displacement to compute distance per pixel. Depth accuracy is best between 0.5m and 5m.',
          ),
          const ContentBlock.subheading('Occlusion Rendering — Two Approaches'),
          const ContentBlock.bullet(
            'Per-Object Forward-Pass: Each material shader reads depth and clips occluded pixels. Best for simple scenes.',
          ),
          const ContentBlock.bullet(
            'Two-Pass Rendering: Renders virtual content to a buffer, and then composites onto camera feed. Better for complex scenes.',
          ),
          const ContentBlock.subheading('Depth for Hit Testing'),
          const ContentBlock.body(
            'Depth hit tests find the actual surface geometry (e.g. carpet fibers), not just the estimated plane. frame.hitTest() uses this automatically when enabled.',
          ),
          const ContentBlock.code(
            '// Acquire depth image (Kotlin)\n'
            'config.depthMode = Config.DepthMode.AUTOMATIC\n'
            'frame.acquireDepthImage16Bits().use { depthImage ->\n'
            '    val width = depthImage.width\n'
            '    val height = depthImage.height\n'
            '    // Each pixel is uint16 in millimetres\n'
            '}',
          ),
          const ContentBlock.quote(
            'INTERVIEW FOCUS: Depth API\n'
            'Q: "How would you implement realistic occlusion in an ARCore app?"\n'
            'A: Enable Depth API in session config (Config.DepthMode.AUTOMATIC). Acquire the depth image per frame and pass it to your fragment shader. Compare virtual depth vs real depth and discard pixels if real depth is closer.',
          ),
        ],
      ),
      Topic(
        id: 'scene_semantics',
        title: 'Scene Semantics API',
        subtitle: 'Giving the World Meaning.',
        contentBlocks: [
          const ContentBlock.heading('Understanding Your Environment\'s Meaning'),
          const ContentBlock.body(
            'Scene Semantics classifies each pixel of the camera image into labels like Sky, Building, Tree, Road, and Water.',
          ),
          const ContentBlock.subheading('Practical Applications'),
          const ContentBlock.bullet(
            'Sky Replacement: Swap "Sky" pixels with custom textures.',
          ),
          const ContentBlock.bullet(
            'Terrain-Aware Placement: Ensure objects only spawn on "Sidewalk" or "Terrain" labels.',
          ),
          const ContentBlock.code(
            'frame.acquireSemanticImage().use { semanticImage ->\n'
            '    val label = semanticImage.getSemanticLabelAt(x, y)\n'
            '    if (label == SemanticLabel.SKY) { /* Replace Sky */ }\n'
            '}',
          ),
          const ContentBlock.subheading('Scene Semantics + Geospatial Depth'),
          const ContentBlock.body(
            'When combined, Geospatial Depth API improves accuracy up to 65 metres — far beyond the 5m limit of motion-based depth.',
          ),
        ],
      ),
      Topic(
        id: 'recording_playback',
        title: 'Recording & Playback API',
        subtitle: 'The Developer\'s Time Machine.',
        contentBlocks: [
          const ContentBlock.heading('Record AR Sessions for Debugging'),
          const ContentBlock.body(
            'The Recording API captures camera feed, IMU, and tracking data to an MP4 file. You can replay this file in Android Studio as if it were a live session.',
          ),
          const ContentBlock.subheading('Why This Is Transformative'),
          const ContentBlock.bullet(
            'Remote Testing: Record a unique physical space and share it with remote teammates who can\'t travel to that location.',
          ),
          const ContentBlock.bullet(
            'Automated Testing: Use Playback to run CI/CD tests against known environment datasets.',
          ),
          const ContentBlock.bullet(
            'No Device Needed: Once recorded, you can debug logic without holding the phone or being in the AR space.',
          ),
        ],
      ),
      Topic(
        id: 'ar_future',
        title: 'Future of AR',
        subtitle: 'Emerging trends and technologies.',
        contentBlocks: [
          const ContentBlock.heading('The Near-Future of Augmented Reality'),
          const ContentBlock.body(
            'AR technology is evolving rapidly across hardware, software, and standards. '
            'Understanding these trajectories positions you as a forward-thinking practitioner.',
          ),
          const ContentBlock.subheading('Emerging Hardware Trends'),
          const ContentBlock.bullet(
            'True AR Glasses: Lightweight, socially acceptable OST glasses. Meta Orion (2024 prototype) and upcoming consumer waveguide devices aim for all-day wearability.',
          ),
          const ContentBlock.bullet(
            'Neural Interfaces: Early-stage research into BCI (Brain-Computer Interface) input for XR, potentially replacing hand controllers.',
          ),
          const ContentBlock.bullet(
            'Foveated Rendering: Tracking the user\'s gaze to render only the foveal region at full quality, dramatically reducing GPU load on HMDs.',
          ),
          const ContentBlock.subheading('Software & Platform Trends'),
          const ContentBlock.bullet(
            'World-Scale AR: Persistent, city-scale 3D maps enabling outdoor navigation AR — already emerging via Google Geospatial API and Niantic Lightship.',
          ),
          const ContentBlock.bullet(
            'Generative AI + AR: Real-time 3D content generation and AI-driven scene understanding for automatic semantic labelling of the environment.',
          ),
          const ContentBlock.bullet(
            'OpenXR Adoption: Broad industry standardisation reducing fragmentation across platforms.',
          ),
          const ContentBlock.subheading('Challenges Ahead'),
          const ContentBlock.bullet(
            'Privacy: Always-on spatial cameras raise significant concerns around environmental data capture and biometric identification.',
          ),
          const ContentBlock.bullet(
            'Battery & Thermal: Sustained AR computing at glasses form-factor remains a major unsolved hardware challenge.',
          ),
          const ContentBlock.bullet(
            'Social Acceptance: Public and workplace norms around wearing cameras on your face are still forming.',
          ),
          const ContentBlock.info(
            'The spatial computing market is projected to grow substantially through the late 2020s, '
            'driven by enterprise adoption in manufacturing, healthcare, and logistics. '
            'AR developers with deep technical knowledge are consistently among the most sought-after roles.',
          ),
        ],
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  MODULE 7 — WebAR Fundamentals
  // ───────────────────────────────────────────────────────────────
  LearningModule(
    id: 'webar',
    title: 'WebAR Fundamentals',
    description: 'Bringing AR directly to the web browser — no app installation required.',
    icon: Icons.public_rounded,
    order: 7,
    unlockCost: 1,
    requiredQuizId: 'quiz_advanced_ar',
    topics: [
      Topic(
        id: 'webar_intro',
        title: 'What Is WebAR?',
        subtitle: 'AR running directly in the mobile browser.',
        contentBlocks: [
          const ContentBlock.heading('WebAR: Zero-Install Augmented Reality'),
          const ContentBlock.body(
            'WebAR delivers AR experiences through a standard mobile web browser — no app store, '
            'no download, no installation. The user taps a link or scans a QR code and the AR experience '
            'opens immediately.',
          ),
          const ContentBlock.subheading('Why It Matters'),
          const ContentBlock.body(
            'Requiring a native app for a single-use AR experience creates a significant drop-off in user engagement. '
            'WebAR eliminates this friction entirely, making it the preferred delivery method for consumer marketing, '
            'retail, education, and single-session industrial guides.',
          ),
          const ContentBlock.subheading('Core Technology Stack'),
          const ContentBlock.bullet(
            'WebXR Device API: The W3C browser standard for immersive experiences. Supported natively in Chrome on Android.',
          ),
          const ContentBlock.bullet(
            'Three.js: The most widely used JavaScript 3D rendering library. Powers the visual layer of most WebAR scenes.',
          ),
          const ContentBlock.bullet(
            'A-Frame: A declarative HTML-based framework built on Three.js. Makes basic WebAR scenes accessible without deep JS knowledge.',
          ),
          const ContentBlock.bullet(
            '8th Wall: The commercial leader in WebAR. Implements full SLAM tracking via WebAssembly, supporting devices that do not yet have native WebXR support.',
          ),
          const ContentBlock.info(
            'WebXR AR (immersive-ar mode) is currently supported natively on Chrome for Android. '
            'iOS Safari does not natively support WebXR AR. WebAR SDKs like 8th Wall bridge this gap with their own tracking stack.',
          ),
          const ContentBlock.quote(
            'INTERVIEW QUESTION: "Why would you choose 8th Wall over the free WebXR API?" \n'
            'Answer: Device Reach. WebXR is limited to modern Android devices. '
            '8th Wall supports both iOS and Android browsers by using its own WebAssembly SLAM engine, '
            'reaching billions of devices that WebXR cannot.',
          ),
        ],
      ),
      Topic(
        id: 'webar_architecture',
        title: 'WebAR Architecture',
        subtitle: 'How tracking works inside a browser.',
        contentBlocks: [
          const ContentBlock.heading('Inside the Browser Sandbox'),
          const ContentBlock.body(
            'A native AR app has direct access to the GPU and camera hardware. A web app runs inside a sandbox '
            'with restricted access. WebAR frameworks solve this through a combination of modern web APIs and '
            'compile-to-web technologies.',
          ),
          const ContentBlock.subheading('Key Technologies'),
          const ContentBlock.bullet(
            'WebAssembly (Wasm): C/C++ computer vision code (SLAM, feature tracking) is compiled to Wasm for near-native execution speed inside the browser.',
          ),
          const ContentBlock.bullet(
            'WebGL / WebGL2: The browser\'s GPU API. Used by Three.js to render 3D scenes and composit virtual content over the camera feed.',
          ),
          const ContentBlock.bullet(
            'MediaDevices.getUserMedia(): The Web API for accessing the device camera stream.',
          ),
          const ContentBlock.bullet(
            'DeviceMotion / DeviceOrientation API: Provides access to IMU data (accelerometer, gyroscope) in the browser for sensor fusion.',
          ),
          const ContentBlock.subheading('Asset Optimisation for the Web'),
          const ContentBlock.bullet(
            'Draco Mesh Compression: Reduces 3D model file sizes by 5–10× without perceptible quality loss.',
          ),
          const ContentBlock.bullet(
            'KTX2 / Basis Universal: Transcoding texture format that compresses to the native GPU format (ASTC on iOS, ETC2 on Android) at load time.',
          ),
          const ContentBlock.bullet(
            'glTF 2.0: The web standard for 3D assets. Compact, efficient, and directly supported by Three.js.',
          ),
          const ContentBlock.warning(
            'WebAR file size budget is critical. Aim to keep all assets under 5MB total for fast loading on mobile networks. '
            'Large assets are the most common cause of user abandonment in WebAR experiences.',
          ),
          const ContentBlock.quote(
            'PRO TIP: Use "KTX2" for textures. \n'
            'Standard PNG/JPGs occupy huge amounts of VRAM after being uncompressed by the browser. '
            'KTX2 textures remain compressed on the GPU, saving memory and preventing browser crashes.',
          ),
        ],
      ),
      Topic(
        id: 'webar_limitations',
        title: 'WebAR Limitations vs Native',
        subtitle: 'Where native still wins.',
        contentBlocks: [
          const ContentBlock.heading('WebAR Trade-offs'),
          const ContentBlock.body(
            'WebAR is a powerful delivery mechanism, but native apps retain meaningful advantages '
            'for certain use cases. Understanding these trade-offs is essential for making the right technology choice.',
          ),
          const ContentBlock.subheading('Where WebAR Falls Short'),
          const ContentBlock.bullet(
            'Performance: No direct GPU access means the rendering pipeline is less efficient than a native app. Complex scenes are more likely to drop frames.',
          ),
          const ContentBlock.bullet(
            'Hardware Access: LiDAR depth data, TrueDepth face tracking, and low-level camera controls are not accessible from the browser.',
          ),
          const ContentBlock.bullet(
            'Tracking Quality: Browser-based SLAM is very good with 8th Wall, but still lags behind ARKit and ARCore for precision-critical applications.',
          ),
          const ContentBlock.bullet(
            'Persistent State: No equivalent to native Cloud Anchors. Persistent multi-session experiences are difficult to implement in WebAR.',
          ),
          const ContentBlock.bullet(
            'Background Execution: Browser pages cannot run tracking in the background.',
          ),
          const ContentBlock.subheading('When to Choose WebAR'),
          const ContentBlock.bullet('Consumer campaigns with a single-use or one-time experience.'),
          const ContentBlock.bullet('Retail and e-commerce product visualisation.'),
          const ContentBlock.bullet('Educational content requiring maximum audience reach.'),
          const ContentBlock.subheading('When to Choose Native AR'),
          const ContentBlock.bullet('Long-session industrial guidance (30+ minutes per use).'),
          const ContentBlock.bullet('Precision applications requiring sub-centimetre accuracy.'),
          const ContentBlock.bullet('Apps requiring LiDAR, face tracking, or persistent anchors.'),
        ],
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  MODULE 8 — OpenXR Standard
  // ───────────────────────────────────────────────────────────────
  LearningModule(
    id: 'openxr',
    title: 'OpenXR Standard',
    description: 'The open standard unifying XR development across all platforms and devices.',
    icon: Icons.link_rounded,
    order: 8,
    unlockCost: 0,
    requiredQuizId: 'quiz_webar',
    topics: [
      Topic(
        id: 'openxr_intro',
        title: 'Why OpenXR Exists',
        subtitle: 'Solving the XR fragmentation problem.',
        contentBlocks: [
          const ContentBlock.heading('The Fragmentation Problem'),
          const ContentBlock.body(
            'Before OpenXR, every XR platform had its own proprietary API: '
            'Oculus SDK, SteamVR/OpenVR, HoloLens WMR SDK, HTC Vive SDK, and others. '
            'Developers had to write and maintain separate codepaths for every platform. '
            'OpenXR solves this by defining a single, open, royalty-free API for all XR hardware.',
          ),
          const ContentBlock.subheading('What Is OpenXR?'),
          const ContentBlock.body(
            'OpenXR is a specification developed by the Khronos Group — the same organisation behind OpenGL and Vulkan. '
            'An application written to the OpenXR API can run on any conformant XR runtime without modification.',
          ),
          const ContentBlock.subheading('Adoption'),
          const ContentBlock.bullet('Meta Quest (all headsets): Full OpenXR support.'),
          const ContentBlock.bullet('Microsoft HoloLens 2 / Windows Mixed Reality: Full OpenXR support.'),
          const ContentBlock.bullet('Valve SteamVR: Full OpenXR support.'),
          const ContentBlock.bullet('Unity XR: OpenXR plugin available as the recommended backend.'),
          const ContentBlock.bullet('Unreal Engine: Built-in OpenXR support.'),
          const ContentBlock.info(
            'Apple platforms (visionOS, ARKit) are the notable exception — Apple uses its own proprietary APIs '
            'and has not adopted OpenXR. This remains the primary fragmentation gap in the industry.',
          ),
          const ContentBlock.quote(
            'INTERVIEW FOCUS: The benefit of OpenXR. \n'
            'Question: "How does OpenXR help a developer?" \n'
            'Answer: It provides "Write once, run anywhere" for XR. A developer can write one '
            'C++ application and deploy it to Quest, HoloLens, and Index without recompiling for different SDKs.',
          ),
        ],
      ),
      Topic(
        id: 'openxr_arch',
        title: 'OpenXR Architecture',
        subtitle: 'Instances, sessions, and the action system.',
        contentBlocks: [
          const ContentBlock.heading('Core Concepts'),
          const ContentBlock.body(
            'OpenXR has a clear layered architecture between the application, the OpenXR loader, and the runtime.',
          ),
          const ContentBlock.bullet(
            'Instance (XrInstance): The connection between the application and the OpenXR runtime. Created once at startup.',
          ),
          const ContentBlock.bullet(
            'System (XrSystemId): Represents the XR hardware devices (headset and controllers). Queried from the instance.',
          ),
          const ContentBlock.bullet(
            'Session (XrSession): The active XR application context. Manages the render loop and frame lifecycle.',
          ),
          const ContentBlock.bullet(
            'Reference Spaces (XrSpace): Defines coordinate frames — STAGE (room-scale), LOCAL (head-centred), VIEW (eye-centred).',
          ),
          const ContentBlock.subheading('The Action System'),
          const ContentBlock.body(
            'OpenXR uses an abstract Action System for input — rather than querying specific button names, '
            'developers define abstract actions (e.g., "select", "grab") and bind them to interaction profiles. '
            'The runtime maps these to the actual hardware buttons.',
          ),
          const ContentBlock.bullet(
            'Interaction Profile: A descriptor for a specific controller type (e.g., /interaction_profiles/oculus/touch_controller).',
          ),
          const ContentBlock.bullet(
            'Suggested Binding: The application suggests a mapping from its abstract action to a physical input path.',
          ),
          const ContentBlock.info(
            'The Action System is what makes OpenXR truly portable: the same "select" action works on '
            'a Meta Touch controller, a HoloLens hand gesture, and a keyboard — without any application code changes.',
          ),
          const ContentBlock.subheading('Extensions'),
          const ContentBlock.body(
            'Advanced features (hand tracking, eye tracking, passthrough, performance metrics) are exposed as '
            'OpenXR extensions. Core OpenXR is lean; everything platform-specific is an extension.',
          ),
          const ContentBlock.quote(
            'PRO INSIGHT: The "Action System" is the secret sauce. \n'
            'Instead of coding "If the A button is pressed," you code "If the Select action is triggered." '
            'The runtime then maps "Select" to whatever button or gesture makes sense for that hardware.',
          ),
          const ContentBlock.code(
            '// OpenXR: Creating an Action (C++)\n'
            'XrActionCreateInfo actionInfo{XR_TYPE_ACTION_CREATE_INFO};\n'
            'strcpy(actionInfo.actionName, "grab_object");\n'
            'actionInfo.actionType = XR_ACTION_TYPE_BOOLEAN_INPUT;\n'
            'xrCreateAction(actionSet, &actionInfo, &grabAction);',
          ),
        ],
      ),
      Topic(
        id: 'openxr_vs_arkit',
        title: 'OpenXR vs ARKit / ARCore',
        subtitle: 'Understanding where each standard fits.',
        contentBlocks: [
          const ContentBlock.heading('Different Tools for Different Problems'),
          const ContentBlock.body(
            'OpenXR, ARKit, and ARCore are not alternatives — they target different problems and platforms. '
            'Understanding this distinction is important for architecture decisions.',
          ),
          const ContentBlock.subheading('Scope Comparison'),
          const ContentBlock.bullet(
            'OpenXR: A cross-platform API focused on the XR rendering loop, tracking spaces, and input. Primarily targets HMDs (headsets). Not optimised for mobile phone AR.',
          ),
          const ContentBlock.bullet(
            'ARKit: Apple\'s full-stack mobile AR SDK for iOS/iPadOS. Covers tracking, plane detection, object recognition, face tracking, and rendering integration. No OpenXR.',
          ),
          const ContentBlock.bullet(
            'ARCore: Google\'s full-stack mobile AR SDK for Android. Covers the same scope as ARKit for the Android ecosystem.',
          ),
          const ContentBlock.subheading('AR Foundation\'s Role'),
          const ContentBlock.body(
            'Unity\'s AR Foundation bridges ARKit and ARCore into one C# API — playing a similar abstraction role '
            'to OpenXR, but specifically for mobile phone AR rather than headsets.',
          ),
          const ContentBlock.info(
            'In practice: if you are building for headsets (HoloLens, Quest, SteamVR), learn OpenXR. '
            'If you are building for iOS/Android phones, learn ARKit/ARCore/AR Foundation. '
            'Enterprise cross-device projects may need to understand all three.',
          ),
        ],
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  MODULE 9 — The AR Cloud
  // ───────────────────────────────────────────────────────────────
  LearningModule(
    id: 'ar_cloud',
    title: 'The AR Cloud',
    description: 'Persistent, shared, and city-scale spatial computing experiences.',
    icon: Icons.cloud_rounded,
    order: 9,
    unlockCost: 0,
    requiredQuizId: 'quiz_openxr',
    topics: [
      Topic(
        id: 'arcloud_concept',
        title: 'What Is the AR Cloud?',
        subtitle: 'A persistent digital layer over the physical world.',
        contentBlocks: [
          const ContentBlock.heading('Beyond Single-User, Single-Session AR'),
          const ContentBlock.body(
            'Today\'s standard mobile AR is ephemeral: objects disappear when you close the app, '
            'and no one else can see what you placed. The AR Cloud envisions a world where digital content '
            'is persistent — it stays exactly where you left it — and shared — everyone with the right app sees it.',
          ),
          const ContentBlock.subheading('Core Properties'),
          const ContentBlock.bullet(
            'Persistence: Virtual objects remain anchored in the physical world across sessions, days, and device restarts.',
          ),
          const ContentBlock.bullet(
            'Multiuser: Multiple users on different devices, in the same physical space, see the same virtual objects simultaneously.',
          ),
          const ContentBlock.bullet(
            'World Scale: A sufficiently dense AR Cloud could map entire buildings, campuses, or cities.',
          ),
          const ContentBlock.info(
            'The AR Cloud requires a high-precision 3D spatial map of the environment stored server-side, '
            'combined with fast relocalization on the device — the ability to instantly recognise "where I am" '
            'relative to the stored map.',
          ),
        ],
      ),
      Topic(
        id: 'arcloud_platforms',
        title: 'AR Cloud Platforms',
        subtitle: 'Azure Spatial Anchors, Google Cloud Anchors, and Niantic Lightship.',
        contentBlocks: [
          const ContentBlock.heading('Current AR Cloud Solutions'),
          const ContentBlock.subheading('Azure Spatial Anchors (ASA)'),
          const ContentBlock.body(
            'Microsoft\'s enterprise AR Cloud. Stores spatial anchors in Azure, supports iOS, Android, and HoloLens. '
            'Designed for large industrial deployments: a factory floor, a hospital wing, a construction site.',
          ),
          const ContentBlock.bullet('Cross-platform and cross-device by design.'),
          const ContentBlock.bullet('Supports "nearby anchors" queries to discover anchors in a physical area.'),
          const ContentBlock.bullet('Integrates with Azure services for enterprise security and access control.'),
          const ContentBlock.subheading('Google Cloud Anchors (ARCore)'),
          const ContentBlock.body(
            'Google\'s AR Cloud for consumer and developer use. Limited to ARCore-compatible Android devices. '
            'Best suited for multi-user shared social or gaming experiences.',
          ),
          const ContentBlock.subheading('Niantic Lightship (VPS)'),
          const ContentBlock.body(
            'Niantic\'s Visual Positioning System uses crowdsourced scans from Pokémon GO and Ingress players '
            'to build a global AR Cloud. Developers can access it through the Lightship SDK.',
          ),
          const ContentBlock.bullet('Covers tens of thousands of real-world locations.'),
          const ContentBlock.bullet('Enables centimetre-accurate relocalization at street scale.'),
          const ContentBlock.info(
            'The AR Cloud is the infrastructure that transforms AR from a personal toy into a shared communication layer — '
            'the equivalent of what the internet did for information, applied to physical space.',
          ),
          const ContentBlock.quote(
            'PRO INSIGHT: The AR Cloud is "The Digital Twin of the World." \n'
            'Companies like Google and Apple are building this not just for fun, '
            'but because whoever owns the 3D map of the world owns the interface '
            'for the next decade of spatial computing.',
          ),
          const ContentBlock.code(
            '// Google Cloud Anchors: Hosting an anchor (Kotlin)\n'
            'session.hostCloudAnchorAsync(anchor) { cloudAnchorId, state ->\n'
            '    if (state == Anchor.CloudAnchorState.SUCCESS) {\n'
            '        // Share cloudAnchorId to your backend (e.g. Firebase)\n'
            '        saveToFirebase(cloudAnchorId)\n'
            '    }\n'
            '}',
          ),
        ],
      ),
      Topic(
        id: 'arcloud_challenges',
        title: 'AR Cloud Challenges',
        subtitle: 'Privacy, scale, and technical hurdles.',
        contentBlocks: [
          const ContentBlock.heading('Unsolved Problems'),
          const ContentBlock.body(
            'The AR Cloud is technically achievable in controlled environments, but achieving '
            'world-scale deployment presents formidable challenges.',
          ),
          const ContentBlock.subheading('Technical Challenges'),
          const ContentBlock.bullet(
            'Map Size: A dense 3D map of a city is enormously large. Efficient storage, indexing, and streaming are active research problems.',
          ),
          const ContentBlock.bullet(
            'Map Freshness: The physical world changes constantly. Parked cars, new construction, and furniture rearrangement all invalidate stored maps.',
          ),
          const ContentBlock.bullet(
            'Relocalization Speed: The device must identify its location in a global map within milliseconds to maintain tracking continuity.',
          ),
          const ContentBlock.subheading('Privacy Challenges'),
          const ContentBlock.bullet(
            'Always-On Spatial Scanning: Devices building the AR Cloud passively scan and upload their surroundings, raising serious surveillance concerns.',
          ),
          const ContentBlock.bullet(
            'Biometric Data: High-resolution environment scans may incidentally capture faces and other identifiable information.',
          ),
          const ContentBlock.bullet(
            'Data Ownership: Who owns the spatial map of a private building? The owner, the mapper, or the platform?',
          ),
          const ContentBlock.warning(
            'Privacy regulation around spatial data is nascent and rapidly evolving. '
            'AR Cloud platforms must design for privacy-by-default — anonymising scans, '
            'minimising stored data, and implementing clear consent mechanisms.',
          ),
          const ContentBlock.quote(
            'INTERVIEW QUESTION: "What is the biggest risk to the AR Cloud?" \n'
            'Answer: Privacy and regulation. If a city bans private spatial mapping '
            'due to privacy concerns, the AR Cloud becomes impossible to maintain or update '
            'in those areas.',
          ),
        ],
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  MODULE 10 — SLAM Deep Dive
  // ───────────────────────────────────────────────────────────────
  LearningModule(
    id: 'slam_deepdive',
    title: 'SLAM Deep Dive',
    description: 'The mathematics and algorithms behind world-scale AR tracking.',
    icon: Icons.calculate_rounded,
    order: 10,
    unlockCost: 0,
    requiredQuizId: 'quiz_ar_cloud',
    topics: [
      Topic(
        id: 'slam_vio',
        title: 'Visual-Inertial Odometry (VIO)',
        subtitle: 'Tightly fusing camera and IMU data.',
        contentBlocks: [
          const ContentBlock.heading('Why VIO Is the Core of Mobile AR'),
          const ContentBlock.body(
            'VIO combines visual data from the camera with inertial measurements from the IMU '
            '(accelerometer + gyroscope) to estimate the device\'s 6DoF pose in real time. '
            'It is the tracking engine inside both ARKit and ARCore.',
          ),
          const ContentBlock.subheading('How VIO Works'),
          const ContentBlock.numbered(
            '1. The camera detects and tracks visual feature points frame-to-frame (optical flow).',
          ),
          const ContentBlock.numbered(
            '2. The IMU measures acceleration and angular velocity at a much higher rate (hundreds of Hz).',
          ),
          const ContentBlock.numbered(
            '3. A sensor fusion algorithm (EKF) combines both streams.',
          ),
          const ContentBlock.numbered(
            '4. The IMU predicts fast motion between frames; the camera corrects IMU drift.',
          ),
          const ContentBlock.subheading('Coupling Methods'),
          const ContentBlock.bullet(
            'Tightly Coupled VIO: Raw camera features and IMU measurements are fused in a single optimization. More accurate and robust. Used by ARKit and ARCore.',
          ),
          const ContentBlock.info(
            'The IMU\'s high sampling rate (e.g., 100–500 Hz) is what enables AR to remain smooth during fast motion — '
            'the IMU fills the gaps between camera frames with high-frequency pose predictions.',
          ),
          const ContentBlock.quote(
            'INTERVIEW DEEP DIVE: What is "IMU Bias"? \n'
            'An IMU is never perfect; it has a "bias" (small constant error) '
            'that changes over time with temperature. A SLAM system must '
            'continuously estimate and "subtract" this bias, or the tracking will drift exponentially.',
          ),
        ],
      ),
      Topic(
        id: 'slam_optimisation',
        title: 'Map Optimisation & Loop Closure',
        subtitle: 'Bundle adjustment and drift correction.',
        contentBlocks: [
          const ContentBlock.heading('Keeping the Map Accurate Over Time'),
          const ContentBlock.body(
            'Small pose estimation errors accumulate over time — this is drift. '
            'SLAM uses two key techniques to periodically correct these errors: Bundle Adjustment and Loop Closure.',
          ),
          const ContentBlock.subheading('Bundle Adjustment (BA)'),
          const ContentBlock.body(
            'Bundle Adjustment jointly optimises all camera poses and all 3D map point positions simultaneously '
            'to minimise reprojection error — the difference between where a map point was expected to appear '
            'in a camera frame and where it actually appeared.',
          ),
          const ContentBlock.bullet(
            'Full BA: Optimises the entire map at once. Too slow for real-time use.',
          ),
          const ContentBlock.bullet(
            'Local BA / Windowed BA: Optimises only the most recent N keyframes and their associated map points. Fast enough for real-time.',
          ),
          const ContentBlock.subheading('Loop Closure'),
          const ContentBlock.body(
            'Loop closure detects when the device returns to a previously mapped location. '
            'It creates a "loop edge" in the pose graph connecting the current pose to the earlier one, '
            'then runs a global optimisation to distribute and eliminate accumulated drift.',
          ),
          const ContentBlock.info(
            'The result of a loop closure is a sudden, global correction to the map — '
            'sometimes called a "map snap." This is why you may see AR content briefly shift position '
            'when you re-enter an area you mapped earlier.',
          ),
          const ContentBlock.warning(
            'Loop closure is computationally expensive. In mobile AR SDKs, it runs on a background thread '
            'asynchronously to avoid blocking the rendering loop.',
          ),
          const ContentBlock.code(
            '// SLAM Loop Closure Concept (Pseudo-code)\n'
            'if (Map.containsSimilarKeyframe(currentFrame)) {\n'
            '    Transform driftCorrection = calculateDrift(currentFrame, oldKeyframe);\n'
            '    Map.ApplyGlobalCorrection(driftCorrection);\n'
            '    TriggerEvent("OnMapSnapped");\n'
            '}',
          ),
        ],
      ),
      Topic(
        id: 'slam_failure_modes',
        title: 'SLAM Failure Modes',
        subtitle: 'Why tracking fails and how to mitigate it.',
        contentBlocks: [
          const ContentBlock.heading('When SLAM Breaks Down'),
          const ContentBlock.body(
            'Understanding SLAM failure modes is essential for building robust AR applications '
            'and for giving good answers in technical interviews.',
          ),
          const ContentBlock.subheading('Common Failure Scenarios'),
          const ContentBlock.bullet(
            'Featureless Environments: Blank white walls, clear glass, and uniform floors provide no visual features to track. SLAM loses its reference points entirely.',
          ),
          const ContentBlock.bullet(
            'Rapid Motion / Motion Blur: Fast camera movement blurs features beyond recognition between frames. VI-SLAM is more robust here because the IMU continues tracking during blurry frames.',
          ),
          const ContentBlock.bullet(
            'Drastic Lighting Changes: Sudden changes in scene brightness (walking from darkness into sunlight) cause the appearance of features to change, breaking matches.',
          ),
          const ContentBlock.bullet(
            'Dynamic Objects: People or moving objects generate "phantom" features that corrupt the static map.',
          ),
          const ContentBlock.bullet(
            'Sensor Saturation / Over-Exposure: A camera pointed directly at a bright light source can saturate the sensor, losing all feature data.',
          ),
          const ContentBlock.subheading('Mitigation Strategies'),
          const ContentBlock.bullet(
            'Application design: Warn users to move slowly during initialisation, and avoid featureless environments when first starting the session.',
          ),
          const ContentBlock.bullet(
            'Tracking state handling: Detect LIMITED/NONE tracking states and show appropriate recovery guidance.',
          ),
          const ContentBlock.bullet(
            'Fiducial markers: In known difficult environments (surgery, clean rooms), add ARUco or AprilTag fiducial markers as reliable fallback anchors.',
          ),
          const ContentBlock.quote(
            'PRO TIP: Handling "Dynamic Scenes." \n'
            'If you have a group of people walking through your AR scene, '
            'the SLAM system should use "RANSAC" (Random Sample Consensus) '
            'to identify and ignore feature points that don\'t move with the rest of the static world.',
          ),
        ],
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────────
  //  MODULE 11 — Performance Profiling
  // ───────────────────────────────────────────────────────────────
  LearningModule(
    id: 'performance',
    title: 'Performance Profiling',
    description: 'Systematically diagnosing and fixing AR app performance issues.',
    icon: Icons.bolt_rounded,
    order: 11,
    unlockCost: 0,
    requiredQuizId: 'quiz_slam_deepdive',
    topics: [
      Topic(
        id: 'perf_methodology',
        title: 'Profiling Methodology',
        subtitle: 'Measure first, optimise second.',
        contentBlocks: [
          const ContentBlock.heading('The Golden Rule: Measure Before You Optimise'),
          const ContentBlock.body(
            'Premature optimisation leads to wasted effort and harder-to-read code. '
            'Always identify the actual bottleneck through profiling before changing anything. '
            'In AR, the bottleneck could be the CPU, the GPU, the camera pipeline, or memory — '
            'the fix is completely different for each.',
          ),
          const ContentBlock.subheading('Profiling Tools'),
          const ContentBlock.bullet(
            'Unity Profiler: CPU frame time, GPU frame time, memory allocations, and rendering statistics. Essential for any Unity AR project.',
          ),
          const ContentBlock.bullet(
            'Xcode Instruments (iOS): GPU Frame Debugger, Metal Performance HUD, and Time Profiler. Required for native iOS AR debugging.',
          ),
          const ContentBlock.bullet(
            'Android GPU Inspector (AGI): Google\'s tool for deep GPU analysis on Android. Shows shader performance, texture bandwidth, and GPU pipeline stalls.',
          ),
          const ContentBlock.bullet(
            'RenderDoc: Frame capture and analysis. Useful for inspecting individual draw calls and shader behaviour.',
          ),
          const ContentBlock.subheading('Key Metrics to Monitor'),
          const ContentBlock.bullet('Frame time (ms): Target ≤16.67ms for 60 FPS, ≤11.11ms for 90 FPS.'),
          const ContentBlock.bullet('Draw calls: Each call has CPU overhead. Target under 100 for mobile AR.'),
          const ContentBlock.bullet('Fill rate: Pixels rendered per frame. Overdraw (rendering the same pixel multiple times) is a common mobile GPU killer.'),
          const ContentBlock.bullet('Memory: Total allocated, peak allocation, and GC allocation frequency.'),
          const ContentBlock.info(
            'The AR camera pipeline itself consumes a baseline of CPU and memory resources that is outside your control. '
            'Your budget for the 3D scene is what remains after the tracking and camera systems take their share.',
          ),
          const ContentBlock.quote(
            'INTERVIEW FOCUS: Why profile on device? \n'
            'Answer: Thermal Throttling. A desktop PC stays at 100% speed. '
            'A phone will slow down its CPU by 50% after 10 minutes of heavy AR use. '
            'You need to know how your app performs when the device is "Hot," not just "Cold."',
          ),
        ],
      ),
      Topic(
        id: 'perf_cpu',
        title: 'CPU Bottlenecks',
        subtitle: 'Draw calls, scripts, and physics.',
        contentBlocks: [
          const ContentBlock.heading('CPU-Side Performance'),
          const ContentBlock.body(
            'A CPU bottleneck means the GPU is waiting for the CPU to issue commands. '
            'Common causes in AR: too many draw calls, expensive scripts running each frame, and physics simulation.',
          ),
          const ContentBlock.subheading('Draw Calls'),
          const ContentBlock.body(
            'Every unique object the GPU needs to render requires a draw call from the CPU. '
            'Each draw call has a fixed overhead cost regardless of object complexity.',
          ),
          const ContentBlock.bullet(
            'Static Batching: Combine non-moving objects that share a material into a single draw call.',
          ),
          const ContentBlock.bullet(
            'Dynamic Batching: Unity automatically batches small moving objects that share a material.',
          ),
          const ContentBlock.bullet(
            'GPU Instancing: Render hundreds of copies of the same mesh with a single draw call.',
          ),
          const ContentBlock.subheading('Script Optimisation'),
          const ContentBlock.bullet(
            'Avoid per-frame allocations in Update() — every allocation increases GC pressure.',
          ),
          const ContentBlock.bullet(
            'Cache component references in Awake/Start instead of calling GetComponent() every frame.',
          ),
          const ContentBlock.bullet(
            'Use coroutines or jobs for expensive operations that do not need to run every frame.',
          ),
          const ContentBlock.warning(
            'Garbage Collection spikes cause sudden frame drops that are very hard to diagnose without profiling. '
            'In Unity AR, GC pauses of even 5ms can be enough to drop a frame.',
          ),
          const ContentBlock.quote(
            'PRO TIP: Use "String Formatting" carefully. \n'
            'In C# (Unity), code like `text = "Value: " + val;` creates a new string object every frame. '
            'Use `StringBuilder` or pre-generate strings to avoid "Garbage Collection Hell."',
          ),
          const ContentBlock.code(
            '// Unity Object Pooling: Avoid Instantiate() during gameplay\n'
            'GameObject GetBullet() {\n'
            '    foreach (var b in bulletPool) {\n'
            '        if (!b.activeInHierarchy) return b;\n'
            '    }\n'
            '    // Only allocate if pool is empty\n'
            '    return Instantiate(bulletPrefab);\n'
            '}',
          ),
        ],
      ),
      Topic(
        id: 'perf_gpu',
        title: 'GPU Bottlenecks',
        subtitle: 'Fill rate, overdraw, and shader complexity.',
        contentBlocks: [
          const ContentBlock.heading('GPU-Side Performance'),
          const ContentBlock.body(
            'A GPU bottleneck means the CPU is waiting for the GPU to finish rendering. '
            'Common causes: too many pixels to fill (fill rate limited), overly complex shaders, '
            'and high-resolution render targets.',
          ),
          const ContentBlock.subheading('Fill Rate and Overdraw'),
          const ContentBlock.body(
            'Fill rate is the number of pixels the GPU can process per second. '
            'Overdraw occurs when the same screen pixel is written by multiple layers of geometry — '
            'transparent UI panels, particles, and overlapping objects are common culprits.',
          ),
          const ContentBlock.bullet(
            'Reduce transparent objects and particle effects, which force per-pixel blending calculations.',
          ),
          const ContentBlock.bullet(
            'Use solid geometry where possible — opaque objects can use early-z culling to skip the fragment shader entirely.',
          ),
          const ContentBlock.subheading('Shader Complexity'),
          const ContentBlock.bullet(
            'Use mobile-optimised shaders. Unity\'s Universal Render Pipeline (URP) includes mobile-friendly variants.',
          ),
          const ContentBlock.bullet(
            'Avoid per-pixel lighting for objects far from the camera — use vertex lighting or baked lighting instead.',
          ),
          const ContentBlock.bullet(
            'Avoid discard/clip operations in fragment shaders — they disable early-z and force full fragment evaluation.',
          ),
          const ContentBlock.subheading('Render Resolution'),
          const ContentBlock.bullet(
            'Scale the render target to 75–85% of native resolution. On most AR apps, users cannot perceive the difference, but GPU load drops significantly.',
          ),
          const ContentBlock.code(
            '// Unity URP: Downscaling Render Resolution dynamically\n'
            'var cameraData = camera.GetUniversalAdditionalCameraData();\n'
            'cameraData.renderScale = 0.8f; // Renders at 80% to save GPU\n',
          ),
          const ContentBlock.info(
            'On AR specifically: the camera feed texture itself occupies significant GPU bandwidth. '
            'Sampling and compositing this texture on every frame is a baseline cost unique to AR vs pure 3D games.',
          ),
          const ContentBlock.quote(
            'INTERVIEW QUESTION: "What is Overdraw and why is it bad for mobile?" \n'
            'Answer: Overdraw is when you paint the same pixel multiple times. '
            'Mobile GPUs are very bandwidth-limited. If you have 10 layers of semi-transparent UI, '
            'you are asking the GPU to write 10x more data to memory than if you had one opaque layer.',
          ),
        ],
      ),
    ],
  ),
];