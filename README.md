# Infinite Mind Maze

Infinite Mind Maze is a minimalist, top-down maze exploration game built in pure HTML5 Canvas and JavaScript.
You start at the center of an enormous maze, seeing almost nothing. As you survive and push outward, new stages unlock tools that slowly “upgrade” your brain: flashlight, compass, memory map, breadcrumbs, and more.

The maze feels endless, but if you reach Stage 8 and find the secret exit, the run ends with a clean victory screen.

---

## Core Features

- 🌀 **Infinite-style maze feeling**
  A single huge maze with the player always in the center of the camera. You never see the exit marked on screen.

- 🌑 **Fog of war + flashlight**
  In Stage 1 you only see the tile in front of you. In later stages your flashlight radius grows and more space is revealed.

- 🎯 **Stage-based progression**
  Distance from the center controls your stage:
  - Stage 1: One-step visibility
  - Stage 2: Flashlight + Pulse Scanner
  - Stage 3+: Compass, heat trail, auto-turn helper, shadow sense, etc.

- 🧠 **Memory map & tools**
  - **Pulse Scanner (Q / button)** – reveals nearby tiles permanently on your mental map (with cooldown).
  - **Flash Bomb (E / button)** – big temporary flash; some tiles from that flash stay in your memory.
  - **Breadcrumbs (Space / button)** – drop markers to avoid getting lost.
  - Plus extra “passive” tools like Wall Vibration, Path Whisperer, Memory Glyph, Wall-X Vision, Micro-Compass.

- 🧭 **Secret exit on Stage 8**
  The maze has one hidden exit. It does nothing in Stage 1–7. Only when you reach Stage 8 does it become a “secret exit.”
  Stepping on it triggers a full-screen victory screen and a fresh restart option.

- ⚙️ **Built-in settings panel**
  - Difficulty: Easy / Normal / Hard (affects stage thresholds & visibility).
  - Wall color: pick any color with a color picker.
  - Sound toggle: enable/disable in-browser sound effects.

- 📱 **Desktop + Mobile friendly**
  - Keyboard: WASD / arrows to move, Q/E/Space for tools.
  - Mobile: swipe to move, on-screen buttons for tools.

---

## Tech Stack

- **HTML5 Canvas** – rendering the maze and all effects
- **Vanilla JavaScript** – no external libraries or game engine
- **Responsive UI** – works on desktop and mobile browsers
- **Inline Web Audio** – tiny synthesized sound effects (no audio files)

---

## How to Run

1. Clone the repo:
   ```bash
   git clone https://github.com/<your-username>/infinite-mind-maze.git
   cd infinite-mind-maze
   ```
2. Serve the static files. Any simple HTTP server works; for example with Python:
   ```bash
   python3 -m http.server 8000
   ```
3. Open the game in your browser at http://localhost:8000.
4. Press **Start Run**, then move with WASD/arrow keys or swipe on mobile. Use **Q/E/Space** or the on-screen buttons for tools.

---

## Notes for contributors

- The entire game lives in `index.html` and runs in modern evergreen browsers.
- No build step is required, but please keep the HTML/JS/CSS self-contained and dependency-free.
- If you add assets, prefer lightweight formats and update the run instructions accordingly.
