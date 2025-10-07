import gi
import os
gi.require_version('AppIndicator3', '0.1')
from gi.repository import AppIndicator3, Gtk

def get_batteries():
    batteries = []
    base_path = "/sys/class/power_supply"

    # Find all batteries in the specified base_path
    for item in os.listdir(base_path):
        bat_path = os.path.join(base_path, item)
        if not (os.path.isdir(bat_path) and item.startswith("BAT")):
            continue
        
        # Modern
        start_modern = os.path.join(bat_path, "charge_control_start_threshold")
        end_modern = os.path.join(bat_path, "charge_control_end_threshold")

        # Legacy 
        start_legacy = os.path.join(bat_path, "charge_start_threshold")
        stop_legacy = os.path.join(bat_path, "charge_stop_threshold")

        thresholds = {}

        # 
        if os.path.isfile(end_modern):
            thresholds["type"] = "modern"
            thresholds["start"] = start_modern if os.path.isfile(start_modern) else None
            thresholds["end"] = end_modern
        elif os.path.isfile(stop_legacy):
            thresholds["type"] = "legacy"
            thresholds["start"] = start_legacy if os.path.isfile(start_legacy) else None
            thresholds["end"] = stop_legacy

        if thresholds:
            batteries.append((item, thresholds))

    return batteries

# Get current battery limit
def get_current_limit(thresholds):
    try:
        with open(thresholds["end"], "r") as f:
            return int(f.read().strip())
    except Exception:
        return None

def set_limit(thresholds, value):
        ttype = thresholds.get("type")
        if ttype == "modern":
            # Modern: end threshold always present
            os.system(f"pkexec sh -c 'echo {value} > {thresholds['end']}'")
            
            # Create optional start threshold (set 10% lower if exists) // TODO Add custom start
            if thresholds.get("start"):
                start_val = max(1, value - 10)
                os.system(f"pkexec sh -c 'echo {start_val} > {thresholds['start']}'")

        elif ttype == "legacy":
            # Legacy: stop threshold always present
            os.system(f"pkexec sh -c 'echo {value} > {thresholds['end']}'")
            
            # Create optional start threshold (set 10% lower if exists) // TODO Add custom start
            if thresholds.get("start"):
                start_val = max(1, value - 10)
                os.system(f"pkexec sh -c 'echo {start_val} > {thresholds['start']}'")

def on_select(path_data, value):
    set_limit(path_data, value)
    refresh_menu()

def build_menu():
    menu = Gtk.Menu()

    batteries = get_batteries()
    options = [50, 80, 100]
    
    # Create a new submenu for each battery
    for bat_name, thresholds in batteries:
        submenu = Gtk.Menu()
        current = get_current_limit(thresholds)
        for val in options:
            label = f"Limit to {val}%"
            if current == val:
                label += " \u2713"
            item = Gtk.MenuItem(label=label)
            item.connect("activate", lambda w, t=thresholds, v=val: on_select(t, v))
            submenu.append(item)

        # Top level battery menu
        bat_item = Gtk.MenuItem(label=f"Battery ({bat_name})")
        bat_item.set_submenu(submenu)
        menu.append(bat_item)

    separator = Gtk.SeparatorMenuItem()
    menu.append(separator)

    quit_item = Gtk.MenuItem(label="Quit")
    quit_item.connect("activate", Gtk.main_quit)
    menu.append(quit_item)

    menu.show_all()
    return menu

def refresh_menu():
    indicator.set_menu(build_menu())
    indicator.set_icon("battery")
    indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)

def main():
    global indicator
    indicator = AppIndicator3.Indicator.new(
        "battery-limit",
        "battery",
        AppIndicator3.IndicatorCategory.APPLICATION_STATUS
    )
    indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)
    refresh_menu()
    Gtk.main()

if __name__ == "__main__":
    main()
