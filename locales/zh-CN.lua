return {
  ["zh-CN"] = {
    -- Settings menu translations
    settings = {
      title = "设置",
      volume = "音量",
      fullscreen = "全屏",
      language = "语言",
      back = "返回",
      yes = "是",
      no = "否"
    },
    
    -- Pause Menu translations
    pausemenu = {
      title = "游戏暂停",
      continue = "继续游戏",
      settings = "设置",
      mainmenu = "返回主菜单"
    },
    
    -- Main Menu translations
    mainmenu = {
      title = "主菜单",
      start = "开始游戏",
      settings = "设置",
      exit = "退出"
    },
    
    -- Game Over translations
    gameover = {
      title = "游戏结束",
      score = "分数: %d",
      return_to_hub = "返回大厅",
      try_again = "再试一次"
    },
    
    -- Hub translations
    hub = {
      title = "中心世界",
      start_run = "开始冒险",
      settings = "设置",
      exit = "返回主菜单",
      select_buffs = "选择增益: (%d/%d)",
      instructions = "使用方向键导航，按空格键选择增益",
      buffs = {
        health_up = {
          name = "生命提升",
          desc = "增加最大生命值25%"
        },
        attack_speed = {
          name = "攻击速度",
          desc = "提高攻击速度15%"
        },
        critical_hit = {
          name = "暴击",
          desc = "10%几率造成双倍伤害"
        },
        regeneration = {
          name = "生命回复",
          desc = "随时间缓慢恢复生命值"
        }
      }
    },
    
    -- Run state translations
    run = {
      health = "生命值: %d/%d",
      score = "分数: %d",
      level = "关卡: %d",
      time = "时间: %d",
      floor = "层数: %d (房间 %d/%d)",
      active_buffs = "激活的增益:",
      debug = {
        floor_generated = "生成了第%d层，共有%d个房间",
        run_ended = "冒险结束于第%d层，总分数为%d",
        critical_hit = "暴击!"
      }
    },
    
    -- Common translations
    common = {
      loading = "加载中...",
      version = "版本 %s"
    }
  }
}
