#!/bin/bash

# setup-ticket-system.sh - Interactive ticket management system setup
# This script configures the ticket management system in CLAUDE.md

set -e

echo "🎫 Ticket Management System Setup"
echo ""
echo "Please choose your ticket management system:"
echo ""
echo "1. GitHub Issues (most common for open source)"
echo "2. Linear (popular for product teams)"
echo "3. Jira (enterprise/traditional)"
echo "4. GitLab Issues (if using GitLab)"
echo "5. Other (manual configuration)"
echo ""

# Get user choice
read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        SYSTEM="GitHub Issues"
        CLI_TOOL="gh"
        INSTALL_CMD="brew install gh"
        AUTH_CMD="gh auth login"
        ;;
    2)
        SYSTEM="Linear"
        CLI_TOOL="linear"
        INSTALL_CMD="npm install -g @linear/cli"
        AUTH_CMD="linear auth"
        ;;
    3)
        SYSTEM="Jira"
        CLI_TOOL="jira"
        INSTALL_CMD="go install github.com/go-jira/jira/cmd/jira@latest"
        AUTH_CMD="jira login"
        ;;
    4)
        SYSTEM="GitLab Issues"
        CLI_TOOL="glab"
        INSTALL_CMD="brew install glab"
        AUTH_CMD="glab auth login"
        ;;
    5)
        echo "Manual configuration selected. Please edit CLAUDE.md manually."
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "Selected: $SYSTEM"
echo ""

# Check if CLAUDE.md exists
if [ ! -f "CLAUDE.md" ]; then
    echo "❌ CLAUDE.md not found in current directory"
    echo "Please run this script from the project root"
    exit 1
fi

# Create backup
cp CLAUDE.md CLAUDE.md.backup
echo "📄 Created backup: CLAUDE.md.backup"

# Update CLAUDE.md based on selection
case $choice in
    1) # GitHub Issues
        # Remove the selection instruction and keep only GitHub section
        sed -i '' '/\*\*CONFIGURE THIS SECTION DURING PROJECT SETUP\*\*/d' CLAUDE.md
        sed -i '' 's/This project uses: \[SELECT ONE AND REMOVE OTHERS\]/This project uses: **GitHub Issues**/' CLAUDE.md
        # Remove other sections (Linear, Jira, GitLab)
        sed -i '' '/### Linear/,/### GitLab Issues/d' CLAUDE.md
        sed -i '' '/### GitLab Issues/,/^$/d' CLAUDE.md
        ;;
    2) # Linear
        sed -i '' '/\*\*CONFIGURE THIS SECTION DURING PROJECT SETUP\*\*/d' CLAUDE.md
        sed -i '' 's/This project uses: \[SELECT ONE AND REMOVE OTHERS\]/This project uses: **Linear**/' CLAUDE.md
        # Remove other sections
        sed -i '' '/### GitHub Issues/,/### Linear/d' CLAUDE.md
        sed -i '' '/### Jira/,/^$/d' CLAUDE.md
        ;;
    3) # Jira
        sed -i '' '/\*\*CONFIGURE THIS SECTION DURING PROJECT SETUP\*\*/d' CLAUDE.md
        sed -i '' 's/This project uses: \[SELECT ONE AND REMOVE OTHERS\]/This project uses: **Jira**/' CLAUDE.md
        # Remove other sections
        sed -i '' '/### GitHub Issues/,/### Jira/d' CLAUDE.md
        sed -i '' '/### GitLab Issues/,/^$/d' CLAUDE.md
        ;;
    4) # GitLab Issues
        sed -i '' '/\*\*CONFIGURE THIS SECTION DURING PROJECT SETUP\*\*/d' CLAUDE.md
        sed -i '' 's/This project uses: \[SELECT ONE AND REMOVE OTHERS\]/This project uses: **GitLab Issues**/' CLAUDE.md
        # Remove other sections
        sed -i '' '/### GitHub Issues/,/### GitLab Issues/d' CLAUDE.md
        ;;
esac

echo "✅ CLAUDE.md updated with $SYSTEM configuration"

# Check CLI installation
echo ""
echo "🔍 Checking CLI tool installation..."

if ! command -v "$CLI_TOOL" &> /dev/null; then
    echo "⚠️  $CLI_TOOL CLI not found."
    echo "Install with: $INSTALL_CMD"
    echo "Then authenticate with: $AUTH_CMD"
else
    echo "✅ $CLI_TOOL CLI is installed"
    echo "Make sure you're authenticated with: $AUTH_CMD"
fi

echo ""
echo "✅ Ticket management system configured!"
echo ""
echo "The following commands will now use $SYSTEM:"
echo "- /cmd-issue-create - Creates tickets using $CLI_TOOL"
echo "- /cmd-pr-create - References tickets in PR/MR descriptions"
echo "- /cmd-issue-start - Adapts to your ticket linking format"
echo "- /cmd-issue-complete - Uses your ticket management workflow"
echo ""
echo "Next steps:"
echo "1. Install and authenticate with $CLI_TOOL if needed"
echo "2. Test ticket creation with /cmd-issue-create"
echo "3. Start working on your first ticket with /cmd-issue-start"