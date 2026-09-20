# SnapReading - User Guide (English)

SnapReading is a speed reading web application built with Flutter WebAssembly (WASM) utilizing the RSVP (Rapid Serial Visual Presentation) technique and Spritz-style ORP (Optimal Recognition Point) focus.

## Key Features

1. **EPUB Book Library (`assets/books/`)**:
   - The application automatically detects and parses EPUB files located in `assets/books/`.
   - Displays title, author, chapter count, and saved reading progress for each book.

2. **RSVP Reading with Optimal Recognition Point (ORP)**:
   - Words are displayed one by one inside a fixed reticle with horizontal guide lines and center ticks.
   - The optimal anchor letter (ORP) is highlighted in coral red and locked in the exact horizontal center, removing eye saccades.
   - **Smart Pacing**: Natural longer pauses for commas/semicolons (1.5x) and sentence endings (2.0x).

3. **Ultra-Minimal Mobile-First UI**:
   - Tailored for mobile screens in both **Portrait** and **Landscape** orientations.
   - **Tap Screen**: Start or pause reading.
   - **Keyboard Shortcuts**:
     - `Spacebar`: Play / Pause.
     - `Left / Right Arrows`: Rewind or skip forward 10 words.
     - `Up / Down Arrows`: Increase or decrease speed by 25 WPM.

4. **Side Drawer (Statistics & Controls)**:
   - Accessible by swiping from the edge or tapping the top-right menu icon.
   - **Live Reading Stats**: Progress percentage, words read / total, estimated remaining reading time.
   - **Speed Control (WPM)**: Slider ranging from 150 to 900 WPM, with quick jump buttons (-50, -25, +25, +50).
   - **Font Size Adjuster**: Slider from 24 to 56 px.
   - **Chapter Scrub Bar**: Jump to any word offset within the active chapter.
   - **Chapter List**: Switch between chapters instantly.

5. **Automatic Reading Progress Persistence**:
   - Current chapter, word offset, and preferred WPM / font settings are saved in the browser (`localStorage` via SharedPreferences).
