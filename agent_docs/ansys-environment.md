# ANSYS Environment

## Software
- **Version:** ANSYS Mechanical APDL 2025 R2
- **Executable:** `C:\Program Files\ANSYS Inc\v252\ANSYS\bin\winx64\MAPDL.exe`
- **Desktop shortcut:** `Mechanical APDL 2025 R2`
- **License:** Research/Academic (single seat)

## Batch Mode Syntax
```
MAPDL.exe -b -np <cores> -m <memory_MB> -i <input.txt> -o <output.out>
```
| Flag | Description |
|------|-------------|
| `-b` | Batch mode (no GUI) |
| `-np 4` | 4 CPU cores |
| `-m 24000` | 24 GB memory allocation |
| `-i` | Input APDL script |
| `-o` | Output log file |

## Hardware
- **CPU:** Intel Core i5-14500 (14 cores / 20 threads)
- **RAM:** 32 GB DDR5
- **Storage:** NVMe SSD
- **OS:** Windows 11 Pro

## Notes
- Typical solve time: 30-60 min per coil (SMRT=5 mesh, ~2.4M elements)
- Output per coil: ~1.5 GB (rst + db + supporting files)
- Total for 6 coils: ~10 GB
