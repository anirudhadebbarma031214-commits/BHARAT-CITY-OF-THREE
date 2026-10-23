# BHARAT: CITY OF THREE

**A game by ANI STUDIO**

A Windows-first, Godot 4 third-person open-world prototype inspired by Agartala, Tripura. The initial build focuses on a playable 3D street, drivable/stealable test cars, a GTA-style wanted HUD, a corner minimap, and a Windows `.exe` build workflow.

## Current prototype
- WASD movement and mouse-look camera
- Press **F** near a parked car to enter/steal it; press **F** again to exit
- WASD driving, Space handbrake, E horn, V camera toggle, Esc pause
- Wanted stars rise when the player steals a car or causes a traffic incident, and cool down over time
- Corner minimap and mission objective HUD
- Procedural Agartala-inspired street scene with tropical greenery, shopfronts, road markings and traffic props
- Windows desktop build via GitHub Actions

## Build
1. Install Godot 4.4.1 (standard build) on Windows.
2. Open this repository's `project.godot` in Godot.
3. Press **F6** to run the current scene, or use **Project → Export** after installing the Windows export templates.
4. GitHub Actions can build a Windows executable and upload it as an artifact. Open **Actions → Windows EXE Build** after a successful run.

## Visual target
The project aims for cinematic lighting, detailed materials and a grounded Indian setting. Call of Duty / GTA-level fidelity requires substantial original art, animations, audio, and optimization; the starter scene is a foundation, not a claim that AAA assets are already present. It is designed to scale up with real assets and graphics settings.

## Planned campaign
60 missions: 10 emotional opening missions, 30 action/robbery missions (missions 11–40), and 20 concluding missions (missions 41–60), with the finale returning to emotional story themes. These are campaign goals; not all missions are implemented in this prototype.
