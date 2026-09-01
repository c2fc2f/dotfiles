use evdev::{Device, KeyCode};
use std::fs;

fn main() {
  let entries = match fs::read_dir("/dev/input") {
    Ok(dir) => dir,
    Err(_) => std::process::exit(1),
  };

  for entry in entries.flatten() {
    let path = entry.path();

    if !path.is_dir()
      && let Ok(dev) = Device::open(&path)
      && is_ctrl_pressed(&dev)
    {
      std::process::exit(0);
    }
  }

  std::process::exit(1);
}

fn is_ctrl_pressed(dev: &Device) -> bool {
  dev
    .get_key_state()
    .ok()
    .map(|keys| {
      keys.contains(KeyCode::KEY_LEFTCTRL)
        || keys.contains(KeyCode::KEY_RIGHTCTRL)
    })
    .unwrap_or(false)
}
