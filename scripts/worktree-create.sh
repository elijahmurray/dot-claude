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

# Copy environment files
echo "📄 Copying environment configuration..."
if [ -f "$PROJECT_ROOT/.env.example" ]; then
    if [ -f "$PROJECT_ROOT/.env" ]; then
        cp "$PROJECT_ROOT/.env" .env
        echo "✅ Copied backend .env"
    else
        cp "$PROJECT_ROOT/.env.example" .env
        echo "⚠️  Copied .env.example - you'll need to configure API keys"
    fi
else
    echo "❌ No .env.example found in main directory"
fi

# Copy frontend environment files
if [ -f "$PROJECT_ROOT/frontend/.env.example" ]; then
    mkdir -p frontend
    if [ -f "$PROJECT_ROOT/frontend/.env.local" ]; then
        cp "$PROJECT_ROOT/frontend/.env.local" frontend/.env.local
        echo "✅ Copied frontend .env.local"
    else
        cp "$PROJECT_ROOT/frontend/.env.example" frontend/.env.local
        echo "⚠️  Copied frontend/.env.example - you'll need to configure OAuth keys"
    fi
else
    echo "❌ No frontend/.env.example found in main directory"
fi

# Copy frontend lib directory for auth and utilities
if [ -d "$PROJECT_ROOT/frontend/lib" ]; then
    mkdir -p frontend
    cp -r "$PROJECT_ROOT/frontend/lib" frontend/
    echo "✅ Copied frontend/lib directory"
else
    echo "❌ No frontend/lib directory found"
fi

# Copy Google credentials if needed
if [ -f "$PROJECT_ROOT/credentials.json" ]; then
    cp "$PROJECT_ROOT/credentials.json" ./credentials.json
    echo "✅ Copied Google Calendar credentials"
fi

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
echo "You can now work on this feature without affecting other work!"