#!/bin/bash

# worktree-create.sh
# Automated worktree creation script

set -e

# Function to find project root (directory containing .git)
find_project_root() {
    local current_dir="$(pwd)"
    while [[ "$current_dir" != "/" ]]; do
        if [[ -d "$current_dir/.git" ]] || [[ -f "$current_dir/.git" ]]; then
            echo "$current_dir"
            return
        fi
        current_dir="$(dirname "$current_dir")"
    done
    echo "❌ Error: Not in a git repository" >&2
    exit 1
}

# Get project root and change to it
PROJECT_ROOT=$(find_project_root)
cd "$PROJECT_ROOT"
echo "📍 Working from project root: $PROJECT_ROOT"

# Get parameters
BRANCH_TYPE=${1:-"feature"}
BRANCH_NAME=${2:-""}

if [ -z "$BRANCH_NAME" ]; then
    echo "❌ Error: Branch name is required"
    echo "Usage: ./scripts/worktree-create.sh [branch-type] <branch-name>"
    echo "Example: ./scripts/worktree-create.sh feature my-new-feature"
    exit 1
fi

echo "🔧 Creating worktree for $BRANCH_TYPE/$BRANCH_NAME..."

# Create trees directory if it doesn't exist
mkdir -p trees

# Create worktree inside trees/
git worktree add trees/${BRANCH_NAME} -b ${BRANCH_TYPE}/${BRANCH_NAME}

# Go there
cd trees/${BRANCH_NAME}

echo "🔧 Setting up worktree environment..."

# Copy environment files - Dynamic discovery approach
echo "📄 Copying environment configuration files..."

# Find and copy all .env* files from the project root, maintaining directory structure
echo "🔍 Discovering environment files..."
env_files_found=0

# Use find to locate all .env* files, excluding certain directories
find "$PROJECT_ROOT" -type f \( -name ".env*" -o -name "*.env" \) \
    ! -path "*/node_modules/*" \
    ! -path "*/.git/*" \
    ! -path "*/trees/*" \
    ! -path "*/venv/*" \
    ! -path "*/__pycache__/*" \
    ! -path "*/dist/*" \
    ! -path "*/build/*" | while read -r env_file; do

    # Get relative path from project root
    rel_path="${env_file#$PROJECT_ROOT/}"
    target_dir="$(dirname "$rel_path")"

    # Create target directory if needed
    if [ "$target_dir" != "." ]; then
        mkdir -p "$target_dir"
    fi

    # Copy the file
    cp "$env_file" "$rel_path"
    echo "✅ Copied $rel_path"
    env_files_found=$((env_files_found + 1))
done

# If no .env files found, look for .env.example files as fallback
if [ $env_files_found -eq 0 ]; then
    echo "⚠️  No .env files found, looking for .env.example templates..."
    find "$PROJECT_ROOT" -type f -name ".env.example" \
        ! -path "*/node_modules/*" \
        ! -path "*/.git/*" \
        ! -path "*/trees/*" | while read -r example_file; do

        rel_path="${example_file#$PROJECT_ROOT/}"
        target_path="${rel_path%.example}"  # Remove .example suffix
        target_dir="$(dirname "$target_path")"

        if [ "$target_dir" != "." ]; then
            mkdir -p "$target_dir"
        fi

        cp "$example_file" "$target_path"
        echo "⚠️  Copied $rel_path as $target_path - configure as needed"
    done
fi

# Copy other configuration files (credentials, secrets, local configs)
echo "🔍 Looking for additional configuration files..."
find "$PROJECT_ROOT" -maxdepth 3 -type f \( \
    -name "*credentials*.json" -o \
    -name "*secret*" -o \
    -name "*config.local*" -o \
    -name "*.key" -o \
    -name "*.pem" \) \
    ! -path "*/node_modules/*" \
    ! -path "*/.git/*" \
    ! -path "*/trees/*" \
    ! -path "*/venv/*" | while read -r config_file; do

    rel_path="${config_file#$PROJECT_ROOT/}"
    target_dir="$(dirname "$rel_path")"

    if [ "$target_dir" != "." ]; then
        mkdir -p "$target_dir"
    fi

    cp "$config_file" "$rel_path"
    echo "✅ Copied config: $rel_path"
done

# Copy frontend lib directory for auth and utilities
if [ -d "$PROJECT_ROOT/frontend/lib" ]; then
    mkdir -p frontend
    cp -r "$PROJECT_ROOT/frontend/lib" frontend/
    echo "✅ Copied frontend/lib directory"
fi

# Copy any other project-specific directories that might contain local configs
# Look for directories with .env files to identify project structure
for dir in backend frontend api server client app src; do
    if [ -d "$PROJECT_ROOT/$dir" ] && [ ! -d "$dir" ]; then
        # Check if this directory has important non-git files
        if find "$PROJECT_ROOT/$dir" -maxdepth 1 -name ".env*" -o -name "*config.local*" | grep -q .; then
            echo "📁 Found $dir directory with local configs"
        fi
    fi
done

# Initialize .claude submodule properly (don't copy content!)
if [ -d "$PROJECT_ROOT/.claude" ]; then
    echo "📦 Initializing .claude submodule in worktree..."
    
    # Check if .claude is a submodule (has a .git file, not directory)
    if [ -f "$PROJECT_ROOT/.claude/.git" ]; then
        echo "📦 Detected .claude as submodule, initializing properly..."
        # Properly initialize the submodule in this worktree
        git submodule update --init --recursive
        echo "✅ Initialized .claude submodule"
        
        # Only copy the local settings file (which should be gitignored)
        if [ -f "$PROJECT_ROOT/.claude/settings.local.json" ]; then
            cp "$PROJECT_ROOT/.claude/settings.local.json" ./.claude/settings.local.json
            echo "✅ Copied settings.local.json to worktree"
        else
            echo "⚠️  No settings.local.json found - you may need to create one from settings.local.json.example"
        fi
        
        # Ensure all scripts have execute permissions (git submodule init might not preserve them)
        echo "🔧 Ensuring script permissions are correct..."
        chmod +x ./.claude/scripts/*.sh 2>/dev/null || true
        echo "✅ Script permissions updated"
    else
        echo "📂 Detected .claude as regular directory, copying content..."
        # Regular directory copy (fallback for non-submodule setups)
        cp -r "$PROJECT_ROOT/.claude" ./.claude
        echo "✅ Copied .claude directory"
    fi
else
    echo "❌ No .claude directory found in main directory"
fi

# Copy CLAUDE.md files for proper context
if [ -f "$PROJECT_ROOT/CLAUDE.md" ]; then
    cp "$PROJECT_ROOT/CLAUDE.md" ./CLAUDE.md
    echo "✅ Copied main CLAUDE.md"
fi

if [ -f "$PROJECT_ROOT/frontend/CLAUDE.md" ]; then
    mkdir -p frontend
    cp "$PROJECT_ROOT/frontend/CLAUDE.md" frontend/CLAUDE.md
    echo "✅ Copied frontend CLAUDE.md"
fi

# Python project setup
if [ -f "requirements.txt" ]; then
    echo "🐍 Setting up Python environment..."
    
    # Detect Python command
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_CMD="python3"
    elif command -v python >/dev/null 2>&1; then
        PYTHON_CMD="python"
    else
        echo "❌ Python not found. Please install Python 3."
        exit 1
    fi
    
    # Create virtual environment
    $PYTHON_CMD -m venv venv
    source venv/bin/activate  # On Windows: venv\Scripts\activate
    
    # Install dependencies using pip module for consistency
    $PYTHON_CMD -m pip install -r requirements.txt
    echo "✅ Python dependencies installed"
fi

# Node project setup  
if [ -f "frontend/package.json" ]; then
    echo "📦 Installing frontend dependencies..."
    cd frontend
    npm install
    cd ..
    echo "✅ Frontend dependencies installed"
elif [ -f "package.json" ]; then
    echo "📦 Installing Node dependencies..."
    npm install
    echo "✅ Node dependencies installed"
fi

# Database setup - Clone main database for this worktree
echo "🗄️  Setting up worktree database..."
if command -v psql &> /dev/null; then
    # Try to detect PostgreSQL connection parameters from environment
    PG_HOST=${PGHOST:-localhost}
    PG_PORT=${PGPORT:-5432}
    PG_USER=${PGUSER:-$USER}
    
    echo "🔍 Testing PostgreSQL connection..."
    echo "   Host: $PG_HOST"
    echo "   Port: $PG_PORT"
    echo "   User: $PG_USER"
    
    if ! pg_isready -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" &> /dev/null; then
        echo "⚠️  PostgreSQL not running or not accessible"
        echo "   Troubleshooting options:"
        echo "   - Start PostgreSQL: brew services start postgresql"
        echo "   - Or try: brew services start postgresql@14"
        echo "   - Or try: brew services start postgresql@15"
        echo "   - Check if different port/host: export PGHOST=... PGPORT=... PGUSER=..."
        echo "   - Skip database setup by continuing..."
    else
        echo "✅ PostgreSQL connection successful"
        
        # Try to detect main database name from environment files
        MAIN_DB_NAME=""
        
        # Check common env files for database name
        for env_file in "$PROJECT_ROOT/.env" "$PROJECT_ROOT/backend/.env" "$PROJECT_ROOT/frontend/.env.local"; do
            if [ -f "$env_file" ]; then
                # Look for DATABASE_URL or DB_NAME patterns
                DB_FROM_URL=$(grep -E "^DATABASE_URL=" "$env_file" 2>/dev/null | head -1 | sed -E 's|.*://[^/]*/([^?]*)\??.*|\1|')
                DB_FROM_NAME=$(grep -E "^DB_NAME=" "$env_file" 2>/dev/null | head -1 | cut -d'=' -f2)
                
                if [ -n "$DB_FROM_URL" ]; then
                    MAIN_DB_NAME="$DB_FROM_URL"
                    echo "📍 Found database in $env_file: $MAIN_DB_NAME"
                    break
                elif [ -n "$DB_FROM_NAME" ]; then
                    MAIN_DB_NAME="$DB_FROM_NAME"
                    echo "📍 Found database in $env_file: $MAIN_DB_NAME"
                    break
                fi
            fi
        done
        
        # If no database found in env files, try to detect from existing databases
        if [ -z "$MAIN_DB_NAME" ]; then
            echo "🔍 No database found in env files, checking for existing databases..."
            # Try with detected user first, fallback to postgres user
            EXISTING_DBS=$(psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -lqt 2>/dev/null | cut -d \| -f 1 | grep -E "^[[:space:]]*[a-zA-Z]" | grep -v -E "^[[:space:]]*(postgres|template[01]|)" | head -1 | xargs)
            if [ -z "$EXISTING_DBS" ] && [ "$PG_USER" != "postgres" ]; then
                echo "🔄 Trying with postgres user..."
                EXISTING_DBS=$(psql -h "$PG_HOST" -p "$PG_PORT" -U postgres -lqt 2>/dev/null | cut -d \| -f 1 | grep -E "^[[:space:]]*[a-zA-Z]" | grep -v -E "^[[:space:]]*(postgres|template[01]|)" | head -1 | xargs)
            fi
            
            if [ -n "$EXISTING_DBS" ]; then
                MAIN_DB_NAME="$EXISTING_DBS"
                echo "📍 Found existing database: $MAIN_DB_NAME"
            fi
        fi
        
        if [ -n "$MAIN_DB_NAME" ]; then
            # Create branch-specific database name
            BRANCH_DB_NAME="${MAIN_DB_NAME}_${BRANCH_NAME}"
            echo "📋 Main database: $MAIN_DB_NAME"
            echo "🌿 Branch database: $BRANCH_DB_NAME"
            
            # Check if main database exists
            DB_EXISTS=false
            if psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw "$MAIN_DB_NAME"; then
                DB_EXISTS=true
            elif [ "$PG_USER" != "postgres" ] && psql -h "$PG_HOST" -p "$PG_PORT" -U postgres -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw "$MAIN_DB_NAME"; then
                DB_EXISTS=true
                PG_USER="postgres"  # Use postgres user for database operations
            fi
            
            if [ "$DB_EXISTS" = true ]; then
                echo "🔄 Cloning database $MAIN_DB_NAME to $BRANCH_DB_NAME..."
                
                # Create the new database
                if createdb -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -T "$MAIN_DB_NAME" "$BRANCH_DB_NAME" 2>/dev/null; then
                    echo "✅ Database cloned successfully"
                    
                    # Update environment files to point to the new database
                    echo "🔧 Updating environment files..."
                    for env_file in ".env" "backend/.env" "frontend/.env.local"; do
                        if [ -f "$env_file" ]; then
                            # Update DATABASE_URL
                            if grep -q "DATABASE_URL=" "$env_file"; then
                                sed -i.bak "s|/$MAIN_DB_NAME|/$BRANCH_DB_NAME|g" "$env_file"
                                echo "   ✅ Updated DATABASE_URL in $env_file"
                            fi
                            
                            # Update DB_NAME
                            if grep -q "DB_NAME=" "$env_file"; then
                                sed -i.bak "s/DB_NAME=$MAIN_DB_NAME/DB_NAME=$BRANCH_DB_NAME/g" "$env_file"
                                echo "   ✅ Updated DB_NAME in $env_file"
                            fi
                            
                            # Clean up backup files
                            rm -f "$env_file.bak"
                        fi
                    done
                    
                    # Try to run migrations if migration command exists
                    echo "🔄 Checking for migration commands..."
                    if [ -f "alembic.ini" ] || [ -f "../alembic.ini" ] || [ -f "../../alembic.ini" ]; then
                        echo "📦 Found Alembic configuration"
                        echo "   Run 'alembic upgrade head' to apply migrations to your branch database"
                    elif [ -f "package.json" ] && grep -q "migrate" package.json; then
                        echo "📦 Found npm migration script"
                        echo "   Run 'npm run migrate' to apply migrations to your branch database"
                    elif [ -f "../package.json" ] && grep -q "migrate" ../package.json; then
                        echo "📦 Found npm migration script in parent"
                        echo "   Run 'cd .. && npm run migrate' to apply migrations to your branch database"
                    else
                        echo "ℹ️  No migration scripts detected - you may need to run migrations manually"
                    fi
                    
                else
                    echo "❌ Failed to clone database - you may need to create it manually"
                    echo "   Manual command: createdb -h $PG_HOST -p $PG_PORT -U $PG_USER -T $MAIN_DB_NAME $BRANCH_DB_NAME"
                fi
            else
                echo "⚠️  Main database '$MAIN_DB_NAME' not found"
                echo "   You may need to set up the main database first"
            fi
        else
            echo "⚠️  Could not detect main database name"
            echo "   Please set up your database configuration manually"
        fi
    fi
else
    echo "⚠️  PostgreSQL client not found"
    echo "   Install with: brew install postgresql"
fi

# Run prerequisite check
echo "🔍 Running final environment check..."
if [ -f "$PROJECT_ROOT/scripts/check_prerequisites.sh" ]; then
    "$PROJECT_ROOT/scripts/check_prerequisites.sh"
else
    echo "⚠️  Prerequisites check script not found"
fi

# Show summary
echo ""
echo "✅ Created worktree: $(pwd)"
echo "🌿 Branch: ${BRANCH_TYPE}/${BRANCH_NAME}"
echo ""

# CRITICAL: Display prominent session transition instructions
WORKTREE_PATH="$(pwd)"
RELATIVE_PATH="trees/${BRANCH_NAME}"

# ANSI color codes for prominent display
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${RED}║                                                                              ║${RESET}"
echo -e "${RED}║${WHITE}${BOLD}                    ⚠️  IMPORTANT: SWITCH TO WORKTREE NOW! ⚠️                   ${RESET}${RED}║${RESET}"
echo -e "${RED}║                                                                              ║${RESET}"
echo -e "${RED}║${YELLOW}  Your worktree is ready, but you MUST switch to it for proper isolation!   ${RESET}${RED}║${RESET}"
echo -e "${RED}║                                                                              ║${RESET}"
echo -e "${RED}║${WHITE}${BOLD}  REQUIRED NEXT STEPS:                                                       ${RESET}${RED}║${RESET}"
echo -e "${RED}║                                                                              ║${RESET}"
echo -e "${RED}║${GREEN}  1. END this Claude session (Ctrl+C or type 'exit')                        ${RESET}${RED}║${RESET}"
echo -e "${RED}║                                                                              ║${RESET}"
echo -e "${RED}║${GREEN}  2. Change to the worktree directory:                                       ${RESET}${RED}║${RESET}"
echo -e "${RED}║${CYAN}     cd ${RELATIVE_PATH}                                                    ${RESET}${RED}║${RESET}"
echo -e "${RED}║                                                                              ║${RESET}"
echo -e "${RED}║${GREEN}  3. Start a NEW Claude session:                                             ${RESET}${RED}║${RESET}"
echo -e "${RED}║${CYAN}     claude code                                                             ${RESET}${RED}║${RESET}"
echo -e "${RED}║                                                                              ║${RESET}"
echo -e "${RED}║${MAGENTA}  WHY THIS MATTERS:                                                          ${RESET}${RED}║${RESET}"
echo -e "${RED}║${WHITE}  • Ensures all commands run in the correct worktree                        ${RESET}${RED}║${RESET}"
echo -e "${RED}║${WHITE}  • Prevents accidentally modifying wrong files                             ${RESET}${RED}║${RESET}"
echo -e "${RED}║${WHITE}  • Uses the isolated database and environment                              ${RESET}${RED}║${RESET}"
echo -e "${RED}║                                                                              ║${RESET}"
echo -e "${RED}║${YELLOW}${BOLD}  DO NOT CONTINUE WORKING IN THIS SESSION! SWITCH NOW!                      ${RESET}${RED}║${RESET}"
echo -e "${RED}║                                                                              ║${RESET}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${BOLD}${WHITE}Copy this command: ${CYAN}cd ${RELATIVE_PATH}${RESET}"
echo ""

# Attempt Warp Terminal automation if available
if [ "$TERM_PROGRAM" = "WarpTerminal" ]; then
    echo -e "${CYAN}🚀 Attempting to open new Warp tab in worktree directory...${RESET}"
    
    # Try multiple methods to open new Warp tab
    TAB_CREATED=false
    TAB_TITLE="${BRANCH_NAME} (worktree)"
    
    # Method 1: Try warp-cli if available
    if command -v warp-cli >/dev/null 2>&1; then
        if warp-cli open "$WORKTREE_PATH" --new-tab --title "$TAB_TITLE" >/dev/null 2>&1; then
            TAB_CREATED=true
            echo -e "${GREEN}✅ New Warp tab opened: ${TAB_TITLE}${RESET}"
        fi
    fi
    
    # Method 2: Try AppleScript if warp-cli failed
    if [ "$TAB_CREATED" = false ]; then
        if osascript -e "tell application \"Warp\"" \
                     -e "tell current window" \
                     -e "set newTab to create tab" \
                     -e "tell newTab" \
                     -e "set current directory to \"$WORKTREE_PATH\"" \
                     -e "set title to \"$TAB_TITLE\"" \
                     -e "end tell" \
                     -e "end tell" \
                     -e "end tell" >/dev/null 2>&1; then
            TAB_CREATED=true
            echo -e "${GREEN}✅ New Warp tab opened: ${TAB_TITLE}${RESET}"
        fi
    fi
    
    # Method 3: Try simple AppleScript tab creation
    if [ "$TAB_CREATED" = false ]; then
        if osascript -e "tell application \"Warp\" to tell front window to set newTab to create tab" >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠️  New Warp tab created (you'll need to cd manually)${RESET}"
            TAB_CREATED=true
        fi
    fi
    
    if [ "$TAB_CREATED" = true ]; then
        echo ""
        echo -e "${GREEN}${BOLD}🎉 Automation Success!${RESET}"
        echo -e "${WHITE}• New Warp tab opened${RESET}"
        echo -e "${WHITE}• Switch to the new tab and start: ${CYAN}claude code${RESET}"
        echo ""
        echo -e "${YELLOW}If the new tab didn't navigate automatically, run: ${CYAN}cd ${RELATIVE_PATH}${RESET}"
    else
        echo -e "${YELLOW}⚠️  Warp automation unavailable - follow manual instructions above${RESET}"
    fi
    
    echo ""
else
    echo -e "${BLUE}ℹ️  Non-Warp terminal detected - follow the manual instructions above${RESET}"
fi

# Send desktop notification using existing notification system
NOTIFICATION_SCRIPT="$PROJECT_ROOT/.claude/scripts/notify-agent-complete.sh"
if [ -f "$NOTIFICATION_SCRIPT" ]; then
    # Use the existing notification system to alert the user
    NOTIFICATION_MESSAGE="Worktree ready! Switch to: cd trees/${BRANCH_NAME} then start claude code"
    "$NOTIFICATION_SCRIPT" "attention" "$NOTIFICATION_MESSAGE" "worktree-${BRANCH_NAME}" >/dev/null 2>&1 &
    echo -e "${CYAN}🔔 Desktop notification sent${RESET}"
else
    echo -e "${YELLOW}⚠️  Notification script not found - skipping desktop alert${RESET}"
fi

echo ""
echo -e "${GREEN}${BOLD}🌿 Worktree creation complete!${RESET}"
echo -e "${WHITE}Remember: ${BOLD}Switch sessions to work in isolation!${RESET}"