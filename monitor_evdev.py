#!/usr/bin/env python3
# /path/of/the/software/monitor_evdev.py
from evdev import InputDevice, ecodes
import subprocess, time, os, sys

DEV = '/dev/input/event4'
KEY_CODE = 425
GUI_SERVICE = 'predator-sense-gui.service'

def get_active_user():
    """
    Returns the user of the active graphical session.
    """
    try:
        sessions = subprocess.check_output(
            ['loginctl', 'list-sessions', '--no-legend'],
            text=True
        ).strip().splitlines()

        if not sessions:
            return None

        session_id = sessions[0].split()[0]

        user = subprocess.check_output(
            ['loginctl', 'show-session', session_id, '-p', 'Name', '--value'],
            text=True
        ).strip()

        return user if user else None

    except Exception as e:
        print("Cannot detect active user:", e, file=sys.stderr)
        return None


def main():
    user = get_active_user()
    if not user:
        print("No active user detected", file=sys.stderr)
        return

    print(f"Active user detected: {user}", file=sys.stderr)

    try:
        dev = InputDevice(DEV)
    except Exception as e:
        print("Cannot open device:", e, file=sys.stderr)
        return

    print("Listening on", DEV)
    for ev in dev.read_loop():
        if ev.type == ecodes.EV_KEY and ev.code == KEY_CODE and ev.value == 1:
            try:
                print("Monitor: launching GUI user service", file=sys.stderr)
                subprocess.run([
                    'systemctl',
                    f'--machine={user}@.host',
                    '--user',
                    'start',
                    GUI_SERVICE
                ])
            except Exception as ex:
                print("Monitor exception:", ex, file=sys.stderr)
            time.sleep(0.1)

if __name__ == '__main__':
    main()
