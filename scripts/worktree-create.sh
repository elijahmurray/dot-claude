#!/bin/bash

# worktree-create.sh
# Automated worktree creation script with optional setup components
# Usage: ./worktree-create.sh <branch-type> <branch-name> [--frontend] [--backend] [--db] [--full]

set -e

# Colors for output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
BOLD='\033[1m'
RESET='\033[0m'

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
    echo "Error: Not in a git repository" >&2
    exit 1
}

# Parse arguments
BRANCH_TYPE=""
BRANCH_NAME=""
SETUP_FRONTEND=false
SETUP_BACKEND=false
SETUP_DB=false
SETUP_WORKERS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --frontend)
            SETUP_FRONTEND=true
            shift
            ;;
        --backend)
            SETUP_BACKEND=true
            shift
            ;;
        --db)
            SETUP_DB=true
            shift
            ;;
        --workers)
            SETUP_WORKERS=true
            shift
            ;;
        --full)
            SETUP_FRONTEND=true
            SETUP_BACKEND=true
            SETUP_DB=true
            shift
            ;;
        --frontend-only)
            SETUP_FRONTEND=true
            SETUP_BACKEND=false
            SETUP_DB=false
            shift
            ;;
        --backend-only)
            SETUP_BACKEND=true
            SETUP_FRONTEND=false
            SETUP_DB=false
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            if [ -z "$BRANCH_TYPE" ]; then
                BRANCH_TYPE="$1"
            elif [ -z "$BRANCH_NAME" ]; then
                BRANCH_NAME="$1"
            fi
            shift
            ;;
    esac
done

# Default to feature if not specified
BRANCH_TYPE=${BRANCH_TYPE:-"feature"}

if [ -z "$BRANCH_NAME" ]; then
    echo "Error: Branch name is required"
    echo "Usage: ./worktree-create.sh [branch-type] <branch-name> [options]"
    echo ""
    echo "Options:"
    echo "  --full          Set up frontend + backend + database (default if no flags)"
    echo "  --frontend      Set up frontend (npm install)"
    echo "  --backend       Set up backend (Python venv + pip)"
    echo "  --db            Clone database for isolation"
    echo "  --workers       Check Redis and provide Celery worker commands"
    echo "  --frontend-only Frontend only, skip backend/db"
    echo "  --backend-only  Backend only, skip frontend/db"
    echo ""
    echo "Examples:"
    echo "  ./worktree-create.sh feature my-feature --full"
    echo "  ./worktree-create.sh feature ui-update --frontend-only"
    echo "  ./worktree-create.sh bugfix api-fix --backend --db"
    echo "  ./worktree-create.sh feature task-queue --backend --workers"
    exit 1
fi

# If no setup flags provided, default to full setup
if [ "$SETUP_FRONTEND" = false ] && [ "$SETUP_BACKEND" = false ] && [ "$SETUP_DB" = false ]; then
    SETUP_FRONTEND=true
    SETUP_BACKEND=true
    SETUP_DB=true
fi

# Get project root and change to it
PROJECT_ROOT=$(find_project_root)
cd "$PROJECT_ROOT"
echo -e "${BLUE}Working from project root: $PROJECT_ROOT${RESET}"

echo -e "${CYAN}Creating worktree for $BRANCH_TYPE/$BRANCH_NAME...${RESET}"
echo -e "  Frontend: $([ "$SETUP_FRONTEND" = true ] && echo "yes" || echo "no")"
echo -e "  Backend:  $([ "$SETUP_BACKEND" = true ] && echo "yes" || echo "no")"
echo -e "  Database: $([ "$SETUP_DB" = true ] && echo "yes" || echo "no")"
echo -e "  Workers:  $([ "$SETUP_WORKERS" = true ] && echo "yes" || echo "no")"
echo ""

# Create trees directory if it doesn't exist
mkdir -p trees

# Create worktree
git worktree add "trees/${BRANCH_NAME}" -b "${BRANCH_TYPE}/${BRANCH_NAME}"

# Change to worktree
cd "trees/${BRANCH_NAME}"
WORKTREE_PATH="$(pwd)"

echo -e "${GREEN}Worktree created at: $WORKTREE_PATH${RESET}"

# ============================================================================
# PHASE 1: Copy environment files (always runs, fast)
# ============================================================================
echo -e "${CYAN}Copying environment files...${RESET}"

# Find and copy all .env* files
find "$PROJECT_ROOT" -maxdepth 3 -type f \( -name ".env*" -o -name "*.env" \) \
    ! -path "*/node_modules/*" \
    ! -path "*/.git/*" \
    ! -path "*/trees/*" \
    ! -path "*/venv/*" \
    ! -path "*/__pycache__/*" 2>/dev/null | while read -r env_file; do
    rel_path="${env_file#$PROJECT_ROOT/}"
    target_dir="$(dirname "$rel_path")"
    [ "$target_dir" != "." ] && mkdir -p "$target_dir"
    cp "$env_file" "$rel_path" 2>/dev/null && echo -e "  ${GREEN}Copied $rel_path${RESET}"
done

# Copy credentials and config files
find "$PROJECT_ROOT" -maxdepth 3 -type f \( \
    -name "*credentials*.json" -o \
    -name "*config.local*" \) \
    ! -path "*/node_modules/*" \
    ! -path "*/.git/*" \
    ! -path "*/trees/*" 2>/dev/null | while read -r config_file; do
    rel_path="${config_file#$PROJECT_ROOT/}"
    target_dir="$(dirname "$rel_path")"
    [ "$target_dir" != "." ] && mkdir -p "$target_dir"
    cp "$config_file" "$rel_path" 2>/dev/null && echo -e "  ${GREEN}Copied $rel_path${RESET}"
done

# ============================================================================
# PHASE 2: Initialize .claude submodule (always runs, medium speed)
# ============================================================================
if [ -d "$PROJECT_ROOT/.claude" ]; then
    echo -e "${CYAN}Setting up .claude directory...${RESET}"

    if [ -f "$PROJECT_ROOT/.claude/.git" ]; then
        # It's a submodule
        git submodule update --init --recursive 2>/dev/null
        if [ -f "$PROJECT_ROOT/.claude/settings.local.json" ]; then
            cp "$PROJECT_ROOT/.claude/settings.local.json" ./.claude/settings.local.json
        fi
        chmod +x ./.claude/scripts/*.sh 2>/dev/null || true
        echo -e "  ${GREEN}Initialized .claude submodule${RESET}"
    else
        # Regular directory
        cp -r "$PROJECT_ROOT/.claude" ./.claude
        echo -e "  ${GREEN}Copied .claude directory${RESET}"
    fi
fi

# Copy CLAUDE.md files
[ -f "$PROJECT_ROOT/CLAUDE.md" ] && cp "$PROJECT_ROOT/CLAUDE.md" ./CLAUDE.md

# ============================================================================
# PHASE 3: Parallel setup of frontend, backend, and database
# ============================================================================
echo -e "${CYAN}Setting up development environment...${RESET}"

# Track background jobs
PIDS=()

# --- FRONTEND SETUP (background) ---
if [ "$SETUP_FRONTEND" = true ]; then
    (
        # Detect frontend location
        if [ -f "frontend/package.json" ]; then
            cd frontend
            echo -e "  ${BLUE}[frontend] Installing npm dependencies...${RESET}"
            npm install --prefer-offline --no-audit 2>/dev/null
            echo -e "  ${GREEN}[frontend] Done${RESET}"
        elif [ -f "client/package.json" ]; then
            cd client
            echo -e "  ${BLUE}[frontend] Installing npm dependencies...${RESET}"
            npm install --prefer-offline --no-audit 2>/dev/null
            echo -e "  ${GREEN}[frontend] Done${RESET}"
        elif [ -f "package.json" ] && [ ! -f "requirements.txt" ]; then
            echo -e "  ${BLUE}[frontend] Installing npm dependencies...${RESET}"
            npm install --prefer-offline --no-audit 2>/dev/null
            echo -e "  ${GREEN}[frontend] Done${RESET}"
        else
            echo -e "  ${YELLOW}[frontend] No package.json found, skipping${RESET}"
        fi
    ) &
    PIDS+=($!)
fi

# --- BACKEND SETUP (background) ---
if [ "$SETUP_BACKEND" = true ]; then
    (
        # Detect the ONE Python directory (priority order)
        PYTHON_DIR=""
        REQUIREMENTS_FILE=""

        for dir in "backend" "api" "server" "app" "src" "."; do
            if [ -f "$dir/requirements.txt" ]; then
                PYTHON_DIR="$dir"
                REQUIREMENTS_FILE="$dir/requirements.txt"
                break
            fi
        done

        if [ -n "$PYTHON_DIR" ]; then
            echo -e "  ${BLUE}[backend] Setting up Python in $PYTHON_DIR...${RESET}"

            # Find Python
            PYTHON_CMD=""
            command -v python3 >/dev/null 2>&1 && PYTHON_CMD="python3"
            [ -z "$PYTHON_CMD" ] && command -v python >/dev/null 2>&1 && PYTHON_CMD="python"

            if [ -n "$PYTHON_CMD" ]; then
                cd "$PYTHON_DIR"
                $PYTHON_CMD -m venv venv 2>/dev/null
                source venv/bin/activate 2>/dev/null
                $PYTHON_CMD -m pip install -q -r requirements.txt 2>/dev/null
                deactivate 2>/dev/null || true
                echo -e "  ${GREEN}[backend] Python environment ready in $PYTHON_DIR/venv${RESET}"
            else
                echo -e "  ${YELLOW}[backend] Python not found, skipping venv creation${RESET}"
            fi
        else
            echo -e "  ${YELLOW}[backend] No requirements.txt found, skipping${RESET}"
        fi
    ) &
    PIDS+=($!)
fi

# --- DATABASE SETUP (background) ---
if [ "$SETUP_DB" = true ]; then
    (
        if ! command -v psql &> /dev/null; then
            echo -e "  ${YELLOW}[database] PostgreSQL client not found, skipping${RESET}"
            exit 0
        fi

        PG_HOST=${PGHOST:-localhost}
        PG_PORT=${PGPORT:-5432}
        PG_USER=${PGUSER:-$USER}

        if ! pg_isready -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" &> /dev/null; then
            echo -e "  ${YELLOW}[database] PostgreSQL not running, skipping${RESET}"
            exit 0
        fi

        # Try to detect main database name from environment files
        MAIN_DB_NAME=""
        for env_file in ".env" "backend/.env" "../.env"; do
            if [ -f "$env_file" ]; then
                DB_FROM_URL=$(grep -E "^DATABASE_URL=" "$env_file" 2>/dev/null | head -1 | sed -E 's|.*://[^/]*/([^?]*)\??.*|\1|')
                DB_FROM_NAME=$(grep -E "^DB_NAME=" "$env_file" 2>/dev/null | head -1 | cut -d'=' -f2)
                [ -n "$DB_FROM_URL" ] && MAIN_DB_NAME="$DB_FROM_URL" && break
                [ -n "$DB_FROM_NAME" ] && MAIN_DB_NAME="$DB_FROM_NAME" && break
            fi
        done

        if [ -z "$MAIN_DB_NAME" ]; then
            echo -e "  ${YELLOW}[database] Could not detect database name, skipping${RESET}"
            exit 0
        fi

        BRANCH_DB_NAME="${MAIN_DB_NAME}_${BRANCH_NAME}"
        echo -e "  ${BLUE}[database] Cloning $MAIN_DB_NAME to $BRANCH_DB_NAME...${RESET}"

        if createdb -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -T "$MAIN_DB_NAME" "$BRANCH_DB_NAME" 2>/dev/null; then
            # Update environment files
            for env_file in ".env" "backend/.env"; do
                if [ -f "$env_file" ]; then
                    sed -i.bak "s|/$MAIN_DB_NAME|/$BRANCH_DB_NAME|g" "$env_file" 2>/dev/null
                    sed -i.bak "s/DB_NAME=$MAIN_DB_NAME/DB_NAME=$BRANCH_DB_NAME/g" "$env_file" 2>/dev/null
                    rm -f "$env_file.bak"
                fi
            done
            echo -e "  ${GREEN}[database] Cloned and configured${RESET}"
        else
            echo -e "  ${YELLOW}[database] Clone failed (may already exist)${RESET}"
        fi
    ) &
    PIDS+=($!)
fi

# Wait for all background jobs
echo -e "${CYAN}Waiting for setup to complete...${RESET}"
for pid in "${PIDS[@]}"; do
    wait $pid 2>/dev/null || true
done

# --- WORKER SETUP (after other setup completes) ---
WORKER_COMMANDS=""
if [ "$SETUP_WORKERS" = true ]; then
    echo -e "${CYAN}Checking worker requirements...${RESET}"

    # Detect if project uses Celery/Redis
    HAS_CELERY=false
    CELERY_APP=""

    # Check for celery in requirements
    for req_file in "requirements.txt" "backend/requirements.txt" "api/requirements.txt"; do
        if [ -f "$req_file" ] && grep -qi "celery" "$req_file" 2>/dev/null; then
            HAS_CELERY=true
            break
        fi
    done

    # Find celery app location
    if [ "$HAS_CELERY" = true ]; then
        # Common celery app locations
        for celery_file in "celery.py" "backend/celery.py" "app/celery.py" "*/celery.py"; do
            found_file=$(find . -name "celery.py" -not -path "*/venv/*" -not -path "*/.git/*" 2>/dev/null | head -1)
            if [ -n "$found_file" ]; then
                CELERY_DIR=$(dirname "$found_file")
                break
            fi
        done

        # Check if Redis is running
        REDIS_RUNNING=false
        if command -v redis-cli &> /dev/null; then
            if redis-cli ping &> /dev/null; then
                REDIS_RUNNING=true
                echo -e "  ${GREEN}[workers] Redis is running${RESET}"
            else
                echo -e "  ${YELLOW}[workers] Redis not running - start with: brew services start redis${RESET}"
            fi
        else
            # Check if CELERY_BROKER_URL uses something other than Redis
            BROKER_URL=$(grep -E "^CELERY_BROKER_URL=" .env 2>/dev/null | head -1 | cut -d'=' -f2)
            if [ -n "$BROKER_URL" ]; then
                echo -e "  ${BLUE}[workers] Broker configured: $BROKER_URL${RESET}"
            else
                echo -e "  ${YELLOW}[workers] redis-cli not found, can't verify Redis status${RESET}"
            fi
        fi

        # Determine the celery command
        if [ -n "$CELERY_DIR" ] && [ "$CELERY_DIR" != "." ]; then
            WORKER_COMMANDS="cd $CELERY_DIR && celery -A celery worker --loglevel=info"
        else
            # Try to detect app name from celery.py or common patterns
            WORKER_COMMANDS="celery -A app worker --loglevel=info"
        fi

        echo -e "  ${GREEN}[workers] Celery detected${RESET}"
    else
        echo -e "  ${YELLOW}[workers] No Celery found in requirements, skipping${RESET}"
    fi
fi

# ============================================================================
# PHASE 4: Summary and next steps
# ============================================================================
RELATIVE_PATH="trees/${BRANCH_NAME}"

echo ""
echo -e "${GREEN}${BOLD}Worktree ready!${RESET}"
echo -e "${CYAN}Location:${RESET} $WORKTREE_PATH"
echo -e "${CYAN}Branch:${RESET}   ${BRANCH_TYPE}/${BRANCH_NAME}"
echo ""
echo -e "${YELLOW}${BOLD}Next steps:${RESET}"
echo -e "  1. ${CYAN}cd ${RELATIVE_PATH}${RESET}"
echo -e "  2. Start a new Claude session: ${CYAN}claude${RESET}"

# Show worker commands if configured
if [ -n "$WORKER_COMMANDS" ]; then
    echo ""
    echo -e "${YELLOW}${BOLD}To start Celery workers:${RESET}"
    echo -e "  ${CYAN}$WORKER_COMMANDS${RESET}"
    echo -e "  ${CYAN}celery -A app beat --loglevel=info${RESET}  # For scheduled tasks"
fi
echo ""

# Copy command to clipboard if pbcopy available
if command -v pbcopy &> /dev/null; then
    echo "cd ${RELATIVE_PATH}" | pbcopy
    echo -e "${GREEN}Command copied to clipboard${RESET}"
fi

# Desktop notification
NOTIFICATION_SCRIPT="$PROJECT_ROOT/.claude/scripts/notify-agent-complete.sh"
if [ -f "$NOTIFICATION_SCRIPT" ]; then
    "$NOTIFICATION_SCRIPT" "main" "Worktree ready: $BRANCH_NAME" 2>/dev/null &
fi
