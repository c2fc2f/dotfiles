use evdev::{Device, KeyCode};
use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    for entry in fs::read_dir("/dev/input")? {
        let path = entry?.path();
        if let Some(name) = path.file_name() {
            if name.to_string_lossy().starts_with("event") {
                if let Ok(dev) = Device::open(&path) {
                    if dev.supported_keys().is_some() && is_ctrl_pressed(&dev) {
                        std::process::exit(0);
                    }
                }
            }
        }
    }

    std::process::exit(1);
}

fn is_ctrl_pressed(dev: &Device) -> bool {
    dev.get_key_state()
        .ok()
        .map(|keys| {
            keys.contains(KeyCode::KEY_LEFTCTRL)
                || keys.contains(KeyCode::KEY_RIGHTCTRL)
        })
        .unwrap_or(false)
}
