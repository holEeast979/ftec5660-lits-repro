# Quick start for the FTEC5660 reproduction

This reproduces the paper's ReST-MCTS behavior on the first three numerical MATH500 test examples, then changes only the search budget from 10 to 5 iterations. It runs three repetitions for each setting. Public repository: https://github.com/holEeast979/ftec5660-lits-repro.

## Local setup

The project requires Python 3.11 or newer. From the repository root:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
cp .env.example .env
```

Edit the ignored local `.env` file and set:

```dotenv
OPENAI_API_KEY=your-DeepSeek-key
OPENAI_API_BASE=https://api.deepseek.com
```

Do not commit `.env`. The script uses the DeepSeek API model alias `deepseek-flash` through LiTS's OpenAI-compatible wrapper. At the time of this run, the alias routed to DeepSeek-V4.1-Flash-1017; provider aliases can follow model updates. See the [official API changelog](https://api-docs.deepseek.com/updates/).

## Run

```bash
./run_experiment.sh baseline
./run_experiment.sh modified
```

The first command runs the baseline (`n_iters=10`); the second runs the one-parameter modification (`n_iters=5`). Each uses the same first three examples for three repetitions. Use `./run_experiment.sh all` to run both conditions in sequence. Results are saved under `results/`; `results/summary.csv` contains the measured per-trial accuracy, runtime, API token counts, and call counts. Compact baseline and modified output summaries are also provided in `results/`.

For an offline data/configuration check before using the API:

```bash
cd demos
HF_HUB_OFFLINE=1 ../.venv/bin/lits-search \
  --include lits_benchmark.math_qa \
  --dataset math500 \
  --search_framework rest \
  --policy concat --transition concat --reward generative \
  --policy-model openai/deepseek-flash \
  --eval-model openai/deepseek-flash \
  --search-arg n_iters=10 n_actions=3 max_steps=10 \
    enable_think_policy=false enable_think_eval=false enable_think_terminal_gen=false \
  --var offset=0 limit=3 --dry-run
```

The paper reports 37% accuracy for ReST-MCTS on 100 examples using Llama3-8B-Instruct. These three-example DeepSeek results are a narrow partial reproduction and should not be compared directly to the full-set number. The checked-in run showed 9/9 correct answers in each condition; the lower iteration cap did not reduce runtime because the repository's default early-stop behavior ended each example after the first MCTS iteration.

The local OpenAI-compatible wrapper includes a small DeepSeek adapter: it disables DeepSeek's reasoning channel by default so the framework receives its final answer in the `content` field. This provider setup is applied identically to both experiment conditions and is described in the report.
