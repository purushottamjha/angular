#!/usr/bin/env bash

set -eux -o pipefail

function testBazel() {
  # Set up
  bazel version
  rm -rf demo
  # Create project
  ng new demo --collection=@angular/bazel --defaults --skip-git
  cd demo
  # Run build
  # TODO(kyliau): Use `bazel build` for now. Running `ng build` requires
  # node_modules to be available in project directory.
  bazel build //src:bundle
  # Run test
  ng test
  ng e2e
}

function testNonBazel() {
  # Replace angular.json that uses Bazel builder with the default generated by CLI
  cp ../angular.json.original ./angular.json
  # TODO(kyliau) Remove this once the additional assertion is added to CLI
  cp ../app.e2e-spec.ts ./e2e/src/
  # TODO(kyliau) Remove this once web_package rule is in use
  cp ../index.html ./src/
  rm -rf dist src/main.dev.ts src/main.prod.ts
  # Just make a symlink instead of full yarn install to expose node_modules
  ln -s $(bazel info output_base)/external/npm/node_modules node_modules
  ng build
  ng test --watch=false
  ng e2e
}

testBazel
testNonBazel