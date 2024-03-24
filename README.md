# actions-chiritori

[chiritori](https://github.com/piyoppi/chiritori/tree/main) on GitHub Actions.

This action is for removing expired source code in the repository.

## Inputs

| name | detail |
| -- | -- |
| `filepattern` | Target file pattern (default: `*.html`)|
| `encoding` | Character encoding of target files. (Optional, default: `UTF-8`) |
| `delimiter-start` | Delimiter (start) (Optional, default: `<!--`) |
| `delimiter-end` | Delimiter (start) (Optional, default: `-->`) |
| `time-limited-tag-name` | Tag name of Time limited source code (Optional, default: `time-limited`) |

## Example

This is an example of creating a Pull Request for HTML files in the repository and removing the expired code.

([Example of a pull request created using this workflow](https://github.com/piyoppi/actions-sandbox/pull/3))

```yml
name: Remove time-limited source code

on: workflow_dispatch

env:
  BRANCH_NAME: remove-time-limited-${{ github.sha }}
  FILE_PATTERN: '*.html'

jobs:
  remove-time-limited:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: piyoppi/actions-chiritori@v1
        with:
          filepattern: ${{ env.FILE_PATTERN }}

      - name: 'Commit diff'
        run: |
          git config --global user.email "chiritori-bot@example.com"
          git config --global user.name "chiritori-bot"
          git checkout -b ${{ env.BRANCH_NAME }}
          git add ${{ env.FILE_PATTERN }}
          git commit -m "Remove time-limited by chiritori"
          git push origin ${{ env.BRANCH_NAME }}

      - name: 'Create pull request'
        uses: actions/github-script@v7
        with:
          script: |
            await github.rest.pulls.create({
              owner: 'owner',
              repo: 'owners-repo',
              title: 'Remove time-limited by chiritori',
              head: `${{ env.BRANCH_NAME }}`,
              base: 'main'
            });
```
