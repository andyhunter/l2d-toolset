return {
  ["en"] = {
    -- Settings menu translations
    settings = {
      title = "Settings",
      volume = "Volume",
      fullscreen = "Fullscreen",
      language = "Language",
      back = "Back",
      yes = "Yes",
      no = "No"
    },
    
    -- Pause Menu translations
    pausemenu = {
      title = "Game Paused",
      continue = "Continue",
      settings = "Settings",
      mainmenu = "Return to Main Menu"
    },
    
    -- Main Menu translations
    mainmenu = {
      title = "Main Menu",
      start = "Start",
      settings = "Settings",
      exit = "Exit"
    },
    
    -- Game Over translations
    gameover = {
      title = "Game Over",
      score = "Score: %d",
      return_to_hub = "Return to Hub",
      try_again = "Try Again"
    },
    
    -- Hub translations
    hub = {
      title = "Hub World",
      start_run = "Start Run",
      settings = "Settings",
      exit = "Return to Main Menu",
      select_buffs = "Select Buffs: (%d/%d)",
      instructions = "Use arrow keys to navigate, SPACE to select buffs",
      buffs = {
        health_up = {
          name = "Health Up",
          desc = "Increases max health by 25%"
        },
        attack_speed = {
          name = "Attack Speed",
          desc = "Increases attack speed by 15%"
        },
        critical_hit = {
          name = "Critical Hit",
          desc = "10% chance to deal double damage"
        },
        regeneration = {
          name = "Regeneration",
          desc = "Slowly recover health over time"
        }
      }
    },
    
    -- Run state translations
    run = {
      health = "Health: %d/%d",
      score = "Score: %d",
      level = "Level: %d",
      time = "Time: %d",
      floor = "Floor: %d (Room %d/%d)",
      active_buffs = "Active Buffs:",
      debug = {
        floor_generated = "Generated floor %d with %d rooms",
        run_ended = "Run ended on floor %d with a score of %d",
        critical_hit = "Critical hit!"
      }
    },
    
    -- Common translations
    common = {
      loading = "Loading...",
      version = "Version %s"
    }
  }
}
