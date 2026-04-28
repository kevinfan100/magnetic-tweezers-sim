#!/bin/bash
# Pole length L_P sweep wrapper
# For each L_P, runs sim + post-proc, parses B_peak, ∫B_y dz, L_m, computes RMS cost.

set -e
ANSYS="G:/ANSYS Inc/v252/ansys/bin/winx64/MAPDL.exe"
KUO_DIR="G:/my_workspace/code/magnetic-tweezers-sim/kuo"
SIM="$KUO_DIR/apdl/sim/MT_Kuo_Quadrupole_Sim_Dipole.txt"
POST="$KUO_DIR/apdl/postproc/MT_Kuo_Sweep_Post.txt"
PARAM="$KUO_DIR/apdl/sim/lp_param.inp"

# JMEMS Fig 5 fit targets
B_PEAK_TARGET_MT=8.0
INTBDZ_TARGET_UTM=5.49
LM_TARGET_UM=686.0

OUT_CSV="$KUO_DIR/data/lp_sweep_results.csv"
mkdir -p "$KUO_DIR/data"
echo "L_P_mm,B_peak_mT,IntBdz_uTm,L_m_um,cost_RMS" > "$OUT_CSV"

# Default sweep list (overrideable by command-line args)
if [ $# -gt 0 ]; then
    SWEEP_LIST="$@"
else
    SWEEP_LIST="0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90"
fi

for LP_MM in $SWEEP_LIST; do
    LP_M=$(awk "BEGIN {printf \"%.6e\", $LP_MM * 1e-3}")
    LP_TAG=$(echo "$LP_MM" | tr '.' 'p')   # 0.65 -> 0p65 for dirname
    RES_DIR="$KUO_DIR/results/Lp${LP_TAG}_T100_dipole"
    mkdir -p "$RES_DIR"

    echo ""
    echo "===== L_P = $LP_MM mm ($LP_M m) ====="

    # 1. Write parameter file
    cat > "$PARAM" <<EOF
*SET, L_P_VAL, $LP_M
EOF

    # 2. Run sim
    "$ANSYS" -b -np 4 -m 4000 -dir "$RES_DIR" -j "kuo_dipole_sim" \
        -i "$SIM" -o "$RES_DIR/sim_run.out" 2>&1 | tail -1

    # 3. Run post
    "$ANSYS" -b -np 4 -m 4000 -dir "$RES_DIR" -j "kuo_post" \
        -i "$POST" -o "$RES_DIR/post_run.out" 2>&1 | tail -1

    # 4. Parse: ∫B_y dz from FINAL SUMMATION line (use tail to skip source-listing match)
    INTBDZ=$(grep "FINAL SUMMATION" "$RES_DIR/post_run.out" | tail -1 | awk '{print $NF}')

    # 5. Parse: B_y peak (max abs) from PATH VARIABLE SUMMARY block
    BPEAK=$(awk '/PATH VARIABLE SUMMARY/,/^$/' "$RES_DIR/post_run.out" \
            | awk 'NF==3 && $1 ~ /^[0-9.E+-]+$/ {v=$2; if(v<0)v=-v; if(v>m)m=v} END {print m}')

    # 6. Compute L_m, cost
    LM=$(awk "BEGIN {printf \"%.6e\", ($INTBDZ < 0 ? -$INTBDZ : $INTBDZ) / $BPEAK}")

    # In display units
    BPEAK_MT=$(awk "BEGIN {printf \"%.4f\", $BPEAK * 1000}")
    INTBDZ_UTM=$(awk "BEGIN {printf \"%.4f\", ($INTBDZ < 0 ? -$INTBDZ : $INTBDZ) * 1e6}")
    LM_UM=$(awk "BEGIN {printf \"%.2f\", $LM * 1e6}")

    # 7. RMS cost
    COST=$(awk "BEGIN {
        e1 = ($BPEAK_MT - $B_PEAK_TARGET_MT) / $B_PEAK_TARGET_MT;
        e2 = ($INTBDZ_UTM - $INTBDZ_TARGET_UTM) / $INTBDZ_TARGET_UTM;
        e3 = ($LM_UM - $LM_TARGET_UM) / $LM_TARGET_UM;
        printf \"%.5f\", sqrt((e1*e1 + e2*e2 + e3*e3) / 3.0)
    }")

    echo "$LP_MM,$BPEAK_MT,$INTBDZ_UTM,$LM_UM,$COST" >> "$OUT_CSV"
    echo "  B_peak=${BPEAK_MT} mT  |∫B dz|=${INTBDZ_UTM} µT·m  L_m=${LM_UM} µm  cost=${COST}"
done

echo ""
echo "===== Sweep complete ====="
echo "Results in $OUT_CSV"
cat "$OUT_CSV"
