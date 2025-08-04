# cmd-claude-update.md

Update the .claude submodule to the latest version from the main repository.

## Instructions

This command helps you update your .claude directory when it's included as a git submodule. The script automatically updates without manual prompts.

```bash
# Run the automated update script
.claude/scripts/claude-update.sh

# Or force update without checks
# .claude/scripts/claude-update.sh --force
```

## Alternative: Update to Specific Version

If you need a specific version instead of latest:

```bash
# To update to a specific tag or commit:
cd .claude
git fetch --tags
echo ""
echo "Available tags:"
git tag -l | tail -10

echo ""
echo "To switch to a specific version:"
echo "  cd .claude"
echo "  git checkout v1.2.3  # or specific commit"
echo "  cd .."
echo "  git add .claude"
echo "  git commit -m \"Pin .claude to version v1.2.3\""
```

## Troubleshooting

### If you see "modified content" warnings:

This usually means you have local changes in .claude. Either:
1. Commit them to a local branch
2. Stash them: `cd .claude && git stash`
3. Discard them: `cd .claude && git checkout .`

### If the update fails:

```bash
# Reset to a clean state
cd .claude
git reset --hard HEAD
git checkout main
git pull origin main
```

## Purpose

This command simplifies the process of keeping your .claude commands and workflows up to date with the latest improvements from the community.