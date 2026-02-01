# ShapeSim - AI Agent Instructions

A Godot 4 civilization simulation game with god-like abilities and a dynamic news ticker. Created for Global Game Jam 2026.

## Architecture Overview

### Core Systems
- **Civilizations** ([civilization/civilization.gd](civilization/civilization.gd)): Autonomous agents that spawn buildings, manage warriors, and have dynamic hostility values toward other civs
- **Units** ([unit/unit.gd](unit/unit.gd)): Warriors that navigate to enemy hubs, attack on contact, and are affected by god abilities
- **Buildings** ([civilization/building.gd](civilization/building.gd)): WarriorHut, Science, WatchTower, Campfire - each with unique effects on civilization behavior
- **GodAbility** ([GodAbility.gd](GodAbility.gd)): Player-controlled area effects that track and modify units/buildings in radius
- **Eventbus** ([Eventbus/eventbus.gd](Eventbus/eventbus.gd)): Singleton for game-wide event communication
- **NewsTicker** ([newsticker/news_ticker.gd](newsticker/news_ticker.gd)): Event-driven news feed with templated headlines

### Critical Patterns

**Singleton Pattern via Static Reference**
```gdscript
static var this: ClassName
func _ready(): 
    this = self
```
Used in: `Eventbus`, `GodAbility`, `NewsTicker`. Access via `Eventbus.this.signal_name.emit()`.

**Registration System for God Abilities**
Units/buildings register themselves when entering the god ability radius:
```gdscript
if !isRegisteredOnAbility && godAbility.is_inside_ability(global_position):
    godAbility.register_unit(self)
    isRegisteredOnAbility = true
```
Deregister when leaving. GodAbility uses `weakref()` to track without preventing deletion.

**Event-Driven News System**
Events aggregate in [event_aggregator.gd](newsticker/event_aggregator.gd), count thresholds, then queue news:
```gdscript
news_ticker.add_to_queue({"type": Constants.NewsType.War, "count": deathCount})
```
News templates defined in [constants.gd](Globals/constants.gd) with `{CIV}`, `{COUNT}`, `{LEVEL}` placeholders.

**Civilization Behavior Cycles**
Civs evaluate goals every `reevaluateGoalCooldown` ticks, choosing between War/Science/Defense/Chilling based on hostility and level. Goals affect building priorities and warrior spawn rates.

**Hostility System**
Each civ maintains `otherCivToHostilityValue` dictionary. Warriors target civs weighted by these values. Hostility increases when units die or buildings are attacked (scaled by `reactivity`).

## Constants & Enums ([Globals/constants.gd](Globals/constants.gd))

All game enums centralized here:
- `Civilization`: Red, Blue, Green, Yellow, Purple
- `AbilityType`: Speedup, Slowdown, Heal, Meteorite, Push, Pull, Duplicate
- `BuildingType`, `CivilizationGoal`, `NewsType`, `CivilizationStyle`

Sprite loading convention:
```gdscript
Constants.getWarriorTexture(civilizationStyle, level)
// Looks in: res://Sprites/{CivStyle}/Warriors/{level}.tres
```

## God Abilities Implementation

Abilities apply every `abilityCooldown` seconds to all registered units:
- **Timed Effects** (Meteorite, Heal): Apply damage/healing each tick
- **Instant Effects** (Push, Pull, Duplicate): Apply once, use Tweens for smooth movement
- **Continuous Modifiers** (Speedup, Slowdown): Modify unit properties on enter/exit

Push/Pull use tweens + disable physics processing during movement to prevent nav interference. Stored in `_knockbacks` dictionary for cleanup.

## News Ticker Behavior

- Scroll container has `alignment = 2` (bottom-aligned) so new items appear at bottom
- Auto-scrolls to `scroll_container.get_v_scroll_bar().max_value` after adding news
- Queue system prevents spam: max 5 items, removes oldest when full
- Generic news fills gaps when queue is empty

## Testing & Development

**Running the Project**: Open `project.godot` in Godot 4.x. Main scene likely in root or `world_nils.tscn`.

**Debug Prints**: Many methods use `print_debug()` for event tracking. Check Output panel in Godot.

**Common Modification Points**:
- Add new god ability: Update `Constants.AbilityType`, add case in `GodAbility.apply_timed_ability()`
- Add news template: Define in `constants.gd`, add handler in `event_aggregator.gd`, update queue logic in `news_ticker.gd`
- Tune civilization AI: Adjust `hostility`, `reactivity`, `buildingPlaceCooldown` exports in civilization scenes

## File Organization Conventions

- `*.gd` scripts paired with `*.gd.uid` files (Godot's resource tracking)
- `*.tscn` scenes reference scripts via `uid://` paths
- Exports defined with `@export` for editor tweaking
- Class names use `class_name` for global access without paths
