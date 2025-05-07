# Love2D Project

## Overview
This project is a template for developing games using the Love2D engine. It integrates commonly used libraries and provides a structured approach to game development.

## Project Structure
```
l2d-toolset
├── main.lua          # Main entry point of the application
├── conf.lua          # Configuration settings for the Love2D application
├── src               # Source files for game logic and entities
│   ├── esc           # Entity-Component-System framework
│   │   ├── world.lua # World management
│   │   ├── components/  # Component definitions
│   │   ├── entities/    # Entity definitions
│   │   └── systems/     # System implementations
│   ├── states        # Game states management
│   │   ├── boot.lua     # Boot/loading state
│   │   ├── gameover.lua # Game over state
│   │   ├── hub.lua      # Hub/central area state
│   │   ├── mainmenu.lua # Main menu state
│   │   ├── pausemenu.lua# Pause menu state
│   │   ├── run.lua      # Gameplay run state
│   │   └── settings.lua # Settings state
│   └── utils         # Utility functions
│       ├── audio.lua    # Audio management
│       ├── config.lua   # Configuration utilities
│       ├── helpers.lua  # Helper functions
│       ├── resources.lua# Resource management
│       └── input/       # Input handling
├── libs              # External libraries
│   ├── anim8         # Animation library
│   ├── baton         # Input handling library
│   ├── batteries     # Various utility modules
│   ├── bump          # Collision detection library
│   ├── concord       # Entity-Component-System library
│   ├── hump          # HUMP libraries (camera, gamestate, etc.)
│   ├── lume          # Utility library
│   ├── smiti18n      # Internationalization library
│   ├── sti           # Tiled map integration
│   └── suit          # Immediate mode GUI library
├── assets            # Game assets
│   ├── images        # Image assets
│   ├── audio         # Audio assets
│   │   ├── music     # Music files (mp3)
│   │   └── sfx       # Sound effect files (wav)
│   ├── fonts         # Font files
│   └── maps          # Game maps
│       └── level1.lua# First level definition
├── locales           # Localization files
│   ├── en.lua        # English localization
│   └── zh-CN.lua     # Chinese localization
└── README.md         # Project documentation
```

## Setup Instructions
1. **Install Love2D**: Download and install Love2D from the official website.
2. **Clone the Repository**: Clone this project to your local machine.
3. **Run the Project**: Open a terminal, navigate to the project directory, and run the project using Love2D:
   ```
   love .
   ```

## Usage
- Modify the `main.lua` file to customize the game loop and resource loading.
- Use the `src` directory to implement game logic, states, and entities.
- Integrate external libraries from the `lib` directory as needed.
- Add assets to the `assets` directory for images, audio, and maps.

## Contributing
Feel free to contribute to this project by adding new features, fixing bugs, or improving documentation.