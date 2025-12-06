# make_ingest.py

import sys
import subprocess


def generate_digest_cli(source, output_file="digest.txt", exclude_exts=None):
    cmd = ["gitingest", source, "-o", output_file]

    # Comprehensive exclusions for common non-essential files and directories
    exclusions = [
        # Python-related
        "__pycache__",
        "__pycache__/*",
        "*/__pycache__",
        "*/__pycache__/*",
        "**/__pycache__/**",
        "*.pyc",
        "*.pyo",
        "*.egg-info",
        ".pytest_cache",
        ".pytest_cache/*",
        "venv",
        "venv/*",
        ".venv",
        ".venv/*",
        "env",
        ".env",
        ".env.local",
        ".env.example",
        ".env.local.example",
        # Version control
        ".git",
        ".git/*",
        ".gitignore",
        # IDE and editor files
        ".vscode",
        ".vscode/*",
        ".idea",
        ".idea/*",
        ".cursor",
        ".cursor/*",
        "*/.cursor",
        "*/.cursor/*",
        "**/.cursor/**",
        "*.swp",
        "*.swo",
        # System files
        ".DS_Store",
        "Thumbs.db",
        "desktop.ini",
        # Next.js build and cache files
        ".next",
        ".next/*",
        "frontend/.next",
        "frontend/.next/*",
        ".nuxt",
        ".nuxt/*",
        "out",
        "out/*",
        ".cache",
        ".parcel-cache",
        ".turbo",
        ".swc",
        ".tsbuildinfo",
        "*.tsbuildinfo",
        # Node.js dependencies and lock files
        "node_modules",
        "node_modules/*",
        "*/node_modules",
        "*/node_modules/*",
        "**/node_modules/**",
        "frontend/node_modules",
        "frontend/node_modules/*",
        "package-lock.json",
        "*/package-lock.json",
        "yarn.lock",
        "*/yarn.lock",
        "pnpm-lock.yaml",
        "*/pnpm-lock.yaml",
        "bun.lockb",
        "*/bun.lockb",
        "npm-debug.log",
        "yarn-error.log",
        "npm-debug.log*",
        "yarn-debug.log*",
        "lerna-debug.log*",
        # Build and distribution directories
        "build",
        "build/*",
        "dist",
        "dist/*",
        "coverage",
        "coverage/*",
        ".nyc_output",
        ".vercel",
        ".netlify",
        "storybook-static",
        ".rpt2_cache",
        ".rollup.cache",
        ".stylelintcache",
        ".eslintcache",
        ".angular",
        ".angular/*",
        ".svelte-kit",
        ".svelte-kit/*",
        ".output",
        ".nuxt",
        ".vuepress",
        ".serverless",
        ".fusebox",
        # Database files
        "*.sqlite3",
        "*.sqlite",
        "*.db",
        # Binary and data files
        "*.bin",
        "*.mmdb",
        "GeoLite2-Country.mmdb",
        "app/GeoLite2-Country.mmdb",
        # Additional package manager lock files
        "composer.lock",
        "Pipfile.lock",
        "poetry.lock",
        "Gemfile.lock",
        "go.sum",
        "Cargo.lock",
        # Logs and temporary files
        "*.log",
        "*.tmp",
        "*.temp",
        "*.pid",
        "logs",
        "logs/*",
        # Documentation and media files (keeping essential ones)
        "*.pdf",
        "*.doc",
        "*.docx",
        "*.xls",
        "*.xlsx",
        "*.ppt",
        "*.pptx",
        "*.png",
        "*.jpg",
        "*.jpeg",
        "*.gif",
        "*.svg",
        "*.ico",
        "frontend/public/*",
        "public/*",
        # Archives
        "*.zip",
        "*.tar",
        "*.tar.gz",
        "*.rar",
        "*.7z",
        # Docker ignore files
        ".dockerignore",
        "frontend/.dockerignore",
        # Prettier config (not essential for understanding code)
        ".prettierrc.json",
        "frontend/.prettierrc.json",
        # Documentation files (README, docs)
        "README.md",
        "*/README.md",
        "frontend/README.md",
        "docs/*",
        "docs/DEPLOYMENT.md",
        # Configuration files (not core logic)
        "components.json",
        "frontend/components.json",
        "eslint.config.mjs",
        "frontend/eslint.config.mjs",
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.json",
        ".eslintrc.yml",
        ".eslintrc.yaml",
        "postcss.config.mjs", 
        "frontend/postcss.config.mjs",
        "tailwind.config.js",
        "frontend/tailwind.config.js",
        "tsconfig.json",
        "frontend/tsconfig.json",
        "jsconfig.json",
        "babel.config.js",
        ".babelrc",
        ".babelrc.js",
        ".babelrc.json",
        "jest.config.js",
        "jest.config.json",
        "jest.setup.js",
        "vitest.config.js",
        "vitest.config.ts",
        "webpack.config.js",
        "rollup.config.js",
        "vite.config.js",
        "vite.config.ts",
        ".editorconfig",
        ".gitattributes",
        ".nvmrc",
        "Procfile",
        "LICENSE",
        "LICENSE.txt",
        "LICENSE.md",
        "CHANGELOG.md",
        "HISTORY.md",
        "CHANGES.md",
        "CONTRIBUTING.md",
        "CODE_OF_CONDUCT.md",
        # Next.js generated files
        "next-env.d.ts",
        "frontend/next-env.d.ts",
        # Empty or minimal directories
        "frontend/types",
        "frontend/types/*",
        "types",
        "types/*",
    ]

    if exclude_exts:
        # Format extensions as "*.ext" and add to exclusions
        exclusions.extend(f"*{ext}" for ext in exclude_exts)

    if exclusions:
        patterns = ",".join(exclusions)
        cmd += ["-e", patterns]

    print("Running:", " ".join(cmd))

    try:
        subprocess.run(cmd, check=True)
        print(f"✅ Digest written to {output_file}")
    except subprocess.CalledProcessError as e:
        print("❌ Error during gitingest execution:", e)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(
            "Usage: python make_ingest.py <path_or_url> [output_file] [excluded_exts...]"
        )
        sys.exit(1)

    source = sys.argv[1]

    # Determine if second argument is an output file or an extension
    output_file = "digest.txt"
    exclude_exts = []

    if len(sys.argv) >= 3 and sys.argv[2].startswith(".") is False:
        output_file = sys.argv[2]
        exclude_exts = sys.argv[3:]
    else:
        exclude_exts = sys.argv[2:]

    generate_digest_cli(source, output_file, exclude_exts)
