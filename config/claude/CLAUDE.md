# Global Claude Instructions

## Package Manager Requirements

### Python
Use `uv` and `uvx` for all Python work. Do not use `python`, `python3`, or `pip` directly.

- Run scripts: `uv run script.py` instead of `python script.py`
- Run tools: `uvx tool-name` instead of `pip install tool-name && tool-name`
- Add dependencies: `uv add package` instead of `pip install package`
- Create projects: `uv init` instead of manual setup

### JavaScript/TypeScript
Use package runner commands instead of direct execution.

- Run packages: `npx package-name` or `bunx package-name` instead of global installs
- Run scripts: `npm run script` / `pnpm run script` / `bun run script`
- Add dependencies: Use the project's package manager (`npm`, `pnpm`, `bun`, or `yarn`)
- Do not use `node script.js` directly when a package.json script exists
