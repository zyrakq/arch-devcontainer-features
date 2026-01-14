#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test basic Rust installation
check "rustc version" rustc --version
check "cargo version" cargo --version
check "rustup version" rustup --version

# Test that additional targets are installed
check "wasm32-unknown-unknown target installed" rustup target list --installed | grep -q "wasm32-unknown-unknown"
check "x86_64-pc-windows-gnu target installed" rustup target list --installed | grep -q "x86_64-pc-windows-gnu"

# Test that we can build for WebAssembly target
check "create new cargo project" cargo new test_wasm_project --lib

# Add a simple lib.rs for WebAssembly (safe code)
cat > test_wasm_project/src/lib.rs << 'EOF'
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(2, 3), 5);
    }
}
EOF

# Test building for WebAssembly
check "build for wasm32-unknown-unknown" bash -c 'cd test_wasm_project && cargo build --target wasm32-unknown-unknown'

# Test building for Windows target (cross-compilation)
check "build for x86_64-pc-windows-gnu" bash -c 'cd test_wasm_project && cargo build --target x86_64-pc-windows-gnu'

# Clean up
rm -rf test_wasm_project

# Report result
reportResults