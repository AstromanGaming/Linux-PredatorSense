#!/usr/bin/env python3

# /path/of/the/software/monitor_evdev.py

from evdev import InputDevice, ecodes
import subprocess, time, os, sys

DEV = '/dev/input/event4'
KEY_CODE = 425
GUI_SERVICE = 'predator-sense-gui.service'


def find_active_graphical_session():
    """
    Return (session_id, username, uid) for the active graphical session (wayland/x11),
    excluding greeter accounts (gdm, gdm-greeter, etc.).
    """
    try:
        lines = subprocess.check_output(
            ['loginctl', 'list-sessions', '--no-legend'],
            text=True
        ).strip().splitlines()
    except subprocess.CalledProcessError:
        return None, None, None

    for line in lines:
        parts = line.split()
        if not parts:
            continue
        sid = parts[0]

        try:
            uid_str = subprocess.check_output(
                ['loginctl', 'show-session', sid, '-p', 'User', '--value'],
                text=True
            ).strip()
        except subprocess.CalledProcessError:
            continue

        try:
            uid_int = int(uid_str)
        except ValueError:
            continue

        try:
            passwd = subprocess.check_output(['getent', 'passwd', str(uid_int)], text=True).strip()
            if not passwd:
                continue
            username = passwd.split(':', 1)[0]
        except subprocess.CalledProcessError:
            continue

        if username.startswith('gdm'):
            continue

        try:
            stype = subprocess.check_output(
                ['loginctl', 'show-session', sid, '-p', 'Type', '--value'],
                text=True
            ).strip()
            state = subprocess.check_output(
                ['loginctl', 'show-session', sid, '-p', 'State', '--value'],
                text=True
            ).strip()
        except subprocess.CalledProcessError:
            continue

        if state == 'active' and stype in ('wayland', 'x11'):
            return sid, username, str(uid_int)

    return None, None, None


def start_gui_service_for_user(username, uid):
    """
    Start the GUI service in the correct user session by exporting DBUS_SESSION_BUS_ADDRESS.
    """
    try:
        bus = f"unix:path=/run/user/{uid}/bus"

        if not os.path.exists(f"/run/user/{uid}/bus"):
            for _ in range(10):
                time.sleep(0.2)
                if os.path.exists(f"/run/user/{uid}/bus"):
                    break
            else:
                print(f"DBus session bus not found for uid {uid}", file=sys.stderr)
                return

        subprocess.run([
            'sudo', '-u', username,
            'env', f'DBUS_SESSION_BUS_ADDRESS={bus}',
            'systemctl', '--user', 'start', GUI_SERVICE
        ], check=False)
    except Exception as e:
        print("Monitor exception while starting GUI service:", e, file=sys.stderr)


def main():
    print("Monitor starting", file=sys.stderr)

    try:
        dev = InputDevice(DEV)
    except Exception as e:
        print("Cannot open device:", e, file=sys.stderr)
        return

    print("Listening on", DEV, file=sys.stderr)

    for ev in dev.read_loop():
        if ev.type == ecodes.EV_KEY and ev.code == KEY_CODE and ev.value == 1:
            sid, user, uid = find_active_graphical_session()
            if not user or not uid:
                print("No graphical user detected at keypress", file=sys.stderr)
                continue

            print(f"Active graphical user detected at keypress: {user} (session {sid}, uid {uid})", file=sys.stderr)
            print("Monitor: launching GUI user service", file=sys.stderr)
            start_gui_service_for_user(user, uid)
            time.sleep(0.1)


if __name__ == '__main__':
    main()
