#!/bin/bash
# Install WordPress plugin from WordPress.org or GitHub
# Usage: 
#   ./scripts/install-wp-plugin.sh <plugin-slug>              # From WordPress.org
#   ./scripts/install-wp-plugin.sh <github-user/repo>         # From GitHub (latest release)
#   ./scripts/install-wp-plugin.sh <github-url> <release-tag> # From GitHub (specific tag)

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <plugin-slug> [release-tag]"
    echo ""
    echo "WordPress.org:"
    echo "  $0 advanced-custom-fields"
    echo ""
    echo "GitHub (latest release):"
    echo "  $0 axewp/wp-graphql-rank-math"
    echo ""
    echo "GitHub (specific tag):"
    echo "  $0 axewp/wp-graphql-rank-math v0.2.0"
    exit 1
fi

PLUGIN_SOURCE=$1
RELEASE_TAG=$2
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/wp/wp-content/plugins"
TEMP_DIR=$(mktemp -d)

# Determine if it's GitHub or WordPress.org
if [[ $PLUGIN_SOURCE == *"/"* ]]; then
    # GitHub format: user/repo
    echo "📦 Installing from GitHub: $PLUGIN_SOURCE"
    echo "📍 Target directory: $PLUGIN_DIR"
    
    # Get the repo name (last part of the path)
    PLUGIN_NAME=${PLUGIN_SOURCE##*/}
    
    if [ -z "$RELEASE_TAG" ]; then
        # Get latest release
        echo "⬇️  Downloading latest release..."
        DOWNLOAD_URL="https://github.com/$PLUGIN_SOURCE/archive/refs/heads/main.zip"
        EXTRACT_DIR="$PLUGIN_NAME-main"
    else
        # Get specific release tag
        echo "⬇️  Downloading release: $RELEASE_TAG..."
        DOWNLOAD_URL="https://github.com/$PLUGIN_SOURCE/archive/refs/tags/$RELEASE_TAG.zip"
        EXTRACT_DIR="$PLUGIN_NAME-${RELEASE_TAG#v}"
    fi
    
    if command -v curl &> /dev/null; then
        curl -L -o "$TEMP_DIR/plugin.zip" "$DOWNLOAD_URL"
    else
        wget -O "$TEMP_DIR/plugin.zip" "$DOWNLOAD_URL"
    fi
    
    echo "📂 Extracting..."
    unzip -q "$TEMP_DIR/plugin.zip" -d "$TEMP_DIR"
    mv "$TEMP_DIR/$EXTRACT_DIR" "$PLUGIN_DIR/$PLUGIN_NAME"
else
    # WordPress.org format: plugin-slug
    PLUGIN_SLUG=$PLUGIN_SOURCE
    echo "📦 Installing from WordPress.org: $PLUGIN_SLUG"
    echo "📍 Target directory: $PLUGIN_DIR"
    
    echo "⬇️  Downloading..."
    if command -v curl &> /dev/null; then
        curl -L -o "$TEMP_DIR/$PLUGIN_SLUG.zip" "https://downloads.wordpress.org/plugin/$PLUGIN_SLUG.zip"
    else
        wget -O "$TEMP_DIR/$PLUGIN_SLUG.zip" "https://downloads.wordpress.org/plugin/$PLUGIN_SLUG.zip"
    fi
    
    echo "📂 Extracting..."
    unzip -q "$TEMP_DIR/$PLUGIN_SLUG.zip" -d "$PLUGIN_DIR"
    PLUGIN_NAME=$PLUGIN_SLUG
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo "✅ Plugin installed: $PLUGIN_NAME"
echo "🔄 Next steps:"
echo "   1. git add wp/wp-content/plugins/$PLUGIN_NAME/"
echo "   2. git commit -m 'Add plugin: $PLUGIN_NAME'"
echo "   3. git push (Vercel will redeploy)"
