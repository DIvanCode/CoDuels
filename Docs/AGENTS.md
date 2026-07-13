# Documentation agent guide

- Write project documentation in Russian unless the surrounding file is clearly English.
- Edit Markdown and LaTeX sources, not generated PDFs. `thesis/thesis-main.pdf` and `slides/slides.pdf` are build outputs.
- Treat the thesis as the architectural rationale and historical design. Verify current ports, event transports, deployment modes, dependencies, and APIs against the code repositories before documenting them as current behavior.
- When behavior or architecture changes, update the smallest relevant component README plus `tech.md` or the thesis section only when the user requests thesis synchronization.
- Preserve LaTeX style and existing terminology: Execution, Job, Coordinator, Worker, Taski, Exesh, Duely, Analyzer, filestorage.
- Build affected LaTeX with `make` in `thesis/` or `slides/`. The build uses `latexmk`, `minted`, and `-shell-escape`.
