const ALL_COLORS = {
  red: "#FF0000", // Pure Red - Level 1
  navy: "#0F46F8", // Navy Blue - Level 2
  green: "#22C55E", // Forest Green - Level 3
  orange: "#F97316", // Bright Orange - Level 4
  yellow: "#95FF00", // Bright Lime Yellow - Level 5
  pink: "#CB23E4", // Bright Magenta Pink - Level 6
  brown: "#9B521F", // Dark Brown - Level 7
  cyan: "#06B6D4", // Bright Cyan - Level 8
  magenta: "#EC4899", // Hot Pink - Level 9
  blue: "#2255A7", // Deep Blue - Level 10
  olive: "#67604B", // Olive Brown - Level 11
  white: "#FFFFFF", // Pure White - Level 12
  black: "#000000", // Pure Black - Level 13
};

const LEVEL_CONFIG = [
  { gridSize: 5, colors: ["red", "navy", "green", "orange", "yellow"] },
  { gridSize: 6, colors: ["red", "navy", "green", "orange", "yellow", "pink"] },
  {
    gridSize: 7,
    colors: ["red", "navy", "green", "orange", "yellow", "pink", "brown"],
  },
  {
    gridSize: 8,
    colors: [
      "red",
      "navy",
      "green",
      "orange",
      "yellow",
      "pink",
      "brown",
      "cyan",
    ],
  },
  {
    gridSize: 9,
    colors: [
      "red",
      "navy",
      "green",
      "orange",
      "yellow",
      "pink",
      "brown",
      "cyan",
      "magenta",
    ],
  },
  {
    gridSize: 10,
    colors: [
      "red",
      "navy",
      "green",
      "orange",
      "yellow",
      "pink",
      "brown",
      "cyan",
      "magenta",
      "blue",
    ],
  },
  {
    gridSize: 11,
    colors: [
      "red",
      "navy",
      "green",
      "orange",
      "yellow",
      "pink",
      "brown",
      "cyan",
      "magenta",
      "blue",
      "olive",
    ],
  },
  {
    gridSize: 12,
    colors: [
      "red",
      "navy",
      "green",
      "orange",
      "yellow",
      "pink",
      "brown",
      "cyan",
      "magenta",
      "blue",
      "olive",
      "white",
    ],
  },
  {
    gridSize: 13,
    colors: [
      "red",
      "navy",
      "green",
      "orange",
      "yellow",
      "pink",
      "brown",
      "cyan",
      "magenta",
      "blue",
      "olive",
      "white",
      "black",
    ],
  },
];

const gridBoard = document.getElementById("grid-board");
const colorSelector = document.getElementById("color-selector");
const statusMessage = document.getElementById("status-message");
const restartButton = document.getElementById("restart-button");
const solutionButton = document.getElementById("solution-button");
const homeButton = document.getElementById("home-button");
const soundButton = document.getElementById("sound-button");
const soundIcon = document.getElementById("sound-icon");
const startGameButton = document.getElementById("start-game-button");
const levelIndicator = document.getElementById("level-indicator");
const undoButton = document.getElementById("undo-button");
const playAgainButton = document.getElementById("play-again-button");

const gameContainer = document.getElementById("game-container");
const startupModal = document.getElementById("startup-modal");
const navigationButtons = document.getElementById("navigation-buttons");

const modalContainer = document.getElementById("modal-container");
const solutionModal = document.getElementById("solution-modal");
const solutionCompleteModal = document.getElementById(
  "solution-complete-modal"
);
const levelCompleteModal = document.getElementById("level-complete-modal");
const gameOverModal = document.getElementById("game-over-modal");
const gameCompleteModal = document.getElementById("game-complete-modal");

let GRID_SIZE;
let COLORS;
let COLOR_NAMES;

let currentLevel;
let gridState;
let path;
let currentStep;
let ballCounts;
let isGameOver;
let moveHistory; // Array to store move history for undo functionality
let preFilledCells; // Set to track which cells are pre-filled clues

// Audio Context for sound effects
let audioContext;
let isSoundEnabled = true;

// Initialize Audio Context
function initAudioContext() {
  if (!audioContext) {
    audioContext = new (window.AudioContext || window.webkitAudioContext)();
  }
}

// Toggle sound on/off
function toggleSound() {
  isSoundEnabled = !isSoundEnabled;
  
  // Update icon class
  if (isSoundEnabled) {
    soundIcon.className = "fa-solid fa-volume-high button-icon";
  } else {
    soundIcon.className = "fa-solid fa-volume-xmark button-icon";
  }
  
  // Add visual feedback
  soundButton.style.animation = "shake 0.3s";
  setTimeout(() => {
    soundButton.style.animation = "";
  }, 300);
}

// Play ball placement sound - sweet and lovely!
function playPlacementSound() {
  if (!isSoundEnabled) return; // Don't play if sound is disabled
  
  initAudioContext();
  
  const now = audioContext.currentTime;
  
  // Create a sweet, musical chord with harmonics
  // Main note - soft and warm
  const osc1 = audioContext.createOscillator();
  const gain1 = audioContext.createGain();
  osc1.connect(gain1);
  gain1.connect(audioContext.destination);
  osc1.type = 'sine';
  osc1.frequency.setValueAtTime(523.25, now); // C5 note
  gain1.gain.setValueAtTime(0, now);
  gain1.gain.linearRampToValueAtTime(0.2, now + 0.02); // Soft attack
  gain1.gain.exponentialRampToValueAtTime(0.01, now + 0.4);
  osc1.start(now);
  osc1.stop(now + 0.4);
  
  // Second harmonic - adds sweetness (major third)
  const osc2 = audioContext.createOscillator();
  const gain2 = audioContext.createGain();
  osc2.connect(gain2);
  gain2.connect(audioContext.destination);
  osc2.type = 'sine';
  osc2.frequency.setValueAtTime(659.25, now); // E5 note
  gain2.gain.setValueAtTime(0, now);
  gain2.gain.linearRampToValueAtTime(0.15, now + 0.02);
  gain2.gain.exponentialRampToValueAtTime(0.01, now + 0.35);
  osc2.start(now);
  osc2.stop(now + 0.35);
  
  // Third harmonic - adds sparkle (perfect fifth)
  const osc3 = audioContext.createOscillator();
  const gain3 = audioContext.createGain();
  osc3.connect(gain3);
  gain3.connect(audioContext.destination);
  osc3.type = 'sine';
  osc3.frequency.setValueAtTime(784, now); // G5 note
  gain3.gain.setValueAtTime(0, now);
  gain3.gain.linearRampToValueAtTime(0.1, now + 0.02);
  gain3.gain.exponentialRampToValueAtTime(0.01, now + 0.3);
  osc3.start(now);
  osc3.stop(now + 0.3);
}

// Play beautiful win sound - triumphant and celebratory!
function playWinSound() {
  if (!isSoundEnabled) return; // Don't play if sound is disabled
  
  initAudioContext();
  
  const now = audioContext.currentTime;
  
  // Create a triumphant ascending melody with multiple layers
  const notes = [523.25, 659.25, 783.99, 1046.5, 1318.51]; // C5, E5, G5, C6, E6
  const durations = [0.3, 0.3, 0.3, 0.4, 0.5];
  
  notes.forEach((frequency, index) => {
    const startTime = now + index * 0.2;
    const duration = durations[index];
    
    // Main melody note
    const osc1 = audioContext.createOscillator();
    const gain1 = audioContext.createGain();
    osc1.connect(gain1);
    gain1.connect(audioContext.destination);
    osc1.type = 'sine';
    osc1.frequency.setValueAtTime(frequency, startTime);
    gain1.gain.setValueAtTime(0, startTime);
    gain1.gain.linearRampToValueAtTime(0.3, startTime + 0.05);
    gain1.gain.exponentialRampToValueAtTime(0.01, startTime + duration);
    osc1.start(startTime);
    osc1.stop(startTime + duration);
    
    // Add harmony (perfect fifth above)
    const osc2 = audioContext.createOscillator();
    const gain2 = audioContext.createGain();
    osc2.connect(gain2);
    gain2.connect(audioContext.destination);
    osc2.type = 'sine';
    osc2.frequency.setValueAtTime(frequency * 1.5, startTime);
    gain2.gain.setValueAtTime(0, startTime);
    gain2.gain.linearRampToValueAtTime(0.2, startTime + 0.05);
    gain2.gain.exponentialRampToValueAtTime(0.01, startTime + duration);
    osc2.start(startTime);
    osc2.stop(startTime + duration);
    
    // Add sparkle (octave above)
    const osc3 = audioContext.createOscillator();
    const gain3 = audioContext.createGain();
    osc3.connect(gain3);
    gain3.connect(audioContext.destination);
    osc3.type = 'triangle';
    osc3.frequency.setValueAtTime(frequency * 2, startTime);
    gain3.gain.setValueAtTime(0, startTime);
    gain3.gain.linearRampToValueAtTime(0.15, startTime + 0.05);
    gain3.gain.exponentialRampToValueAtTime(0.01, startTime + duration * 0.7);
    osc3.start(startTime);
    osc3.stop(startTime + duration * 0.7);
  });
  
  // Add a final celebratory chord at the end
  setTimeout(() => {
    const chordTime = audioContext.currentTime;
    const chordFreqs = [523.25, 659.25, 783.99, 1046.5]; // C major chord
    
    chordFreqs.forEach((freq, index) => {
      const osc = audioContext.createOscillator();
      const gain = audioContext.createGain();
      osc.connect(gain);
      gain.connect(audioContext.destination);
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, chordTime);
      gain.gain.setValueAtTime(0, chordTime);
      gain.gain.linearRampToValueAtTime(0.25, chordTime + 0.1);
      gain.gain.exponentialRampToValueAtTime(0.01, chordTime + 1.5);
      osc.start(chordTime);
      osc.stop(chordTime + 1.5);
    });
  }, 1000);
}

// Play engaging loss/defeat sound - dramatic but not harsh
function playLossSound() {
  if (!isSoundEnabled) return; // Don't play if sound is disabled
  
  initAudioContext();
  
  const now = audioContext.currentTime;
  
  // Create a descending melody that's dramatic but not harsh
  const notes = [1046.5, 880, 783.99, 659.25, 523.25, 440]; // C6, A5, G5, E5, C5, A4
  const durations = [0.4, 0.4, 0.4, 0.4, 0.5, 0.6];
  
  notes.forEach((frequency, index) => {
    const startTime = now + index * 0.25;
    const duration = durations[index];
    
    // Main melody note with slight vibrato
    const osc1 = audioContext.createOscillator();
    const gain1 = audioContext.createGain();
    const lfo = audioContext.createOscillator(); // Low frequency oscillator for vibrato
    const lfoGain = audioContext.createGain();
    
    lfo.frequency.setValueAtTime(5, startTime); // 5Hz vibrato
    lfoGain.gain.setValueAtTime(10, startTime); // Small vibrato amount
    lfo.connect(lfoGain);
    lfoGain.connect(osc1.frequency);
    
    osc1.connect(gain1);
    gain1.connect(audioContext.destination);
    osc1.type = 'sine';
    osc1.frequency.setValueAtTime(frequency, startTime);
    gain1.gain.setValueAtTime(0, startTime);
    gain1.gain.linearRampToValueAtTime(0.25, startTime + 0.1);
    gain1.gain.exponentialRampToValueAtTime(0.01, startTime + duration);
    osc1.start(startTime);
    osc1.stop(startTime + duration);
    lfo.start(startTime);
    lfo.stop(startTime + duration);
    
    // Add a subtle harmony below
    const osc2 = audioContext.createOscillator();
    const gain2 = audioContext.createGain();
    osc2.connect(gain2);
    gain2.connect(audioContext.destination);
    osc2.type = 'triangle';
    osc2.frequency.setValueAtTime(frequency * 0.75, startTime); // Perfect fourth below
    gain2.gain.setValueAtTime(0, startTime);
    gain2.gain.linearRampToValueAtTime(0.15, startTime + 0.1);
    gain2.gain.exponentialRampToValueAtTime(0.01, startTime + duration);
    osc2.start(startTime);
    osc2.stop(startTime + duration);
  });
}

// Play gentle solution revealed sound - magical and mysterious
function playSolutionRevealedSound() {
  if (!isSoundEnabled) return; // Don't play if sound is disabled
  
  initAudioContext();
  
  const now = audioContext.currentTime;
  
  // Create a gentle, magical ascending arpeggio
  const notes = [392, 523.25, 659.25, 783.99]; // G4, C5, E5, G5
  const durations = [0.4, 0.4, 0.4, 0.6];
  
  notes.forEach((frequency, index) => {
    const startTime = now + index * 0.3;
    const duration = durations[index];
    
    // Main note with gentle attack
    const osc1 = audioContext.createOscillator();
    const gain1 = audioContext.createGain();
    osc1.connect(gain1);
    gain1.connect(audioContext.destination);
    osc1.type = 'sine';
    osc1.frequency.setValueAtTime(frequency, startTime);
    gain1.gain.setValueAtTime(0, startTime);
    gain1.gain.linearRampToValueAtTime(0.2, startTime + 0.1);
    gain1.gain.exponentialRampToValueAtTime(0.01, startTime + duration);
    osc1.start(startTime);
    osc1.stop(startTime + duration);
    
    // Add a subtle harmonic shimmer
    const osc2 = audioContext.createOscillator();
    const gain2 = audioContext.createGain();
    osc2.connect(gain2);
    gain2.connect(audioContext.destination);
    osc2.type = 'triangle';
    osc2.frequency.setValueAtTime(frequency * 2, startTime); // Octave above
    gain2.gain.setValueAtTime(0, startTime);
    gain2.gain.linearRampToValueAtTime(0.1, startTime + 0.1);
    gain2.gain.exponentialRampToValueAtTime(0.01, startTime + duration * 0.8);
    osc2.start(startTime);
    osc2.stop(startTime + duration * 0.8);
  });
  
  // Add a final gentle bell-like tone
  setTimeout(() => {
    const bellTime = audioContext.currentTime;
    const osc = audioContext.createOscillator();
    const gain = audioContext.createGain();
    osc.connect(gain);
    gain.connect(audioContext.destination);
    osc.type = 'sine';
    osc.frequency.setValueAtTime(1046.5, bellTime); // High C6
    gain.gain.setValueAtTime(0, bellTime);
    gain.gain.linearRampToValueAtTime(0.15, bellTime + 0.2);
    gain.gain.exponentialRampToValueAtTime(0.01, bellTime + 1.2);
    osc.start(bellTime);
    osc.stop(bellTime + 1.2);
  }, 1200);
}

function startLevel(levelIndex) {
  // Check if level index is valid
  if (levelIndex < 0 || levelIndex >= LEVEL_CONFIG.length) {
    console.error(
      `Invalid level index: ${levelIndex}. Valid range: 0-${
        LEVEL_CONFIG.length - 1
      }`
    );
    return;
  }

  currentLevel = levelIndex;
  const config = LEVEL_CONFIG[levelIndex];

  GRID_SIZE = config.gridSize;
  COLOR_NAMES = config.colors;
  COLORS = COLOR_NAMES.reduce((acc, name) => {
    acc[name] = ALL_COLORS[name];
    return acc;
  }, {});
  
  initializeGame();
}

function generateSnakePath() {
  const newPath = [];
  for (let row = 0; row < GRID_SIZE; row++) {
    if (row % 2 === 0) {
      // Move left-to-right
      for (let col = 0; col < GRID_SIZE; col++) {
        newPath.push({ row, col });
      }
    } else {
      // Move right-to-left
      for (let col = GRID_SIZE - 1; col >= 0; col--) {
        newPath.push({ row, col });
      }
    }
  }
  return newPath;
}

function generateSolution() {
  // Generate a proper solution that follows all game rules
  const solutionBoard = Array(GRID_SIZE)
    .fill(null)
    .map(() => Array(GRID_SIZE).fill(null));
  
  // Create a valid solution using backtracking
  const tempCounts = COLOR_NAMES.reduce((acc, color) => {
    acc[color] = GRID_SIZE;
    return acc;
  }, {});
  
  // Try to generate a valid solution
  if (generateValidSolution(solutionBoard, tempCounts, 0)) {
    return solutionBoard;
  }
  
  // If backtracking fails, create a simple but valid pattern
  return createSimpleValidSolution();
}

function generateValidSolution(board, counts, step) {
  if (step === GRID_SIZE * GRID_SIZE) {
    return true; // Solution complete
  }
  
  const row = Math.floor(step / GRID_SIZE);
  const col = step % GRID_SIZE;
  
  // Try each color
  for (const color of COLOR_NAMES) {
    if (counts[color] > 0 && isMoveValid(board, row, col, color)) {
      board[row][col] = color;
      counts[color]--;
      
      if (generateValidSolution(board, counts, step + 1)) {
        return true;
      }
      
      // Backtrack
      board[row][col] = null;
      counts[color]++;
    }
  }
  
  return false;
}

function createSimpleValidSolution() {
  // Create a simple but valid solution as fallback
  const solutionBoard = Array(GRID_SIZE)
    .fill(null)
    .map(() => Array(GRID_SIZE).fill(null));
  
  // Fill row by row, ensuring no conflicts
  for (let row = 0; row < GRID_SIZE; row++) {
    const usedInRow = new Set();
    const usedInCol = new Set();
    
    // Get colors already used in this row and column
    for (let c = 0; c < GRID_SIZE; c++) {
      if (solutionBoard[row][c]) {
        usedInRow.add(solutionBoard[row][c]);
      }
    }
    for (let r = 0; r < GRID_SIZE; r++) {
      if (solutionBoard[r][0]) {
        usedInCol.add(solutionBoard[r][0]);
      }
    }
    
    // Fill this row with valid colors
    for (let col = 0; col < GRID_SIZE; col++) {
      for (const color of COLOR_NAMES) {
        if (!usedInRow.has(color) && !usedInCol.has(color)) {
          // Check adjacent cells
          let valid = true;
          for (let r_off = -1; r_off <= 1; r_off++) {
            for (let c_off = -1; c_off <= 1; c_off++) {
              if (r_off === 0 && c_off === 0) continue;
              const checkRow = row + r_off;
              const checkCol = col + c_off;
              if (checkRow >= 0 && checkRow < GRID_SIZE && 
                  checkCol >= 0 && checkCol < GRID_SIZE &&
                  solutionBoard[checkRow][checkCol] === color) {
                valid = false;
                break;
              }
            }
            if (!valid) break;
          }
          
          if (valid) {
            solutionBoard[row][col] = color;
            usedInRow.add(color);
            usedInCol.add(color);
            break;
          }
        }
      }
    }
  }
  
  return solutionBoard;
}

function prefillCells(solution) {
  // Create a smarter clue system: one clue per color, one per row/column, spread out
  const clues = generateSmartClues(solution);
  
  // Apply the clues to the grid and track them as pre-filled
  clues.forEach(({ row, col, color }) => {
    gridState[row][col] = color;
    preFilledCells.add(`${row},${col}`); // Track this cell as pre-filled
  });
  
  // Update currentStep to skip pre-filled cells in the path
  updateCurrentStepForPrefilledCells();
}

function generateSmartClues(solution) {
  const clues = [];
  const usedRows = new Set();
  const usedCols = new Set();
  const usedColors = new Set();
  const usedPositions = new Set(); // Track all used positions for diagonal checking
  
  // Create all possible clue positions
  const allPositions = [];
  for (let row = 0; row < GRID_SIZE; row++) {
    for (let col = 0; col < GRID_SIZE; col++) {
      allPositions.push({ row, col });
    }
  }
  
  // Shuffle positions to get random distribution
  const shuffledPositions = shuffleArray([...allPositions]);
  
  // Try to place one clue for each color, ensuring no row/column/diagonal conflicts
  for (const { row, col } of shuffledPositions) {
    const color = solution[row][col];
    
    // Skip if this color, row, or column is already used
    if (usedColors.has(color) || usedRows.has(row) || usedCols.has(col)) {
      continue;
    }
    
    // Check for diagonal conflicts with existing clues
    if (hasDiagonalConflict(row, col, usedPositions)) {
      continue;
    }
    
    // Add this clue
    clues.push({ row, col, color });
    usedColors.add(color);
    usedRows.add(row);
    usedCols.add(col);
    usedPositions.add(`${row},${col}`);
    
    // Stop when we have one clue per color (up to the number of colors available)
    if (clues.length >= COLOR_NAMES.length) {
      break;
    }
  }
  
  return clues;
}

function hasDiagonalConflict(row, col, usedPositions) {
  // Check all 8 diagonal and adjacent positions
  for (let r_off = -1; r_off <= 1; r_off++) {
    for (let c_off = -1; c_off <= 1; c_off++) {
      if (r_off === 0 && c_off === 0) continue; // Skip the cell itself
      
      const checkRow = row + r_off;
      const checkCol = col + c_off;
      
      // Check if this position is within bounds and already used
      if (checkRow >= 0 && checkRow < GRID_SIZE && 
          checkCol >= 0 && checkCol < GRID_SIZE) {
        if (usedPositions.has(`${checkRow},${checkCol}`)) {
          return true; // Found a diagonal/adjacent conflict
        }
      }
    }
  }
  return false; // No conflicts found
}

function updateCurrentStepForPrefilledCells() {
  // Find the first empty cell in the path
  for (let i = 0; i < path.length; i++) {
    const { row, col } = path[i];
    if (gridState[row][col] === null) {
      currentStep = i;
      return;
    }
  }
  // If all cells are filled, set to end
  currentStep = path.length;
}

function calculateBallCounts() {
  // Count how many of each color are already placed
  const placedCounts = COLOR_NAMES.reduce((acc, color) => {
    acc[color] = 0;
    return acc;
  }, {});
  
  // Count placed colors
  for (let row = 0; row < GRID_SIZE; row++) {
    for (let col = 0; col < GRID_SIZE; col++) {
      const color = gridState[row][col];
      if (color) {
        placedCounts[color]++;
      }
    }
  }
  
  // Calculate remaining ball counts
  ballCounts = COLOR_NAMES.reduce((acc, color) => {
    acc[color] = GRID_SIZE - placedCounts[color];
    return acc;
  }, {});
}

function initializeGame() {
  isGameOver = false;
  currentStep = 0;
  moveHistory = []; // Initialize move history
  preFilledCells = new Set(); // Initialize pre-filled cells tracking
  gridState = Array(GRID_SIZE)
    .fill(null)
    .map(() => Array(GRID_SIZE).fill(null));
  path = generateSnakePath();
  
  // Generate solution first
  const solution = generateSolution();
  
  // Pre-fill 15% of cells based on solution
  prefillCells(solution);
  
  // Calculate ball counts based on remaining cells
  calculateBallCounts();

  levelIndicator.textContent = `Level ${currentLevel + 1}`;
  
  // Setup UI first, then display pre-filled cells
  setupUI();
  
  // Display pre-filled cells after UI is set up
  setTimeout(() => {
    displayPrefilledCells();
  }, 50);
  
  updateNextCellHighlight();
  updateBallCountsUI();
  updateUndoButton();
  hidePlayAgainButton(); // Hide the Play Again button when starting new level
  statusMessage.textContent = "";
}

function setupUI() {
  gridBoard.innerHTML = "";
  // Dynamically set grid columns
  gridBoard.className = `game-grid`;
  gridBoard.style.gridTemplateColumns = `repeat(${GRID_SIZE}, 1fr)`;

  for (let i = 0; i < GRID_SIZE * GRID_SIZE; i++) {
    const cell = document.createElement("div");
    cell.classList.add("grid-cell");
    // We'll set the dataset attributes after sorting
    gridBoard.appendChild(cell);
  }

  // Re-order cells in the DOM to match visual layout
  const cells = Array.from(gridBoard.children);
  let cellIndex = 0;
  for (let r = 0; r < GRID_SIZE; r++) {
    for (let c = 0; c < GRID_SIZE; c++) {
      const cellToUpdate = cells[cellIndex++];
      cellToUpdate.dataset.row = r;
      cellToUpdate.dataset.col = c;
    }
  }

  colorSelector.innerHTML = "";
  COLOR_NAMES.forEach((color) => {
    const colorContainer = document.createElement("div");
    colorContainer.className = "text-center flex-1";
    colorContainer.dataset.color = color;

    const ball = document.createElement("div");
    ball.className = "ball";
    ball.style.backgroundColor = COLORS[color];
    ball.style.width = "var(--ball-size)";
    ball.style.height = "var(--ball-size)";
    ball.style.borderRadius = "50%";
    ball.addEventListener("click", () => handleColorSelection(color));

    // Add count display directly on the ball
    const count = document.createElement("div");
    count.className = "ball-count";
    count.id = `count-${color}`;

    ball.appendChild(count);
    colorContainer.appendChild(ball);
    colorSelector.appendChild(colorContainer);
  });
}

function displayPrefilledCells() {
  for (let row = 0; row < GRID_SIZE; row++) {
    for (let col = 0; col < GRID_SIZE; col++) {
      const color = gridState[row][col];
      const cellKey = `${row},${col}`;
      if (color && preFilledCells.has(cellKey)) {
        const cell = getCellElement(row, col);
        if (cell) {
          const ball = document.createElement("div");
          ball.className = "ball prefilled-ball";
          ball.style.backgroundColor = COLORS[color];
          ball.style.width = "80%";
          ball.style.height = "80%";
          ball.style.borderRadius = "50%";
          ball.style.transform = "scale(1)";
          ball.style.animation = "none"; // No animation for pre-filled balls
          ball.style.position = "relative";
          ball.style.boxShadow = "0 2px 8px rgba(0, 0, 0, 0.2)";
          cell.innerHTML = "";
          cell.appendChild(ball);
        }
      }
    }
  }
}

// ... (getCellElement, updateNextCellHighlight, updateColorSelectorUI, updateBallCountsUI functions remain largely the same)
function getCellElement(row, col) {
  return gridBoard.querySelector(`[data-row='${row}'][data-col='${col}']`);
}

function updateNextCellHighlight() {
  // Remove highlight from all cells
  document
    .querySelectorAll(".next-cell")
    .forEach((c) => c.classList.remove("next-cell"));

  if (!isGameOver && currentStep < path.length) {
    const { row, col } = path[currentStep];
    const nextCell = getCellElement(row, col);
    if (nextCell && gridState[row][col] === null) {
      nextCell.classList.add("next-cell");
    }
    updateColorSelectorUI(col, row); // Update color availability for the current column and row
  } else {
    updateColorSelectorUI(null, null); // No column/row is active, so enable all
  }
}

function updateColorSelectorUI(currentCol, currentRow) {
  // Color selector UI is now simplified - no blocking of colors
  // Players can select any color and the game will validate the move
  COLOR_NAMES.forEach((color) => {
    const colorContainer = colorSelector.querySelector(
      `[data-color='${color}']`
    );
    if (colorContainer) {
      // Remove any disabled state
      colorContainer.classList.remove("color-disabled");
    }
  });
}

function updateBallCountsUI() {
  COLOR_NAMES.forEach((color) => {
    const countEl = document.getElementById(`count-${color}`);
    if (countEl) {
      countEl.textContent = ballCounts[color];
      const colorContainer = countEl.parentElement.parentElement; // Updated to get the container
      // Only show visual feedback based on ball count, not disabled state
      colorContainer.style.opacity = ballCounts[color] > 0 ? "1" : "0.4";
      colorContainer.style.pointerEvents =
        ballCounts[color] > 0 ? "auto" : "none";
    }
  });
}

function updateUndoButton() {
  // Enable/disable undo button based on move history
  if (moveHistory && moveHistory.length > 0) {
    undoButton.disabled = false;
    undoButton.style.opacity = "1";
  } else {
    undoButton.disabled = true;
    undoButton.style.opacity = "0.5";
  }
}

function undoMove() {
  // Check if there are moves to undo
  if (moveHistory.length === 0) {
    return;
  }

  // Get the last move
  const lastMove = moveHistory.pop();
  const { row, col, color, previousStep } = lastMove;

  // Check if this cell is a pre-filled cell (should not be undone)
  const cellKey = `${row},${col}`;
  if (preFilledCells.has(cellKey)) {
    // Don't undo pre-filled cells, just restore the move to history
    moveHistory.push(lastMove);
    return;
  }

  // Restore the cell to empty state
  gridState[row][col] = null;
  ballCounts[color]++;

  // Remove the ball from the UI
  const cell = getCellElement(row, col);
  if (cell) {
    cell.innerHTML = "";
  }

  // Restore the current step
  currentStep = previousStep;

  // Update UI
  updateBallCountsUI();
  updateUndoButton();
  updateNextCellHighlight();

  // Clear any status messages
  statusMessage.textContent = "";

  // Play a gentle undo sound
  if (isSoundEnabled) {
    initAudioContext();
    const now = audioContext.currentTime;
    const osc = audioContext.createOscillator();
    const gain = audioContext.createGain();
    osc.connect(gain);
    gain.connect(audioContext.destination);
    osc.type = 'sine';
    osc.frequency.setValueAtTime(392, now); // G4 note - gentle and lower pitch
    gain.gain.setValueAtTime(0, now);
    gain.gain.linearRampToValueAtTime(0.15, now + 0.05);
    gain.gain.exponentialRampToValueAtTime(0.01, now + 0.3);
    osc.start(now);
    osc.stop(now + 0.3);
  }
}

// ... (handleColorSelection, checkPlacementValidity, placeBall functions remain the same)
function handleColorSelection(color) {
  const colorContainer = colorSelector.querySelector(`[data-color='${color}']`);
  // Check if game is over or no balls of this color are available
  if (isGameOver || ballCounts[color] <= 0) {
    return;
  }

  // Add visual feedback for color selection
  enhanceColorSelection(color);

  const { row, col } = path[currentStep];

  const placementInfo = checkPlacementValidity(row, col, color);

  if (placementInfo.valid) {
    placeBall(row, col, color);
  } else {
    showInvalidMoveWarning(row, col, color, placementInfo.reason);
  }
}

function checkPlacementValidity(row, col, color) {
  // Check all 8 neighbors (including diagonals)
  for (let r_off = -1; r_off <= 1; r_off++) {
    for (let c_off = -1; c_off <= 1; c_off++) {
      if (r_off === 0 && c_off === 0) continue; // Skip the cell itself

      const checkRow = row + r_off;
      const checkCol = col + c_off;

      // Check if neighbor is within bounds
      if (
        checkRow >= 0 &&
        checkRow < GRID_SIZE &&
        checkCol >= 0 &&
        checkCol < GRID_SIZE
      ) {
        if (gridState[checkRow][checkCol] === color) {
          return { valid: false, reason: "Adjacent colors." };
        }
      }
    }
  }

  // Check for same color in the same column
  for (let r = 0; r < GRID_SIZE; r++) {
    if (gridState[r][col] === color) {
      return { valid: false, reason: "Color already in column." };
    }
  }

  // Check for same color in the same row
  for (let c = 0; c < GRID_SIZE; c++) {
    if (gridState[row][c] === color) {
      return { valid: false, reason: "Color already in row." };
    }
  }

  return { valid: true, reason: null };
}

function placeBall(row, col, color) {
  // Check if cell is already filled (shouldn't happen with proper validation)
  if (gridState[row][col] !== null) {
    console.warn("Attempting to place ball in already filled cell");
    return;
  }

  // Store move in history for undo functionality
  moveHistory.push({
    row: row,
    col: col,
    color: color,
    previousStep: currentStep
  });

  // Update state
  gridState[row][col] = color;
  ballCounts[color]--;

  // Play sound effect
  playPlacementSound();

  // Update UI
  const cell = getCellElement(row, col);
  const ball = document.createElement("div");
  ball.className = "ball";
  ball.style.backgroundColor = COLORS[color];
  ball.style.transform = "scale(0)";
  cell.innerHTML = "";
  cell.appendChild(ball);

  // Enhanced ball placement animation
  requestAnimationFrame(() => {
    ball.style.transform = "scale(1)";
    ball.style.animation = "ballPlace 0.6s cubic-bezier(0.4, 0, 0.2, 1)";

    // Add particle effect
    createParticleEffect(cell, COLORS[color]);
  });

  // Move to next empty cell in path
  moveToNextEmptyCell();
  updateBallCountsUI();
  updateUndoButton();

  if (isGameComplete()) {
    winGame();
  } else {
    updateNextCellHighlight();

    // Check if all balls are used up (but don't end the game)
    if (!isGameOver && currentStep < path.length) {
      checkIfAllBallsBlocked();
    }
  }
}

function moveToNextEmptyCell() {
  // Find next empty cell in path
  for (let i = currentStep + 1; i < path.length; i++) {
    const { row, col } = path[i];
    if (gridState[row][col] === null) {
      currentStep = i;
      return;
    }
  }
  // If no empty cells found, set to end
  currentStep = path.length;
}

function isGameComplete() {
  // Check if all cells are filled
  for (let row = 0; row < GRID_SIZE; row++) {
    for (let col = 0; col < GRID_SIZE; col++) {
      if (gridState[row][col] === null) {
        return false;
      }
    }
  }
  return true;
}

function showInvalidMoveWarning(row, col, color, reason) {
  statusMessage.innerHTML = `<span class="text-red-600 font-bold">Invalid Move!</span> ${reason}`;

  const conflictingCells = [];

  if (reason === "Adjacent colors.") {
    for (let r_off = -1; r_off <= 1; r_off++) {
      for (let c_off = -1; c_off <= 1; c_off++) {
        if (r_off === 0 && c_off === 0) continue;
        const checkRow = row + r_off;
        const checkCol = col + c_off;
        if (
          checkRow >= 0 &&
          checkRow < GRID_SIZE &&
          checkCol >= 0 &&
          checkCol < GRID_SIZE
        ) {
          if (gridState[checkRow][checkCol] === color) {
            conflictingCells.push(getCellElement(checkRow, checkCol));
          }
        }
      }
    }
  } else if (reason === "Color already in column.") {
    for (let r = 0; r < GRID_SIZE; r++) {
      if (gridState[r][col] === color) {
        conflictingCells.push(getCellElement(r, col));
        break;
      }
    }
  } else if (reason === "Color already in row.") {
    for (let c = 0; c < GRID_SIZE; c++) {
      if (gridState[row][c] === color) {
        conflictingCells.push(getCellElement(row, c));
        break;
      }
    }
  }

  // Apply warning animation and highlight
  conflictingCells.forEach((cell) => {
    cell.style.animation = "shake 0.5s";
    const ball = cell.querySelector(".ball");
    if (ball) {
      ball.style.boxShadow = "0 0 10px 4px #ef4444"; // Red glow
    }
  });

  // Also shake the invalid color choice in the selector
  const selectedColorUI = colorSelector.querySelector(
    `[data-color='${color}']`
  );
  if (selectedColorUI) {
    selectedColorUI.style.animation = "shake 0.5s";
  }

  // Remove warning after animation ends
  setTimeout(() => {
    conflictingCells.forEach((cell) => {
      cell.style.animation = "";
      const ball = cell.querySelector(".ball");
      if (ball) {
        ball.style.boxShadow = ""; // Reset style
      }
    });
    if (selectedColorUI) {
      selectedColorUI.style.animation = "";
    }

    statusMessage.textContent = "";
  }, 1500);
}

function checkIfAllBallsBlocked() {
  // Check if there are any available colors with remaining balls
  const availableColors = COLOR_NAMES.filter((color) => {
    return ballCounts[color] > 0;
  });

  // If no colors are available, show a helpful message but don't end the game
  if (availableColors.length === 0) {
    statusMessage.innerHTML = `<span class="text-yellow-600 font-bold">⚠️ No balls left!</span> Use the undo button to go back and try a different strategy.`;
  }
}

function gameOver() {
  isGameOver = true;
  statusMessage.textContent = "";
  updateNextCellHighlight();
  
  // Play loss sound effect
  playLossSound();
  
  showModal(gameOverModal);
}

function winGame() {
  isGameOver = true;
  statusMessage.textContent = "";
  updateNextCellHighlight();
  
  // Play win sound effect
  playWinSound();
  
  if (currentLevel < LEVEL_CONFIG.length - 1) {
    showModal(levelCompleteModal);
  } else {
    showModal(gameCompleteModal);
  }
}

// ... (Solver functions shuffleArray, isMoveValid, solve, showSolution remain the same)
function shuffleArray(array) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
  return array;
}

function isMoveValid(board, row, col, color) {
  // Check all 8 neighbors (including diagonals)
  for (let r_off = -1; r_off <= 1; r_off++) {
    for (let c_off = -1; c_off <= 1; c_off++) {
      if (r_off === 0 && c_off === 0) continue;
      const checkRow = row + r_off;
      const checkCol = col + c_off;
      if (
        checkRow >= 0 &&
        checkRow < GRID_SIZE &&
        checkCol >= 0 &&
        checkCol < GRID_SIZE
      ) {
        if (board[checkRow][checkCol] === color) return false;
      }
    }
  }
  // Check for same color in the same column
  for (let r = 0; r < GRID_SIZE; r++) {
    if (board[r][col] === color) return false;
  }
  // Check for same color in the same row
  for (let c = 0; c < GRID_SIZE; c++) {
    if (board[row][c] === color) return false;
  }
  return true;
}

function solve(board, counts, step) {
  // Check if all cells are filled (board is complete)
  if (step >= path.length) {
    return true; // Base case: board is successfully filled
  }

  const { row, col } = path[step];
  
  // Skip if this cell is already filled (pre-filled cell)
  if (board[row][col] !== null) {
    return solve(board, counts, step + 1);
  }
  
  const colorsToTry = shuffleArray([...COLOR_NAMES]);

  for (const color of colorsToTry) {
    if (counts[color] > 0 && isMoveValid(board, row, col, color)) {
      board[row][col] = color;
      counts[color]--;

      if (solve(board, counts, step + 1)) {
        return true; // Solution found down this path
      }

      // Backtrack if the path was a dead end
      counts[color]++;
      board[row][col] = null;
    }
  }

  return false; // No valid color found for this step
}

function showSolution() {
  isGameOver = true;
  statusMessage.textContent = "";
  solutionButton.disabled = true;
  restartButton.disabled = true;
  updateNextCellHighlight();
  updateColorSelectorUI(null, null);

  setTimeout(() => {
    const boardCopy = JSON.parse(JSON.stringify(gridState));
    const countsCopy = { ...ballCounts };

    // Check if the board is already complete
    let hasEmptyCells = false;
    for (let row = 0; row < GRID_SIZE; row++) {
      for (let col = 0; col < GRID_SIZE; col++) {
        if (boardCopy[row][col] === null) {
          hasEmptyCells = true;
          break;
        }
      }
      if (hasEmptyCells) break;
    }

    // If no empty cells, show solution complete immediately
    if (!hasEmptyCells) {
      showModal(solutionCompleteModal);
      restartButton.disabled = false;
      solutionButton.disabled = false;
      return;
    }

    // Try to solve with current player moves first
    let startStep = 0;
    for (let i = 0; i < path.length; i++) {
      const { row, col } = path[i];
      if (boardCopy[row][col] === null) {
        startStep = i;
        break;
      }
    }

    if (solve(boardCopy, countsCopy, startStep)) {
      // Successfully solved with player's existing moves
      statusMessage.textContent = "";
      let animationDelay = 0;
      
      for (let i = startStep; i < path.length; i++) {
        const { row, col } = path[i];
        const color = boardCopy[row][col];
        const cell = getCellElement(row, col);

        // Only animate if the cell is currently empty
        if (gridState[row][col] === null) {
          setTimeout(() => {
            const ball = document.createElement("div");
            ball.className = "ball";
            ball.style.backgroundColor = COLORS[color];
            ball.style.transform = "scale(0)";
            cell.innerHTML = "";
            cell.appendChild(ball);
            requestAnimationFrame(() => {
              ball.style.transform = "scale(1)";
              ball.style.animation =
                "ballPlace 0.6s cubic-bezier(0.4, 0, 0.2, 1)";
              createParticleEffect(cell, COLORS[color]);
            });
          }, animationDelay);
          animationDelay += 100;
        }
      }

      // Show Play Again button after all balls are placed
      setTimeout(() => {
        showPlayAgainButton();
      }, animationDelay + 500);
    } else {
      // Player's moves make it impossible to solve, show a complete new solution
      showCompleteNewSolution();
    }
    restartButton.disabled = false;
    solutionButton.disabled = false;
  }, 100);
}

function showCompleteNewSolution() {
  // Generate a completely new solution and replace everything except pre-filled cells
  const newSolution = generateSolution();
  
  // Create a fresh board with only pre-filled cells preserved
  const boardCopy = Array(GRID_SIZE).fill(null).map(() => Array(GRID_SIZE).fill(null));
  
  // Restore pre-filled cells
  for (let row = 0; row < GRID_SIZE; row++) {
    for (let col = 0; col < GRID_SIZE; col++) {
      const cellKey = `${row},${col}`;
      if (preFilledCells.has(cellKey)) {
        boardCopy[row][col] = gridState[row][col]; // Keep the original pre-filled color
      }
    }
  }
  
  // Fill the rest with the new solution
  for (let row = 0; row < GRID_SIZE; row++) {
    for (let col = 0; col < GRID_SIZE; col++) {
      if (boardCopy[row][col] === null) {
        boardCopy[row][col] = newSolution[row][col];
      }
    }
  }
  
  // Calculate new ball counts based on the solution
  const newBallCounts = COLOR_NAMES.reduce((acc, color) => {
    acc[color] = GRID_SIZE;
    return acc;
  }, {});
  
  // Subtract pre-filled colors from counts
  for (let row = 0; row < GRID_SIZE; row++) {
    for (let col = 0; col < GRID_SIZE; col++) {
      const color = boardCopy[row][col];
      if (preFilledCells.has(`${row},${col}`)) {
        newBallCounts[color]--;
      }
    }
  }
  
  // Clear the current board except pre-filled cells
  const cells = gridBoard.querySelectorAll('.grid-cell');
  cells.forEach(cell => {
    cell.innerHTML = '';
  });
  
  // Re-display pre-filled cells
  displayPrefilledCells();
  
  // Animate the new solution
  let animationDelay = 0;
  for (let row = 0; row < GRID_SIZE; row++) {
    for (let col = 0; col < GRID_SIZE; col++) {
      const color = boardCopy[row][col];
      const cellKey = `${row},${col}`;
      
      // Only animate non-pre-filled cells
      if (!preFilledCells.has(cellKey)) {
        const cell = getCellElement(row, col);
        if (cell) {
          setTimeout(() => {
            const ball = document.createElement("div");
            ball.className = "ball";
            ball.style.backgroundColor = COLORS[color];
            ball.style.transform = "scale(0)";
            cell.innerHTML = "";
            cell.appendChild(ball);
            requestAnimationFrame(() => {
              ball.style.transform = "scale(1)";
              ball.style.animation = "ballPlace 0.6s cubic-bezier(0.4, 0, 0.2, 1)";
              createParticleEffect(cell, COLORS[color]);
            });
          }, animationDelay);
          animationDelay += 50; // Faster animation for complete solution
        }
      }
    }
  }
  
  // Update the actual game state to match the solution
  gridState = boardCopy;
  ballCounts = newBallCounts;
  
  // Show Play Again button
  setTimeout(() => {
    showPlayAgainButton();
  }, animationDelay + 300);
}

function showModal(modalElement) {
  modalContainer.classList.remove("hidden");
  // Hide all modals first
  solutionModal.classList.add("hidden");
  solutionCompleteModal.classList.add("hidden");
  levelCompleteModal.classList.add("hidden");
  gameOverModal.classList.add("hidden");
  gameCompleteModal.classList.add("hidden");

  // Show the correct one
  modalElement.classList.remove("hidden");

  const modalContent = modalElement; // FIX: The modal element itself is the content to animate
  setTimeout(() => {
    if (modalContent) {
      // Check if modalContent is not null
      modalContent.style.transform = "scale(1)";
      modalContent.style.opacity = "1";
    }
  }, 10);
}

function hideAllModals() {
  // Find the currently visible modal.
  const activeModal = modalContainer.querySelector(
    "#solution-modal:not(.hidden), #solution-complete-modal:not(.hidden), #level-complete-modal:not(.hidden), #game-over-modal:not(.hidden), #game-complete-modal:not(.hidden)"
  );
  if (activeModal) {
    activeModal.style.transform = "scale(0.95)";
    activeModal.style.opacity = "0";
  }
  setTimeout(() => {
    modalContainer.classList.add("hidden");
  }, 200);
}

// Function to show startup modal
function showStartupModal() {
  startupModal.classList.remove("hidden");
  gameContainer.classList.add("hidden");
  // Hide navigation buttons when showing startup modal
  navigationButtons.classList.add("hidden");
}

// Function to hide startup modal and show game
function hideStartupModal() {
  startupModal.classList.add("hidden");
  gameContainer.classList.remove("hidden");
  // Show navigation buttons when game starts
  navigationButtons.classList.remove("hidden");
}

// Function to go back to home
function goHome() {
  showStartupModal();
}

// Function to show the Play Again button and hide navigation buttons
function showPlayAgainButton() {
  playAgainButton.classList.remove("hidden");
  // Hide the navigation buttons when solution is shown
  restartButton.style.display = "none";
  solutionButton.style.display = "none";
  undoButton.style.display = "none";
}

// Function to hide the Play Again button and show navigation buttons
function hidePlayAgainButton() {
  playAgainButton.classList.add("hidden");
  // Show the navigation buttons when hiding play again
  restartButton.style.display = "block";
  solutionButton.style.display = "block";
  undoButton.style.display = "block";
}

// Function to reset the level while preserving pre-filled cells
function resetLevel() {
  // Store the pre-filled cells before resetting
  const preFilledBackup = new Set(preFilledCells);
  
  // Reset game state
  isGameOver = false;
  currentStep = 0;
  moveHistory = []; // Clear move history
  
  // Clear the grid but preserve pre-filled cells
  for (let row = 0; row < GRID_SIZE; row++) {
    for (let col = 0; col < GRID_SIZE; col++) {
      const cellKey = `${row},${col}`;
      if (!preFilledBackup.has(cellKey)) {
        // Only clear cells that are not pre-filled
        gridState[row][col] = null;
      }
    }
  }
  
  // Restore pre-filled cells tracking
  preFilledCells = preFilledBackup;
  
  // Clear all cells in UI
  const cells = gridBoard.querySelectorAll('.grid-cell');
  cells.forEach(cell => {
    cell.innerHTML = '';
  });
  
  // Re-display pre-filled cells
  displayPrefilledCells();
  
  // Recalculate ball counts based on remaining cells
  calculateBallCounts();
  
  // Update current step to first empty cell
  updateCurrentStepForPrefilledCells();
  
  // Update UI
  updateNextCellHighlight();
  updateBallCountsUI();
  updateUndoButton();
  hidePlayAgainButton(); // Hide the Play Again button
  statusMessage.textContent = "";
}

// Event listeners
restartButton.addEventListener("click", resetLevel);
undoButton.addEventListener("click", undoMove);
solutionButton.addEventListener("click", showSolution);
homeButton.addEventListener("click", goHome);
soundButton.addEventListener("click", toggleSound);
playAgainButton.addEventListener("click", resetLevel);
startGameButton.addEventListener("click", () => {
  hideStartupModal();
  startLevel(0);
});

modalContainer.addEventListener("click", (e) => {
  const button = e.target.closest("[data-action]");
  if (!button) return;

  const action = button.dataset.action;
  if (action === "close") {
    hideAllModals();
  } else if (action === "next-level") {
    console.log(
      `Next level clicked! Current level: ${currentLevel}, Next level: ${
        currentLevel + 1
      }`
    );
    hideAllModals();
    startLevel(currentLevel + 1);
  } else if (action === "restart-level") {
    hideAllModals();
    resetLevel();
  } else if (action === "play-again") {
    hideAllModals();
    resetLevel();
  } else if (action === "restart-game") {
    hideAllModals();
    startLevel(0);
  }
});

// ===== VISUAL EFFECTS =====
function createParticleEffect(element, color) {
  const rect = element.getBoundingClientRect();
  const centerX = rect.left + rect.width / 2;
  const centerY = rect.top + rect.height / 2;

  for (let i = 0; i < 8; i++) {
    const particle = document.createElement("div");
    particle.style.position = "fixed";
    particle.style.width = "4px";
    particle.style.height = "4px";
    particle.style.backgroundColor = color;
    particle.style.borderRadius = "50%";
    particle.style.pointerEvents = "none";
    particle.style.zIndex = "1000";
    particle.style.left = centerX + "px";
    particle.style.top = centerY + "px";

    document.body.appendChild(particle);

    const angle = (i / 8) * Math.PI * 2;
    const distance = 30 + Math.random() * 20;
    const endX = centerX + Math.cos(angle) * distance;
    const endY = centerY + Math.sin(angle) * distance;

    particle.animate(
      [
        {
          transform: "translate(0, 0) scale(1)",
          opacity: 1,
        },
        {
          transform: `translate(${endX - centerX}px, ${
            endY - centerY
          }px) scale(0)`,
          opacity: 0,
        },
      ],
      {
        duration: 600,
        easing: "cubic-bezier(0.4, 0, 0.2, 1)",
      }
    ).onfinish = () => {
      particle.remove();
    };
  }
}

function createGlowEffect(element, color) {
  const glow = document.createElement("div");
  glow.style.position = "absolute";
  glow.style.top = "-5px";
  glow.style.left = "-5px";
  glow.style.right = "-5px";
  glow.style.bottom = "-5px";
  glow.style.borderRadius = "50%";
  glow.style.background = `radial-gradient(circle, ${color}40, transparent)`;
  glow.style.pointerEvents = "none";
  glow.style.animation = "ballGlow 1s ease-in-out";

  element.appendChild(glow);

  setTimeout(() => {
    glow.remove();
  }, 1000);
}

// Enhanced color selection feedback
function enhanceColorSelection(color) {
  const colorContainer = colorSelector.querySelector(`[data-color='${color}']`);
  if (colorContainer) {
    const ball = colorContainer.querySelector(".ball");
    if (ball) {
      createGlowEffect(ball, COLORS[color]);
    }
  }
}

// Prevent arrow key scrolling
document.addEventListener("keydown", (e) => {
  // Prevent default browser behavior for game control keys
  if (
    e.key === "ArrowUp" ||
    e.key === "ArrowDown" ||
    e.key === "ArrowLeft" ||
    e.key === "ArrowRight" ||
    e.key === " " ||
    e.key === "Spacebar" ||
    e.code === "Space"
  ) {
    e.preventDefault();
  }
});

document.addEventListener("keyup", (e) => {
  // Prevent default browser behavior for game control keys
  if (
    e.key === "ArrowUp" ||
    e.key === "ArrowDown" ||
    e.key === "ArrowLeft" ||
    e.key === "ArrowRight" ||
    e.key === " " ||
    e.key === "Spacebar" ||
    e.code === "Space"
  ) {
    e.preventDefault();
  }
});

// Initial startup modal display
showStartupModal();
