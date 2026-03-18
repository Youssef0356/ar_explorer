import 'package:flutter/material.dart';
import '../models/inspector_game_models.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  INSPECTOR GAME — Level Content
//  Shared colors
// ═══════════════════════════════════════════════════════════════════════════

const _cyan   = Color(0xFF00D4AA);
const _blue   = Color(0xFF4FC3F7);
const _green  = Color(0xFF4CAF50);
const _amber  = Color(0xFFFFCA28);
const _purple = Color(0xFFBB86FC);
const _pink   = Color(0xFFFF6B9D);

const _wrongDot = Color(0xFFEF5350);

// ═══════════════════════════════════════════════════════════════════════════
//  ZONE 1 — SEE THE WORLD
//  The player learns that AR = camera + session + background renderer.
//  Everything is written in plain English. Zero jargon assumed.
// ═══════════════════════════════════════════════════════════════════════════

const _zone1 = InspectorZone(
  id: 'zone_inspector_1',
  name: 'Zone 1 — See the World',
  subtitle: 'Get the camera running',
  accentColor: _cyan,
  icon: Icons.videocam_rounded,
  levels: [

    // ── L1-1: Black screen ─────────────────────────────────────────────────
    InspectorLevel(
      id: 'iz1_l1',
      zoneId: 'zone_inspector_1',
      title: 'The Screen is Black',
      isFree: true,
      objective:
          'Your XR app opens and the screen is completely black. '
          'The player can\'t see anything. '
          'Add the right scripts to the Camera so it shows the real world through the phone\'s camera.',
      gameObjectName: 'Main Camera',
      gameObjectIcon: '📷',
      sceneObjects: [SceneObjectType.camera],
      existingComponents: [
        ExistingComponent(
          name: 'Transform',
          icon: '⊞',
          accentColor: _blue,
          fields: [
            InspectorField(label: 'Position', value: '0,  0,  0'),
            InspectorField(label: 'Rotation', value: '0°, 0°, 0°'),
            InspectorField(label: 'Scale',    value: '1,  1,  1'),
          ],
        ),
        ExistingComponent(
          name: 'Camera',
          icon: '📷',
          accentColor: _blue,
          fields: [
            InspectorField(label: 'Projection',   value: 'Perspective'),
            InspectorField(label: 'Field of View', value: '60°'),
            InspectorField(label: 'Clipping Far', value: '1000'),
          ],
        ),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim,     '> Scene loaded  —  1 object'),
        TerminalLine(TerminalLineType.dim,     '> Main Camera found  —  0 AR scripts'),
        TerminalLine(TerminalLineType.warning, '> WARNING: No background renderer  →  screen will be black'),
        TerminalLine(TerminalLineType.warning, '> WARNING: AR session not initialised'),
      ],
      hint: 'You need two things: "AR Session" to start the tracking engine, '
            'and "AR Camera Background" to paint the real-world camera feed behind your 3D objects.',
      scriptBank: [
        ScriptChip(
          id: 'ar_session',
          label: 'AR Session',
          description: 'Starts and manages the AR tracking engine. Without it, nothing tracks.',
          dotColor: _cyan,
          isCorrect: true,
          activates: [SceneObjectType.camera],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> AR Session attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Tracking engine initialised'),
          ],
          addFields: [
            InspectorField(label: 'Attempt Update',  value: 'True'),
            InspectorField(label: 'Tracking Mode',   value: 'Positional'),
          ],
        ),
        ScriptChip(
          id: 'ar_cam_bg',
          label: 'AR Camera Background',
          description: 'Renders the phone\'s real camera feed behind all 3D objects.',
          dotColor: _cyan,
          isCorrect: true,
          addLines: [
            TerminalLine(TerminalLineType.info,    '> AR Camera Background attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Real-world camera feed  —  ACTIVE'),
            TerminalLine(TerminalLineType.success, '> INFO: Rendering at 60fps'),
          ],
          addFields: [
            InspectorField(label: 'Renderer Mode',   value: 'After Opaques'),
            InspectorField(label: 'Custom Material', value: 'None (default)'),
          ],
        ),
        // ── Distractors ──
        ScriptChip(
          id: 'wrong_cinemachine',
          label: 'Cinemachine Brain',
          description: 'A cinematic camera system for cutscenes — has nothing to do with AR.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Cinemachine Brain controls virtual cameras for films, not AR feeds. Remove it.',
        ),
        ScriptChip(
          id: 'wrong_postfx',
          label: 'Post Process Layer',
          description: 'Adds bloom and colour grading — breaks the AR camera composite.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Post Process Layer overrides the camera output — it will destroy your AR feed.',
        ),
      ],
      correctIds: ['ar_session', 'ar_cam_bg'],
      successMessage: 'The camera is live! The player now sees the real world through the phone.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> Scene compiled  —  0 errors'),
        TerminalLine(TerminalLineType.success, '> ✓  AR Session running'),
        TerminalLine(TerminalLineType.success, '> ✓  Camera feed active at 60fps'),
        TerminalLine(TerminalLineType.success, '> ✓  Screen is no longer black'),
      ],
    ),

    // ── L1-2: Place a virtual cube in the real world ───────────────────────
    InspectorLevel(
      id: 'iz1_l2',
      zoneId: 'zone_inspector_1',
      title: 'Put a Cube in the Room',
      objective:
          'The camera works, but virtual objects don\'t know where "forward" is. '
          'Add the scripts that let the XR Rig understand its position and orientation '
          'in the real room, so a virtual cube hovers in front of the player.',
      gameObjectName: 'XR Rig',
      gameObjectIcon: '🥽',
      sceneObjects: [SceneObjectType.camera, SceneObjectType.xrRig, SceneObjectType.cube],
      existingComponents: [
        ExistingComponent(name: 'Transform', icon: '⊞', accentColor: _blue,
          fields: [InspectorField(label: 'Position', value: '0, 0, 0')]),
        ExistingComponent(name: 'AR Session Origin', icon: '🌐', accentColor: _cyan,
          fields: [
            InspectorField(label: 'Scale', value: '1, 1, 1'),
            InspectorField(label: 'Camera Floor Offset', value: '1.36 m'),
          ]),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim,     '> XR Rig selected'),
        TerminalLine(TerminalLineType.dim,     '> AR Session Origin found'),
        TerminalLine(TerminalLineType.warning, '> WARNING: No camera manager  →  pose unknown'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Cube position not tracked'),
      ],
      hint: '"AR Camera Manager" feeds the live camera image AND the device\'s 6DOF pose '
            'into the system every frame. Without it, the engine can see but cannot tell where it is.',
      scriptBank: [
        ScriptChip(
          id: 'ar_cam_mgr',
          label: 'AR Camera Manager',
          description: 'Feeds the camera image and device pose into the AR system every frame.',
          dotColor: _cyan,
          isCorrect: true,
          activates: [SceneObjectType.xrRig, SceneObjectType.cube],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> AR Camera Manager attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Pose tracking  —  6DOF active'),
            TerminalLine(TerminalLineType.success, '> INFO: Cube position locked in world space'),
          ],
          addFields: [
            InspectorField(label: 'Facing Direction', value: 'World'),
            InspectorField(label: 'Auto Focus',       value: 'True'),
            InspectorField(label: 'Light Estimation', value: 'Disabled'),
          ],
        ),
        ScriptChip(
          id: 'wrong_audiolis',
          label: 'Audio Listener',
          description: 'Captures 3D sound for the scene — not related to pose tracking.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Audio Listener is for 3D sound, not for tracking where the camera is.',
        ),
        ScriptChip(
          id: 'wrong_physmgr',
          label: 'Physics Manager',
          description: 'Controls global gravity and physics — the cube needs a pose, not gravity.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Physics Manager changes gravity settings — it won\'t help the camera know where it is.',
        ),
      ],
      correctIds: ['ar_cam_mgr'],
      successMessage: 'Pose tracking active! The cube now knows exactly where it is in the real room.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> Scene compiled  —  0 errors'),
        TerminalLine(TerminalLineType.success, '> ✓  6DOF pose tracking: active'),
        TerminalLine(TerminalLineType.success, '> ✓  Cube world position: stable'),
      ],
    ),

    // ── L1-3: Face filters / front camera ─────────────────────────────────
    InspectorLevel(
      id: 'iz1_l3',
      zoneId: 'zone_inspector_1',
      title: 'Front Camera Face Filter',
      objective:
          'You want to add a face filter like Snapchat — a virtual hat that sticks to the user\'s head. '
          'Switch to the front-facing camera and add face tracking so the hat knows where the face is.',
      gameObjectName: 'AR Camera Manager',
      gameObjectIcon: '🤳',
      sceneObjects: [SceneObjectType.camera, SceneObjectType.avatar],
      existingComponents: [
        ExistingComponent(name: 'Transform', icon: '⊞', accentColor: _blue,
          fields: [InspectorField(label: 'Position', value: '0, 1.6, 0')]),
        ExistingComponent(name: 'AR Camera Manager', icon: '📷', accentColor: _cyan,
          fields: [
            InspectorField(label: 'Facing Direction', value: 'World (back)'),
            InspectorField(label: 'Auto Focus',       value: 'True'),
          ]),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim,     '> AR Camera Manager — Facing: World (back camera)'),
        TerminalLine(TerminalLineType.warning, '> WARNING: No face tracking manager found'),
        TerminalLine(TerminalLineType.warning, '> WARNING: AR Face Manager required for selfie mode'),
        TerminalLine(TerminalLineType.error,   '> ERROR: FaceFilterController.cs — no face found'),
      ],
      hint: '"AR Face Manager" detects and tracks human faces. It also automatically '
            'switches the camera to face-forward (selfie) mode.',
      scriptBank: [
        ScriptChip(
          id: 'ar_face_mgr',
          label: 'AR Face Manager',
          description: 'Detects faces and tracks facial geometry in real time. Enables selfie mode.',
          dotColor: _cyan,
          isCorrect: true,
          activates: [SceneObjectType.avatar],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> AR Face Manager attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Facing direction → User (front camera)'),
            TerminalLine(TerminalLineType.success, '> INFO: Face mesh tracking: active'),
            TerminalLine(TerminalLineType.success, '> INFO: FaceFilterController.cs error resolved'),
          ],
          addFields: [
            InspectorField(label: 'Face Prefab',       value: 'DefaultFaceMesh'),
            InspectorField(label: 'Max Faces',         value: '1'),
            InspectorField(label: 'Request Update',    value: 'True'),
          ],
        ),
        ScriptChip(
          id: 'wrong_bodytrack',
          label: 'AR Body Manager',
          description: 'Tracks the full human body skeleton — not just the face.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'AR Body Manager tracks the whole skeleton. For a face filter, you need AR Face Manager.',
        ),
        ScriptChip(
          id: 'wrong_planedet',
          label: 'AR Plane Manager',
          description: 'Detects flat surfaces like floors and tables — not faces.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'AR Plane Manager scans for floors and walls, not for human faces.',
        ),
      ],
      correctIds: ['ar_face_mgr'],
      successMessage: 'Face tracking active! The virtual hat now sticks to the user\'s head.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> Scene compiled  —  0 errors'),
        TerminalLine(TerminalLineType.success, '> ✓  Front camera enabled'),
        TerminalLine(TerminalLineType.success, '> ✓  Face mesh: 468 landmarks tracked'),
        TerminalLine(TerminalLineType.success, '> ✓  FaceFilterController.cs running'),
      ],
    ),

    // ── L1-BOSS: Multi-camera mixed reality ────────────────────────────────
    InspectorLevel(
      id: 'iz1_boss',
      zoneId: 'zone_inspector_1',
      title: 'BOSS — Split-Screen Mixed Reality',
      isBoss: true,
      timeLimit: 90,
      objective:
          'A mixed-reality broadcast app: the front camera shows the presenter\'s face with a virtual overlay, '
          'while the back camera shows the AR scene behind them. '
          'Both cameras need their own managers. Wire both GameObjects correctly before time runs out.',
      gameObjectName: 'Camera Rig (Boss)',
      gameObjectIcon: '🎬',
      sceneObjects: [SceneObjectType.camera, SceneObjectType.xrRig, SceneObjectType.avatar],
      existingComponents: [
        ExistingComponent(name: 'Transform',         icon: '⊞', accentColor: _blue, fields: []),
        ExistingComponent(name: 'AR Session Origin', icon: '🌐', accentColor: _cyan, fields: [
          InspectorField(label: 'Camera Floor Offset', value: '1.36 m'),
        ]),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim,     '> Camera Rig selected — 2 cameras required'),
        TerminalLine(TerminalLineType.error,   '> ERROR: Back camera — AR background missing'),
        TerminalLine(TerminalLineType.error,   '> ERROR: Front camera — face tracking missing'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Broadcast will not render correctly'),
      ],
      hint: 'You need four scripts total: AR Session, AR Camera Background, AR Camera Manager (back), '
            'and AR Face Manager (front). Each manager controls one of the two cameras.',
      scriptBank: [
        ScriptChip(
          id: 'boss_ar_session',
          label: 'AR Session',
          description: 'The global AR tracking engine — needed once for the whole scene.',
          dotColor: _cyan,
          isCorrect: true,
          addLines: [TerminalLine(TerminalLineType.info, '> AR Session: running')],
          addFields: [InspectorField(label: 'Attempt Update', value: 'True')],
        ),
        ScriptChip(
          id: 'boss_ar_bg',
          label: 'AR Camera Background',
          description: 'Renders the back-camera real-world feed on screen.',
          dotColor: _cyan,
          isCorrect: true,
          activates: [SceneObjectType.camera],
          addLines: [TerminalLine(TerminalLineType.success, '> Back camera feed: active')],
          addFields: [InspectorField(label: 'Renderer Mode', value: 'After Opaques')],
        ),
        ScriptChip(
          id: 'boss_ar_cam_mgr',
          label: 'AR Camera Manager',
          description: 'Feeds the back-camera pose into the AR system every frame.',
          dotColor: _cyan,
          isCorrect: true,
          activates: [SceneObjectType.xrRig],
          addLines: [TerminalLine(TerminalLineType.success, '> Back camera pose: 6DOF active')],
          addFields: [InspectorField(label: 'Facing Direction', value: 'World (back)')],
        ),
        ScriptChip(
          id: 'boss_ar_face',
          label: 'AR Face Manager',
          description: 'Tracks the presenter\'s face on the front camera.',
          dotColor: _cyan,
          isCorrect: true,
          activates: [SceneObjectType.avatar],
          addLines: [
            TerminalLine(TerminalLineType.success, '> Front camera face tracking: active'),
            TerminalLine(TerminalLineType.success, '> Presenter overlay: rendering'),
          ],
          addFields: [
            InspectorField(label: 'Facing Direction', value: 'User (front)'),
            InspectorField(label: 'Max Faces', value: '1'),
          ],
        ),
        ScriptChip(
          id: 'boss_wrong_body',
          label: 'AR Body Manager',
          description: 'Full-body skeleton tracker — not needed for face overlay.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'AR Body Manager needs a LiDAR sensor. Use AR Face Manager for the presenter.',
        ),
        ScriptChip(
          id: 'boss_wrong_plane',
          label: 'AR Plane Manager',
          description: 'Detects floors and walls — irrelevant for this broadcast setup.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'AR Plane Manager scans for surfaces, not for camera feeds or faces.',
        ),
      ],
      correctIds: ['boss_ar_session', 'boss_ar_bg', 'boss_ar_cam_mgr', 'boss_ar_face'],
      successMessage: 'Broadcast ready! Back camera shows the AR scene, front camera shows the presenter.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> Scene compiled  —  0 errors'),
        TerminalLine(TerminalLineType.success, '> ✓  Back camera: AR scene rendering'),
        TerminalLine(TerminalLineType.success, '> ✓  Front camera: face overlay active'),
        TerminalLine(TerminalLineType.success, '> ✓  Broadcast stream: LIVE'),
      ],
    ),
  ],
);


// ═══════════════════════════════════════════════════════════════════════════
//  ZONE 2 — USE YOUR HANDS
//  The player learns XR hand tracking, interaction toolkit, and gesture input.
// ═══════════════════════════════════════════════════════════════════════════

const _zone2 = InspectorZone(
  id: 'zone_inspector_2',
  name: 'Zone 2 — Use Your Hands',
  subtitle: 'Track and interact with bare hands',
  accentColor: _green,
  icon: Icons.back_hand_rounded,
  levels: [

    // ── L2-1: Show hands ──────────────────────────────────────────────────
    InspectorLevel(
      id: 'iz2_l1',
      zoneId: 'zone_inspector_2',
      title: 'Make the Hands Visible',
      isFree: true,
      objective:
          'Players hold up their hands but see nothing. '
          'No controllers — just bare hands. '
          'Add the scripts that detect the hand skeleton and render a mesh over it '
          'so players can see their virtual hands.',
      gameObjectName: 'XR Rig',
      gameObjectIcon: '🥽',
      sceneObjects: [SceneObjectType.xrRig, SceneObjectType.handLeft, SceneObjectType.handRight],
      existingComponents: [
        ExistingComponent(name: 'Transform',  icon: '⊞', accentColor: _blue, fields: []),
        ExistingComponent(name: 'XR Origin',  icon: '🥽', accentColor: _green,
          fields: [
            InspectorField(label: 'Tracking Origin Mode', value: 'Device'),
            InspectorField(label: 'Camera Floor Offset',  value: '1.36 m'),
          ]),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim,     '> XR Rig  —  0 hand scripts'),
        TerminalLine(TerminalLineType.warning, '> WARNING: No hand tracking subsystem'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Controllers will be used by default'),
        TerminalLine(TerminalLineType.error,   '> ERROR: HandInteractionDemo.cs — no hand data'),
      ],
      hint: 'Two scripts work together: "XR Hand Subsystem" activates the hardware\'s hand skeleton '
            'tracking, and "XR Hand Mesh Renderer" draws a visible mesh over each detected hand.',
      scriptBank: [
        ScriptChip(
          id: 'xr_hand_sub',
          label: 'XR Hand Subsystem',
          description: 'Activates the device\'s hand skeleton tracking pipeline (26 joints per hand).',
          dotColor: _green,
          isCorrect: true,
          addLines: [
            TerminalLine(TerminalLineType.info,    '> XR Hand Subsystem attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Skeleton tracking: 26 joints / hand'),
            TerminalLine(TerminalLineType.success, '> INFO: Confidence threshold: 0.7'),
          ],
          addFields: [
            InspectorField(label: 'Update Type',       value: 'BeforeRender'),
            InspectorField(label: 'Min Confidence',    value: '0.70'),
          ],
        ),
        ScriptChip(
          id: 'xr_hand_mesh',
          label: 'XR Hand Mesh Renderer',
          description: 'Renders a visible mesh over the tracked hand skeleton.',
          dotColor: _green,
          isCorrect: true,
          activates: [SceneObjectType.handLeft, SceneObjectType.handRight],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> XR Hand Mesh Renderer attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Left hand mesh  —  visible'),
            TerminalLine(TerminalLineType.success, '> INFO: Right hand mesh  —  visible'),
            TerminalLine(TerminalLineType.success, '> INFO: HandInteractionDemo.cs error resolved'),
          ],
          addFields: [
            InspectorField(label: 'Hand Mesh Prefab', value: 'DefaultHand'),
            InspectorField(label: 'Scale Factor',     value: '1.0'),
          ],
        ),
        ScriptChip(
          id: 'wrong_xrcontroller',
          label: 'XR Controller (Action-based)',
          description: 'For physical handheld controllers — not bare-hand tracking.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'XR Controller is for gamepads and buttons. For bare hands, use XR Hand Subsystem.',
        ),
        ScriptChip(
          id: 'wrong_input_mgr',
          label: 'Input Action Manager',
          description: 'Binds button presses to actions — not needed for hand rendering.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Input Action Manager handles button bindings. Hands render from pose data, not actions.',
        ),
      ],
      correctIds: ['xr_hand_sub', 'xr_hand_mesh'],
      successMessage: 'Hands visible and tracking! Players can see their own hands in the virtual scene.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> Scene compiled  —  0 errors'),
        TerminalLine(TerminalLineType.success, '> ✓  Left hand: 26 joints tracked'),
        TerminalLine(TerminalLineType.success, '> ✓  Right hand: 26 joints tracked'),
        TerminalLine(TerminalLineType.success, '> ✓  Mesh renderer: active'),
      ],
    ),

    // ── L2-2: Grab an object ──────────────────────────────────────────────
    InspectorLevel(
      id: 'iz2_l2',
      zoneId: 'zone_inspector_2',
      title: 'Make the Box Grabbable',
      objective:
          'There\'s a box floating in the scene. Players reach out but their hands pass right through it. '
          'Click "GrabBox" and add the scripts that give it a physical shape and let hands grab, move, and throw it.',
      gameObjectName: 'GrabBox',
      gameObjectIcon: '📦',
      sceneObjects: [
        SceneObjectType.xrRig,
        SceneObjectType.handLeft,
        SceneObjectType.handRight,
        SceneObjectType.cube,
      ],
      existingComponents: [
        ExistingComponent(name: 'Transform',    icon: '⊞', accentColor: _blue,
          fields: [InspectorField(label: 'Position', value: '0.0, 1.2, -0.5 m')]),
        ExistingComponent(name: 'Mesh Renderer', icon: '◉', accentColor: _blue,
          fields: [
            InspectorField(label: 'Material',     value: 'GrabBox_Mat'),
            InspectorField(label: 'Cast Shadows', value: 'On'),
          ]),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim,     '> GrabBox selected'),
        TerminalLine(TerminalLineType.dim,     '> Rigidbody: None  |  Collider: None  |  Interactable: None'),
        TerminalLine(TerminalLineType.warning, '> WARNING: No physics body  →  hands will phase through'),
        TerminalLine(TerminalLineType.warning, '> WARNING: No collider  →  no touch detection'),
      ],
      hint: 'A grabbable object needs three things: '
            '(1) Rigidbody for physics/gravity, '
            '(2) Box Collider so hands have something to touch, '
            '(3) XR Grab Interactable so the XR system registers it as grabbable.',
      scriptBank: [
        ScriptChip(
          id: 'rigidbody',
          label: 'Rigidbody',
          description: 'Gives the object mass, gravity, and velocity. Required for physics interactions.',
          dotColor: _amber,
          isCorrect: true,
          addLines: [
            TerminalLine(TerminalLineType.info,    '> Rigidbody attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Mass = 1 kg, Gravity enabled'),
          ],
          addFields: [
            InspectorField(label: 'Mass',         value: '1'),
            InspectorField(label: 'Use Gravity',  value: 'True'),
            InspectorField(label: 'Is Kinematic', value: 'False'),
          ],
        ),
        ScriptChip(
          id: 'box_collider',
          label: 'Box Collider',
          description: 'Defines the physical boundary that hands and other objects can collide with.',
          dotColor: _amber,
          isCorrect: true,
          activates: [SceneObjectType.cube],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> Box Collider attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Bounds: 0.2 × 0.2 × 0.2 m'),
          ],
          addFields: [
            InspectorField(label: 'Size',       value: '0.2, 0.2, 0.2'),
            InspectorField(label: 'Center',     value: '0, 0, 0'),
            InspectorField(label: 'Is Trigger', value: 'False'),
          ],
        ),
        ScriptChip(
          id: 'xr_grab',
          label: 'XR Grab Interactable',
          description: 'Registers the object with the XR Interaction Toolkit as something that can be grabbed and thrown.',
          dotColor: _amber,
          isCorrect: true,
          addLines: [
            TerminalLine(TerminalLineType.info,    '> XR Grab Interactable attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Attach point: centroid'),
            TerminalLine(TerminalLineType.success, '> INFO: Throw velocity scale: 1.5'),
          ],
          addFields: [
            InspectorField(label: 'Movement Type',  value: 'VelocityTracking'),
            InspectorField(label: 'Throw Velocity', value: '1.5'),
            InspectorField(label: 'Throw Angular',  value: '0.5'),
          ],
        ),
        ScriptChip(
          id: 'wrong_navmesh',
          label: 'Nav Mesh Agent',
          description: 'AI pathfinding agent — boxes don\'t navigate anywhere.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Nav Mesh Agent makes objects walk around AI paths. A box doesn\'t need to navigate.',
        ),
        ScriptChip(
          id: 'wrong_animator',
          label: 'Animator',
          description: 'Plays animation clips — this box has no animations.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Animator plays skeletal animations. The GrabBox has no animation clips.',
        ),
      ],
      correctIds: ['rigidbody', 'box_collider', 'xr_grab'],
      successMessage: 'The box has physics and is grabbable. Reach out and pick it up!',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> Scene compiled  —  0 errors'),
        TerminalLine(TerminalLineType.success, '> ✓  Rigidbody: active, gravity on'),
        TerminalLine(TerminalLineType.success, '> ✓  Collider: bounds active'),
        TerminalLine(TerminalLineType.success, '> ✓  XR Grab: registered with Interaction Manager'),
        TerminalLine(TerminalLineType.success, '> ✓  Object is now grabbable and throwable'),
      ],
    ),

    // ── L2-3: Pinch-to-scale ──────────────────────────────────────────────
    InspectorLevel(
      id: 'iz2_l3',
      zoneId: 'zone_inspector_2',
      title: 'Pinch to Scale Objects',
      objective:
          'Players want to resize a virtual furniture piece by pinching with both hands — '
          'like stretching a photo. Add the scripts that detect the pinch gesture '
          'and apply scaling to the selected object.',
      gameObjectName: 'FurniturePiece',
      gameObjectIcon: '🪑',
      sceneObjects: [SceneObjectType.handLeft, SceneObjectType.handRight, SceneObjectType.cube],
      existingComponents: [
        ExistingComponent(name: 'Transform',     icon: '⊞', accentColor: _blue,
          fields: [InspectorField(label: 'Scale', value: '1, 1, 1')]),
        ExistingComponent(name: 'Mesh Renderer', icon: '◉', accentColor: _blue,
          fields: [InspectorField(label: 'Material', value: 'Sofa_Mat')]),
        ExistingComponent(name: 'Rigidbody',     icon: '⚙', accentColor: _amber,
          fields: [
            InspectorField(label: 'Mass',        value: '5'),
            InspectorField(label: 'Is Kinematic', value: 'True'),
          ]),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim,     '> FurniturePiece selected'),
        TerminalLine(TerminalLineType.warning, '> WARNING: No gesture recognizer found'),
        TerminalLine(TerminalLineType.warning, '> WARNING: XR Object Manipulator missing'),
        TerminalLine(TerminalLineType.error,   '> ERROR: PinchScale.cs — no hand gestures registered'),
      ],
      hint: '"XR Hand Gesture Recognizer" listens for specific finger poses (like pinch). '
            '"XR Object Manipulator" takes that gesture data and applies scale, rotate, or translate to the object.',
      scriptBank: [
        ScriptChip(
          id: 'gesture_recognizer',
          label: 'XR Hand Gesture Recognizer',
          description: 'Listens for hand shapes like pinch, fist, or spread and fires events.',
          dotColor: _green,
          isCorrect: true,
          addLines: [
            TerminalLine(TerminalLineType.info,    '> XR Hand Gesture Recognizer attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Pinch gesture: registered'),
            TerminalLine(TerminalLineType.success, '> INFO: Minimum confidence: 0.8'),
          ],
          addFields: [
            InspectorField(label: 'Gesture',    value: 'Pinch'),
            InspectorField(label: 'Hand',       value: 'Both'),
            InspectorField(label: 'Min Conf.',  value: '0.80'),
          ],
        ),
        ScriptChip(
          id: 'xr_manipulator',
          label: 'XR Object Manipulator',
          description: 'Applies pinch, grab, and rotate gestures to scale and move the object.',
          dotColor: _green,
          isCorrect: true,
          activates: [SceneObjectType.cube],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> XR Object Manipulator attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Two-handed scale: enabled'),
            TerminalLine(TerminalLineType.success, '> INFO: PinchScale.cs error resolved'),
          ],
          addFields: [
            InspectorField(label: 'Allowed Transforms', value: 'Scale, Translate'),
            InspectorField(label: 'Min Scale',          value: '0.1'),
            InspectorField(label: 'Max Scale',          value: '5.0'),
          ],
        ),
        ScriptChip(
          id: 'wrong_animator_2',
          label: 'Animator',
          description: 'Plays animation clips — not for gesture-driven scaling.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Animator plays pre-baked clips. For gesture-driven scaling, use XR Object Manipulator.',
        ),
        ScriptChip(
          id: 'wrong_event_sys',
          label: 'Event System',
          description: 'Unity UI event routing — not related to hand gesture recognition.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Event System handles UI clicks, not physical gesture recognition.',
        ),
      ],
      correctIds: ['gesture_recognizer', 'xr_manipulator'],
      successMessage: 'Pinch-to-scale works! Players can now resize furniture with both hands.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> Scene compiled  —  0 errors'),
        TerminalLine(TerminalLineType.success, '> ✓  Pinch gesture: detected'),
        TerminalLine(TerminalLineType.success, '> ✓  Two-handed scale: active'),
        TerminalLine(TerminalLineType.success, '> ✓  Scale range: 0.1× → 5.0×'),
      ],
    ),

    // ── L2-BOSS: Full hand interaction suite ──────────────────────────────
    InspectorLevel(
      id: 'iz2_boss',
      zoneId: 'zone_inspector_2',
      isBoss: true,
      timeLimit: 90,
      title: 'BOSS — The Virtual Workshop',
      objective:
          'A virtual workshop where players walk in, pick up tools with bare hands, '
          'resize them with a pinch, and press a virtual button to start the machine. '
          'You need hands to be visible, tools to be grabbable, a button to be pressable, '
          'and a poke interaction for pushing UI buttons. Wire it all up.',
      gameObjectName: 'Workshop Rig',
      gameObjectIcon: '🔧',
      sceneObjects: [
        SceneObjectType.xrRig,
        SceneObjectType.handLeft,
        SceneObjectType.handRight,
        SceneObjectType.cube,
      ],
      existingComponents: [
        ExistingComponent(name: 'Transform', icon: '⊞', accentColor: _blue, fields: []),
        ExistingComponent(name: 'XR Origin', icon: '🥽', accentColor: _green,
          fields: [InspectorField(label: 'Tracking Origin', value: 'Floor')]),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.error,   '> ERROR: Hands not visible'),
        TerminalLine(TerminalLineType.error,   '> ERROR: Tools not interactable'),
        TerminalLine(TerminalLineType.error,   '> ERROR: Button poke not registered'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Workshop is completely non-functional'),
      ],
      hint: 'You need: XR Hand Subsystem + XR Hand Mesh Renderer (for visible hands), '
            'XR Grab Interactable on the tool (for picking up), and XR Poke Interactor (for pressing buttons).',
      scriptBank: [
        ScriptChip(
          id: 'boss2_hand_sub',  label: 'XR Hand Subsystem',
          description: 'Enables hand skeleton tracking.',
          dotColor: _green, isCorrect: true,
          activates: [SceneObjectType.handLeft, SceneObjectType.handRight],
          addLines: [TerminalLine(TerminalLineType.success, '> Hand skeleton tracking: 26 joints/hand')],
          addFields: [InspectorField(label: 'Update Type', value: 'BeforeRender')],
        ),
        ScriptChip(
          id: 'boss2_hand_mesh', label: 'XR Hand Mesh Renderer',
          description: 'Renders visible hand meshes.',
          dotColor: _green, isCorrect: true,
          addLines: [TerminalLine(TerminalLineType.success, '> Hand meshes: visible')],
          addFields: [InspectorField(label: 'Hand Mesh Prefab', value: 'DefaultHand')],
        ),
        ScriptChip(
          id: 'boss2_grab',      label: 'XR Grab Interactable',
          description: 'Makes the tool grabbable by hands.',
          dotColor: _amber, isCorrect: true,
          activates: [SceneObjectType.cube],
          addLines: [TerminalLine(TerminalLineType.success, '> Wrench: registered as grabbable')],
          addFields: [InspectorField(label: 'Movement Type', value: 'VelocityTracking')],
        ),
        ScriptChip(
          id: 'boss2_poke',      label: 'XR Poke Interactor',
          description: 'Lets a finger poke and press flat UI buttons and surfaces.',
          dotColor: _blue, isCorrect: true,
          addLines: [
            TerminalLine(TerminalLineType.success, '> Poke Interactor: registered'),
            TerminalLine(TerminalLineType.success, '> Machine start button: pressable'),
          ],
          addFields: [
            InspectorField(label: 'Poke Offset', value: '0.01 m'),
            InspectorField(label: 'Haptic Impulse', value: 'True'),
          ],
        ),
        ScriptChip(
          id: 'boss2_wrong_nav', label: 'Nav Mesh Agent',
          description: 'AI pathfinding — tools don\'t walk around.',
          dotColor: _wrongDot, isCorrect: false,
          errorMessage: 'Nav Mesh Agent is for NPCs. Tools and buttons don\'t navigate.',
        ),
        ScriptChip(
          id: 'boss2_wrong_anim', label: 'Animator',
          description: 'Animation clips — no animations here.',
          dotColor: _wrongDot, isCorrect: false,
          errorMessage: 'Animator plays clips. The workshop uses physics and gestures, not animations.',
        ),
      ],
      correctIds: ['boss2_hand_sub', 'boss2_hand_mesh', 'boss2_grab', 'boss2_poke'],
      successMessage: 'Workshop fully operational! Players can grab tools, scale them, and press the start button.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> Scene compiled  —  0 errors'),
        TerminalLine(TerminalLineType.success, '> ✓  Both hands: visible and tracked'),
        TerminalLine(TerminalLineType.success, '> ✓  Wrench: grabbable'),
        TerminalLine(TerminalLineType.success, '> ✓  Machine button: pokeable'),
        TerminalLine(TerminalLineType.success, '> ✓  Workshop is LIVE'),
      ],
    ),
  ],
);


// ═══════════════════════════════════════════════════════════════════════════
//  ZONE 3 — TOUCH THE WORLD
//  Plane detection, hit testing, tap-to-place, surface anchors.
// ═══════════════════════════════════════════════════════════════════════════

const _zone3 = InspectorZone(
  id: 'zone_inspector_3',
  name: 'Zone 3 — Touch the World',
  subtitle: 'Detect surfaces and place objects on them',
  accentColor: _amber,
  icon: Icons.touch_app_rounded,
  levels: [

    // ── L3-1: Detect the floor ─────────────────────────────────────────────
    InspectorLevel(
      id: 'iz3_l1',
      zoneId: 'zone_inspector_3',
      title: 'Detect the Real Floor',
      isFree: true,
      objective:
          'Virtual objects keep falling through the floor because the app doesn\'t know the floor exists. '
          'Add the script that scans the real room for flat surfaces — floors, tables, walls — '
          'so objects can rest on them.',
      gameObjectName: 'XR Rig',
      gameObjectIcon: '🥽',
      sceneObjects: [SceneObjectType.xrRig, SceneObjectType.cube, SceneObjectType.plane],
      existingComponents: [
        ExistingComponent(name: 'Transform',         icon: '⊞', accentColor: _blue, fields: []),
        ExistingComponent(name: 'AR Session Origin', icon: '🌐', accentColor: _cyan,
          fields: [InspectorField(label: 'Scale', value: '1, 1, 1')]),
        ExistingComponent(name: 'AR Camera Manager', icon: '📷', accentColor: _cyan,
          fields: [InspectorField(label: 'Facing Direction', value: 'World')]),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim,     '> XR Rig selected'),
        TerminalLine(TerminalLineType.error,   '> ERROR: AR Plane Manager not found'),
        TerminalLine(TerminalLineType.warning, '> WARNING: No surfaces detected'),
        TerminalLine(TerminalLineType.error,   '> ERROR: PlaceOnFloor.cs — no planes in scene'),
      ],
      hint: '"AR Plane Manager" continuously scans the camera image and detects flat surfaces. '
            'It creates invisible plane meshes the physics engine can collide with.',
      scriptBank: [
        ScriptChip(
          id: 'ar_plane_mgr',
          label: 'AR Plane Manager',
          description: 'Scans the real environment and creates invisible collision meshes for detected surfaces.',
          dotColor: _amber,
          isCorrect: true,
          activates: [SceneObjectType.plane, SceneObjectType.cube],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> AR Plane Manager attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Horizontal detection: ON'),
            TerminalLine(TerminalLineType.success, '> INFO: Vertical detection: ON'),
            TerminalLine(TerminalLineType.success, '> INFO: PlaceOnFloor.cs error resolved'),
          ],
          addFields: [
            InspectorField(label: 'Detection Mode', value: 'Horizontal & Vertical'),
            InspectorField(label: 'Plane Prefab',   value: 'AR Default Plane'),
            InspectorField(label: 'Max Planes',     value: 'Unlimited'),
          ],
        ),
        ScriptChip(
          id: 'wrong_face_mgr_3',
          label: 'AR Face Manager',
          description: 'Detects human faces — not floor surfaces.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'AR Face Manager tracks faces, not floors. Use AR Plane Manager for surfaces.',
        ),
        ScriptChip(
          id: 'wrong_body_mgr_3',
          label: 'AR Body Manager',
          description: 'Tracks human body skeleton — not flat surfaces.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'AR Body Manager tracks people, not geometry. You need AR Plane Manager.',
        ),
      ],
      correctIds: ['ar_plane_mgr'],
      successMessage: 'Surfaces detected! The cube now rests on the real floor instead of falling through it.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> Scene compiled  —  0 errors'),
        TerminalLine(TerminalLineType.success, '> ✓  Plane Manager: scanning environment'),
        TerminalLine(TerminalLineType.success, '> ✓  Detected: floor (3.2 × 4.5 m)'),
        TerminalLine(TerminalLineType.success, '> ✓  Cube resting on detected floor'),
      ],
    ),

    // ── L3-2: Tap to place ─────────────────────────────────────────────────
    InspectorLevel(
      id: 'iz3_l2',
      zoneId: 'zone_inspector_3',
      title: 'Tap the Floor to Place Objects',
      objective:
          'The app can see the floor, but tapping on it does nothing. '
          'Add the script that lets the player tap anywhere on a detected surface '
          'and place a virtual object exactly at that spot.',
      gameObjectName: 'XR Rig',
      gameObjectIcon: '🥽',
      sceneObjects: [SceneObjectType.xrRig, SceneObjectType.plane, SceneObjectType.cube],
      existingComponents: [
        ExistingComponent(name: 'Transform',         icon: '⊞', accentColor: _blue, fields: []),
        ExistingComponent(name: 'AR Session Origin', icon: '🌐', accentColor: _cyan, fields: []),
        ExistingComponent(name: 'AR Camera Manager', icon: '📷', accentColor: _cyan, fields: []),
        ExistingComponent(name: 'AR Plane Manager',  icon: '▭',  accentColor: _amber,
          fields: [InspectorField(label: 'Detection Mode', value: 'Horizontal & Vertical')]),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim,     '> Planes detected and visible'),
        TerminalLine(TerminalLineType.error,   '> ERROR: AR Raycast Manager not found'),
        TerminalLine(TerminalLineType.error,   '> ERROR: TapToPlace.cs — cannot cast rays against planes'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Tap input has no target'),
      ],
      hint: '"AR Raycast Manager" fires a virtual ray from the tap point on the screen '
            'into the 3D world and tells you exactly which plane it hit and where.',
      scriptBank: [
        ScriptChip(
          id: 'ar_raycast_mgr',
          label: 'AR Raycast Manager',
          description: 'Converts a 2D screen tap into a 3D world position on a detected plane.',
          dotColor: _amber,
          isCorrect: true,
          activates: [SceneObjectType.cube],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> AR Raycast Manager attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Raycast against: Planes, Meshes'),
            TerminalLine(TerminalLineType.success, '> INFO: TapToPlace.cs error resolved'),
          ],
          addFields: [
            InspectorField(label: 'Raycast Layers', value: 'All'),
            InspectorField(label: 'Max Rays',       value: '10 / frame'),
          ],
        ),
        ScriptChip(
          id: 'wrong_physics_ray',
          label: 'Physics Raycaster',
          description: 'Casts rays against Unity physics colliders — not AR planes.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Physics Raycaster works with collider meshes. AR planes are AR trackables, not colliders. Use AR Raycast Manager.',
        ),
        ScriptChip(
          id: 'wrong_event_sys_3',
          label: 'Event System',
          description: 'Manages UI click events — not AR surface raycasts.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Event System handles UI events. For AR surface placement, use AR Raycast Manager.',
        ),
      ],
      correctIds: ['ar_raycast_mgr'],
      successMessage: 'Tap-to-place works! Players can now tap the floor to place objects anywhere.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> Scene compiled  —  0 errors'),
        TerminalLine(TerminalLineType.success, '> ✓  Raycast Manager: active'),
        TerminalLine(TerminalLineType.success, '> ✓  Tap → 3D world position: working'),
        TerminalLine(TerminalLineType.success, '> ✓  Cube placed at tap location'),
      ],
    ),

    // ── L3-3: Persistent anchor ────────────────────────────────────────────
    InspectorLevel(
      id: 'iz3_l3',
      zoneId: 'zone_inspector_3',
      title: 'Remember Where I Put It',
      objective:
          'The player places a virtual trophy on their real desk. '
          'They close the app and come back tomorrow — but the trophy is gone. '
          'Add the script that saves the trophy\'s position so it reappears in the same spot next time.',
      gameObjectName: 'Trophy',
      gameObjectIcon: '🏆',
      sceneObjects: [SceneObjectType.plane, SceneObjectType.spatialAnchor, SceneObjectType.cube],
      existingComponents: [
        ExistingComponent(name: 'Transform',    icon: '⊞', accentColor: _blue,
          fields: [InspectorField(label: 'Position', value: '0.3, 0.85, -1.2 m')]),
        ExistingComponent(name: 'Mesh Renderer', icon: '◉', accentColor: _blue,
          fields: [InspectorField(label: 'Material', value: 'Trophy_Gold')]),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim,     '> Trophy placed on desk'),
        TerminalLine(TerminalLineType.warning, '> WARNING: No AR Anchor attached to Trophy'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Position is relative to session only'),
        TerminalLine(TerminalLineType.error,   '> ERROR: On next launch, Trophy will not be found'),
      ],
      hint: '"AR Anchor" attaches the object to a physical point in space that ARKit/ARCore '
            'remember via visual feature points. It survives session restarts.',
      scriptBank: [
        ScriptChip(
          id: 'ar_anchor',
          label: 'AR Anchor',
          description: 'Locks the object to a real-world physical feature point that persists across sessions.',
          dotColor: _amber,
          isCorrect: true,
          activates: [SceneObjectType.spatialAnchor],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> AR Anchor attached to Trophy'),
            TerminalLine(TerminalLineType.success, '> INFO: Anchor saved to local storage'),
            TerminalLine(TerminalLineType.success, '> INFO: Feature signature captured'),
            TerminalLine(TerminalLineType.success, '> INFO: Trophy will survive app restart'),
          ],
          addFields: [
            InspectorField(label: 'Anchor ID',         value: 'trophy_desk_001'),
            InspectorField(label: 'Persistence',       value: 'Local'),
            InspectorField(label: 'Auto Re-Localise',  value: 'True'),
          ],
        ),
        ScriptChip(
          id: 'wrong_rigidbody_3',
          label: 'Rigidbody',
          description: 'Physics body — gives gravity, not persistence across sessions.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Rigidbody adds physics. For persistence across sessions, use AR Anchor.',
        ),
        ScriptChip(
          id: 'wrong_plane_mgr_3',
          label: 'AR Plane Manager',
          description: 'Detects new surfaces — won\'t save where the trophy was placed.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'AR Plane Manager detects surfaces. To save object positions, add AR Anchor to the object itself.',
        ),
      ],
      correctIds: ['ar_anchor'],
      successMessage: 'Trophy anchored! It will appear in the same spot on the desk when the app reopens.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> Scene compiled  —  0 errors'),
        TerminalLine(TerminalLineType.success, '> ✓  Anchor saved: trophy_desk_001'),
        TerminalLine(TerminalLineType.success, '> ✓  Feature signature: 847 points captured'),
        TerminalLine(TerminalLineType.success, '> ✓  Re-localisation on next launch: enabled'),
      ],
    ),

    // ── L3-BOSS: Full interior AR app ─────────────────────────────────────
    InspectorLevel(
      id: 'iz3_boss',
      zoneId: 'zone_inspector_3',
      isBoss: true,
      timeLimit: 90,
      title: 'BOSS — Furniture Placement App',
      objective:
          'A furniture app: players scan a room, tap to place virtual sofas on the real floor, '
          'resize them with a pinch, and save their layout. When they come back, '
          'every piece is exactly where they left it. You need: surface detection, '
          'tap-to-place, scaling, and persistent anchors.',
      gameObjectName: 'Room Session',
      gameObjectIcon: '🛋',
      sceneObjects: [
        SceneObjectType.xrRig, SceneObjectType.plane,
        SceneObjectType.cube, SceneObjectType.spatialAnchor,
      ],
      existingComponents: [
        ExistingComponent(name: 'Transform',         icon: '⊞', accentColor: _blue, fields: []),
        ExistingComponent(name: 'AR Session Origin', icon: '🌐', accentColor: _cyan, fields: []),
        ExistingComponent(name: 'AR Camera Manager', icon: '📷', accentColor: _cyan, fields: []),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.error,   '> ERROR: No plane detection'),
        TerminalLine(TerminalLineType.error,   '> ERROR: Tap-to-place disabled'),
        TerminalLine(TerminalLineType.error,   '> ERROR: No scaling gestures'),
        TerminalLine(TerminalLineType.error,   '> ERROR: Layout will not persist'),
      ],
      hint: 'You need all four: AR Plane Manager (scan room), AR Raycast Manager (tap to place), '
            'XR Object Manipulator (resize), and AR Anchor (save layout).',
      scriptBank: [
        ScriptChip(
          id: 'boss3_plane', label: 'AR Plane Manager',
          description: 'Scans the room for surfaces.',
          dotColor: _amber, isCorrect: true,
          activates: [SceneObjectType.plane],
          addLines: [TerminalLine(TerminalLineType.success, '> Surfaces detected: floor, walls')],
          addFields: [InspectorField(label: 'Detection Mode', value: 'Horizontal & Vertical')],
        ),
        ScriptChip(
          id: 'boss3_raycast', label: 'AR Raycast Manager',
          description: 'Lets player tap to place furniture on surfaces.',
          dotColor: _amber, isCorrect: true,
          activates: [SceneObjectType.cube],
          addLines: [TerminalLine(TerminalLineType.success, '> Tap-to-place: active')],
          addFields: [InspectorField(label: 'Raycast Layers', value: 'All')],
        ),
        ScriptChip(
          id: 'boss3_manip', label: 'XR Object Manipulator',
          description: 'Pinch-to-resize furniture pieces.',
          dotColor: _green, isCorrect: true,
          addLines: [TerminalLine(TerminalLineType.success, '> Pinch-to-resize: active')],
          addFields: [InspectorField(label: 'Allowed Transforms', value: 'Scale, Translate')],
        ),
        ScriptChip(
          id: 'boss3_anchor', label: 'AR Anchor',
          description: 'Saves furniture positions across sessions.',
          dotColor: _amber, isCorrect: true,
          activates: [SceneObjectType.spatialAnchor],
          addLines: [TerminalLine(TerminalLineType.success, '> Layout anchored and persistent')],
          addFields: [InspectorField(label: 'Persistence', value: 'Local')],
        ),
        ScriptChip(
          id: 'boss3_wrong', label: 'Cinemachine Brain',
          description: 'Cinematic camera — not relevant here.',
          dotColor: _wrongDot, isCorrect: false,
          errorMessage: 'Cinemachine is for film cameras, not AR furniture placement.',
        ),
      ],
      correctIds: ['boss3_plane', 'boss3_raycast', 'boss3_manip', 'boss3_anchor'],
      successMessage: 'Furniture app complete! Scan, place, resize, and save — full room layout preserved.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> ✓  Room scanned: 6 planes found'),
        TerminalLine(TerminalLineType.success, '> ✓  Sofa placed on floor via tap'),
        TerminalLine(TerminalLineType.success, '> ✓  Sofa resized via two-hand pinch'),
        TerminalLine(TerminalLineType.success, '> ✓  Layout saved: 3 anchors persisted'),
        TerminalLine(TerminalLineType.success, '> ✓  Room setup will reload on next launch'),
      ],
    ),
  ],
);


// ═══════════════════════════════════════════════════════════════════════════
//  ZONE 4 — MAKE IT LOOK REAL
//  Lighting estimation, occlusion, shadows. Visual realism.
// ═══════════════════════════════════════════════════════════════════════════

const _zone4 = InspectorZone(
  id: 'zone_inspector_4',
  name: 'Zone 4 — Make It Look Real',
  subtitle: 'Lighting, shadows, and occlusion',
  accentColor: _purple,
  icon: Icons.lightbulb_rounded,
  levels: [

    InspectorLevel(
      id: 'iz4_l1',
      zoneId: 'zone_inspector_4',
      title: 'Match the Room\'s Lighting',
      isFree: false,
      objective:
          'The virtual sofa looks like it\'s glowing in a dark room — too bright, clearly fake. '
          'Add the script that reads the real room\'s lighting and applies it to '
          'all virtual objects so they match the environment.',
      gameObjectName: 'AR Camera Manager',
      gameObjectIcon: '💡',
      sceneObjects: [SceneObjectType.camera, SceneObjectType.cube, SceneObjectType.lightProbe],
      existingComponents: [
        ExistingComponent(name: 'Transform',         icon: '⊞', accentColor: _blue, fields: []),
        ExistingComponent(name: 'AR Camera Manager', icon: '📷', accentColor: _cyan,
          fields: [
            InspectorField(label: 'Light Estimation', value: 'Disabled'),
            InspectorField(label: 'Facing Direction', value: 'World'),
          ]),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim,     '> AR Camera Manager found'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Light estimation: Disabled'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Virtual objects use default brightness'),
        TerminalLine(TerminalLineType.error,   '> ERROR: LightingAdapter.cs — no estimate data'),
      ],
      hint: 'Enable "Light Estimation" on AR Camera Manager — it reads brightness and colour temperature '
            'from the camera image every frame and feeds that into a Light component on the scene.',
      scriptBank: [
        ScriptChip(
          id: 'light_estimation',
          label: 'AR Light Estimation',
          description: 'Reads the real room\'s brightness and colour temperature every frame and applies it to virtual objects.',
          dotColor: _purple,
          isCorrect: true,
          activates: [SceneObjectType.lightProbe],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> Light Estimation: ENABLED'),
            TerminalLine(TerminalLineType.success, '> INFO: Ambient intensity: 1,420 lux'),
            TerminalLine(TerminalLineType.success, '> INFO: Colour temperature: 4,200 K (daylight)'),
            TerminalLine(TerminalLineType.success, '> INFO: LightingAdapter.cs error resolved'),
          ],
          addFields: [
            InspectorField(label: 'Light Estimation',   value: 'Ambient Intensity + Colour'),
            InspectorField(label: 'Main Light Direction', value: 'Enabled'),
          ],
        ),
        ScriptChip(
          id: 'wrong_bloom',
          label: 'Bloom Post Process',
          description: 'Adds a glow effect — makes virtual objects MORE fake-looking, not less.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Bloom adds a glow effect and will make your sofa look even more fake. Use AR Light Estimation.',
        ),
        ScriptChip(
          id: 'wrong_reflection',
          label: 'Reflection Probe',
          description: 'Captures cube-map reflections — doesn\'t read real-world lighting.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Reflection Probe bakes static reflections. For live real-world lighting, use AR Light Estimation.',
        ),
      ],
      correctIds: ['light_estimation'],
      successMessage: 'Lighting matched! The sofa now looks like it belongs in the real room.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> ✓  Ambient intensity: synced to real room'),
        TerminalLine(TerminalLineType.success, '> ✓  Colour temperature: 4,200 K applied'),
        TerminalLine(TerminalLineType.success, '> ✓  Virtual sofa: visually grounded'),
      ],
    ),

    InspectorLevel(
      id: 'iz4_l2',
      zoneId: 'zone_inspector_4',
      title: 'Hide Behind Real Objects',
      objective:
          'A virtual character is walking around the room — but it walks in front of the sofa '
          'even when it should be behind it. Add the script that makes virtual objects '
          'correctly disappear behind real physical objects.',
      gameObjectName: 'AR Occlusion Manager',
      gameObjectIcon: '🪑',
      sceneObjects: [SceneObjectType.xrRig, SceneObjectType.avatar, SceneObjectType.cube],
      existingComponents: [
        ExistingComponent(name: 'Transform',         icon: '⊞', accentColor: _blue, fields: []),
        ExistingComponent(name: 'AR Camera Manager', icon: '📷', accentColor: _cyan, fields: []),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.warning, '> WARNING: Occlusion depth: Disabled'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Virtual character renders in front of all real objects'),
        TerminalLine(TerminalLineType.error,   '> ERROR: OcclusionController.cs — no depth estimate'),
      ],
      hint: '"AR Occlusion Manager" uses the depth camera (on supported phones) to map real-world '
            'distances, then masks virtual pixels that are behind real objects.',
      scriptBank: [
        ScriptChip(
          id: 'ar_occlusion',
          label: 'AR Occlusion Manager',
          description: 'Uses the depth sensor to make virtual objects correctly hide behind real objects.',
          dotColor: _purple,
          isCorrect: true,
          activates: [SceneObjectType.avatar],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> AR Occlusion Manager attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Depth mode: Fastest'),
            TerminalLine(TerminalLineType.success, '> INFO: Real objects now occlude virtual content'),
          ],
          addFields: [
            InspectorField(label: 'Human Depth Mode',   value: 'Fastest'),
            InspectorField(label: 'Env Depth Mode',     value: 'Fastest'),
            InspectorField(label: 'Occlusion Preference', value: 'Prefer Environment'),
          ],
        ),
        ScriptChip(
          id: 'wrong_shader',
          label: 'Custom Depth Shader',
          description: 'A GPU shader — won\'t automatically occlude without the AR manager feeding it data.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'A shader alone can\'t occlude — it needs depth data from AR Occlusion Manager.',
        ),
        ScriptChip(
          id: 'wrong_stencil',
          label: 'Stencil Buffer Renderer',
          description: 'Stencil masking technique — works for predefined shapes, not live real-world geometry.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Stencil buffers are for predefined masks. AR Occlusion Manager handles dynamic real-world geometry.',
        ),
      ],
      correctIds: ['ar_occlusion'],
      successMessage: 'Occlusion working! The virtual character now correctly hides behind real furniture.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> ✓  Depth map: 30fps'),
        TerminalLine(TerminalLineType.success, '> ✓  Character hidden behind sofa: correct'),
        TerminalLine(TerminalLineType.success, '> ✓  Occlusion mode: Environment'),
      ],
    ),

    InspectorLevel(
      id: 'iz4_l3',
      zoneId: 'zone_inspector_4',
      title: 'Cast Real Shadows',
      objective:
          'The virtual cube floats without a shadow — making it look unreal. '
          'Add the script that reads the real room\'s main light direction '
          'and casts a correct shadow from virtual objects onto the real floor.',
      gameObjectName: 'Directional Light',
      gameObjectIcon: '☀️',
      sceneObjects: [SceneObjectType.cube, SceneObjectType.plane, SceneObjectType.lightProbe],
      existingComponents: [
        ExistingComponent(name: 'Transform', icon: '⊞', accentColor: _blue,
          fields: [InspectorField(label: 'Rotation', value: '45°, -30°, 0°')]),
        ExistingComponent(name: 'Light',     icon: '💡', accentColor: _amber,
          fields: [
            InspectorField(label: 'Type',      value: 'Directional'),
            InspectorField(label: 'Intensity', value: '1.0'),
            InspectorField(label: 'Shadows',   value: 'Soft'),
          ]),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim,     '> Directional Light found'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Light direction is a fixed default (45°)'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Does not match real room sunlight'),
        TerminalLine(TerminalLineType.error,   '> ERROR: ShadowAligner.cs — no estimation data'),
      ],
      hint: '"AR Light Estimation" with "Main Light Direction" enabled sends the real sun/lamp '
            'angle into Unity\'s Directional Light every frame so shadows point the right way.',
      scriptBank: [
        ScriptChip(
          id: 'light_est_shadow',
          label: 'AR Light Estimation (+ Direction)',
          description: 'Estimates the real light source\'s angle and feeds it into the scene\'s Directional Light.',
          dotColor: _purple,
          isCorrect: true,
          activates: [SceneObjectType.lightProbe],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> AR Light Estimation: ENABLED'),
            TerminalLine(TerminalLineType.success, '> INFO: Main light direction: 62°, -18° (window)'),
            TerminalLine(TerminalLineType.success, '> INFO: Shadow angle matched to real room'),
            TerminalLine(TerminalLineType.success, '> INFO: ShadowAligner.cs error resolved'),
          ],
          addFields: [
            InspectorField(label: 'Main Light Direction', value: 'Enabled'),
            InspectorField(label: 'Main Light Intensity', value: 'Enabled'),
            InspectorField(label: 'Update Rate',          value: 'Every Frame'),
          ],
        ),
        ScriptChip(
          id: 'wrong_baked_gi',
          label: 'Baked Global Illumination',
          description: 'Pre-bakes lighting at build time — can\'t adapt to a real room.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Baked GI is static — it cannot read the real room\'s live light direction.',
        ),
        ScriptChip(
          id: 'wrong_realtime_gi',
          label: 'Realtime Global Illumination',
          description: 'Expensive real-time GI pass — doesn\'t read the real camera image.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Realtime GI simulates light bounces inside the virtual scene, not the real room.',
        ),
      ],
      correctIds: ['light_est_shadow'],
      successMessage: 'Shadows aligned! The cube\'s shadow now points in the same direction as the real room\'s light.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> ✓  Light direction synced: 62°, -18°'),
        TerminalLine(TerminalLineType.success, '> ✓  Shadow direction: matches window'),
        TerminalLine(TerminalLineType.success, '> ✓  Virtual cube: visually convincing'),
      ],
    ),

    InspectorLevel(
      id: 'iz4_boss',
      zoneId: 'zone_inspector_4',
      isBoss: true,
      timeLimit: 90,
      title: 'BOSS — Photorealistic AR Scene',
      objective:
          'A premium AR app review. Everything must look real: '
          'lighting matches the room, characters hide behind furniture, '
          'shadows point the right way. Three realism systems, one scene. '
          'Wire them all correctly before time runs out.',
      gameObjectName: 'Realism Rig',
      gameObjectIcon: '🎭',
      sceneObjects: [
        SceneObjectType.camera, SceneObjectType.avatar,
        SceneObjectType.cube, SceneObjectType.lightProbe,
      ],
      existingComponents: [
        ExistingComponent(name: 'Transform',         icon: '⊞', accentColor: _blue, fields: []),
        ExistingComponent(name: 'AR Camera Manager', icon: '📷', accentColor: _cyan, fields: [
          InspectorField(label: 'Light Estimation', value: 'Disabled'),
        ]),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.error, '> ERROR: Lighting fake — does not match room'),
        TerminalLine(TerminalLineType.error, '> ERROR: Character floats over furniture'),
        TerminalLine(TerminalLineType.error, '> ERROR: Shadows pointing wrong direction'),
      ],
      hint: 'AR Light Estimation (for ambient colour), AR Occlusion Manager (to hide behind real objects), '
            'and AR Light Estimation + Direction (for shadow angle). '
            'Note: Light Estimation appears twice with different settings.',
      scriptBank: [
        ScriptChip(
          id: 'boss4_ambient', label: 'AR Light Estimation (Ambient)',
          description: 'Syncs ambient brightness and colour to the real room.',
          dotColor: _purple, isCorrect: true,
          activates: [SceneObjectType.lightProbe],
          addLines: [TerminalLine(TerminalLineType.success, '> Ambient light: synced to room')],
          addFields: [InspectorField(label: 'Mode', value: 'Ambient Intensity + Colour')],
        ),
        ScriptChip(
          id: 'boss4_occlusion', label: 'AR Occlusion Manager',
          description: 'Makes virtual content hide behind real objects.',
          dotColor: _purple, isCorrect: true,
          activates: [SceneObjectType.avatar],
          addLines: [TerminalLine(TerminalLineType.success, '> Occlusion: character hides behind furniture')],
          addFields: [InspectorField(label: 'Depth Mode', value: 'Fastest')],
        ),
        ScriptChip(
          id: 'boss4_shadow_dir', label: 'AR Light Estimation (+ Shadow Direction)',
          description: 'Aligns shadow angle to the real room\'s main light source.',
          dotColor: _purple, isCorrect: true,
          addLines: [TerminalLine(TerminalLineType.success, '> Shadow direction: matched to real light')],
          addFields: [InspectorField(label: 'Main Light Direction', value: 'Enabled')],
        ),
        ScriptChip(
          id: 'boss4_wrong_bloom', label: 'Bloom Post Process',
          description: 'Visual effect — makes things worse, not more realistic.',
          dotColor: _wrongDot, isCorrect: false,
          errorMessage: 'Bloom adds a glow effect. It will make the scene look less realistic, not more.',
        ),
        ScriptChip(
          id: 'boss4_wrong_gi', label: 'Baked Global Illumination',
          description: 'Static pre-baked GI — can\'t adapt to a real room.',
          dotColor: _wrongDot, isCorrect: false,
          errorMessage: 'Baked GI is pre-computed at build time. It cannot reflect real-world lighting.',
        ),
      ],
      correctIds: ['boss4_ambient', 'boss4_occlusion', 'boss4_shadow_dir'],
      successMessage: 'Scene is photorealistic! Lighting, occlusion, and shadows all match the real world.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> ✓  Ambient light: synced'),
        TerminalLine(TerminalLineType.success, '> ✓  Occlusion: character hides correctly'),
        TerminalLine(TerminalLineType.success, '> ✓  Shadows: angle matched to real sun'),
        TerminalLine(TerminalLineType.success, '> ✓  Realism score: EXCELLENT'),
      ],
    ),
  ],
);


// ═══════════════════════════════════════════════════════════════════════════
//  ZONE 5 — MASTER THE SCENE
//  Multiplayer shared anchors, cloud, image tracking, SLAM depth.
//  Only accessible to premium / highest-XP players.
// ═══════════════════════════════════════════════════════════════════════════

const _zone5 = InspectorZone(
  id: 'zone_inspector_5',
  name: 'Zone 5 — Master the Scene',
  subtitle: 'Multiplayer, cloud anchors, and advanced tracking',
  accentColor: _pink,
  icon: Icons.public_rounded,
  levels: [

    InspectorLevel(
      id: 'iz5_l1',
      zoneId: 'zone_inspector_5',
      title: 'Scan a Book Cover to Unlock Content',
      isFree: false,
      objective:
          'An educational app: when a student points the camera at a specific book cover, '
          'a 3D character pops out of it. No SLAM needed — the image is the anchor. '
          'Add the script that recognises the book\'s image and positions AR content on it.',
      gameObjectName: 'AR Session Origin',
      gameObjectIcon: '📚',
      sceneObjects: [SceneObjectType.camera, SceneObjectType.avatar],
      existingComponents: [
        ExistingComponent(name: 'Transform',         icon: '⊞', accentColor: _blue, fields: []),
        ExistingComponent(name: 'AR Session Origin', icon: '🌐', accentColor: _cyan, fields: []),
        ExistingComponent(name: 'AR Camera Manager', icon: '📷', accentColor: _cyan, fields: []),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.warning, '> WARNING: No image tracking manager found'),
        TerminalLine(TerminalLineType.error,   '> ERROR: BookTrigger.cs — no tracked image data'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Character will not appear on book scan'),
      ],
      hint: '"AR Tracked Image Manager" holds a reference image database. '
            'When the camera finds a match, it fires an event your code listens to.',
      scriptBank: [
        ScriptChip(
          id: 'ar_img_mgr',
          label: 'AR Tracked Image Manager',
          description: 'Matches camera frames against a reference image database and fires events when found.',
          dotColor: _pink,
          isCorrect: true,
          activates: [SceneObjectType.avatar],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> AR Tracked Image Manager attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Reference library: science_books_db'),
            TerminalLine(TerminalLineType.success, '> INFO: 3 images loaded'),
            TerminalLine(TerminalLineType.success, '> INFO: BookTrigger.cs error resolved'),
          ],
          addFields: [
            InspectorField(label: 'Reference Library', value: 'science_books_db'),
            InspectorField(label: 'Max Moving Images', value: '1'),
            InspectorField(label: 'Tracked Image Prefab', value: 'CharacterSpawner'),
          ],
        ),
        ScriptChip(
          id: 'wrong_plane_5',
          label: 'AR Plane Manager',
          description: 'Detects floors and walls — not images or book covers.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'AR Plane Manager detects surfaces, not specific images. Use AR Tracked Image Manager.',
        ),
        ScriptChip(
          id: 'wrong_occlusion_5',
          label: 'AR Occlusion Manager',
          description: 'Handles depth masking — not image recognition.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'AR Occlusion Manager handles depth masking. For book recognition, use AR Tracked Image Manager.',
        ),
      ],
      correctIds: ['ar_img_mgr'],
      successMessage: 'Image tracking active! Pointing at the book cover now spawns the 3D character.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> ✓  Reference library loaded: 3 images'),
        TerminalLine(TerminalLineType.success, '> ✓  Book cover matched in 0.12s'),
        TerminalLine(TerminalLineType.success, '> ✓  Character spawned at image origin'),
      ],
    ),

    InspectorLevel(
      id: 'iz5_l2',
      zoneId: 'zone_inspector_5',
      title: 'Two Players, Same Virtual Object',
      objective:
          'Two players in the same room both open the app on their own phones. '
          'They should see the same virtual chess board between them, perfectly aligned. '
          'Add the script that uploads an anchor to the cloud so both phones share it.',
      gameObjectName: 'Shared Chess Board',
      gameObjectIcon: '♟',
      sceneObjects: [SceneObjectType.cube, SceneObjectType.spatialAnchor, SceneObjectType.plane],
      existingComponents: [
        ExistingComponent(name: 'Transform',    icon: '⊞', accentColor: _blue, fields: []),
        ExistingComponent(name: 'Mesh Renderer', icon: '◉', accentColor: _blue,
          fields: [InspectorField(label: 'Material', value: 'ChessBoard_Mat')]),
        ExistingComponent(name: 'AR Anchor',    icon: '📌', accentColor: _amber,
          fields: [InspectorField(label: 'Persistence', value: 'Local only')]),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim,     '> Chess board placed by Player 1'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Anchor is local only — Player 2 cannot see it'),
        TerminalLine(TerminalLineType.error,   '> ERROR: ARCloudAnchor.cs — no cloud anchor component'),
      ],
      hint: '"AR Cloud Anchor" uploads the local anchor\'s feature signature to Google or Apple\'s cloud. '
            'Other devices resolve the same anchor ID and see the object in the same place.',
      scriptBank: [
        ScriptChip(
          id: 'ar_cloud_anchor',
          label: 'AR Cloud Anchor',
          description: 'Uploads the anchor to the cloud so multiple devices can resolve it and see the same object.',
          dotColor: _pink,
          isCorrect: true,
          activates: [SceneObjectType.spatialAnchor],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> AR Cloud Anchor attached'),
            TerminalLine(TerminalLineType.success, '> INFO: Uploading feature map… done (1.2s)'),
            TerminalLine(TerminalLineType.success, '> INFO: Cloud Anchor ID: xca_03f7b2e9'),
            TerminalLine(TerminalLineType.success, '> INFO: Player 2 resolved anchor — chess board visible'),
          ],
          addFields: [
            InspectorField(label: 'Anchor ID',    value: 'xca_03f7b2e9'),
            InspectorField(label: 'Sharing Mode', value: 'Persistent (24h)'),
            InspectorField(label: 'Auto Resolve', value: 'True'),
          ],
        ),
        ScriptChip(
          id: 'wrong_photon',
          label: 'Photon Network View',
          description: 'Photon multiplayer sync — syncs game state but not world-space position.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Photon syncs game data, not physical AR anchor positions. Use AR Cloud Anchor for shared world-space.',
        ),
        ScriptChip(
          id: 'wrong_ar_anchor_5',
          label: 'AR Anchor',
          description: 'Local anchor — already on the object. Doesn\'t share across devices.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'AR Anchor (local) is already on the object. You need AR Cloud Anchor to share with another device.',
        ),
      ],
      correctIds: ['ar_cloud_anchor'],
      successMessage: 'Multiplayer anchor shared! Both players see the chess board in exactly the same position.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> ✓  Cloud anchor uploaded'),
        TerminalLine(TerminalLineType.success, '> ✓  Player 2 resolved: xca_03f7b2e9'),
        TerminalLine(TerminalLineType.success, '> ✓  Chess board aligned on both devices'),
        TerminalLine(TerminalLineType.success, '> ✓  Multiplayer AR: ACTIVE'),
      ],
    ),

    InspectorLevel(
      id: 'iz5_l3',
      zoneId: 'zone_inspector_5',
      title: 'Map the Whole Room (Meshing)',
      objective:
          'On a LiDAR-equipped iPhone, you want to scan the entire room geometry — '
          'every wall, every piece of furniture — as a 3D mesh, so virtual objects '
          'can rest on any surface and occlude behind anything. Add meshing.',
      gameObjectName: 'AR Session Origin',
      gameObjectIcon: '🗺',
      sceneObjects: [
        SceneObjectType.xrRig, SceneObjectType.plane,
        SceneObjectType.cube, SceneObjectType.spatialAnchor,
      ],
      existingComponents: [
        ExistingComponent(name: 'Transform',         icon: '⊞', accentColor: _blue, fields: []),
        ExistingComponent(name: 'AR Session Origin', icon: '🌐', accentColor: _cyan, fields: []),
        ExistingComponent(name: 'AR Camera Manager', icon: '📷', accentColor: _cyan, fields: []),
        ExistingComponent(name: 'AR Plane Manager',  icon: '▭',  accentColor: _amber, fields: []),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim,     '> LiDAR depth sensor: available'),
        TerminalLine(TerminalLineType.warning, '> WARNING: AR Mesh Manager not found'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Only planes detected — full geometry missing'),
        TerminalLine(TerminalLineType.error,   '> ERROR: RoomMeshController.cs — no mesh data'),
      ],
      hint: '"AR Mesh Manager" uses the LiDAR sensor to build a continuous 3D mesh of the entire room. '
            'It is far more detailed than plane detection alone.',
      scriptBank: [
        ScriptChip(
          id: 'ar_mesh_mgr',
          label: 'AR Mesh Manager',
          description: 'Uses LiDAR to build a real-time 3D mesh of every surface in the room.',
          dotColor: _pink,
          isCorrect: true,
          activates: [SceneObjectType.plane, SceneObjectType.spatialAnchor],
          addLines: [
            TerminalLine(TerminalLineType.info,    '> AR Mesh Manager attached'),
            TerminalLine(TerminalLineType.success, '> INFO: LiDAR mesh density: Medium'),
            TerminalLine(TerminalLineType.success, '> INFO: Meshes generated: 24 submeshes'),
            TerminalLine(TerminalLineType.success, '> INFO: RoomMeshController.cs error resolved'),
          ],
          addFields: [
            InspectorField(label: 'Mesh Prefab',     value: 'AR Default Mesh'),
            InspectorField(label: 'Density',         value: 'Medium'),
            InspectorField(label: 'Concurrency',     value: '4'),
          ],
        ),
        ScriptChip(
          id: 'wrong_extra_plane',
          label: 'AR Plane Manager (extra)',
          description: 'Already in the scene — adding twice does nothing.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'AR Plane Manager is already in the scene. For full room geometry, add AR Mesh Manager.',
        ),
        ScriptChip(
          id: 'wrong_nav_mesh',
          label: 'Nav Mesh Surface',
          description: 'Bakes walkable paths for AI agents — not real-time LiDAR meshing.',
          dotColor: _wrongDot,
          isCorrect: false,
          errorMessage: 'Nav Mesh Surface is for AI navigation paths. AR Mesh Manager handles real-time LiDAR geometry.',
        ),
      ],
      correctIds: ['ar_mesh_mgr'],
      successMessage: 'Full room mesh generated! Every wall, chair, and surface is now a real collision mesh.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> ✓  LiDAR mesh: 24 submeshes, 14,200 tris'),
        TerminalLine(TerminalLineType.success, '> ✓  Sofa, desk, walls: all meshed'),
        TerminalLine(TerminalLineType.success, '> ✓  Virtual objects rest on any real surface'),
      ],
    ),

    // ── FINAL BOSS ─────────────────────────────────────────────────────────
    InspectorLevel(
      id: 'iz5_boss',
      zoneId: 'zone_inspector_5',
      isBoss: true,
      timeLimit: 120,
      title: 'FINAL BOSS — Ship the AR App',
      objective:
          'A production-ready AR multiplayer game launches today. '
          'Two players. Shared world. Hands tracked. Real lighting. Characters hide behind furniture. '
          'Book covers trigger bonus levels. Every system from all 5 zones in one scene. '
          'You have 2 minutes. No hints after the first mistake.',
      gameObjectName: 'Production Session',
      gameObjectIcon: '🚀',
      sceneObjects: [
        SceneObjectType.camera, SceneObjectType.xrRig,
        SceneObjectType.handLeft, SceneObjectType.handRight,
        SceneObjectType.avatar, SceneObjectType.cube,
        SceneObjectType.lightProbe, SceneObjectType.spatialAnchor,
      ],
      existingComponents: [
        ExistingComponent(name: 'Transform',         icon: '⊞', accentColor: _blue, fields: []),
        ExistingComponent(name: 'AR Session Origin', icon: '🌐', accentColor: _cyan, fields: []),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.error, '> ERROR: 7 systems offline'),
        TerminalLine(TerminalLineType.error, '> ERROR: App will not function'),
        TerminalLine(TerminalLineType.warning, '> Launch blocked — fix all errors'),
      ],
      hint: 'You need all 7: AR Session, AR Camera Background, XR Hand Subsystem, '
            'XR Hand Mesh Renderer, AR Cloud Anchor, AR Light Estimation, AR Occlusion Manager.',
      scriptBank: [
        ScriptChip(id: 'fb_session',     label: 'AR Session',
          description: 'Global AR tracking engine.',
          dotColor: _cyan, isCorrect: true,
          addLines: [TerminalLine(TerminalLineType.success, '> AR Session: running')],
          addFields: [InspectorField(label: 'Attempt Update', value: 'True')]),
        ScriptChip(id: 'fb_bg',          label: 'AR Camera Background',
          description: 'Real-world camera feed.',
          dotColor: _cyan, isCorrect: true,
          activates: [SceneObjectType.camera],
          addLines: [TerminalLine(TerminalLineType.success, '> Camera feed: active')],
          addFields: [InspectorField(label: 'Renderer Mode', value: 'After Opaques')]),
        ScriptChip(id: 'fb_hand_sub',    label: 'XR Hand Subsystem',
          description: 'Hand skeleton tracking.',
          dotColor: _green, isCorrect: true,
          activates: [SceneObjectType.handLeft, SceneObjectType.handRight],
          addLines: [TerminalLine(TerminalLineType.success, '> Hand tracking: 26 joints/hand')],
          addFields: [InspectorField(label: 'Update Type', value: 'BeforeRender')]),
        ScriptChip(id: 'fb_hand_mesh',   label: 'XR Hand Mesh Renderer',
          description: 'Visible hand meshes.',
          dotColor: _green, isCorrect: true,
          addLines: [TerminalLine(TerminalLineType.success, '> Hand meshes: visible')],
          addFields: [InspectorField(label: 'Hand Mesh Prefab', value: 'DefaultHand')]),
        ScriptChip(id: 'fb_cloud',       label: 'AR Cloud Anchor',
          description: 'Shared multiplayer anchor.',
          dotColor: _pink, isCorrect: true,
          activates: [SceneObjectType.spatialAnchor],
          addLines: [TerminalLine(TerminalLineType.success, '> Cloud anchor: Player 2 resolved')],
          addFields: [InspectorField(label: 'Sharing Mode', value: 'Persistent 24h')]),
        ScriptChip(id: 'fb_light',       label: 'AR Light Estimation',
          description: 'Real-world lighting sync.',
          dotColor: _purple, isCorrect: true,
          activates: [SceneObjectType.lightProbe],
          addLines: [TerminalLine(TerminalLineType.success, '> Lighting: synced to real room')],
          addFields: [InspectorField(label: 'Mode', value: 'Ambient + Direction')]),
        ScriptChip(id: 'fb_occlusion',   label: 'AR Occlusion Manager',
          description: 'Characters hide behind real furniture.',
          dotColor: _purple, isCorrect: true,
          activates: [SceneObjectType.avatar],
          addLines: [TerminalLine(TerminalLineType.success, '> Occlusion: characters hide correctly')],
          addFields: [InspectorField(label: 'Depth Mode', value: 'Fastest')]),
        // Distractors
        ScriptChip(id: 'fb_wrong_photon', label: 'Photon Network View',
          description: 'Photon multiplayer sync — not AR world-space.',
          dotColor: _wrongDot, isCorrect: false,
          errorMessage: 'Photon syncs game state, not AR world positions. Use AR Cloud Anchor.'),
        ScriptChip(id: 'fb_wrong_baked',  label: 'Baked Global Illumination',
          description: 'Static pre-baked lighting.',
          dotColor: _wrongDot, isCorrect: false,
          errorMessage: 'Baked GI is static. Use AR Light Estimation for live real-world lighting.'),
      ],
      correctIds: ['fb_session','fb_bg','fb_hand_sub','fb_hand_mesh','fb_cloud','fb_light','fb_occlusion'],
      successMessage: '🚀 App shipped! All 7 systems online. Production-ready AR multiplayer is LIVE.',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> Build succeeded  —  0 errors, 0 warnings'),
        TerminalLine(TerminalLineType.success, '> ✓  AR session running'),
        TerminalLine(TerminalLineType.success, '> ✓  Both players: hands tracked'),
        TerminalLine(TerminalLineType.success, '> ✓  Multiplayer anchor shared'),
        TerminalLine(TerminalLineType.success, '> ✓  Lighting and occlusion: real-world accurate'),
        TerminalLine(TerminalLineType.success, '> ✓  App store submission: READY'),
      ],
    ),
  ],
);

// MASTER LIST
final List<InspectorZone> inspectorGameZones = [
  _zone1,
  _zone2,
  _zone3,
  _zone4,
  _zone5,
];

List<InspectorLevel> get allInspectorLevels =>
    inspectorGameZones.expand((z) => z.levels).toList();
