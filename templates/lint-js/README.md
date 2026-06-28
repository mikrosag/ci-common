# lint-js template

For a JavaScript/TypeScript repo.

## Setup

1. Copy `.eslintrc.json` into the repo root, adjust `extends`/`parserOptions` for the actual stack (e.g. add `"plugin:@typescript-eslint/recommended"` for TS).
2. `npm install --save-dev eslint` (and any plugins) so `package.json`/`package-lock.json` pin the version — the workflow runs `npm ci`, which needs a lockfile.
3. In `ci.yml`, add:
   ```yaml
   jobs:
     lint:
       uses: mikrosag/ci-common/.github/workflows/lint-js.yml@main
   ```
