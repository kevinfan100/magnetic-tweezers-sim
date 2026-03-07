#!/bin/bash
# Run Coil2-6 ANSYS simulations sequentially with POST1 data extraction
# Each coil: ~8 min solve + POST1 extraction -> 4 data files per coil
# Continues to next coil even if one fails (no wasted time)

cd "$(dirname "$0")"

MAPDL="C:/Program Files/ANSYS2025R2/v252/ansys/bin/winx64/MAPDL.exe"
LOG="results/run_all.log"

mkdir -p results

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }

log "=========================================="
log "Starting Coil2-6 simulations"
log "=========================================="

PASS=0
FAIL=0

for N in 2 3 4 5 6; do
    log "--- Coil${N}: Starting ---"
    mkdir -p "results/coil${N}"

    # Run ANSYS MAPDL in batch mode
    # -dir: temp files (.err/.log) go to results/coilN/ (gitignored)
    # -j: jobname prefix (coilN.err instead of file.err)
    "$MAPDL" -b -np 4 -m 24000 \
        -dir "results/coil${N}" -j "coil${N}" \
        -i "$(pwd)/post_extract_coil${N}.txt" \
        -o "results/coil${N}/solve.out" || true

    # Check for RUN COMPLETED
    if grep -q "RUN COMPLETED" "results/coil${N}/solve.out" 2>/dev/null; then
        log "Coil${N}: RUN COMPLETED found"
    else
        log "Coil${N}: WARNING - RUN COMPLETED not found"
    fi

    # Check output data files
    OK=true
    for F in "coil${N}_coord_all.dat" "coil${N}_bfield_all.dat" "coil${N}_coord_wp.dat" "coil${N}_bfield_wp.dat"; do
        if [ -f "results/coil${N}/$F" ]; then
            SZ=$(wc -c < "results/coil${N}/$F")
            log "Coil${N}: $F (${SZ} bytes)"
        else
            log "Coil${N}: MISSING $F"
            OK=false
        fi
    done

    if $OK && grep -q "RUN COMPLETED" "results/coil${N}/solve.out" 2>/dev/null; then
        log "Coil${N}: PASS"
        ((PASS++))
    else
        log "Coil${N}: FAIL"
        ((FAIL++))
    fi
    log ""
done

log "=========================================="
log "Summary: ${PASS} passed, ${FAIL} failed (out of 5)"
log "=========================================="
