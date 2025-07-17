#!/bin/bash

# Sicherer CPU-Frequenzbereich für Raspberry Pi 3
MIN_FREQ=600000
MID_FREQ=900000
MAX_FREQ=1200000

# Funktion zur Anpassung der CPU-Frequenz
set_cpu_freq() {
    local freq=$1
    echo "$freq" | tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
}

echo "Starte DVFS-Monitor (drücke Ctrl+C zum Beenden)..."

# Fang Ctrl+C ab, damit der User abbrechen kann
trap "echo -e '\nAbbruch durch Benutzer. CPU-Frequenz zurücksetzen...'; set_cpu_freq $MAX_FREQ; exit 0" SIGINT SIGTERM

while true; do
    # CPU-Auslastung berechnen
    cpu_idle_before=$(grep 'cpu ' /proc/stat | awk '{print $5}')
    total_before=$(grep 'cpu ' /proc/stat | awk '{sum=0; for(i=2;i<=NF;i++) sum+=$i; print sum}')
    sleep 1
    cpu_idle_after=$(grep 'cpu ' /proc/stat | awk '{print $5}')
    total_after=$(grep 'cpu ' /proc/stat | awk '{sum=0; for(i=2;i<=NF;i++) sum+=$i; print sum}')

    idle_diff=$((cpu_idle_after - cpu_idle_before))
    total_diff=$((total_after - total_before))
    cpu_usage=$(echo "scale=2; 100 * (1 - $idle_diff / $total_diff)" | bc)

    echo "CPU-Auslastung: $cpu_usage%"

    # Frequenz basierend auf Auslastung anpassen
    if (( $(echo "$cpu_usage < 20.0" | bc -l) )); then
        echo "→ Frequenz gesenkt auf $MIN_FREQ"
        set_cpu_freq $MIN_FREQ
    elif (( $(echo "$cpu_usage > 80.0" | bc -l) )); then
        echo "→ Frequenz erhöht auf $MAX_FREQ"
        set_cpu_freq $MAX_FREQ
    else
        echo "→ Frequenz auf Mittelwert gesetzt ($MID_FREQ)"
        set_cpu_freq $MID_FREQ
    fi

    sleep 5
done

