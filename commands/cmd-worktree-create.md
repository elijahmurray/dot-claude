# worktree-start.md

Create a new Git worktree for parallel feature development.

## Variables
- BRANCH_TYPE: The type (feature, bugfix, hotfix)
- BRANCH_NAME: The name of your feature

## Instructions

1. Create the worktree:
```bash
# Create trees directory if it doesn't exist
mkdir -p trees

# Create worktree inside trees/
git worktree add trees/${BRANCH_NAME} -b ${BRANCH_TYPE}/${BRANCH_NAME}

# Go there
cd trees/${BRANCH_NAME}
```

2. Set up the environment:
```bash
echo "🔧 Setting up worktree environment..."

# Copy environment files
echo "📄 Copying environment configuration..."
if [ -f "../../.env.example" ]; then
    if [ -f "../../.env" ]; then
        cp ../../.env .env
        echo "✅ Copied backend .env"
    else
        cp ../../.env.example .env
        echo "⚠️  Copied .env.example - you'll need to configure API keys"
    fi
else
    echo "❌ No .env.example found in main directory"
fi

# Copy frontend environment files
if [ -f "../../frontend/.env.example" ]; then
    mkdir -p frontend
    if [ -f "../../frontend/.env.local" ]; then
        cp ../../frontend/.env.local frontend/.env.local
        echo "✅ Copied frontend .env.local"
    else
        cp ../../frontend/.env.example frontend/.env.local
        echo "⚠️  Copied frontend/.env.example - you'll need to configure OAuth keys"
    fi
else
    echo "❌ No frontend/.env.example found in main directory"
fi

# Copy frontend lib directory for auth and utilities
if [ -d "../../frontend/lib" ]; then
    mkdir -p frontend
    cp -r ../../frontend/lib frontend/
    echo "✅ Copied frontend/lib directory"
else
    echo "❌ No frontend/lib directory found"
fi

# Copy Google credentials if needed
if [ -f "../../credentials.json" ]; then
    cp ../../credentials.json ./credentials.json
    echo "✅ Copied Google Calendar credentials"
fi

# Copy .claude directory with all settings and commands
if [ -d "../../.claude" ]; then
    echo "📂 Copying .claude directory..."
    
    # Check if .claude is a submodule (has a .git file, not directory)
    if [ -f "../../.claude/.git" ]; then
        echo "📦 Detected .claude as submodule, copying content only..."
        # Use rsync to copy everything except .git
        rsync -av --exclude='.git' ../../.claude/ ./.claude/
    else
        # Regular directory copy
        cp -r ../../.claude ./.claude
    fi
    
    echo "✅ Copied .claude directory with all settings and commands"
    
    # Check if settings.local.json exists
    if [ -f "./.claude/settings.local.json" ]; then
        echo "✅ Found and copied settings.local.json"
    else
        echo "⚠️  No settings.local.json found - you may need to create one from settings.local.json.example"
    fi
else
    echo "❌ No .claude directory found in main directory"
fi

# Copy CLAUDE.md files for proper context
if [ -f "../../CLAUDE.md" ]; then
    cp ../../CLAUDE.md ./CLAUDE.md
    echo "✅ Copied main CLAUDE.md"
fi

if [ -f "../../frontend/CLAUDE.md" ]; then
    mkdir -p frontend
    cp ../../frontend/CLAUDE.md frontend/CLAUDE.md
    echo "✅ Copied frontend CLAUDE.md"
fi

# Python project setup
if [ -f "requirements.txt" ]; then
    echo "🐍 Setting up Python environment..."
    python -m venv venv
    source venv/bin/activate  # On Windows: venv\Scripts\activate
    pip install -r requirements.txt
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

# Database setup check
echo "🗄️  Checking database setup..."
if command -v psql &> /dev/null; then
    if ! pg_isready -h localhost -p 5432 &> /dev/null; then
        echo "⚠️  PostgreSQL not running - you may need to start it"
        echo "   Run: brew services start postgresql@14"
    elif ! PGPASSWORD=postgres psql -U postgres -h localhost -p 5432 -lqt | cut -d \| -f 1 | grep -qw evie_crewai_db; then
        echo "⚠️  Database 'evie_crewai_db' not found"
        echo "   Run: ../../scripts/setup_database.sh"
    else
        echo "✅ Database connection looks good"
    fi
else
    echo "⚠️  PostgreSQL client not found"
fi

# Run prerequisite check
echo "🔍 Running final environment check..."
if [ -f "../../scripts/check_prerequisites.sh" ]; then
    ../../scripts/check_prerequisites.sh
else
    echo "⚠️  Prerequisites check script not found"
fi
```

3. Show summary:
```bash
echo "✅ Created worktree: $(pwd)"
echo "🌿 Branch: ${BRANCH_TYPE}/${BRANCH_NAME}"
echo ""
echo "You can now work on this feature without affecting other work!"
```
Make sure to copy over the env files into the work tree. There's one for the top level directory and then also one for the backend folder. Also, ALWAYS make sure to create the work tree off of the top level directory. Not nested within an existing work tree.

## Next Steps

After creating a worktree:

1. **Start Development**:
   - Run `/cmd-issue-start` if you have an issue to implement
   - Or begin writing tests following TDD approach

2. **During Development**:
   - Write tests first (RED phase)
   - Implement features (GREEN phase)
   - Refactor and optimize (REFACTOR phase)
   - Commit regularly with descriptive messages

3. **When Complete**:
   - Run `/cmd-feature-document` to create spec and update documentation
   - Merge your changes (PR or local merge)
   - Run `/cmd-issue-complete` to clean everything up

4. **Remember**:
   - This worktree is isolated from other branches
   - You can switch between worktrees without stashing
   - Each worktree maintains its own environment 
