# modules/ui/theme/integrations/mode/_lib/theme-mode.sh
# sarisarinama-theme-mode [name]: tells the desktop whether the theme is
# dark or light. GTK reads gtk-theme; color-scheme reaches every program
# that asks the settings portal: Firefox, Chromium, GTK 4 and libadwaita
# apps, which switch while open. No name means the theme in use. Ported
# from omarchy's omarchy-theme-set-gnome.

# dconf talks to its writer over the session bus. With none, as in a
# switch from a TTY, there is no session to tell; the next one will be.
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
  exit 0
fi

mode=$(jq -r '.mode' "$config/themes/$name.json")

if [ "$mode" = light ]; then
  scheme=prefer-light
  gtk=Adwaita
else
  scheme=prefer-dark
  gtk=Adwaita-dark
fi

# dconf takes GVariant text: a string value is single-quoted.
dconf write /org/gnome/desktop/interface/color-scheme "'$scheme'"
dconf write /org/gnome/desktop/interface/gtk-theme "'$gtk'"
