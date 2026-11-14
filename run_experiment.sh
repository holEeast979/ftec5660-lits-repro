#!/usr/bin/env bash
set -euo pipefail

# Usage: ./run_experiment.sh [baseline|modified|all]
cd "$(dirname "$0")/demos"
MODEL="openai/deepseek-flash"
MODE="${1:-all}"

../.venv/bin/python - <<'PY'
from lits_benchmark.math_qa import load_qa_dataset
expected = [
    ("test/number_theory/572.json", "9"),
    ("test/prealgebra/1622.json", "42"),
    ("test/number_theory/515.json", "27"),
]
actual = [(row["unique_id"], str(row["answer"])) for row in load_qa_dataset("math500")[:3]]
if actual != expected:
    raise SystemExit(f"Selected MATH500 subset changed: {actual}")
print("Verified fixed subset:", actual)
PY

run_group() {
  local label="$1"
  local iterations="$2"
  for trial in 1 2 3; do
    local out="../results/${label}/trial_${trial}"
    local start=$SECONDS
    ../.venv/bin/lits-search \
      --include lits_benchmark.math_qa \
      --dataset math500 \
      --search_framework rest \
      --policy concat --transition concat --reward generative \
      --policy-model "$MODEL" --eval-model "$MODEL" \
      --search-arg "n_iters=${iterations}" n_actions=3 max_steps=10 \
        enable_think_policy=false enable_think_eval=false enable_think_terminal_gen=false \
      --var offset=0 limit=3 \
      --output-dir "$out" --override
    ../.venv/bin/lits-eval --result_dir "$out"
    printf '%s,%s,%s,%s\n' "$label" "$trial" "$iterations" "$((SECONDS-start))" >> ../results/runtime.csv
  done
}

mkdir -p ../results
printf 'condition,trial,n_iters,runtime_seconds\n' > ../results/runtime.csv
case "$MODE" in
  baseline) run_group baseline 10 ;;
  modified) run_group modified 5 ;;
  all) run_group baseline 10; run_group modified 5 ;;
  *) echo "Usage: $0 [baseline|modified|all]" >&2; exit 2 ;;
esac
