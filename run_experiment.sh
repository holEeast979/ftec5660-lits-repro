#!/usr/bin/env bash
set -euo pipefail

# Baseline reproduction: first 3 fixed MATH500 examples, 3 trials, 10 MCTS iterations.
cd "$(dirname "$0")/demos"
MODEL="openai/deepseek-flash"

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

mkdir -p ../results/baseline
printf 'condition,trial,n_iters,runtime_seconds\n' > ../results/runtime.csv
for trial in 1 2 3; do
  out="../results/baseline/trial_${trial}"
  start=$SECONDS
  ../.venv/bin/lits-search \
    --include lits_benchmark.math_qa \
    --dataset math500 \
    --search_framework rest \
    --policy concat --transition concat --reward generative \
    --policy-model "$MODEL" --eval-model "$MODEL" \
    --search-arg n_iters=10 n_actions=3 max_steps=10 \
      enable_think_policy=false enable_think_eval=false enable_think_terminal_gen=false \
    --var offset=0 limit=3 \
    --output-dir "$out" --override
  ../.venv/bin/lits-eval --result_dir "$out"
  printf 'baseline,%s,10,%s\n' "$trial" "$((SECONDS-start))" >> ../results/runtime.csv
done
