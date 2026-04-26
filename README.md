# LibsDisguises - Folia Fork

A patch-based fork of [LibsDisguises](https://github.com/libraryaddict/LibsDisguises) with Folia async support.

This repository only contains **patch files and scripts**. The source code is generated automatically by cloning the upstream and applying patches.

---

## Requirements

- Git
- JDK 21+
- Internet connection (first-time setup)

---

## Setup (First Time)

Clone this repository, then run the setup script:

**Windows**
```bat
git clone <this-repo-url>
cd LibsDisguises
setup.bat
```

**Linux / macOS**
```bash
git clone <this-repo-url>
cd LibsDisguises
chmod +x *.sh
./setup.sh
```

The script will:
1. Clone upstream LibsDisguises into `src/`
2. Check out the pinned upstream version
3. Apply all patches in order

Once complete, build the plugin:
```bash
cd src
./gradlew build        # Linux/macOS
gradlew.bat build      # Windows
```

The compiled JAR will be in `src/target/`.

---

## Updating Upstream

When the upstream LibsDisguises releases a new version, run:

**Windows**
```bat
update-upstream.bat
```

**Linux / macOS**
```bash
./update-upstream.sh
```

The script will:
1. Fetch the latest upstream commits
2. Rebase our patches onto the new upstream
3. Update `upstreamRef` in `gradle.properties`
4. Regenerate the patch files
5. Commit everything automatically

If there are **merge conflicts**, the script will pause and tell you what to do. After resolving:
```bash
git -C src add -A
git -C src rebase --continue
# Then re-run update-upstream
```

---

## Making Changes

1. Edit files inside `src/`
2. Commit your changes inside `src/`:
   ```bash
   cd src
   git add -A
   git commit -m "Describe your change"
   ```
3. Go back to the root and regenerate patches:
   ```bash
   cd ..
   make-patches.bat     # Windows
   ./make-patches.sh    # Linux/macOS
   ```
4. Commit the updated patches:
   ```bash
   git add patches/
   git commit -m "Update patches"
   ```

---

## File Structure

```
LibsDisguises/               ← This repository
├── gradle.properties        ← Upstream URL and pinned commit hash
├── patches/
│   └── 0001-*.patch         ← Our changes as git patch files
├── setup.sh / setup.bat     ← First-time setup
├── make-patches.sh / .bat   ← Regenerate patches from src/ commits
└── update-upstream.sh / .bat← Update to new upstream version

src/                         ← Generated (gitignored, do not commit)
└── ...                      ← Full LibsDisguises source with patches applied
```

---

## Changing the Upstream Version Manually

To pin a specific upstream commit instead of the latest, edit `gradle.properties`:

```properties
upstreamRef=<commit-hash>
```

Then run `setup.bat` / `./setup.sh` to rebuild `src/` from scratch.
