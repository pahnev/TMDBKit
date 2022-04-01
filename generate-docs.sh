#!/bin/bash
set -eu

git fetch && git worktree add --checkout ../gh-docs origin/gh-docs

# Pretty print DocC JSON output so that it can be consistently diffed
export DOCC_JSON_PRETTYPRINT="YES"

# Generate documentation for the 'TMDBKit' target and output it
export SWIFTPM_ENABLE_COMMAND_PLUGINS=1 
swift package \
    --allow-writing-to-directory "gh-docs" \
    generate-documentation \
    --target TMDBKit \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path TMDBKit \
    --output-path "gh-docs"


# Copy the redirect file into the 'gh-docs' directory, otherwise github.io/TMDBKit would be just a blank page.
cp redirect.html gh-docs/index.html

# Commit and push changes to the 'gh-docs' branch
cd gh-docs
git add .

if [ -n "$(git status --porcelain)" ]; then
    git commit -m "Documentation update"
    git push origin HEAD:gh-docs
else
  # No changes found, nothing to commit.
  echo "No documentation changes found."
fi

# Delete the git worktree we created
cd ..
git worktree remove gh-docs