# LiTS Reproducibility Report

**Course:** FTEC5660  
**Project:** Reproducibility study of LiTS  
**Date:** 15 November 2026

## 1. Project and target

LiTS (Language Inference via Tree Search) is a modular agent framework that uses Monte Carlo Tree Search to generate and score candidate reasoning steps. The paper demonstrates the framework on MATH500: ReST-MCTS achieved 37% accuracy on 100 numerical-answer examples with Llama3-8B-Instruct. This report partially reproduces that capability on the first three examples. Since this run uses DeepSeek Flash and only three examples, its accuracy is not directly comparable to 37%.

## 2. Environment and setup

- Repository: https://github.com/xinzhel/lits-llm
- Commit: `25e94d862cb4514c22d9a80a635e392461769df7`
- Python: 3.12
- Provider/model: DeepSeek API / `deepseek-flash` (DeepSeek-V4.1-Flash-1017 per current API docs)
- API base URL: `https://api.deepseek.com`
- Generation temperature: repository default; no override was passed
- Provider compatibility: the LiTS OpenAI wrapper was minimally adapted to send DeepSeek's documented `thinking.type=disabled` option, and `enable_think_policy`, `enable_think_eval`, and `enable_think_terminal_gen` are set to false for both conditions. This prevents reasoning-only responses from being parsed as empty `content`; the same setting is used for baseline and modified runs.
- Dataset: `xinzhel/math500-float`, test split, offset 0, limit 3; cached dataset fingerprint `d27dc61b1123c2fdc4eea855c802be87dfa9d536`
- Selected IDs and answers: `572.json`→9, `1622.json`→42, `515.json`→27 (the run script verifies the IDs before making API calls)
- Operating system/hardware: macOS 15.6, Apple Silicon (arm64)
- Reproduction command: `./run_experiment.sh`
- API key: stored locally in ignored `.env`; not committed

## 3. Method

The baseline follows the paper's MATH500 ReST-MCTS setup as closely as the available provider permits: ReST framework, MCTS, `n_iters=10`, `n_actions=3`, and `max_steps=10`. The paper uses Llama3-8B-Instruct and 100 examples; this run uses DeepSeek Flash and the same first three examples in three repetitions. The isolated modification changes only `n_iters` from 10 to 5. We record exact-answer correctness, wall-clock runtime, and API token use for each run. The repository's default `terminate_on_first_solution=true` setting remained enabled.

## 4. Results

| Condition | n_iters | Correct predictions / 9 | Accuracy | Mean runtime per 3-example run (s) | Mean tokens per run |
|---|---:|---:|---:|---:|---:|
| Baseline | 10 | 9/9 | 100% | 97.0 (SD 2.6) | 45,741 |
| Modified | 5 | 9/9 | 100% | 105.3 (SD 2.1) | 46,707 |

| Condition | Trial 1: correct, sec, tokens | Trial 2: correct, sec, tokens | Trial 3: correct, sec, tokens |
|---|---|---|---|
| Baseline | 3/3, 95, 46,240 | 3/3, 100, 48,763 | 3/3, 96, 42,219 |
| Modified | 3/3, 103, 47,474 | 3/3, 106, 46,171 | 3/3, 107, 46,476 |

For context, the paper reports 37% for ReST-MCTS on the 100-example Llama3-8B-Instruct setup. Both settings recovered the expected answers on our three-example DeepSeek subset. The modified setting did not improve accuracy and did not reduce runtime or token use in these runs. The result is a narrow partial reproduction and cannot be compared directly to the paper's full benchmark/model result.

## 5. Modification and debugging diary

The sole modification is an ablation of the search iteration cap (`n_iters=10` to `n_iters=5`). Keeping the task, provider, model, and other search parameters fixed makes the comparison interpretable. A provider compatibility adjustment was needed because DeepSeek's default reasoning mode did not return the final answer in the `content` field expected by LiTS. The adapter disables reasoning mode for both settings; this is documented in the setup section and applied identically. The dataset was read from the existing local Hugging Face cache in offline mode after Hub access failed in this environment. The fixed example IDs were verified by the run script before API calls.

The comparison also exposed a limitation in the chosen ablation: the saved configuration enables `terminate_on_first_solution`, and the search logs show the run ended after its first MCTS iteration. Since neither iteration cap was reached, changing the cap from 10 to 5 was not an effective way to reduce work in this setup.

## 6. Conclusion and limitations

This run partially reproduced LiTS's MATH500 ReST-MCTS behavior on the selected subset: all six three-example runs completed and all 18 evaluated answers were marked correct. Reducing the iteration cap did not reduce the measured work because the search stopped after the first iteration. Limitations include a three-example sample, three stochastic repetitions, DeepSeek Flash differing from the paper's Llama3-8B-Instruct setup, and no full 100-example reproduction. Code, commands, and compact result summaries are available at https://github.com/holEeast979/ftec5660-lits-repro.

## References

- Li, X. and Tao, Y. (2026). *LiTS: A Modular Framework for LLM Tree Search*. arXiv:2603.00631, Table 6 and Appendix B. https://arxiv.org/abs/2603.00631
- Official implementation: https://github.com/xinzhel/lits-llm
