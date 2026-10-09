/*
TOPDOWN.H

Central switch and shared state for the top-down mode (layer 1):
overhead camera + twin-stick controls.

Design: See Top-Down Camera Spec artifact for full rationale.
*/

#ifndef __TOPDOWN_H
#define __TOPDOWN_H
#pragma once

/* ---------- constants */

/* Top-down camera geometry (provisional, pending fresh-fork verification):
   - 35° tilt from vertical
   - 10.0u camera height above focus
   - 7.0u back offset (10 * tan(35°))
   - 12.207u focus distance (sqrt(10² + 7²))
   - 60° FOV (narrower than Halo's 70° for more orthographic feel) */
#define TOPDOWN_CAMERA_TILT_DEGREES 35.0f
#define TOPDOWN_CAMERA_HEIGHT 10.0f
#define TOPDOWN_CAMERA_BACK_OFFSET 7.0f
#define TOPDOWN_CAMERA_FOCUS_DISTANCE 12.207f
#define TOPDOWN_CAMERA_FOV_DEGREES 60.0f

/* ---------- globals */

/* Runtime toggle for top-down mode. When FALSE, all top-down behavior is
   disabled and the game runs as stock Halo CE. Controlled via console
   command (topdown_mode). Default: TRUE. */
extern boolean topdown_mode_enabled;
/* Virtual mouse cursor for topdown aiming (-1 to +1, 0=center) */
extern real topdown_cursor_x;
extern real topdown_cursor_y;
extern boolean topdown_cursor_active;
/* Lock-on target for HUD reticle (Phase 4) */
extern long topdown_lock_target_index;

/* ---------- functions */

/* Sets the top-down mode runtime toggle. Called via console command. */
void topdown_mode_set(boolean enabled);

#endif // __TOPDOWN_H
