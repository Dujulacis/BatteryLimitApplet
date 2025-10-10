# Battery Limit Applet

## **Overview**
Battery Limit Applet is a Linux system tray applet written in Python to manage **battery charge thresholds**. Supports both modern and legacy battery interfaces and provides an easy way to limit charging to extend battery lifespan.

---

## **Features**

- Detects all batteries in `/sys/class/power_supply`.
- Supports **modern** (`charge_control_start_threshold` / `charge_control_end_threshold`) and **legacy** (`charge_start_threshold` / `charge_stop_threshold`) systems.
- Set charge limits (50%, 80%, 100%) from the system tray.
- Displays the current battery limit with a checkmark.
- Supports **multiple batteries** simultaneously.

---

## **Supported Systems**

- Linux distributions with **systemd**.
- Laptops exposing battery thresholds in `/sys/class/power_supply`.
- Tested on:
 - Asus Vivobook
 - Lenovo Thinkpad
   
> Some OEMs may not expose battery thresholds. Check `/sys/class/power_supply/BAT*/` for supported files.

---

## **Dependencies**

- Python 3
- PyGObject (`python3-gi`)
- AppIndicator3 (`gir1.2-appindicator3-0.1`)

**Install dependencies on Debian/Ubuntu/Pop!_OS:**

```bash
sudo apt update
sudo apt install python3-gi python3-gi-cairo gir1.2-appindicator3-0.1
