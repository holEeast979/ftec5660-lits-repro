# 6-minute presentation guide

Keep the recording under 15 minutes; this script is about five minutes. Share the report and a terminal window with the `.env` contents hidden. Do not show API keys. Use the measured values below.

## Slide 1 — Project and target (0:00–0:45)

**Show:** LiTS repository title and one-sentence description.

**Say:** “My project is LiTS, an LLM agent framework that uses Monte Carlo Tree Search. I chose the first three fixed MATH500 examples to check whether the documented search pipeline can recover their answers. This is a narrow partial reproduction, not a full benchmark rerun.”

## Slide 2 — Setup (0:45–1:30)

**Show:** Python version, repository commit, model/provider, dataset example ID, and command with secrets hidden.

**Say:** “I pinned the repository commit and used Python 3.12. The model was DeepSeek Flash through its OpenAI-compatible API. The dataset was the first three examples in the test split. I kept the provider and task constant across conditions.”

## Slide 3 — Baseline protocol (1:30–2:15)

**Show:** Baseline settings: 10 iterations, 3 actions, 10 max steps, three trials.

**Say:** “For the baseline I followed the paper's MATH500 ReST-MCTS setup as closely as my available model allowed: ten MCTS iterations, three actions, and the repository's default generation temperature. I used three fixed questions and repeated the subset three times, recording exact-answer correctness, runtime, and token use.”

## Slide 4 — Modification (2:15–3:00)

**Show:** Diff or command showing only `n_iters` changes from 10 to 5.

**Say:** “I made one isolated change: reducing the MCTS iteration budget from ten to five. Everything else stayed the same. This tests whether less search can reduce cost while retaining answer accuracy on this subset.”

## Slide 5 — Results (3:00–4:30)

**Show:** Final results table and a small bar chart for runtime or token use.

**Say:** “Across three runs, the baseline answered 9 of 9 questions correctly, with a mean runtime of 97 seconds and about 45,741 tokens per three-question run. The modified version also answered 9 of 9 correctly, with 105 seconds and about 46,707 tokens. Reducing the iteration cap did not save time or tokens. The logs show that the search stopped after its first iteration because the repository stops when it finds a solution. This small sample does not establish a general accuracy result. The paper reports 37 percent on 100 examples using Llama 3 8B Instruct, so I treat my different-model, three-example run as a narrow partial reproduction.”

## Slide 6 — Limits and takeaway (4:30–5:30)

**Show:** Three short bullets: three examples, three repeats, DeepSeek vs. paper's Llama3-8B-Instruct.

**Say:** “The result is limited to three questions and three repeats, so it is a narrow behavior check. My main lesson is that the default early-stop setting mattered more than the iteration cap in this setup. A full reproduction would require the complete benchmark and the paper's original model setup. The code, commands, and result summary are in my public repository at github.com/holEeast979/ftec5660-lits-repro. Thank you.”

## Recording checklist

- On Mac, open QuickTime Player, choose **File > New Screen Recording**, select the report or slides window, and record the presentation. Zoom recording also works if available.
- Keep the recording below 15 minutes; aim for about five minutes.
- Use six slides, or show the corresponding report sections if slides are unavailable.
- Show the run command and result files, but never reveal `.env`.
- Speak from the script and show the actual results table and experiment files.
- End by showing github.com/holEeast979/ftec5660-lits-repro and verify the link is public.
- Before recording, close any terminal or editor containing `.env`; never show the API key.
