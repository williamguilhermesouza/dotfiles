#!/usr/bin/env python3
"""Wofi calendar panel following Omarchy Quattro's clock composition."""

import calendar
import datetime as dt
import os
import subprocess
from pathlib import Path


HOME = Path.home()
POPUP = HOME / ".config/waybar/scripts/popup-menu.sh"
STYLE = HOME / ".config/waybar/wofi-calendar.css"
FOREGROUND = "#e5e9f0"
MUTED = "#858b98"
FAINT = "#555c69"
ACCENT = "#89b4fa"


def span(text, **attrs):
    values = " ".join(f'{key}="{value}"' for key, value in attrs.items())
    return f"<span {values}>{text}</span>" if values else text


def locale_week_start():
    locale_name = (os.environ.get("LC_TIME") or os.environ.get("LC_ALL") or os.environ.get("LANG") or "").upper()
    territory = locale_name.split(".", 1)[0].split("@", 1)[0].rsplit("_", 1)[-1]
    return 6 if territory == "US" else 0


def render(today, year, month):
    first = dt.date(year, month, 1)
    rows = []
    hero = (
        f'{span("", font_family="FontAwesome", size="27000", foreground=ACCENT)}  '
        f'{span(today.strftime("%-d %B").upper(), size="27000", weight="bold", foreground=FOREGROUND)}'
    )
    rows.append(hero)

    day_of_year = today.timetuple().tm_yday
    year_length = 366 if calendar.isleap(today.year) else 365
    progress = max(0, min(1, (day_of_year - 1) / year_length))
    percent = round(progress * 100)
    filled = round(progress * 30)
    year_track = (
        f'{span(str(today.year), foreground=MUTED)}   '
        f'{span("━" * filled, foreground=ACCENT)}'
        f'{span("─" * (30 - filled), foreground=FAINT)}   '
        f'{span(str(percent) + "%", foreground=FOREGROUND)}'
    )
    rows.append(span(year_track, font_family="Noto Sans Mono", size="9500"))

    rows.append(span(f'{first.strftime("%B %Y").upper()}', size="10500", letter_spacing="900", foreground=MUTED))
    week_start = locale_week_start()
    weekday_names = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
    weekday_names = weekday_names[week_start:] + weekday_names[:week_start]
    header = span("Wk │ " + "".join(f"{name:<5}" for name in weekday_names), font_family="Noto Sans Mono", size="9000", weight="bold", foreground=MUTED)
    rows.append(header)

    grid_start = first - dt.timedelta(days=(first.weekday() - week_start) % 7)
    for week_index in range(6):
        row_start = grid_start + dt.timedelta(days=week_index * 7)
        iso_week = (row_start + dt.timedelta(days=(3 - week_start) % 7)).isocalendar().week
        cells = []
        for offset in range(7):
            day = row_start + dt.timedelta(days=offset)
            text = f"{day.day:2d}{'*' if day == today else ' '}  "
            if day == today:
                color = ACCENT
                weight = ' weight="bold"'
            elif day.month != month:
                color = FAINT
                weight = ""
            elif day.weekday() >= 5:
                color = MUTED
                weight = ""
            else:
                color = FOREGROUND
                weight = ""
            cells.append(f'<span foreground="{color}"{weight}>{text}</span>')
        rows.append(span(f"{iso_week:02d} │ " + "".join(cells), font_family="Noto Sans Mono", size="9500"))

    rows.append("‹ PREVIOUS MONTH")
    rows.append("NEXT MONTH ›")
    return hero, rows


def main():
    today = dt.date.today()
    view_year, view_month = today.year, today.month
    while True:
        hero, rows = render(today, view_year, view_month)
        data = "\n".join(rows) + "\n"
        try:
            result = subprocess.run(
                [
                    str(POPUP),
                    "--popup-width", "420",
                    "--hide-search",
                    "--allow-markup",
                    "--define=content_halign=center",
                    "--lines", "12",
                    "--height", "350",
                    "--prompt", "",
                    "--style", str(STYLE),
                ],
                input=data,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                env=os.environ.copy(),
                check=False,
            )
        except OSError:
            return 0

        choice = result.stdout.strip()
        if choice == hero:
            view_year, view_month = today.year, today.month
        elif choice == "‹ PREVIOUS MONTH":
            view_year, view_month = (view_year - 1, 12) if view_month == 1 else (view_year, view_month - 1)
        elif choice == "NEXT MONTH ›":
            view_year, view_month = (view_year + 1, 1) if view_month == 12 else (view_year, view_month + 1)
        else:
            return 0


if __name__ == "__main__":
    raise SystemExit(main())
