#!/bin/bash
set -e
# Use the unified app; both collections are available in its sidebar.
cd "$(dirname "$0")"
exec ./start_core.sh
