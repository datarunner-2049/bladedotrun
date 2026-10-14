/* =====================================================================
   timings.js  -  every patch-sensitive number and line of wording.
   Edit this file when a patch changes timers; index.html needs no changes.
   All times are in SECONDS of match time (120 = 2:00).
   ===================================================================== */
window.HUD_TIMINGS = {

  meta: {
    patch: 'City Never Sleeps (Sept 29, 2026) plus 10-05 fixes',
    verified: '2026-10-14'
  },

  /* Lane trooper waves. Each step applies until the given match time.
     First wave spawns at 0:00. Use the "Wave just spawned" button in the HUD
     if the real spawns are offset from this. */
  waves: [
    { until: 1200,   every: 30 },   // 0:00  to 20:00
    { until: 2100,   every: 25 },   // 20:00 to 35:00
    { until: 999999, every: 20 }    // 35:00 onward
  ],

  /* How early the HUD warns you, and how long an objective counts as "up now". */
  alerts: {
    prep: 55,   // gold "shove the wave now" state starts this many seconds before
    go: 10,     // red "move now" state starts this many seconds before
    live: 25    // lime "up right now" state lasts this long after spawn
  },

  /* Objectives. "major" ones trigger the prep/go/now states and sounds. */
  events: {
    small: {
      first: 120, respawn: 85,                      // 2:00, back 1:25 after a full clear
      name: 'SMALL HAUNTS', short: 'SMALL', kind: 'haunt', major: true,
      action: 'Shove the wave, clear the nearest small camp, be back before the next wave hits your Guardian.'
    },
    breakables: {
      first: 180, respawn: 180,                     // 3:00
      name: 'BREAKABLES', short: 'BREAKABLES', kind: 'haunt', major: false,
      action: 'Grab only if they are on your path back to lane.'
    },
    medium: {
      first: 300, respawn: 290,                     // 5:00, back 4:50
      name: 'MEDIUM HAUNTS', short: 'MEDIUM', kind: 'haunt', major: true,
      action: 'Crash the wave, clear ONE medium camp, be back for the next wave.'
    },
    large: {
      first: 480, respawn: 335,                     // 8:00, back 5:35
      name: 'LARGE HAUNTS', short: 'LARGE', kind: 'haunt', major: true,
      action: 'High value from 8:00 to 10:00. Take them after the Sacrifice, with the wave shoved.'
    },
    sacrifice: {
      first: 480, respawn: 300,                     // 8:00, back 5:00 after it is broken
      nagUntil: 1500,                               // show the "Sacrifice is UP" reminder until 25:00
      name: "SINNER'S SACRIFICE", short: 'SACRIFICE', kind: 'sac', major: true,
      action: 'Heavy melees ONLY: 4 permanent buffs. Bank your haunted souls before any fight.'
    },
    urn: {
      first: 600, every: 300, count: 14,            // 10:00, then every 5:00
      liveFor: 30,                                  // board shows LIVE this long after it spawns
      sides: ['YELLOW SIDE', 'OTHER SIDE'],         // alternates, yellow side first
      name: 'SOUL URN', short: 'URN', kind: 'urn', major: true,
      action: 'Usually a side laner job. Shove mid hard so they must pick between the Guardian and the Urn. A melee hit or stun knocks it loose.'
    },
    rift: {
      firstStart: 600, firstEnd: 720,               // first one about 10:00 to 12:00
      afterMin: 360, afterMax: 480,                 // next one 6 to 8 min after the last was seen
      name: 'UNSTABLE RIFT WINDOW', short: 'RIFT', kind: 'rift', major: true,
      action: 'Window is about 2 minutes wide. If it is on your weaker side, shove mid and join. Otherwise push the opposite side.'
    },
    midBoss: {
      windowOpens: 900,                             // start thinking about it at 15:00
      respawns: [420, 360, 300],                    // 7, then 6, then 5 min after each death
      windowName: 'MID BOSS WINDOW', respawnName: 'MID BOSS RESPAWNS', short: 'BOSS', kind: 'boss', major: true,
      windowAction: 'It is alive but not worth starting yet. You need: mid and a side lane pushed, 3 to 4 enemies located, man advantage. Be there before the roar.',
      respawnAction: 'Start it only if mid and a side lane are pushed, you know where 3 to 4 enemies are, and you have the man advantage.'
    }
  },

  /* What to do in each stretch of the match when no objective is imminent. */
  phases: [
    { from: 0, to: 120, name: 'Opening lane',
      call: 'LAST-HIT. CONFIRM ORBS. DENY.',
      steps: ['Shoot your own floating orbs, deny theirs', 'Before 2:00, pick your nearest small camp', 'Keep trades cheap, never skip a last-hit'],
      tip: 'Trade only when it costs you no last-hits. Keep an escape or trap ready for the gank path.' },

    { from: 120, to: 300, name: 'Small camps',
      call: 'SHOVE → SMALL CAMP → BACK TO LANE',
      steps: ['Clear the nearest small camp each shove (respawns 1:25), be back before the wave hits your Guardian',
              'Breakables and snacks only if they are on your way back',
              'Ganks come from both sides of mid. Stay behind the bridge line unless you see both enemy side laners'],
      tip: 'Spend your souls every shop trip, and say out loud what is next and when before you leave.' },

    { from: 300, to: 480, name: 'Medium camps',
      call: 'CRASH WAVE → 1 MEDIUM CAMP → BACK FOR NEXT WAVE',
      steps: ['Never miss a wave for a camp',
              'Ahead: hit the Guardian while your troopers tank it, back off when they die',
              'Losing lane: freeze the wave near your own Guardian'],
      tip: 'No open fights until your core items are bought. Wave first, camp second.' },

    { from: 480, to: 600, name: 'End of laning, start of macro',
      call: 'CRASH WAVE → SACRIFICE → CAMP → NEXT WAVE',
      steps: ['Sacrifice: HEAVY melees only. Jackpot is 4 permanent buffs, light melee gives 1',
              'Haunted souls are not yours until banked: shop before any fight',
              'After a big clear, do not fight. Spend, then move'],
      tip: 'Do not chase kills past the bridge while your wave dies at your Guardian.' },

    { from: 600, to: 900, name: 'First Urn, first Rift',
      call: 'PUSH MID. LET A SIDE LANER RUN THE URN.',
      steps: ['Shove mid so the enemy must choose: defend the Guardian or stop the Urn',
              'Rift on your weaker side: shove mid and join. Otherwise push the opposite side',
              'Do not take the Urn yourself and leave mid empty'],
      tip: 'Start fights with an area stun or from cover, and keep farming between them.' },

    { from: 900, to: 1500, name: 'Walkers and Mid Boss setup',
      call: 'WALKERS + MID BOSS SETUP',
      steps: ['A Walker is 3,675 souls and a Flex Slot. Push with Rift Troopers or right after a pick',
              'Start Mid Boss only if: mid and a side lane are pushed, you know where 3 to 4 enemies are, you have the man advantage',
              'Be there BEFORE the roar at 50% HP, not after'],
      tip: 'Boss pits and Rift circles clump the enemy. Hit them with area damage from cover after their interrupts are spent.' },

    { from: 1500, to: 2280, name: 'Late-mid game',
      call: 'PICKS = OBJECTIVES',
      steps: ['Respawns are long now (38s at 20:00, more later). One pick on their carry is a free objective',
              'Never let a wave crash uncontested into your Walker or Guardian',
              'Ahead: convert the lead to structures. The comeback bonus funds them every minute you wait'],
      tip: 'If hard interrupts (knockdown, hook, silence) keep canceling your key ability, buy the counter.' },

    { from: 2280, to: 999999, name: 'Late game',
      call: 'GROUP UP. FIVE OR SIX, WITH A WAVE.',
      steps: ['Shrines are invulnerable until a pair of Base Guardians is down',
              'Reset the Patron fight if the enemy is about to respawn. Throws happen in their base',
              'Split-push only if they are grouped elsewhere AND a teammate holds mid'],
      tip: 'If your hero has no mobility, a 1v2 kills you. When in doubt, group.' }
  ]
};
