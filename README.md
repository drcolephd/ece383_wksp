ECE 383 Final Project - Tetris
Brandon Sweitzer

1.	Plan

a.	Proposal

The objective of this project was to design and implement a fully hardware-based Tetris game on the FPGA board using VHDL. The system was designed to demonstrate real-time embedded system concepts including finite state machines, memory management, external device interfacing, and video generation.

The project uses HDMI/VGA output to display gameplay, an NES controller connected through the JA pins for user input, and custom hardware modules for all game functionality. Unlike software-based games that rely on processors, this implementation performs all gameplay operations directly in hardware.

The final project fulfills the requirement of interfacing with an external device by integrating an NES controller through the JA header interface.

b.	Minimum Functionality
•	Display playable Tetris board using HDMI output
•	Spawn and move tetrominoes
•	Rotate pieces
•	Detect collisions
•	Lock pieces into the board
•	Detect game over condition

c.	B-Level Functionality
•	Line clearing
•	Piece randomization
•	Score tracking
•	Increasing game speed
•	Next piece preview

d.	A-Level Functionality
•	NES controller support
•	Hold/swap piece functionality
•	Real-time preview windows
•	Dynamic game speed scaling
•	Graphical score and line counters

2.	Detailed Architecture and Sub-System Design

a.	Level 1 Design

The Tetris system was divided into several hardware subsystems.

b.	Major Subsystems
1.	Game FSM
2.	Piece Logic
3.	Collision Detector
4.	Board Memory
5.	Line Clear Detector
6.	Video/VGA System
7.	NES Controller Interface
8.	Score Counter
9.	Game Clock
10.	Piece Randomizer

c.	Top-Level Data Flow

NES Controller
Game FSM 
Piece Logic
Collision Detector
Board Memory
Line Clear
Video/Color Mapper 
HDMI Output

d.	Game FSM

The game FSM acts as the main control unit for the system. It controls spawning pieces, falling logic, locking pieces into the board, line clearing, and game-over transitions.

Key FSM states include:

•	RESET_INIT
•	SPAWN_PIECE
•	WAIT_SPAWN
•	CHECK_SPAWN
•	FALLING
•	LOCK_CAPTURE
•	LOCK_PIECE
•	WAIT_LOCK
•	CHECK_CLEAR
•	CLEAR_ROWS
•	WAIT_CLEAR
•	GAME_OVER

The FSM coordinates communication between all gameplay modules.

e.	Piece Logic

The piece logic module stores the active tetromino state, tracking:

•	Piece X position
•	Piece Y position
•	Rotation state
•	Piece type
•	Hold piece
•	Next piece

The module generates the active piece cell coordinates used by both the renderer and collision detector.

f.	Collision Detector

The collision detector validates movement requests before the FSM commits movement operations.
The detector checks:
•	Left movement validity
•	Right movement validity
•	Downward movement validity
•	Rotation validity
•	Spawn validity
•	Hard drop position

This modular approach simplified the FSM and improved debugging.

g.	Board Memory

The board memory module stores the locked game board state as a 10x20 grid.
The board originally stored full 24-bit RGB color values but was later optimized to store compact 3-bit cell identifiers. This significantly reduced synthesis complexity and improved timing.
Responsibilities include:
•	Storing locked blocks
•	Writing newly locked pieces
•	Clearing completed rows
•	Shifting rows downward

h.	Line Clear Module

The line clear detector scans the board for completed rows.

Outputs include:
•	rows_cleared
•	clear_en
•	shift_en
•	
The FSM then performs controlled row clearing and shifting operations.

i.	Video System

The video system consists of:
•	VGA signal generator
•	Color mapper
•	DVID/HDMI conversion

The color mapper renders:
•	Active piece
•	Locked board blocks
•	Board boundaries
•	Hold piece preview
•	Next piece preview
•	Score display
•	Line counter

The video output is displayed through HDMI.

j.	NES Controller Interface

The NES controller communicates through the JA header interface.

JA Pin Mapping:
•	JA0: Latch
•	JA1: Clock
•	JA2: Data

The NES module serially reads controller button states and converts them into gameplay control signals.

Supported controls:
•	Left movement
•	Right movement
•	Rotate
•	Soft drop
•	Hard drop
•	Hold/swap
•	Reset

k.	Score Counter

The score counter tracks:
•	Total score
•	Total lines cleared
•	Game level

The level output is used to dynamically increase game speed.

l.	Game Clock

The game clock generates the falling tick for the gameplay system. The tick frequency changes dynamically based on player level. As more lines are cleared, the falling speed increases.

m.	Piece Randomizer

A linear-feedback shift register (LFSR) was used to generate pseudo-random tetromino sequences. This provided randomized gameplay while remaining fully synthesizable in hardware.

3.	Calculations / Analysis / Drawings

a.	Board Geometry
The game board consists of:
•	10 columns
•	20 rows
•	20x20 pixel cells

This resulted in a 200x400 pixel gameplay area.

b.	Preview Windows

The hold and next-piece preview windows use scaled-down 12x12 pixel cells.

c.	Fixed-Point and Timing Considerations

The game clock frequency was adjusted dynamically using counter thresholds.

Speed levels:
Level	Tick Count
0	25,000,000
1	20,000,000
2	15,000,000
3	10,000,000
4+	7,500,000

d.	Collision Detection

Collision detection was implemented using board coordinate comparisons.

A valid move required:
•	Board bounds maintained
•	No overlap with locked blocks

e.	Memory Optimization

The board representation was optimized from 24-bit RGB storage to compact 3-bit cell identifiers. This reduced board storage requirements from approximately 4800 bits to 600 bits, which greatly helped with synthesis time for debugging and testing.

4.	Milestone I

a.	Objective

Achieve basic playable Tetris functionality.

b.	Milestone I Requirements
•	VGA/HDMI output operational
•	Single tetromino displayed
•	Piece falling logic operational
•	Piece movement operational
•	Collision detection functional

c.	Testing Performed
•	Verified HDMI signal generation
•	Verified active piece rendering
•	Verified left/right movement
•	Verified soft drop operation
•	Verified collision with floor and walls

d.	Results

Milestone I functionality was successfully achieved.

5.	Milestone II

a.	Objective

Implement advanced gameplay systems and external controller support.

b.	Milestone II Requirements
•	NES controller integration
•	Line clearing
•	Hold/swap system
•	Randomized pieces
•	Score tracking
•	Dynamic speed scaling

c.	Testing Performed
•	Verified NES button decoding
•	Verified hold/swap functionality
•	Verified line clear detection
•	Verified row shifting logic
•	Verified score updates
•	Verified increasing game speed

d.	Results

Milestone II functionality was successfully achieved.

6.	Updated Functionality and Requirements

a.	Final Functionality Achieved
•	Real-time Tetris gameplay
•	Hardware-only implementation
•	HDMI graphics output
•	NES controller input
•	Piece movement and rotation
•	Hard drop
•	Hold/swap system
•	Next-piece preview
•	Randomized piece generation
•	Score tracking
•	Line counter
•	Dynamic speed scaling
•	Game-over detection

b.	Challenges Encountered

Several significant debugging challenges occurred during development:
•	Timing issues between line clear and piece spawning
•	Random board corruption caused by unsafe memory updates
•	Rotation edge cases near walls
•	NES controller synchronization issues
•	Collision mismatch between renderer and collision detector

These issues were resolved by:
•	Adding FSM wait states
•	Centralizing piece coordinate logic
•	Optimizing board memory handling
•	Improving controller timing synchronization
•	Reworking preview rendering logic

7.	Milestone I

Milestone I successfully demonstrated the minimum playable implementation of Tetris.

The system could:
•	Display graphics through HDMI
•	Spawn tetrominoes
•	Move pieces left and right
•	Detect floor collisions
•	Lock pieces into the board

The milestone validated the functionality of the video system, game FSM, and basic gameplay loop.

8.	Milestone II

Milestone II expanded the project into a fully featured game.

Additional features implemented:
•	NES controller support
•	Hold/swap piece system
•	Line clearing
•	Score tracking
•	Randomized pieces
•	Dynamic speed increase
•	Next piece preview

The milestone demonstrated successful integration between all level 1 subsystems.

9.	Final Demonstration and Test Results

The final system successfully demonstrated a fully playable hardware-based Tetris implementation.

a.	Successfully Demonstrated Features
•	Stable HDMI output
•	Real-time gameplay
•	Responsive NES controller input
•	Proper collision handling
•	Correct line clearing
•	Hold/swap operation
•	Next-piece preview
•	Dynamic gameplay speed increase
•	Score and line tracking
•	Game-over handling

b.	Final Performance

The system operated in real time without requiring a software processor.
All gameplay operations were implemented directly in custom VHDL hardware.

The final design demonstrated:
•	Real-time rendering
•	Deterministic gameplay timing
•	Stable hardware operation
•	Modular hardware architecture

c.	Lessons Learned

This project demonstrated the importance of:
•	Modular hardware design
•	FSM-based control systems
•	Careful synchronization between modules
•	Memory optimization for FPGA synthesis
•	Incremental hardware debugging

The project also provided significant experience with:
•	FPGA development
•	HDMI graphics generation
•	External peripheral interfacing
•	Real-time embedded systems

 
Appendix A: Running the Project

Required Hardware
•	FPGA development board
•	HDMI monitor
•	HDMI cable
•	NES controller
•	JA connection wires

Setup Procedure
1.	Open the Vivado project.
2.	Generate the bitstream.
3.	Program the FPGA.
4.	Connect the HDMI monitor.
5.	Connect the NES controller to the JA pins.
6.	Reset the FPGA.
7.	The game should automatically begin.

NES Wiring
JA Pin	NES Signal
JA0	Latch
JA1	Clock
JA2	Data

Controls
NES Button	Action
Left	Move left
Right	Move right
A	Rotate
Down	Soft drop
B	Hard drop
Select	Hold/swap
Start	Reset game

