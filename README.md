# actions-chiritori

[Chiritori](https://github.com/piyoppi/chiritori) on GitHub Actions.

- Remove pre-tagged source code in the repository
- Annotate of removal markers for pull request diffs

## Example

### Remove time-limted and open pull request

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

      - uses: piyoppi/actions-chiritori@v2
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

### Remove released feature

This is an example of creating a Pull Request for an HTML file in the repository and removing code triggered by a release.

- Run with `removal-marker-target-config`. The remove-marker with the name specified in feature.txt is the target for removal.

([Example of a pull request created using this workflow](https://github.com/piyoppi/actions-sandbox/pull/7))

```yml
name: Release-triggered removal of source code

on:
  workflow_dispatch:
    inputs:
      feature:
        description: Released feature name
        required: true
        type: string

env:
  BRANCH_NAME: removal-marker-${{ github.sha }}
  FILE_PATTERN: '*.html'

jobs:
  remove-time-limited:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - run: echo ${{ inputs.feature }} > feature.txt

      - uses: piyoppi/actions-chiritori@v2
        with:
          filepattern: ${{ env.FILE_PATTERN }}
          delimiter-start: "<!--"
          delimiter-end: "-->"
          removal-marker-target-config: "feature.txt"

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
              title: 'Remove Release-triggered by chiritori',
              head: `${{ env.BRANCH_NAME }}`,
              base: 'main'
            });
```

### Annotate removal-marker in pull request diff

This is an example of annotating that the diff in the Pull Request contains a removal-tag.

- Set `run-mode` to `list-all` to list the deletion markers.
- Set `target-file-mode` to `diff` to report only the differences contained in the Pull Request.
- Set `report-mode` to `annotation` to display annotations on File Changed in Pull Requests. 

([Example using this workflow](https://github.com/piyoppi/actions-sandbox/pull/8/files))

```yml
name: Annotate removal-marker in pull request diff

on: pull_request

env:
  FILE_PATTERN: '*.html'

jobs:
  remove-time-limited:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.base_ref }}

      - run: echo BASE_SHA=`git rev-parse HEAD` >> $GITHUB_ENV

      - uses: actions/checkout@v4
        with:
          ref: ${{ github.sha }}

      - uses: piyoppi/actions-chiritori@v2
        with:
          filepattern: ${{ env.FILE_PATTERN }}
          delimiter-start: "<!--"
          delimiter-end: "-->"
          run-mode: "list-all"
          target-file-mode: "diff"
          report-mode: "annotation"
          base-sha: ${{ env.BASE_SHA }}
```

## Inputs

### Required

| name | detail |
| -- | -- |
| `filepattern` | Target file pattern |

### Optional (Chiritori configuration)

| name | detail |
| -- | -- |
| `delimiter-start` | Start delimiter (default: `<!-- <`) |
| `delimiter-end` | End Delimiter (default: `> -->`) |
| `time-limited-tag-name` | Tag name of Time limited source code (default: `time-limited`) |
| `removal-marker-tag-name` | Tag name for removal-marker (default: `removal-marker`) |
| `removal-marker-target-config` | Config file specifying the name of the removal-marker to be removed. For more details, See [Chiritori README](https://github.com/piyoppi/chiritori?tab=readme-ov-file#removal-marker) |

### Optional (Actions behavior)

| name | detail |
| -- | -- |
| `run-mode` | "remove": Remove pre-tagged source codes / "list": List removal tags (Excluding tags not targeted to removal) / "list-all": List all removal tags) (default: `remove`) |
| `target-file-mode` | "all": All files in the repository / "diff": Files included in pull request (default: `all`) |
| `encoding` | Character encoding of target files. (default: `UTF-8`) |

### Optional (run-mode is "list" or "list-all")

| name | detail |
| -- | -- |
| `report-mode` | "none": Print to log (stdout) / "annotation": Annotate in the pull request diffs) (default: `none`) |
| `base-sha` | Base SHA for diff (Required when `target-file-mode` is "diff") |
| `head-sha` | Head SHA for diff (default: `github.sha`, available when `target-file-mode` is "diff") |


