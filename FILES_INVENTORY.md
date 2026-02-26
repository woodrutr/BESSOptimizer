# Samples Folder Inventory: What's Critical vs Archivable

## ✅ CRITICAL FOR OPERATION (Never archive)

### Code & Configuration
- `src/bess_ml/` — entire package (36 Python modules)
- `pyproject.toml` — build configuration & entry points
- `bess_control.py` — main entry point CLI menu
- `Run_BESS.command` — Mac double-click launcher
- `.env.example` — environment variable template
- `.gitignore` — version control rules
- `Makefile` — build targets

### Data Files (Live Model)
- `historical_nyiso.parquet` (79 MB) — **CRITICAL**: NYISO DART spread history 2023–2025, the core input to the forecasting model
- `historical_data/weather.parquet` (331 KB) — NWS hourly observations, required for feature engineering
- `historical_data/generation.parquet` (7.2 MB) — NYISO fuel-mix generation, required for feature engineering
- `historical_data/congestion.parquet` (11 MB) — NYISO congestion prices, required for backtesting
- `historical_data/fuels.parquet` (11 KB) — EIA fuel cost index, required for feature engineering

### Trained Models (Zone-specific)
- `models/NYC/` — **CRITICAL**: production LSTM weights, config, scaler (all zones)
- `models/LONGIL/`, `models/WEST/`, etc. — all zone models needed if trading multiple zones
- `model_checkpoints/NYC/` — versioned checkpoint bundles (good for rollback)

### Runtime State (Essential if daemon is running)
- `state/bess_live_state_NYC.json` — **CRITICAL**: current battery SOC, VWAP basis, inventory (live daemon reads this)
- `state/bess_live_ledger_NYC.csv` — **CRITICAL**: transaction history + PnL log (live daemon reads/writes this)
- `state/*.lock` — daemon lock file (auto-managed)

### Configuration (Zone-specific models)
- `config/best_config_NYC.json` — **CRITICAL**: LSTM hyperparameters for NYC zone (lookback, hidden size, etc.)
- `config/best_config_LONGIL.json`, etc. — all zone configs (one per zone trained)
- `config/best_exec_params_NYC.json` — execution policy params from optimize_execution.py (if generated)

### Databases
- `bess_alpha_search_v5.db` — **ACTIVE** Optuna study (v5 is current; v1/v3/v4 are archived)
- `forecast_logs.db` — SQLite log of all forecast predictions (daemon appends to this)

### Tests & Documentation
- `tests/` — unit & integration test suite (safe to archive but good for regression testing)
- `README.md` — main documentation
- `BACKTEST_ANALYSIS.md` — latest analysis (good reference)

---

## 🗂️ SAFE TO ARCHIVE (Rarely used; easy to regenerate)

### Old Data Artifacts
- `bess_dummy_NYC.parquet` — dummy TOU backtest results (regeneratable)
- `forecast_history.parquet` — old forecast archive (can recreate from forecast_logs.db)
- `backtests/` directory
  - `backtests/bess_backtest_NYC.csv` — old interval-by-interval results
  - `backtests/bess_backtest_NYC.parquet` — old backtest output
  - ↳ **Regeneratable**: just re-run `bess-backtest --zone NYC`

### Analytics & Reports
- `reports/` directory
  - `reports/hyperparam_results_*.csv` — old Optuna trial data
  - `reports/model_eval_*.json` — old model evaluation snapshots
  - `reports/data_quality_*.json` — old data audit logs
  - ↳ **Regeneratable**: Optuna DB is source of truth

### Runtime Logs (keep for debugging, archive for storage)
- `logs/optuna_search_*.log` (44+ files) — Optuna search logs (can grow large)
- `logs/retrain_*.log` (11+ files) — training session logs
- `logs/backtest_*.log` — backtest execution logs
- `logs/bess_daemon.log` — daemon activity log
- ↳ **Safe to archive**: logs can be recreated by re-running commands

### Backup State Files
- `state/bess_live_ledger_NYC.csv.bak_*` — ledger backups (keep if troubleshooting, else archive)
- `state/bess_live_state_NYC.json.bak_*` — state backups (same)
- ↳ **Keep if paranoid, archive if space-constrained**

---

## ❓ OPTIONAL (Not model-critical; Claude's internal files)

### Claude AI Configuration Files
- `config/cache_plan.json` — Claude's internal cache config
- `config/data_sources.yaml` — Claude's data config
- `config/events.jsonl` — Claude's event log
- `config/memory.jsonl` — Claude's memory log
- `config/status.json` — Claude's status file
- `config/telemetry/` — Claude telemetry data
- ↳ **Not used by the BESS model** — safe to delete or archive
- `config/baseline_cv_NYC.json` — old cross-validation baseline (can delete)

### Checkpoint Variants
- `model_checkpoints/CAPITL/`, `CENTRL/`, `DUNWOD/`, etc. — zone variants
  - **Keep NYC at minimum**; archive others if trading only NYC
  - `model_checkpoints/HQ/`, `model_checkpoints/N_Y_C_/`, `model_checkpoints/all_zones/` — old/duplicate variants (archive)

### Miscellaneous
- `.DS_Store` — macOS garbage (safe to delete)
- `.venv/` — Python virtual environment
  - **Safe to archive**: can recreate with `python -m venv .venv && pip install -e .`

### Old Documentation (pre-v2.0)
- `LSTM_MODEL_EXPLAINED.md` — old explainer
- `ML_DEMO_SCRIPT.md` — old demo
- `ML_FEATURE_SPEC.md` — old feature list (superseded by current features)
- `ML_V2_IMPLEMENTATION_STATUS.md` — old status
- `MODEL_ENHANCEMENTS_GUIDE.md` — old guide
- `RUN_SCRIPTS.md` — old CLI docs (superseded by `bess_control.py`)
- `SETUP_INSTRUCTIONS.md` — old setup (outdated)
- `V2_READY_TO_TEST.md`, `V2_USAGE_GUIDE.md` — old v2 docs
- `WEATHER_GENERATION_INTEGRATION_PLAN.md` — old plan
- `WHATS_BUILT_AND_NEXT_STEPS.md` — old roadmap
- `NYISO BESS Model Card.rtf` — old model card
- `BESS Pipeline Workflow v4.docx` — old workflow diagram
- `DART_Interview_Plan.docx` — interview prep (unrelated)
- ↳ **Archive if space-constrained; keep for reference if curious about history**

---

## 📋 ARCHIVE CHECKLIST

### Safe to move to `archive/` (zero risk):
```
bess_dummy_NYC.parquet
backtests/
reports/
logs/optuna_search_*.log
logs/retrain_*.log
logs/backtest_*.log
config/cache_plan.json
config/data_sources.yaml
config/events.jsonl
config/memory.jsonl
config/status.json
config/telemetry/
config/baseline_cv_NYC.json
config/best_config_NYC_v5_candidate.json
LSTM_MODEL_EXPLAINED.md
ML_DEMO_SCRIPT.md
... (all old doc files above)
```

### Keep one backup before archiving:
```
state/*.bak_*  (keep 1 copy, archive the rest)
model_checkpoints/*  (keep NYC, archive variants)
forecast_history.parquet  (keep if you like having full history)
```

### Safe to delete (not needed at all):
```
.DS_Store
.venv/  (recreate on next install)
forecast_history.parquet  (recreatable from forecast_logs.db)
```

---

## Size Breakdown

| Category | Size | Archivable? |
|----------|------|------------|
| `src/bess_ml/` | ~500 KB | ❌ CRITICAL |
| `historical_*.parquet` + weather/gen/cong/fuels | ~97 MB | ❌ CRITICAL |
| `models/` (all zones) | ~50–100 MB | ❌ CRITICAL |
| `model_checkpoints/` (all zones) | ~100–200 MB | ✅ Keep NYC, archive others |
| `state/` (ledger + state) | ~1 MB | ❌ CRITICAL (if running daemon) |
| `logs/` | ~10 MB | ✅ Safe to archive |
| `backtests/`, `reports/` | ~5 MB | ✅ Safe to archive |
| Documentation + config | ~2 MB | ✅ Safe to archive |
| **TOTAL CRITICAL** | ~147–247 MB | |
| **TOTAL ARCHIVABLE** | ~15–20 MB | |

---

## Recommended Archive Strategy

1. **Create archive folder**: `mkdir archive`
2. **Move safely archivable**: `mv backtests reports logs config/*.json config/telemetry archive/`
3. **Keep symlink for logs** (optional): `ln -s archive/logs logs` so old commands still work
4. **Archive old docs**: `mv LSTM_MODEL_EXPLAINED.md ML_*.md V2_*.md *.docx *.rtf archive/`
5. **Compress**: `tar -czf archive.tar.gz archive/ && rm -rf archive/`
6. **Verify operation**: Run `python -m bess_ml.pipeline.bess_backtest --zone NYC --test-days 1` to ensure no breakage
7. **Tar critical files** (optional, for backup): `tar -czf bess_ml_prod_backup.tar.gz src/ models/ state/ historical_data/ historical_nyiso.parquet config/best_*.json bess_control.py pyproject.toml`

**Total space freed**: ~15–20 MB (depends on how many logs you have).
